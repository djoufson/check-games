# OpenTelemetry, Grafana, and Prometheus Configuration

## Overview
Comprehensive observability stack for Check-Game .NET 8 API with OpenTelemetry for distributed tracing and metrics, Prometheus for metrics collection, and Grafana for visualization and alerting.

## OpenTelemetry Configuration

### .NET 8 OpenTelemetry Setup
```csharp
// Program.cs
using OpenTelemetry;
using OpenTelemetry.Exporter;
using OpenTelemetry.Metrics;
using OpenTelemetry.Resources;
using OpenTelemetry.Trace;

var builder = WebApplication.CreateSlimBuilder(args);

// Add OpenTelemetry
builder.Services.AddOpenTelemetry()
    .ConfigureResource(resource => resource
        .AddService("checkgame-api", "1.0.0")
        .AddAttributes(new Dictionary<string, object>
        {
            ["deployment.environment"] = builder.Environment.EnvironmentName.ToLowerInvariant(),
            ["service.instance.id"] = Environment.MachineName,
            ["service.version"] = typeof(Program).Assembly.GetName().Version?.ToString() ?? "unknown"
        }))
    .WithTracing(tracing => tracing
        .AddAspNetCoreInstrumentation(options =>
        {
            options.RecordException = true;
            options.EnrichWithHttpRequest = (activity, request) =>
            {
                activity.SetTag("http.request.body.size", request.ContentLength);
                activity.SetTag("user.id", request.HttpContext.User.FindFirst(ClaimTypes.NameIdentifier)?.Value);
            };
            options.EnrichWithHttpResponse = (activity, response) =>
            {
                activity.SetTag("http.response.body.size", response.ContentLength);
            };
        })
        .AddEntityFrameworkCoreInstrumentation(options =>
        {
            options.SetDbStatementForText = true;
            options.SetDbStatementForStoredProcedure = true;
            options.EnrichWithIDbCommand = (activity, command) =>
            {
                activity.SetTag("db.query.complexity", AnalyzeQueryComplexity(command.CommandText));
            };
        })
        .AddRedisInstrumentation()
        .AddHttpClientInstrumentation()
        .AddSource(CheckGameActivitySource.Name)
        .SetSampler(new TraceIdRatioBasedSampler(0.1)) // Sample 10% of traces in production
        .AddOtlpExporter(options =>
        {
            options.Endpoint = new Uri(builder.Configuration.GetValue<string>("OpenTelemetry:Endpoint")!);
            options.Protocol = OtlpExportProtocol.Grpc;
            options.ExportProcessorType = ExportProcessorType.Batch;
            options.BatchExportProcessorOptions = new BatchExportProcessorOptions<Activity>
            {
                MaxQueueSize = 2048,
                ScheduledDelayMilliseconds = 5000,
                ExporterTimeoutMilliseconds = 30000,
                MaxExportBatchSize = 512
            };
        }))
    .WithMetrics(metrics => metrics
        .AddAspNetCoreInstrumentation()
        .AddRuntimeInstrumentation()
        .AddProcessInstrumentation()
        .AddHttpClientInstrumentation()
        .AddEventCountersInstrumentation(options =>
        {
            options.AddEventSources(
                "Microsoft.AspNetCore.Hosting",
                "Microsoft.AspNetCore.Server.Kestrel",
                "System.Net.Http",
                "System.Net.Security",
                "Microsoft.EntityFrameworkCore"
            );
        })
        .AddMeter(CheckGameMetrics.MeterName)
        .AddPrometheusExporter(options =>
        {
            options.HttpListenerPrefixes = new[] { "http://+:9090/" };
        })
        .AddOtlpExporter(options =>
        {
            options.Endpoint = new Uri(builder.Configuration.GetValue<string>("OpenTelemetry:Endpoint")!);
            options.Protocol = OtlpExportProtocol.Grpc;
        }));

var app = builder.Build();

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.UseDeveloperExceptionPage();
}

// Add OpenTelemetry metrics endpoint
app.UseOpenTelemetryPrometheusScrapingEndpoint();

// Add custom middleware for request tracing
app.UseMiddleware<RequestTracingMiddleware>();

app.Run();
```

### Custom Activity Source
```csharp
public static class CheckGameActivitySource
{
    public const string Name = "CheckGame.Api";
    public const string Version = "1.0.0";
    
    public static readonly ActivitySource Source = new(Name, Version);
}

public static class CheckGameMetrics
{
    public const string MeterName = "CheckGame.Api";
    
    private static readonly Meter Meter = new(MeterName, "1.0.0");
    
    // Counters
    public static readonly Counter<long> GameActionsTotal = 
        Meter.CreateCounter<long>("checkgame_game_actions_total", "Total number of game actions processed");
    
    public static readonly Counter<long> SignalRConnectionsTotal = 
        Meter.CreateCounter<long>("checkgame_signalr_connections_total", "Total SignalR connections");
    
    public static readonly Counter<long> DatabaseQueriesTotal = 
        Meter.CreateCounter<long>("checkgame_database_queries_total", "Total database queries executed");
    
    // Histograms
    public static readonly Histogram<double> GameActionDuration = 
        Meter.CreateHistogram<double>("checkgame_game_action_duration_seconds", "Duration of game actions in seconds");
    
    public static readonly Histogram<double> ApiRequestDuration = 
        Meter.CreateHistogram<double>("checkgame_api_request_duration_seconds", "Duration of API requests in seconds");
    
    public static readonly Histogram<double> DatabaseQueryDuration = 
        Meter.CreateHistogram<double>("checkgame_database_query_duration_seconds", "Duration of database queries in seconds");
    
    // Gauges
    public static readonly ObservableGauge<int> ActiveGames = 
        Meter.CreateObservableGauge<int>("checkgame_active_games", "Number of currently active games");
    
    public static readonly ObservableGauge<int> ActiveSignalRConnections = 
        Meter.CreateObservableGauge<int>("checkgame_active_signalr_connections", "Number of active SignalR connections");
    
    public static readonly ObservableGauge<long> MemoryUsage = 
        Meter.CreateObservableGauge<long>("checkgame_memory_usage_bytes", "Current memory usage in bytes");
    
    // Helper methods for recording metrics
    public static void RecordGameAction(string actionType, double duration, bool success = true)
    {
        GameActionsTotal.Add(1, 
            new KeyValuePair<string, object?>("action", actionType),
            new KeyValuePair<string, object?>("success", success.ToString()));
        
        GameActionDuration.Record(duration,
            new KeyValuePair<string, object?>("action", actionType));
    }
    
    public static void RecordSignalRConnection(string eventType)
    {
        SignalRConnectionsTotal.Add(1,
            new KeyValuePair<string, object?>("event", eventType));
    }
    
    public static void RecordDatabaseQuery(string operation, double duration, bool success = true)
    {
        DatabaseQueriesTotal.Add(1,
            new KeyValuePair<string, object?>("operation", operation),
            new KeyValuePair<string, object?>("success", success.ToString()));
        
        DatabaseQueryDuration.Record(duration,
            new KeyValuePair<string, object?>("operation", operation));
    }
}
```

### Request Tracing Middleware
```csharp
public class RequestTracingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<RequestTracingMiddleware> _logger;

    public RequestTracingMiddleware(RequestDelegate next, ILogger<RequestTracingMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        using var activity = CheckGameActivitySource.Source.StartActivity("http.request");
        
        var stopwatch = Stopwatch.StartNew();
        
        try
        {
            // Add request tags
            activity?.SetTag("http.method", context.Request.Method);
            activity?.SetTag("http.url", context.Request.GetDisplayUrl());
            activity?.SetTag("user.id", context.User.FindFirst(ClaimTypes.NameIdentifier)?.Value);
            activity?.SetTag("user.agent", context.Request.Headers.UserAgent.ToString());
            
            await _next(context);
            
            // Add response tags
            activity?.SetTag("http.status_code", context.Response.StatusCode);
            activity?.SetTag("http.status_text", context.Response.StatusCode.ToString());
            
            // Record metrics
            CheckGameMetrics.ApiRequestDuration.Record(stopwatch.Elapsed.TotalSeconds,
                new KeyValuePair<string, object?>("method", context.Request.Method),
                new KeyValuePair<string, object?>("status", context.Response.StatusCode.ToString()),
                new KeyValuePair<string, object?>("endpoint", GetEndpointName(context)));
        }
        catch (Exception ex)
        {
            activity?.SetStatus(ActivityStatusCode.Error, ex.Message);
            activity?.SetTag("exception.type", ex.GetType().Name);
            activity?.SetTag("exception.message", ex.Message);
            
            _logger.LogError(ex, "Request failed for {Method} {Path}", 
                context.Request.Method, context.Request.Path);
            
            throw;
        }
        finally
        {
            stopwatch.Stop();
            activity?.SetTag("request.duration_ms", stopwatch.ElapsedMilliseconds);
        }
    }
    
    private static string GetEndpointName(HttpContext context)
    {
        return context.GetEndpoint()?.DisplayName ?? "unknown";
    }
}
```

### Game Service with Tracing
```csharp
public class GameStateService : IGameStateService
{
    private readonly IDatabase _database;
    private readonly IGameEngine _gameEngine;
    private readonly ILogger<GameStateService> _logger;

    public async Task<GameActionResult> PlayCardAsync(Guid sessionId, Guid playerId, Card card, CardSuit? chosenSuit)
    {
        using var activity = CheckGameActivitySource.Source.StartActivity("game.play_card");
        activity?.SetTag("session.id", sessionId.ToString());
        activity?.SetTag("player.id", playerId.ToString());
        activity?.SetTag("card.suit", card.Suit.ToString());
        activity?.SetTag("card.rank", card.Rank.ToString());
        
        var stopwatch = Stopwatch.StartNew();
        
        try
        {
            // Acquire distributed lock
            var lockKey = GetGameStateLockKey(sessionId);
            var lockValue = Guid.NewGuid().ToString();
            var lockAcquired = await AcquireLockAsync(lockKey, lockValue, TimeSpan.FromSeconds(5));
            
            if (!lockAcquired)
            {
                activity?.SetStatus(ActivityStatusCode.Error, "Failed to acquire game lock");
                CheckGameMetrics.RecordGameAction("play_card", stopwatch.Elapsed.TotalSeconds, false);
                return GameActionResult.Failure("GAME_LOCKED", "Game is being updated by another player");
            }

            try
            {
                // Get current game state
                using var getStateActivity = CheckGameActivitySource.Source.StartActivity("game.get_state");
                var currentGameId = await GetCurrentGameIdAsync(sessionId);
                
                if (!currentGameId.HasValue)
                {
                    activity?.SetStatus(ActivityStatusCode.Error, "No active game found");
                    return GameActionResult.Failure("NO_ACTIVE_GAME", "No active game in session");
                }

                var gameState = await GetGameStateAsync(currentGameId.Value);
                if (gameState == null)
                {
                    activity?.SetStatus(ActivityStatusCode.Error, "Game state not found");
                    return GameActionResult.Failure("GAME_NOT_FOUND", "Game state not found");
                }

                // Process the card play
                using var processActivity = CheckGameActivitySource.Source.StartActivity("game.process_card_play");
                processActivity?.SetTag("current.player", gameState.CurrentPlayerId.ToString());
                processActivity?.SetTag("players.count", gameState.Players.Count);
                
                var result = _gameEngine.ProcessCardPlay(gameState, playerId, card, chosenSuit);
                
                if (!result.IsSuccess)
                {
                    activity?.SetStatus(ActivityStatusCode.Error, result.Message);
                    CheckGameMetrics.RecordGameAction("play_card", stopwatch.Elapsed.TotalSeconds, false);
                    return result;
                }

                // Update game state
                using var updateActivity = CheckGameActivitySource.Source.StartActivity("game.update_state");
                await SetGameStateAsync(result.NewGameState!);
                
                activity?.SetTag("game.new_current_player", result.NewGameState.CurrentPlayerId.ToString());
                activity?.SetTag("game.attack_stack", result.NewGameState.AttackStack);
                
                CheckGameMetrics.RecordGameAction("play_card", stopwatch.Elapsed.TotalSeconds, true);
                return result;
            }
            finally
            {
                await ReleaseLockAsync(lockKey, lockValue);
            }
        }
        catch (Exception ex)
        {
            activity?.SetStatus(ActivityStatusCode.Error, ex.Message);
            CheckGameMetrics.RecordGameAction("play_card", stopwatch.Elapsed.TotalSeconds, false);
            _logger.LogError(ex, "Error processing card play for player {PlayerId} in session {SessionId}", 
                playerId, sessionId);
            throw;
        }
    }
}
```

## Prometheus Configuration

### Prometheus Configuration File
```yaml
# monitoring/prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s
  external_labels:
    cluster: 'checkgame-production'
    region: 'us-east-1'

rule_files:
  - "alert_rules.yml"

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - alertmanager:9093

scrape_configs:
  # CheckGame API instances
  - job_name: 'checkgame-api'
    static_configs:
      - targets: ['checkgame-api-service:80']
    metrics_path: '/metrics'
    scrape_interval: 10s
    scrape_timeout: 5s
    honor_labels: true
    params:
      format: ['prometheus']

  # Kubernetes API server
  - job_name: 'kubernetes-apiservers'
    kubernetes_sd_configs:
      - role: endpoints
        namespaces:
          names:
            - default
    scheme: https
    tls_config:
      ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
      insecure_skip_verify: true
    bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
    relabel_configs:
      - source_labels: [__meta_kubernetes_namespace, __meta_kubernetes_service_name, __meta_kubernetes_endpoint_port_name]
        action: keep
        regex: default;kubernetes;https

  # Kubernetes nodes
  - job_name: 'kubernetes-nodes'
    kubernetes_sd_configs:
      - role: node
    scheme: https
    tls_config:
      ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
      insecure_skip_verify: true
    bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
    relabel_configs:
      - action: labelmap
        regex: __meta_kubernetes_node_label_(.+)

  # Kubernetes pods
  - job_name: 'kubernetes-pods'
    kubernetes_sd_configs:
      - role: pod
        namespaces:
          names:
            - checkgame
    relabel_configs:
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
        action: keep
        regex: true
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
        action: replace
        target_label: __metrics_path__
        regex: (.+)
      - source_labels: [__address__, __meta_kubernetes_pod_annotation_prometheus_io_port]
        action: replace
        regex: ([^:]+)(?::\d+)?;(\d+)
        replacement: $1:$2
        target_label: __address__
      - action: labelmap
        regex: __meta_kubernetes_pod_label_(.+)
      - source_labels: [__meta_kubernetes_namespace]
        action: replace
        target_label: kubernetes_namespace
      - source_labels: [__meta_kubernetes_pod_name]
        action: replace
        target_label: kubernetes_pod_name

  # PostgreSQL
  - job_name: 'postgresql'
    static_configs:
      - targets: ['postgres-exporter:9187']
    scrape_interval: 30s

  # Redis
  - job_name: 'redis'
    static_configs:
      - targets: ['redis-exporter:9121']
    scrape_interval: 30s

  # Node Exporter
  - job_name: 'node-exporter'
    kubernetes_sd_configs:
      - role: endpoints
        namespaces:
          names:
            - monitoring
    relabel_configs:
      - source_labels: [__meta_kubernetes_service_name]
        action: keep
        regex: node-exporter

# Alert Rules
alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - alertmanager:9093

rule_files:
  - "/etc/prometheus/rules/*.yml"
```

### Alert Rules
```yaml
# monitoring/alert_rules.yml
groups:
  - name: checkgame-api
    rules:
      - alert: HighErrorRate
        expr: sum(rate(checkgame_api_request_duration_seconds_count{status=~"5.."}[5m])) / sum(rate(checkgame_api_request_duration_seconds_count[5m])) > 0.05
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "High error rate detected"
          description: "API error rate is {{ $value | humanizePercentage }} which is above 5%"

      - alert: HighLatency
        expr: histogram_quantile(0.95, sum(rate(checkgame_api_request_duration_seconds_bucket[5m])) by (le)) > 1.0
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High API latency detected"
          description: "95th percentile latency is {{ $value }}s which is above 1s"

      - alert: DatabaseConnectionFailure
        expr: increase(checkgame_database_queries_total{success="false"}[5m]) > 10
        for: 2m
        labels:
          severity: critical
        annotations:
          summary: "Database connection failures"
          description: "{{ $value }} database connection failures in the last 5 minutes"

      - alert: HighMemoryUsage
        expr: (checkgame_memory_usage_bytes / (1024*1024*1024)) > 1
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High memory usage"
          description: "Memory usage is {{ $value | humanize }}GB which is above 1GB"

      - alert: SignalRConnectionDrop
        expr: decrease(checkgame_active_signalr_connections[5m]) > 100
        for: 1m
        labels:
          severity: warning
        annotations:
          summary: "Large SignalR connection drop"
          description: "{{ $value }} SignalR connections dropped in the last 5 minutes"

      - alert: GameActionFailures
        expr: sum(rate(checkgame_game_actions_total{success="false"}[5m])) > 0.1
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "High game action failure rate"
          description: "Game action failure rate is {{ $value }} per second"

  - name: infrastructure
    rules:
      - alert: PodCrashLooping
        expr: rate(kube_pod_container_status_restarts_total[15m]) * 60 * 15 > 0
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Pod is crash looping"
          description: "Pod {{ $labels.namespace }}/{{ $labels.pod }} is crash looping"

      - alert: NodeDiskSpaceLow
        expr: (node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"}) * 100 < 15
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Node disk space is low"
          description: "Node {{ $labels.instance }} disk space is {{ $value }}% which is below 15%"

      - alert: HighCPUUsage
        expr: 100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High CPU usage"
          description: "CPU usage on {{ $labels.instance }} is {{ $value }}% which is above 80%"
```

## Grafana Configuration

### Grafana Dashboard - API Overview
```json
{
  "dashboard": {
    "id": null,
    "title": "CheckGame API Overview",
    "tags": ["checkgame", "api", "overview"],
    "timezone": "browser",
    "panels": [
      {
        "id": 1,
        "title": "Request Rate",
        "type": "stat",
        "targets": [
          {
            "expr": "sum(rate(checkgame_api_request_duration_seconds_count[5m]))",
            "legendFormat": "RPS"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "unit": "reqps",
            "decimals": 1
          }
        },
        "gridPos": {"h": 4, "w": 6, "x": 0, "y": 0}
      },
      {
        "id": 2,
        "title": "Response Time (95th percentile)",
        "type": "stat",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, sum(rate(checkgame_api_request_duration_seconds_bucket[5m])) by (le))",
            "legendFormat": "95th percentile"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "unit": "s",
            "decimals": 3
          }
        },
        "gridPos": {"h": 4, "w": 6, "x": 6, "y": 0}
      },
      {
        "id": 3,
        "title": "Error Rate",
        "type": "stat",
        "targets": [
          {
            "expr": "sum(rate(checkgame_api_request_duration_seconds_count{status=~\"5..\"}[5m])) / sum(rate(checkgame_api_request_duration_seconds_count[5m])) * 100",
            "legendFormat": "Error Rate"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "unit": "percent",
            "decimals": 2,
            "thresholds": {
              "steps": [
                {"color": "green", "value": null},
                {"color": "yellow", "value": 1},
                {"color": "red", "value": 5}
              ]
            }
          }
        },
        "gridPos": {"h": 4, "w": 6, "x": 12, "y": 0}
      },
      {
        "id": 4,
        "title": "Active Games",
        "type": "stat",
        "targets": [
          {
            "expr": "checkgame_active_games",
            "legendFormat": "Active Games"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "unit": "short",
            "decimals": 0
          }
        },
        "gridPos": {"h": 4, "w": 6, "x": 18, "y": 0}
      },
      {
        "id": 5,
        "title": "Request Duration by Endpoint",
        "type": "timeseries",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, sum(rate(checkgame_api_request_duration_seconds_bucket[5m])) by (le, endpoint))",
            "legendFormat": "{{ endpoint }} (95th)"
          },
          {
            "expr": "histogram_quantile(0.50, sum(rate(checkgame_api_request_duration_seconds_bucket[5m])) by (le, endpoint))",
            "legendFormat": "{{ endpoint }} (50th)"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "unit": "s",
            "custom": {
              "drawStyle": "line",
              "lineInterpolation": "linear",
              "lineWidth": 1,
              "fillOpacity": 0,
              "gradientMode": "none",
              "spanNulls": false,
              "insertNulls": false,
              "showPoints": "auto",
              "pointSize": 5,
              "stacking": {"mode": "none", "group": "A"},
              "axisPlacement": "auto",
              "axisLabel": "",
              "axisColorMode": "text",
              "scaleDistribution": {"type": "linear"},
              "axisCenteredZero": false,
              "hideFrom": {"legend": false, "tooltip": false, "vis": false},
              "thresholdsStyle": {"mode": "off"}
            }
          }
        },
        "gridPos": {"h": 8, "w": 12, "x": 0, "y": 4}
      },
      {
        "id": 6,
        "title": "SignalR Connections",
        "type": "timeseries",
        "targets": [
          {
            "expr": "checkgame_active_signalr_connections",
            "legendFormat": "Active Connections"
          },
          {
            "expr": "rate(checkgame_signalr_connections_total{event=\"connected\"}[5m])",
            "legendFormat": "Connection Rate"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "unit": "short"
          }
        },
        "gridPos": {"h": 8, "w": 12, "x": 12, "y": 4}
      }
    ],
    "time": {
      "from": "now-1h",
      "to": "now"
    },
    "refresh": "10s"
  }
}
```

### Grafana Dashboard - Game Metrics
```json
{
  "dashboard": {
    "title": "CheckGame - Game Metrics",
    "panels": [
      {
        "id": 1,
        "title": "Game Actions per Second",
        "type": "timeseries",
        "targets": [
          {
            "expr": "sum(rate(checkgame_game_actions_total[5m])) by (action)",
            "legendFormat": "{{ action }}"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "unit": "ops",
            "custom": {
              "drawStyle": "line",
              "lineInterpolation": "linear",
              "lineWidth": 2,
              "fillOpacity": 10,
              "gradientMode": "opacity"
            }
          }
        }
      },
      {
        "id": 2,
        "title": "Game Action Success Rate",
        "type": "timeseries",
        "targets": [
          {
            "expr": "sum(rate(checkgame_game_actions_total{success=\"true\"}[5m])) by (action) / sum(rate(checkgame_game_actions_total[5m])) by (action) * 100",
            "legendFormat": "{{ action }} Success Rate"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "unit": "percent",
            "min": 0,
            "max": 100
          }
        }
      },
      {
        "id": 3,
        "title": "Game Action Duration Distribution",
        "type": "heatmap",
        "targets": [
          {
            "expr": "sum(rate(checkgame_game_action_duration_seconds_bucket[5m])) by (le)",
            "format": "heatmap",
            "legendFormat": "{{ le }}"
          }
        ]
      },
      {
        "id": 4,
        "title": "Database Operations",
        "type": "timeseries",
        "targets": [
          {
            "expr": "sum(rate(checkgame_database_queries_total[5m])) by (operation)",
            "legendFormat": "{{ operation }}"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "unit": "ops"
          }
        }
      }
    ]
  }
}
```

### Data Source Configuration
```yaml
# monitoring/grafana/datasources/datasources.yml
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: true
    jsonData:
      timeInterval: "5s"
      queryTimeout: "60s"
      httpMethod: "POST"
      customQueryParameters: ""
      
  - name: Jaeger
    type: jaeger
    access: proxy
    url: http://jaeger:16686
    editable: true
    jsonData:
      tracesToLogsV2:
        datasourceUid: 'loki'
        spanStartTimeShift: '1h'
        spanEndTimeShift: '-1h'
        tags:
          - key: 'service.name'
            value: 'checkgame-api'
        filterByTraceID: false
        filterBySpanID: false
        customQuery: true
        query: '{service_name="${__data.fields.serviceName}"} |= "${__data.fields.traceID}"'
      
  - name: Loki
    type: loki
    access: proxy
    url: http://loki:3100
    editable: true
    jsonData:
      maxLines: 1000
      derivedFields:
        - datasourceUid: 'jaeger'
          matcherRegex: 'traceID=(\w+)'
          name: 'TraceID'
          url: '$${__value.raw}'
```

## OpenTelemetry Collector Configuration

### OTEL Collector Config
```yaml
# monitoring/otel-collector-config.yml
receivers:
  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:4317
      http:
        endpoint: 0.0.0.0:4318
  
  prometheus:
    config:
      scrape_configs:
        - job_name: 'checkgame-api'
          static_configs:
            - targets: ['checkgame-api-service:80']
          metrics_path: '/metrics'
          scrape_interval: 10s

processors:
  batch:
    timeout: 1s
    send_batch_size: 1024
    send_batch_max_size: 2048
  
  memory_limiter:
    check_interval: 1s
    limit_mib: 512
  
  resource:
    attributes:
      - key: service.name
        value: checkgame-api
        action: upsert
      - key: service.version
        value: 1.0.0
        action: upsert
      - key: deployment.environment
        value: production
        action: upsert

  # Sampling processor for traces
  probabilistic_sampler:
    sampling_percentage: 10

  # Attributes processor to add custom attributes
  attributes:
    actions:
      - key: environment
        value: production
        action: insert

exporters:
  prometheus:
    endpoint: "0.0.0.0:8888"
    namespace: checkgame
    const_labels:
      environment: production
  
  jaeger:
    endpoint: jaeger:14250
    tls:
      insecure: true
  
  otlp:
    endpoint: http://jaeger:14268/api/traces
    tls:
      insecure: true
  
  logging:
    loglevel: debug

extensions:
  health_check:
    endpoint: 0.0.0.0:13133
  pprof:
    endpoint: 0.0.0.0:1777
  zpages:
    endpoint: 0.0.0.0:55679

service:
  extensions: [health_check, pprof, zpages]
  pipelines:
    traces:
      receivers: [otlp]
      processors: [memory_limiter, resource, probabilistic_sampler, batch]
      exporters: [jaeger, logging]
    
    metrics:
      receivers: [otlp, prometheus]
      processors: [memory_limiter, resource, attributes, batch]
      exporters: [prometheus, logging]
  
  telemetry:
    logs:
      level: info
    metrics:
      address: 0.0.0.0:8888
```

## Alertmanager Configuration

### Alertmanager Config
```yaml
# monitoring/alertmanager.yml
global:
  smtp_smarthost: 'localhost:587'
  smtp_from: 'alerts@checkgame.com'
  smtp_auth_username: 'alerts@checkgame.com'
  smtp_auth_password: 'password'

route:
  group_by: ['alertname']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h
  receiver: 'web.hook'
  routes:
    - match:
        severity: critical
      receiver: 'critical-alerts'
      group_wait: 0s
      repeat_interval: 5m
    - match:
        severity: warning
      receiver: 'warning-alerts'
      repeat_interval: 1h

receivers:
  - name: 'web.hook'
    webhook_configs:
      - url: 'http://127.0.0.1:5001/'

  - name: 'critical-alerts'
    email_configs:
      - to: 'ops@checkgame.com'
        subject: 'CRITICAL: {{ .GroupLabels.alertname }}'
        body: |
          {{ range .Alerts }}
          Alert: {{ .Annotations.summary }}
          Description: {{ .Annotations.description }}
          {{ end }}
    slack_configs:
      - api_url: 'YOUR_SLACK_WEBHOOK_URL'
        channel: '#alerts-critical'
        title: 'CRITICAL Alert'
        text: '{{ range .Alerts }}{{ .Annotations.summary }}{{ end }}'

  - name: 'warning-alerts'
    email_configs:
      - to: 'devs@checkgame.com'
        subject: 'WARNING: {{ .GroupLabels.alertname }}'
        body: |
          {{ range .Alerts }}
          Alert: {{ .Annotations.summary }}
          Description: {{ .Annotations.description }}
          {{ end }}

inhibit_rules:
  - source_match:
      severity: 'critical'
    target_match:
      severity: 'warning'
    equal: ['alertname', 'instance']
```

This comprehensive observability configuration provides full visibility into the Check-Game API performance, user behavior, and system health with automated alerting and rich dashboards for monitoring and troubleshooting.