# Check-Game Technical Architecture

## Overview
Check-Game is a high-performance real-time multiplayer card game built as a tournament-style mobile application with cross-platform support. Players compete in sessions where games are played successively until one winner emerges.

## High-Level Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  Flutter Client │    │   .NET 8 API    │    │   PostgreSQL    │
│   (Mobile/Web)  │◄──►│   + SignalR     │◄──►│    Database     │
│                 │    │   + Redis       │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                              │
                       ┌──────▼──────┐
                       │ Observability│
                       │ (OpenTelemetry)│
                       │ Grafana +    │
                       │ Prometheus   │
                       └─────────────┘
```

## Technology Stack

### Frontend
- **Framework**: Flutter (Dart)
- **Platforms**: iOS, Android, Web, Desktop
- **State Management**: Riverpod
- **Real-time Client**: SignalR Dart client
- **UI**: Material Design 3

### Backend
- **Runtime**: .NET 8 (AOT compiled)
- **Framework**: ASP.NET Core Web API
- **Real-time**: SignalR Hubs
- **Authentication**: JWT Bearer tokens (System.IdentityModel.Tokens.Jwt)
- **Database**: Entity Framework Core
- **Validation**: FluentValidation
- **Testing**: xUnit, NSubstitute, FluentAssertions

### Database & Caching
- **Primary**: PostgreSQL 15+
- **In-Memory Cache**: Redis 7+ (game state, sessions)
- **Connection Pool**: Npgsql connection pooling
- **Migrations**: Entity Framework Core Migrations

### Observability
- **Metrics**: OpenTelemetry + Prometheus
- **Distributed Tracing**: OpenTelemetry + Jaeger
- **Logging**: Serilog with structured logging
- **Dashboards**: Grafana
- **Health Checks**: ASP.NET Core Health Checks

### Infrastructure
- **Containerization**: Docker (Alpine Linux base)
- **Orchestration**: Docker Compose (development), Kubernetes (production)
- **Reverse Proxy**: YARP (built into .NET)
- **SSL/TLS**: Let's Encrypt

## Core Components

### 1. Authentication Service
- JWT Bearer token authentication
- User registration and login with ASP.NET Core Identity
- Token refresh mechanism with refresh tokens
- Anonymous session joining via secure links

### 2. Session Management Service
- Session creation (authenticated users only)
- Session joining (authenticated + anonymous)
- Player capacity management
- In-memory session state with Redis persistence

### 3. Game Engine (In-Memory)
- High-performance card game logic
- Real-time turn management
- Tournament elimination system
- Game state validation and synchronization
- No database persistence for game moves (performance optimized)

### 4. SignalR Real-time Communication
- SignalR hubs for real-time game updates
- Connection-based user authentication
- Group management for game sessions
- Automatic reconnection and state recovery

### 5. Database Layer (Minimal)
- User account management
- Session metadata only
- Basic tournament results
- No real-time game state storage

## Security Considerations

### Authentication & Authorization
- JWT tokens with expiration
- Secure password hashing (bcrypt)
- Rate limiting on API endpoints
- CORS configuration

### Data Protection
- Input validation and sanitization
- SQL injection prevention (Prisma)
- XSS protection
- Secure WebSocket connections (WSS)

### Session Security
- Session-specific access tokens
- Player verification
- Anti-cheating measures
- Graceful handling of disconnections

## Scalability & Performance

### Horizontal Scaling
- Stateless API design
- Session affinity for WebSocket connections
- Load balancer configuration
- Database connection pooling

### Performance Optimization
- **AOT Compilation**: Native ahead-of-time compilation for maximum speed
- **In-Memory Game State**: Redis-cached game state, no database I/O during gameplay
- **Minimal Database Operations**: Only session metadata persisted
- **Connection Pooling**: Optimized database and Redis connections
- **SignalR Scaling**: Redis backplane for horizontal scaling

## Deployment Architecture

### Development Environment
```
Docker Compose:
- .NET 8 API Server (AOT compiled)
- PostgreSQL Database
- Redis Cache
- Grafana + Prometheus
- Jaeger Tracing
```

### Production Environment
```
Kubernetes Cluster:
- .NET API Pods (auto-scaling with HPA)
- PostgreSQL (managed service)
- Redis Cluster (StackExchange.Redis)
- YARP Load Balancer
- OpenTelemetry Collector
- Grafana Stack
```

## Data Flow

### High-Performance Game Session Flow
1. User creates/joins session (minimal DB write)
2. SignalR connection established with authentication
3. Game state managed entirely in Redis
4. Real-time events via SignalR hubs
5. Tournament progression tracked in memory
6. Final results persisted to database

### Event-Driven Architecture
- SignalR hubs broadcast real-time events
- In-memory game state with Redis persistence
- Zero database I/O during active gameplay
- Server maintains authoritative state in Redis
- Clients receive complete game state updates

## Development Principles

### Code Organization
- **Clean Architecture**: Separated concerns with dependency injection
- **Minimal APIs**: High-performance endpoint routing
- **Domain Services**: Business logic separation
- **Repository Pattern**: Data access abstraction

### Comprehensive Testing Strategy
- **Unit Tests**: xUnit with NSubstitute mocking (~90% coverage target)
- **Integration Tests**: ASP.NET Core TestServer with test containers
- **Performance Tests**: NBomber for load testing SignalR hubs
- **SignalR Hub Tests**: Specialized real-time communication testing
- **Contract Tests**: OpenAPI specification validation
- **E2E Tests**: Playwright integration for Flutter web client

### Performance & Observability
- **OpenTelemetry**: Distributed tracing and metrics collection
- **Structured Logging**: Serilog with Seq/ELK integration
- **Health Checks**: Comprehensive application and dependency monitoring
- **Custom Metrics**: Game-specific performance indicators
- **Real-time Dashboards**: Grafana visualization

### Documentation
- **API Documentation**: OpenAPI/Swagger with comprehensive examples
- **Code Documentation**: XML comments for IntelliSense
- **Architecture Decision Records**: Decision tracking and rationale
- **Performance Guides**: Optimization and scaling documentation