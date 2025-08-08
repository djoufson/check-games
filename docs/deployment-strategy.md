# Deployment and DevOps Strategy

## Overview
The Check-Game deployment strategy focuses on scalability, reliability, and security using containerized microservices with automated CI/CD pipelines.

## Infrastructure Architecture

### Production Environment
```
┌─────────────────────────────────────────────────────────┐
│                    Load Balancer (NGINX)                │
├─────────────────────────────────────────────────────────┤
│  Kubernetes Cluster                                     │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
│  │   API Pod   │  │   API Pod   │  │   API Pod   │     │
│  │ (Node.js)   │  │ (Node.js)   │  │ (Node.js)   │     │
│  └─────────────┘  └─────────────┘  └─────────────┘     │
│  ┌─────────────┐  ┌─────────────┐                      │
│  │ WebSocket   │  │ WebSocket   │                      │
│  │    Pod      │  │    Pod      │                      │
│  └─────────────┘  └─────────────┘                      │
│  ┌─────────────┐  ┌─────────────┐                      │
│  │   Redis     │  │ PostgreSQL  │                      │
│  │  Cluster    │  │  Cluster    │                      │
│  └─────────────┘  └─────────────┘                      │
└─────────────────────────────────────────────────────────┘
```

### Development Environment
```
Docker Compose Stack:
├── API Server (Node.js + TypeScript)
├── WebSocket Server (Socket.IO)
├── PostgreSQL Database
├── Redis Cache
├── NGINX Reverse Proxy
└── Monitoring Stack (Prometheus + Grafana)
```

## Containerization Strategy

### Backend Dockerfile
```dockerfile
# Multi-stage build for Node.js API
FROM node:18-alpine AS builder

WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

COPY . .
RUN npm run build

# Production stage
FROM node:18-alpine AS production

RUN apk add --no-cache dumb-init

WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package.json ./

USER node

EXPOSE 3000

ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "dist/main.js"]
```

### Frontend Build Process
```dockerfile
# Flutter Web Build
FROM cirrusci/flutter:stable AS flutter-builder

WORKDIR /app
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .
RUN flutter build web --release

# NGINX serving
FROM nginx:alpine AS production

COPY --from=flutter-builder /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80
```

### Docker Compose - Development
```yaml
version: '3.8'

services:
  api:
    build:
      context: ./backend
      dockerfile: Dockerfile.dev
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=development
      - DATABASE_URL=postgresql://checkgame:password@db:5432/checkgame_dev
      - REDIS_URL=redis://redis:6379
      - JWT_SECRET=${JWT_SECRET}
    depends_on:
      - db
      - redis
    volumes:
      - ./backend:/app
      - /app/node_modules

  websocket:
    build:
      context: ./websocket
      dockerfile: Dockerfile.dev
    ports:
      - "3001:3001"
    environment:
      - NODE_ENV=development
      - REDIS_URL=redis://redis:6379
    depends_on:
      - redis
    volumes:
      - ./websocket:/app
      - /app/node_modules

  db:
    image: postgres:15-alpine
    ports:
      - "5432:5432"
    environment:
      - POSTGRES_DB=checkgame_dev
      - POSTGRES_USER=checkgame
      - POSTGRES_PASSWORD=password
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./database/init.sql:/docker-entrypoint-initdb.d/init.sql

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    command: redis-server --appendonly yes
    volumes:
      - redis_data:/data

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf
      - ./nginx/ssl:/etc/nginx/ssl
    depends_on:
      - api
      - websocket

volumes:
  postgres_data:
  redis_data:
```

## Kubernetes Deployment

### API Deployment
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: checkgame-api
  labels:
    app: checkgame-api
spec:
  replicas: 3
  selector:
    matchLabels:
      app: checkgame-api
  template:
    metadata:
      labels:
        app: checkgame-api
    spec:
      containers:
      - name: api
        image: checkgame/api:latest
        ports:
        - containerPort: 3000
        env:
        - name: NODE_ENV
          value: "production"
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: checkgame-secrets
              key: database-url
        - name: JWT_SECRET
          valueFrom:
            secretKeyRef:
              name: checkgame-secrets
              key: jwt-secret
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5

---
apiVersion: v1
kind: Service
metadata:
  name: checkgame-api-service
spec:
  selector:
    app: checkgame-api
  ports:
  - port: 80
    targetPort: 3000
  type: ClusterIP
```

### WebSocket Deployment
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: checkgame-websocket
spec:
  replicas: 2
  selector:
    matchLabels:
      app: checkgame-websocket
  template:
    metadata:
      labels:
        app: checkgame-websocket
    spec:
      containers:
      - name: websocket
        image: checkgame/websocket:latest
        ports:
        - containerPort: 3001
        env:
        - name: REDIS_URL
          valueFrom:
            configMapKeyRef:
              name: checkgame-config
              key: redis-url
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"

---
apiVersion: v1
kind: Service
metadata:
  name: checkgame-websocket-service
spec:
  selector:
    app: checkgame-websocket
  ports:
  - port: 80
    targetPort: 3001
  sessionAffinity: ClientIP  # Important for WebSocket connections
```

### Ingress Configuration
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: checkgame-ingress
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/proxy-read-timeout: "3600"
    nginx.ingress.kubernetes.io/proxy-send-timeout: "3600"
    nginx.ingress.kubernetes.io/websocket-services: "checkgame-websocket-service"
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
spec:
  tls:
  - hosts:
    - api.checkgame.com
    - ws.checkgame.com
    secretName: checkgame-tls
  rules:
  - host: api.checkgame.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: checkgame-api-service
            port:
              number: 80
  - host: ws.checkgame.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: checkgame-websocket-service
            port:
              number: 80
```

## CI/CD Pipeline

### GitHub Actions Workflow
```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: checkgame

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    
    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '18'
        cache: 'npm'
    
    - name: Install dependencies
      run: npm ci
    
    - name: Run tests
      run: npm run test:coverage
    
    - name: Run linting
      run: npm run lint
    
    - name: Type checking
      run: npm run type-check

  build-and-push:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    strategy:
      matrix:
        service: [api, websocket, frontend]
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v3
    
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
        images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}/${{ matrix.service }}
        tags: |
          type=ref,event=branch
          type=ref,event=pr
          type=sha,prefix={{branch}}-
    
    - name: Build and push Docker image
      uses: docker/build-push-action@v5
      with:
        context: ./${{ matrix.service }}
        push: true
        tags: ${{ steps.meta.outputs.tags }}
        labels: ${{ steps.meta.outputs.labels }}
        cache-from: type=gha
        cache-to: type=gha,mode=max

  deploy:
    needs: build-and-push
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Setup Kubernetes CLI
      uses: azure/setup-kubectl@v3
    
    - name: Set up Kustomize
      run: |
        curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash
        sudo mv kustomize /usr/local/bin/
    
    - name: Deploy to Kubernetes
      env:
        KUBE_CONFIG: ${{ secrets.KUBE_CONFIG }}
      run: |
        echo "$KUBE_CONFIG" | base64 -d > kubeconfig
        export KUBECONFIG=kubeconfig
        
        cd k8s/overlays/production
        kustomize edit set image checkgame/api:${{ github.sha }}
        kustomize edit set image checkgame/websocket:${{ github.sha }}
        kustomize build . | kubectl apply -f -
        
        kubectl rollout status deployment/checkgame-api
        kubectl rollout status deployment/checkgame-websocket
```

### Flutter CI/CD
```yaml
name: Flutter CI/CD

on:
  push:
    branches: [main]
    paths: ['mobile/**']

jobs:
  build-mobile:
    runs-on: macos-latest
    steps:
    - uses: actions/checkout@v4
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.16.0'
    
    - name: Install dependencies
      run: flutter pub get
      working-directory: ./mobile
    
    - name: Run tests
      run: flutter test
      working-directory: ./mobile
    
    - name: Build APK
      run: flutter build apk --release
      working-directory: ./mobile
    
    - name: Build iOS
      run: flutter build ios --release --no-codesign
      working-directory: ./mobile
    
    - name: Build Web
      run: flutter build web --release
      working-directory: ./mobile
    
    - name: Deploy Web to CDN
      uses: peaceiris/actions-gh-pages@v3
      with:
        github_token: ${{ secrets.GITHUB_TOKEN }}
        publish_dir: ./mobile/build/web
```

## Database Management

### Migration Strategy
```typescript
// Prisma migration workflow
npm run prisma:generate      // Generate client
npm run prisma:migrate:dev   // Development migrations  
npm run prisma:migrate:prod  // Production migrations
npm run prisma:seed         // Seed database
```

### Backup Strategy
```bash
#!/bin/bash
# Database backup script

DB_NAME="checkgame_prod"
BACKUP_DIR="/backups/postgresql"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Create backup
pg_dump -h $DB_HOST -U $DB_USER -d $DB_NAME | gzip > "$BACKUP_DIR/backup_$TIMESTAMP.sql.gz"

# Upload to S3
aws s3 cp "$BACKUP_DIR/backup_$TIMESTAMP.sql.gz" s3://checkgame-backups/database/

# Cleanup old local backups (keep 7 days)
find $BACKUP_DIR -name "backup_*.sql.gz" -mtime +7 -delete

# Cleanup old S3 backups (keep 30 days)
aws s3 ls s3://checkgame-backups/database/ | grep backup_ | \
    awk '{print $4}' | head -n -30 | \
    xargs -I {} aws s3 rm s3://checkgame-backups/database/{}
```

## Monitoring and Observability

### Prometheus Configuration
```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'checkgame-api'
    static_configs:
      - targets: ['checkgame-api-service:80']
    metrics_path: '/metrics'
    
  - job_name: 'checkgame-websocket'
    static_configs:
      - targets: ['checkgame-websocket-service:80']
    metrics_path: '/metrics'
    
  - job_name: 'postgresql'
    static_configs:
      - targets: ['postgres-exporter:9187']
    
  - job_name: 'redis'
    static_configs:
      - targets: ['redis-exporter:9121']
```

### Application Metrics
```typescript
// Express middleware for metrics
import prometheus from 'prom-client';

const httpRequestDuration = new prometheus.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.1, 0.3, 0.5, 0.7, 1, 3, 5, 7, 10]
});

const activeGames = new prometheus.Gauge({
  name: 'active_games_total',
  help: 'Number of currently active games'
});

const websocketConnections = new prometheus.Gauge({
  name: 'websocket_connections_total',
  help: 'Number of active WebSocket connections'
});

// Metrics endpoint
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', prometheus.register.contentType);
  res.end(await prometheus.register.metrics());
});
```

### Health Checks
```typescript
// Health check endpoints
app.get('/health', async (req, res) => {
  const checks = {
    database: await checkDatabaseConnection(),
    redis: await checkRedisConnection(),
    memory: checkMemoryUsage(),
    uptime: process.uptime()
  };
  
  const healthy = Object.values(checks).every(check => check.status === 'ok');
  
  res.status(healthy ? 200 : 503).json({
    status: healthy ? 'healthy' : 'unhealthy',
    checks,
    timestamp: new Date().toISOString()
  });
});

app.get('/ready', async (req, res) => {
  // Readiness check - can serve traffic
  const ready = await checkDatabaseMigrations() && 
                await checkRedisConnection();
                
  res.status(ready ? 200 : 503).json({
    status: ready ? 'ready' : 'not-ready',
    timestamp: new Date().toISOString()
  });
});
```

## Security Configuration

### Network Policies
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: checkgame-network-policy
spec:
  podSelector:
    matchLabels:
      app: checkgame-api
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: ingress-nginx
    ports:
    - protocol: TCP
      port: 3000
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: postgresql
    ports:
    - protocol: TCP
      port: 5432
  - to:
    - podSelector:
        matchLabels:
          app: redis
    ports:
    - protocol: TCP
      port: 6379
```

### Secret Management
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: checkgame-secrets
type: Opaque
data:
  database-url: <base64-encoded-value>
  jwt-secret: <base64-encoded-value>
  redis-password: <base64-encoded-value>
```

## Scaling Strategy

### Horizontal Pod Autoscaler
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: checkgame-api-hpa
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
```

### Database Scaling
- **Read Replicas**: For read-heavy operations
- **Connection Pooling**: PgBouncer for connection management
- **Vertical Scaling**: Increase CPU/Memory as needed
- **Sharding**: Database sharding for very high scale (future)

## Disaster Recovery

### Backup Schedule
- **Database**: Daily full backup, hourly incremental
- **File Storage**: Continuous replication to secondary region
- **Configuration**: Version controlled in Git
- **Secrets**: Encrypted backup in secure vault

### Recovery Procedures
1. **Database Recovery**: Point-in-time recovery from backups
2. **Application Recovery**: Redeploy from container registry
3. **DNS Failover**: Automatic failover to backup region
4. **Data Validation**: Integrity checks after recovery

### RTO/RPO Targets
- **Recovery Time Objective (RTO)**: < 1 hour
- **Recovery Point Objective (RPO)**: < 15 minutes
- **Availability Target**: 99.9% uptime
- **Error Budget**: 8.76 hours/year downtime