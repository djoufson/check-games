# Check-Game .NET 8 API Specification

## Base Configuration
- **Runtime**: .NET 8 with AOT compilation
- **Framework**: ASP.NET Core Minimal APIs
- **Authentication**: JWT Bearer tokens
- **Validation**: FluentValidation
- **Documentation**: OpenAPI/Swagger with XML comments

## Base URLs
- Development: `https://localhost:7001/api/v1`
- Production: `https://api.checkgame.com/api/v1`

## Authentication
- **Type**: Bearer Token (JWT)
- **Header**: `Authorization: Bearer <token>`
- **Token Expiration**: 24 hours
- **Refresh Token Expiration**: 30 days

## HTTP Status Codes
- `200` - Success
- `201` - Created
- `400` - Bad Request (validation errors)
- `401` - Unauthorized
- `403` - Forbidden
- `404` - Not Found
- `409` - Conflict
- `422` - Unprocessable Entity
- `500` - Internal Server Error

## Request/Response Models

### Common Response Wrapper
```csharp
public record ApiResponse<T>(
    bool Success,
    T? Data,
    string? Message = null,
    Dictionary<string, string[]>? Errors = null
);

public record PagedResponse<T>(
    IEnumerable<T> Items,
    int Page,
    int PageSize,
    int TotalItems,
    int TotalPages
) : ApiResponse<IEnumerable<T>>(true, Items);
```

### Error Response
```csharp
public record ErrorResponse(
    string Type,
    string Title,
    int Status,
    string Detail,
    string Instance,
    Dictionary<string, object>? Extensions = null
);
```

## API Endpoints

### Authentication Endpoints

#### POST /auth/register
Register a new user account.

**Request Model:**
```csharp
public record RegisterRequest(
    [Required, StringLength(20, MinimumLength = 3)]
    string Username,
    
    [Required, EmailAddress]
    string Email,
    
    [Required, StringLength(100, MinimumLength = 8)]
    string Password,
    
    [Required]
    string ConfirmPassword
);
```

**Response (201):**
```csharp
public record AuthResponse(
    UserDto User,
    TokensDto Tokens
);

public record UserDto(
    Guid Id,
    string Username,
    string Email,
    DateTime CreatedAt
);

public record TokensDto(
    string AccessToken,
    string RefreshToken,
    DateTime ExpiresAt
);
```

#### POST /auth/login
Authenticate user and receive tokens.

**Request Model:**
```csharp
public record LoginRequest(
    [Required, EmailAddress]
    string Email,
    
    [Required]
    string Password
);
```

**Response (200):**
```csharp
public record AuthResponse(
    UserDto User,
    TokensDto Tokens
);
```

#### POST /auth/refresh
Refresh access token using refresh token.

**Request Model:**
```csharp
public record RefreshTokenRequest(
    [Required]
    string RefreshToken
);
```

**Response (200):**
```csharp
public record TokenRefreshResponse(
    string AccessToken,
    DateTime ExpiresAt
);
```

#### POST /auth/logout
Invalidate refresh token and logout.

**Request Model:**
```csharp
public record LogoutRequest(
    [Required]
    string RefreshToken
);
```

**Response (200):**
```csharp
public record LogoutResponse(
    string Message = "Logged out successfully"
);
```

### User Management Endpoints

#### GET /users/profile
Get current user profile. **[Requires Authentication]**

**Response (200):**
```csharp
public record UserProfileDto(
    Guid Id,
    string Username,
    string Email,
    UserStatsDto Stats,
    DateTime CreatedAt
);

public record UserStatsDto(
    int TotalGames,
    int Wins,
    int Losses,
    decimal WinRate
);
```

#### PUT /users/profile
Update user profile. **[Requires Authentication]**

**Request Model:**
```csharp
public record UpdateProfileRequest(
    [StringLength(20, MinimumLength = 3)]
    string? Username,
    
    [EmailAddress]
    string? Email
);
```

### Session Management Endpoints

#### POST /sessions
Create a new game session. **[Requires Authentication]**

**Request Model:**
```csharp
public record CreateSessionRequest(
    [StringLength(50)]
    string? Name,
    
    [Range(2, 8)]
    int MaxPlayers = 4,
    
    bool IsPrivate = false
);
```

**Response (201):**
```csharp
public record SessionDto(
    Guid Id,
    string? Name,
    string JoinCode,
    int MaxPlayers,
    int CurrentPlayers,
    bool IsPrivate,
    SessionStatus Status,
    Guid CreatedBy,
    DateTime CreatedAt,
    string JoinUrl
);

public enum SessionStatus
{
    Waiting,
    Active,
    Completed
}
```

#### GET /sessions/{id:guid}
Get session details by ID.

**Response (200):**
```csharp
public record SessionDetailsDto(
    Guid Id,
    string? Name,
    string JoinCode,
    int MaxPlayers,
    int CurrentPlayers,
    bool IsPrivate,
    SessionStatus Status,
    Guid CreatedBy,
    IEnumerable<SessionPlayerDto> Players,
    CurrentGameDto? CurrentGame,
    TournamentStateDto Tournament,
    DateTime CreatedAt
);

public record SessionPlayerDto(
    Guid Id,
    string Username,
    bool IsAnonymous,
    DateTime JoinedAt,
    bool IsActive
);

public record CurrentGameDto(
    Guid Id,
    int GameNumber,
    GameStatus Status,
    DateTime StartedAt
);

public record TournamentStateDto(
    int GamesPlayed,
    IEnumerable<Guid> EliminatedPlayers,
    int CurrentRound
);

public enum GameStatus
{
    Waiting,
    Active,
    Completed
}
```

#### POST /sessions/{id:guid}/join
Join a session by ID.

**Request Model:**
```csharp
public record JoinSessionRequest(
    [StringLength(20)]
    string? AnonymousName = null
);
```

**Response (200):**
```csharp
public record JoinSessionResponse(
    string SessionToken,
    SessionPlayerDto Player
);
```

#### POST /sessions/join-by-code
Join session using join code.

**Request Model:**
```csharp
public record JoinByCodeRequest(
    [Required, StringLength(6, MinimumLength = 6)]
    string JoinCode,
    
    [StringLength(20)]
    string? AnonymousName = null
);
```

#### DELETE /sessions/{id:guid}/leave
Leave a session. **[Requires Authentication or Session Token]**

**Response (200):**
```csharp
public record LeaveSessionResponse(
    string Message = "Left session successfully"
);
```

#### GET /sessions
List available sessions with filtering and pagination.

**Query Parameters:**
```csharp
public record SessionFilters(
    SessionStatus? Status = null,
    int Page = 1,
    int PageSize = 10,
    bool IncludePrivate = false
);
```

**Response (200):**
```csharp
public record PagedResponse<SessionSummaryDto> : ApiResponse<IEnumerable<SessionSummaryDto>>;

public record SessionSummaryDto(
    Guid Id,
    string? Name,
    int CurrentPlayers,
    int MaxPlayers,
    SessionStatus Status,
    DateTime CreatedAt
);
```

### Game Management Endpoints

#### POST /sessions/{sessionId:guid}/games/start
Start a new game in session. **[Requires Authentication - Session Creator Only]**

**Response (201):**
```csharp
public record StartGameResponse(
    Guid GameId,
    string Message = "Game started successfully"
);
```

#### GET /sessions/{sessionId:guid}/games/current
Get current active game details. **[Requires Session Token]**

**Response (200):**
```csharp
public record GameStateDto(
    Guid Id,
    int GameNumber,
    GameStatus Status,
    IEnumerable<GamePlayerDto> Players,
    GameCardDto CurrentCard,
    int DrawPileSize,
    int DiscardPileSize,
    Guid CurrentPlayerId,
    Guid? WinnerId,
    Guid? LoserId
);

public record GamePlayerDto(
    Guid Id,
    string Username,
    int HandSize,
    int PlayOrder,
    bool IsCurrentPlayer,
    bool IsEliminated
);

public record GameCardDto(
    CardSuit Suit,
    CardRank Rank,
    CardColor Color
);

public enum CardSuit
{
    Spades, Hearts, Diamonds, Clubs
}

public enum CardRank
{
    Ace = 1, Two, Three, Four, Five, Six, Seven, 
    Eight, Nine, Ten, Jack, Queen, King, Joker = 14
}

public enum CardColor
{
    Red, Black
}
```

### Health Check Endpoints

#### GET /health
Application health check endpoint.

**Response (200/503):**
```csharp
public record HealthCheckResponse(
    string Status,
    TimeSpan TotalDuration,
    Dictionary<string, HealthCheckEntryDto> Entries
);

public record HealthCheckEntryDto(
    string Status,
    TimeSpan Duration,
    string? Description = null,
    object? Data = null
);
```

#### GET /health/ready
Readiness probe for Kubernetes.

**Response (200/503):**
```csharp
public record ReadinessResponse(
    string Status,
    string Message
);
```

## Validation Rules

### FluentValidation Examples
```csharp
public class RegisterRequestValidator : AbstractValidator<RegisterRequest>
{
    public RegisterRequestValidator()
    {
        RuleFor(x => x.Username)
            .NotEmpty()
            .Length(3, 20)
            .Matches("^[a-zA-Z0-9_]+$")
            .WithMessage("Username can only contain letters, numbers, and underscores");

        RuleFor(x => x.Email)
            .NotEmpty()
            .EmailAddress()
            .MaximumLength(255);

        RuleFor(x => x.Password)
            .NotEmpty()
            .MinimumLength(8)
            .Matches(@"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)")
            .WithMessage("Password must contain at least one lowercase, uppercase, and digit");

        RuleFor(x => x.ConfirmPassword)
            .Equal(x => x.Password)
            .WithMessage("Passwords must match");
    }
}
```

## Error Handling

### Custom Exception Types
```csharp
public class CheckGameException : Exception
{
    public string ErrorCode { get; }
    
    public CheckGameException(string errorCode, string message) : base(message)
    {
        ErrorCode = errorCode;
    }
}

public class ValidationException : CheckGameException
{
    public Dictionary<string, string[]> Errors { get; }
    
    public ValidationException(Dictionary<string, string[]> errors) 
        : base("VALIDATION_ERROR", "One or more validation errors occurred")
    {
        Errors = errors;
    }
}

public class SessionNotFoundException : CheckGameException
{
    public SessionNotFoundException(Guid sessionId) 
        : base("SESSION_NOT_FOUND", $"Session with ID {sessionId} was not found")
    {
    }
}
```

### Global Exception Handler
```csharp
public class GlobalExceptionHandler : IExceptionHandler
{
    private readonly ILogger<GlobalExceptionHandler> _logger;

    public async ValueTask<bool> TryHandleAsync(
        HttpContext httpContext, 
        Exception exception, 
        CancellationToken cancellationToken)
    {
        _logger.LogError(exception, "An unhandled exception occurred");

        var response = exception switch
        {
            ValidationException validationEx => new ErrorResponse(
                "validation_error",
                "Validation failed",
                400,
                validationEx.Message,
                httpContext.Request.Path,
                new Dictionary<string, object> { ["errors"] = validationEx.Errors }
            ),
            
            SessionNotFoundException => new ErrorResponse(
                "session_not_found",
                "Session not found",
                404,
                exception.Message,
                httpContext.Request.Path
            ),
            
            _ => new ErrorResponse(
                "internal_server_error",
                "An unexpected error occurred",
                500,
                "Please try again later",
                httpContext.Request.Path
            )
        };

        httpContext.Response.StatusCode = response.Status;
        await httpContext.Response.WriteAsJsonAsync(response, cancellationToken);
        
        return true;
    }
}
```

## Rate Limiting

### Rate Limiting Configuration
```csharp
builder.Services.AddRateLimiter(options =>
{
    options.AddFixedWindowLimiter("AuthApi", configure =>
    {
        configure.PermitLimit = 5;
        configure.Window = TimeSpan.FromMinutes(1);
        configure.QueueProcessingOrder = QueueProcessingOrder.OldestFirst;
        configure.QueueLimit = 2;
    });

    options.AddFixedWindowLimiter("GeneralApi", configure =>
    {
        configure.PermitLimit = 100;
        configure.Window = TimeSpan.FromMinutes(1);
    });

    options.AddFixedWindowLimiter("SessionCreate", configure =>
    {
        configure.PermitLimit = 10;
        configure.Window = TimeSpan.FromHours(1);
    });
});

// Usage on endpoints
app.MapPost("/auth/login", LoginAsync)
   .RequireRateLimiting("AuthApi");

app.MapPost("/sessions", CreateSessionAsync)
   .RequireRateLimiting("SessionCreate")
   .RequireAuthorization();
```

## OpenTelemetry Integration

### Metrics Collection
```csharp
// Custom metrics
public static class CheckGameMetrics
{
    private static readonly Counter<long> SessionsCreated = 
        GameMeter.CreateCounter<long>("checkgame.sessions.created");
    
    private static readonly Histogram<double> GameDuration = 
        GameMeter.CreateHistogram<double>("checkgame.game.duration");
    
    private static readonly Gauge<int> ActivePlayers = 
        GameMeter.CreateGauge<int>("checkgame.players.active");

    public static void RecordSessionCreated() => SessionsCreated.Add(1);
    public static void RecordGameDuration(double duration) => GameDuration.Record(duration);
    public static void UpdateActivePlayers(int count) => ActivePlayers.Record(count);
}
```

### Distributed Tracing
```csharp
// Activity tagging for tracing
public static class CheckGameActivityTags
{
    public const string SessionId = "checkgame.session.id";
    public const string GameId = "checkgame.game.id";
    public const string UserId = "checkgame.user.id";
    public const string PlayerCount = "checkgame.players.count";
}

// Usage in services
using var activity = CheckGameActivitySource.StartActivity("CreateSession");
activity?.SetTag(CheckGameActivityTags.UserId, userId.ToString());
activity?.SetTag(CheckGameActivityTags.PlayerCount, request.MaxPlayers);
```

## Performance Optimizations

### Memory Management
```csharp
// Use Span<T> and Memory<T> for high-performance operations
public static ReadOnlySpan<Card> ShuffleDeck(Span<Card> deck)
{
    for (int i = deck.Length - 1; i > 0; i--)
    {
        int j = Random.Shared.Next(i + 1);
        (deck[i], deck[j]) = (deck[j], deck[i]);
    }
    return deck;
}

// Object pooling for frequently allocated objects
public class GameStatePool : ObjectPool<GameState>
{
    // Implementation for reusing GameState objects
}
```

### Caching Strategy
```csharp
// Distributed caching with Redis
public interface IGameStateCache
{
    Task<GameState?> GetGameStateAsync(Guid gameId, CancellationToken cancellationToken = default);
    Task SetGameStateAsync(Guid gameId, GameState gameState, TimeSpan? expiry = null, CancellationToken cancellationToken = default);
    Task RemoveGameStateAsync(Guid gameId, CancellationToken cancellationToken = default);
}

// Redis implementation with serialization optimization
public class RedisGameStateCache : IGameStateCache
{
    private readonly IDatabase _database;
    private readonly JsonSerializerOptions _jsonOptions;

    public async Task<GameState?> GetGameStateAsync(Guid gameId, CancellationToken cancellationToken = default)
    {
        var json = await _database.StringGetAsync($"game:{gameId}");
        return json.HasValue ? JsonSerializer.Deserialize<GameState>(json!, _jsonOptions) : null;
    }
}
```