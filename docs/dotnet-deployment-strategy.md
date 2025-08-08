# .NET 8 Deployment Strategy

## Overview
High-performance deployment strategy for .NET 8 API with AOT compilation, optimized Docker containers, and Kubernetes orchestration with comprehensive observability.

## Container Strategy

### Multi-stage .NET 8 Dockerfile
```dockerfile
# Build stage with full SDK
FROM mcr.microsoft.com/dotnet/sdk:8.0-alpine AS build
WORKDIR /src

# Copy project files
COPY ["CheckGame.Api/CheckGame.Api.csproj", "CheckGame.Api/"]
COPY ["CheckGame.Core/CheckGame.Core.csproj", "CheckGame.Core/"]
COPY ["CheckGame.Infrastructure/CheckGame.Infrastructure.csproj", "CheckGame.Infrastructure/"]

# Restore dependencies
RUN dotnet restore "CheckGame.Api/CheckGame.Api.csproj"

# Copy source code
COPY . .

# Build and publish with AOT
WORKDIR "/src/CheckGame.Api"
RUN dotnet publish "CheckGame.Api.csproj" \
    -c Release \
    -o /app/publish \
    --self-contained true \
    --runtime linux-x64 \
    /p:PublishAot=true \
    /p:PublishSingleFile=true \
    /p:PublishTrimmed=true \
    /p:TrimMode=link

# Runtime stage - minimal Alpine
FROM mcr.microsoft.com/dotnet/runtime-deps:8.0-alpine AS runtime

# Install required packages for AOT
RUN apk add --no-cache \
    icu-libs \
    ca-certificates \
    tzdata

# Create non-root user
RUN addgroup -g 1001 checkgame && \
    adduser -D -s /bin/sh -u 1001 -G checkgame checkgame

WORKDIR /app

# Copy published application
COPY --from=build /app/publish/CheckGame.Api ./checkgame-api
COPY --from=build /app/publish/appsettings.Production.json ./

# Set ownership
RUN chown -R checkgame:checkgame /app

USER checkgame

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8080/health || exit 1

EXPOSE 8080
EXPOSE 8081

ENTRYPOINT ["./checkgame-api"]
```

### Docker Compose - Development
```yaml
version: '3.8'

services:
  checkgame-api:
    build:
      context: .
      dockerfile: CheckGame.Api/Dockerfile.dev
    ports:
      - "7001:8080"
      - "7002:8081" # Health check port
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
      - ASPNETCORE_URLS=http://+:8080;http://+:8081
      - ConnectionStrings__DefaultConnection=Host=postgres;Database=checkgame_dev;Username=checkgame;Password=dev_password
      - ConnectionStrings__Redis=redis:6379
      - Logging__LogLevel__Default=Information
      - OpenTelemetry__Endpoint=http://jaeger:14268/api/traces
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    volumes:
      - ./CheckGame.Api:/app
    networks:
      - checkgame-network

  postgres:
    image: postgres:15-alpine
    ports:
      - "5432:5432"
    environment:
      - POSTGRES_DB=checkgame_dev
      - POSTGRES_USER=checkgame
      - POSTGRES_PASSWORD=dev_password
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./database/init.sql:/docker-entrypoint-initdb.d/init.sql
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U checkgame -d checkgame_dev"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - checkgame-network

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    command: redis-server --appendonly yes --maxmemory 256mb --maxmemory-policy allkeys-lru
    volumes:
      - redis_data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 5s
      timeout: 3s
      retries: 5
    networks:
      - checkgame-network

  prometheus:
    image: prom/prometheus:v2.45.0
    ports:
      - "9090:9090"
    volumes:
      - ./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
      - '--storage.tsdb.retention.time=7d'
      - '--web.enable-lifecycle'
    networks:
      - checkgame-network

  grafana:
    image: grafana/grafana:10.0.0
    ports:
      - "3001:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin123
      - GF_INSTALL_PLUGINS=redis-datasource
    volumes:
      - grafana_data:/var/lib/grafana
      - ./monitoring/grafana/dashboards:/etc/grafana/provisioning/dashboards
      - ./monitoring/grafana/datasources:/etc/grafana/provisioning/datasources
    depends_on:
      - prometheus
    networks:
      - checkgame-network

  jaeger:
    image: jaegertracing/all-in-one:1.48
    ports:
      - "16686:16686"
      - "14268:14268"
      - "14250:14250"
    environment:
      - COLLECTOR_OTLP_ENABLED=true
    networks:
      - checkgame-network

  otel-collector:
    image: otel/opentelemetry-collector-contrib:0.82.0
    command: ["--config=/etc/otel-collector-config.yml"]
    volumes:
      - ./monitoring/otel-collector-config.yml:/etc/otel-collector-config.yml
    ports:
      - "4317:4317" # OTLP gRPC
      - "4318:4318" # OTLP HTTP
      - "8888:8888" # Prometheus metrics
    depends_on:
      - jaeger
      - prometheus
    networks:
      - checkgame-network

volumes:
  postgres_data:
  redis_data:
  prometheus_data:
  grafana_data:

networks:
  checkgame-network:
    driver: bridge
```

## Kubernetes Deployment

### Namespace and RBAC
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: checkgame
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: checkgame-api
  namespace: checkgame
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: checkgame
  name: checkgame-role
rules:
- apiGroups: [""]
  resources: ["pods", "services", "endpoints"]
  verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: checkgame-rolebinding
  namespace: checkgame
subjects:
- kind: ServiceAccount
  name: checkgame-api
  namespace: checkgame
roleRef:
  kind: Role
  name: checkgame-role
  apiGroup: rbac.authorization.k8s.io
```

### ConfigMap and Secrets
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: checkgame-config
  namespace: checkgame
data:
  appsettings.Production.json: |
    {
      "Logging": {
        "LogLevel": {
          "Default": "Information",
          "Microsoft.AspNetCore": "Warning",
          "Microsoft.EntityFrameworkCore": "Warning"
        }
      },
      "AllowedHosts": "*",
      "Kestrel": {
        "Endpoints": {
          "Http": {
            "Url": "http://0.0.0.0:8080"
          },
          "Health": {
            "Url": "http://0.0.0.0:8081"
          }
        }
      },
      "OpenTelemetry": {
        "Endpoint": "http://otel-collector:4317"
      },
      "SignalR": {
        "Redis": {
          "ConnectionString": "redis:6379",
          "ChannelPrefix": "CheckGame"
        }
      }
    }
---
apiVersion: v1
kind: Secret
metadata:
  name: checkgame-secrets
  namespace: checkgame
type: Opaque
data:
  database-connection: <base64-encoded-connection-string>
  jwt-secret-key: <base64-encoded-jwt-secret>
  redis-connection: <base64-encoded-redis-connection>
```

### API Deployment
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: checkgame-api
  namespace: checkgame
  labels:
    app: checkgame-api
    version: v1
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1
  selector:
    matchLabels:
      app: checkgame-api
  template:
    metadata:
      labels:
        app: checkgame-api
        version: v1
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "8080"
        prometheus.io/path: "/metrics"
    spec:
      serviceAccountName: checkgame-api
      securityContext:
        runAsNonRoot: true
        runAsUser: 1001
        fsGroup: 1001
      containers:
      - name: api
        image: checkgame/api:latest
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 8080
          name: http
          protocol: TCP
        - containerPort: 8081
          name: health
          protocol: TCP
        env:
        - name: ASPNETCORE_ENVIRONMENT
          value: "Production"
        - name: ASPNETCORE_URLS
          value: "http://+:8080;http://+:8081"
        - name: ConnectionStrings__DefaultConnection
          valueFrom:
            secretKeyRef:
              name: checkgame-secrets
              key: database-connection
        - name: ConnectionStrings__Redis
          valueFrom:
            secretKeyRef:
              name: checkgame-secrets
              key: redis-connection
        - name: JwtSettings__SecretKey
          valueFrom:
            secretKeyRef:
              name: checkgame-secrets
              key: jwt-secret-key
        - name: OTEL_EXPORTER_OTLP_ENDPOINT
          value: "http://otel-collector:4317"
        - name: OTEL_SERVICE_NAME
          value: "checkgame-api"
        - name: OTEL_RESOURCE_ATTRIBUTES
          value: "service.version=1.0.0,deployment.environment=production"
        volumeMounts:
        - name: config
          mountPath: /app/appsettings.Production.json
          subPath: appsettings.Production.json
          readOnly: true
        - name: tmp
          mountPath: /tmp
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 500m
            memory: 256Mi
        livenessProbe:
          httpGet:
            path: /health
            port: 8081
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3
        readinessProbe:
          httpGet:
            path: /health/ready
            port: 8081
          initialDelaySeconds: 5
          periodSeconds: 5
          timeoutSeconds: 3
          failureThreshold: 2
        startupProbe:
          httpGet:
            path: /health/startup
            port: 8081
          initialDelaySeconds: 10
          periodSeconds: 2
          timeoutSeconds: 1
          failureThreshold: 30
      volumes:
      - name: config
        configMap:
          name: checkgame-config
      - name: tmp
        emptyDir: {}
      nodeSelector:
        kubernetes.io/os: linux
      tolerations:
      - key: "node.kubernetes.io/not-ready"
        operator: "Exists"
        effect: "NoExecute"
        tolerationSeconds: 300
      - key: "node.kubernetes.io/unreachable"
        operator: "Exists"
        effect: "NoExecute"
        tolerationSeconds: 300
---
apiVersion: v1
kind: Service
metadata:
  name: checkgame-api-service
  namespace: checkgame
  labels:
    app: checkgame-api
spec:
  type: ClusterIP
  sessionAffinity: ClientIP # Important for SignalR connections
  sessionAffinityConfig:
    clientIP:
      timeoutSeconds: 300
  ports:
  - port: 80
    targetPort: 8080
    protocol: TCP
    name: http
  - port: 81
    targetPort: 8081
    protocol: TCP
    name: health
  selector:
    app: checkgame-api
```

### Horizontal Pod Autoscaler
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: checkgame-api-hpa
  namespace: checkgame
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: checkgame-api
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
  - type: Pods
    pods:
      metric:
        name: active_signalr_connections
      target:
        type: AverageValue
        averageValue: "100"
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Percent
        value: 10
        periodSeconds: 60
    scaleUp:
      stabilizationWindowSeconds: 60
      policies:
      - type: Percent
        value: 50
        periodSeconds: 15
      - type: Pods
        value: 2
        periodSeconds: 60
```

### Ingress Configuration
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: checkgame-ingress
  namespace: checkgame
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/use-regex: "true"
    nginx.ingress.kubernetes.io/rewrite-target: /$2
    nginx.ingress.kubernetes.io/proxy-read-timeout: "3600"
    nginx.ingress.kubernetes.io/proxy-send-timeout: "3600"
    nginx.ingress.kubernetes.io/proxy-connect-timeout: "60"
    nginx.ingress.kubernetes.io/upstream-hash-by: "$binary_remote_addr"
    nginx.ingress.kubernetes.io/configuration-snippet: |
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection $connection_upgrade;
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
    nginx.ingress.kubernetes.io/rate-limit: "1000"
    nginx.ingress.kubernetes.io/rate-limit-window: "1m"
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - api.checkgame.com
    secretName: checkgame-api-tls
  rules:
  - host: api.checkgame.com
    http:
      paths:
      - path: /api(/|$)(.*)
        pathType: Prefix
        backend:
          service:
            name: checkgame-api-service
            port:
              number: 80
      - path: /gameHub
        pathType: Prefix
        backend:
          service:
            name: checkgame-api-service
            port:
              number: 80
```

## Database Deployment

### PostgreSQL Deployment
```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
  namespace: checkgame
spec:
  serviceName: postgres
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:15-alpine
        env:
        - name: POSTGRES_DB
          value: "checkgame_prod"
        - name: POSTGRES_USER
          value: "checkgame"
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: postgres-secret
              key: password
        - name: PGDATA
          value: "/var/lib/postgresql/data/pgdata"
        ports:
        - containerPort: 5432
          name: postgres
        volumeMounts:
        - name: postgres-storage
          mountPath: /var/lib/postgresql/data
        - name: postgres-config
          mountPath: /etc/postgresql/postgresql.conf
          subPath: postgresql.conf
        resources:
          requests:
            cpu: 250m
            memory: 512Mi
          limits:
            cpu: 500m
            memory: 1Gi
        livenessProbe:
          exec:
            command:
            - pg_isready
            - -U
            - checkgame
            - -d
            - checkgame_prod
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          exec:
            command:
            - pg_isready
            - -U
            - checkgame
            - -d
            - checkgame_prod
          initialDelaySeconds: 5
          periodSeconds: 5
      volumes:
      - name: postgres-config
        configMap:
          name: postgres-config
  volumeClaimTemplates:
  - metadata:
      name: postgres-storage
    spec:
      accessModes: ["ReadWriteOnce"]
      storageClassName: "fast-ssd"
      resources:
        requests:
          storage: 20Gi
---
apiVersion: v1
kind: Service
metadata:
  name: postgres
  namespace: checkgame
spec:
  ports:
  - port: 5432
    name: postgres
  clusterIP: None
  selector:
    app: postgres
```

### Redis Deployment
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis
  namespace: checkgame
spec:
  replicas: 1
  selector:
    matchLabels:
      app: redis
  template:
    metadata:
      labels:
        app: redis
    spec:
      containers:
      - name: redis
        image: redis:7-alpine
        command:
        - redis-server
        - /etc/redis/redis.conf
        ports:
        - containerPort: 6379
          name: redis
        volumeMounts:
        - name: redis-config
          mountPath: /etc/redis
        - name: redis-data
          mountPath: /data
        resources:
          requests:
            cpu: 100m
            memory: 256Mi
          limits:
            cpu: 250m
            memory: 512Mi
        livenessProbe:
          exec:
            command:
            - redis-cli
            - ping
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          exec:
            command:
            - redis-cli
            - ping
          initialDelaySeconds: 5
          periodSeconds: 5
      volumes:
      - name: redis-config
        configMap:
          name: redis-config
      - name: redis-data
        persistentVolumeClaim:
          claimName: redis-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: redis
  namespace: checkgame
spec:
  ports:
  - port: 6379
    name: redis
  selector:
    app: redis
```

## CI/CD Pipeline

### GitHub Actions - Build and Deploy
```yaml
name: Build and Deploy

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: checkgame/api

jobs:
  test:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: postgres
          POSTGRES_DB: checkgame_test
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432
      
      redis:
        image: redis:7-alpine
        options: >-
          --health-cmd "redis-cli ping"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 6379:6379

    steps:
    - uses: actions/checkout@v4

    - name: Setup .NET
      uses: actions/setup-dotnet@v4
      with:
        dotnet-version: '8.0.x'

    - name: Cache NuGet packages
      uses: actions/cache@v3
      with:
        path: ~/.nuget/packages
        key: ${{ runner.os }}-nuget-${{ hashFiles('**/*.csproj') }}
        restore-keys: |
          ${{ runner.os }}-nuget-

    - name: Restore dependencies
      run: dotnet restore

    - name: Build
      run: dotnet build --no-restore --configuration Release

    - name: Test
      run: dotnet test --no-build --configuration Release --logger "trx;LogFileName=test-results.trx" --collect:"XPlat Code Coverage"
      env:
        ConnectionStrings__DefaultConnection: Host=localhost;Database=checkgame_test;Username=postgres;Password=postgres
        ConnectionStrings__Redis: localhost:6379

    - name: Publish Test Results
      uses: dorny/test-reporter@v1
      if: success() || failure()
      with:
        name: .NET Tests
        path: '**/test-results.trx'
        reporter: dotnet-trx

    - name: Code Coverage Report
      uses: codecov/codecov-action@v3
      with:
        files: '**/coverage.cobertura.xml'
        fail_ci_if_error: true

  build-and-push:
    needs: test
    runs-on: ubuntu-latest
    if: github.event_name != 'pull_request'
    
    steps:
    - name: Checkout
      uses: actions/checkout@v4

    - name: Log in to Container Registry
      uses: docker/login-action@v3
      with:
        registry: ${{ env.REGISTRY }}
        username: ${{ github.actor }}
        password: ${{ secrets.GITHUB_TOKEN }}

    - name: Extract metadata
      id: meta
      uses: docker/metadata-action@v5
      with:
        images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
        tags: |
          type=ref,event=branch
          type=sha,prefix={{branch}}-

    - name: Build and push Docker image
      uses: docker/build-push-action@v5
      with:
        context: .
        push: true
        tags: ${{ steps.meta.outputs.tags }}
        labels: ${{ steps.meta.outputs.labels }}
        cache-from: type=gha
        cache-to: type=gha,mode=max
        build-args: |
          BUILDKIT_INLINE_CACHE=1

  deploy:
    needs: build-and-push
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
    - name: Checkout
      uses: actions/checkout@v4

    - name: Setup Kubectl
      uses: azure/setup-kubectl@v3
      with:
        version: '1.28.0'

    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v4
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: us-east-1

    - name: Update kubeconfig
      run: |
        aws eks update-kubeconfig --region us-east-1 --name checkgame-cluster

    - name: Deploy to Kubernetes
      run: |
        # Update image tag in deployment
        sed -i "s|checkgame/api:latest|${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }}|g" k8s/api-deployment.yaml
        
        # Apply all configurations
        kubectl apply -f k8s/namespace.yaml
        kubectl apply -f k8s/secrets.yaml
        kubectl apply -f k8s/configmap.yaml
        kubectl apply -f k8s/api-deployment.yaml
        kubectl apply -f k8s/service.yaml
        kubectl apply -f k8s/hpa.yaml
        kubectl apply -f k8s/ingress.yaml
        
        # Wait for deployment to complete
        kubectl rollout status deployment/checkgame-api -n checkgame --timeout=300s
        
        # Verify deployment
        kubectl get pods -n checkgame -l app=checkgame-api

    - name: Run Health Check
      run: |
        # Wait for ingress to be ready
        sleep 30
        
        # Health check
        curl -f https://api.checkgame.com/health || exit 1
```

## Performance Tuning

### .NET 8 AOT Configuration
```xml
<Project Sdk="Microsoft.NET.Sdk.Web">
  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
    <PublishAot>true</PublishAot>
    <PublishTrimmed>true</PublishTrimmed>
    <TrimMode>link</TrimMode>
    <PublishSingleFile>true</PublishSingleFile>
    <SelfContained>true</SelfContained>
    <RuntimeIdentifier>linux-x64</RuntimeIdentifier>
    <EnableRequestDelegateGenerator>true</EnableRequestDelegateGenerator>
    <EnableConfigurationBindingGenerator>true</EnableConfigurationBindingGenerator>
    <JsonSerializerIsReflectionEnabledByDefault>false</JsonSerializerIsReflectionEnabledByDefault>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="Microsoft.AspNetCore.OpenApi" Version="8.0.0" />
    <PackageReference Include="Swashbuckle.AspNetCore" Version="6.5.0" />
    <PackageReference Include="Microsoft.EntityFrameworkCore.Design" Version="8.0.0" />
    <PackageReference Include="Npgsql.EntityFrameworkCore.PostgreSQL" Version="8.0.0" />
    <PackageReference Include="StackExchange.Redis" Version="2.6.122" />
    <PackageReference Include="Microsoft.AspNetCore.SignalR.StackExchangeRedis" Version="8.0.0" />
    <PackageReference Include="OpenTelemetry.Extensions.Hosting" Version="1.6.0" />
    <PackageReference Include="OpenTelemetry.Exporter.OpenTelemetryProtocol" Version="1.6.0" />
  </ItemGroup>
</Project>
```

### Runtime Optimization
```csharp
// Program.cs optimizations for performance
var builder = WebApplication.CreateSlimBuilder(args);

// AOT-compatible JSON serialization
builder.Services.ConfigureHttpJsonOptions(options =>
{
    options.SerializerOptions.TypeInfoResolverChain.Insert(0, CheckGameSerializerContext.Default);
});

// Minimal API endpoint filters for performance
builder.Services.AddEndpointFilters();

// Connection pooling
builder.Services.AddDbContextPool<CheckGameDbContext>(options =>
    options.UseNpgsql(connectionString), poolSize: 128);

// Redis with connection multiplexer
builder.Services.AddSingleton<IConnectionMultiplexer>(provider =>
{
    var configuration = ConfigurationOptions.Parse(redisConnectionString);
    configuration.AbortOnConnectFail = false;
    configuration.ConnectRetry = 3;
    configuration.ConnectTimeout = 5000;
    return ConnectionMultiplexer.Connect(configuration);
});

var app = builder.Build();

// Minimal middleware pipeline for performance
if (app.Environment.IsProduction())
{
    app.UseExceptionHandler();
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseAuthentication();
app.UseAuthorization();
app.UseRateLimiter();

// Map endpoints with generated delegates
app.MapCheckGameEndpoints();
app.MapHub<GameHub>("/gameHub");

app.Run();

// AOT-compatible JSON context
[JsonSerializable(typeof(GameStateDto))]
[JsonSerializable(typeof(SessionDto))]
[JsonSerializable(typeof(UserDto))]
internal partial class CheckGameSerializerContext : JsonSerializerContext { }
```

This deployment strategy provides maximum performance with AOT compilation, efficient container images, proper Kubernetes orchestration, and comprehensive observability integration.