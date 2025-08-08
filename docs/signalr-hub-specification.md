# Check-Game SignalR Hub Specification

## Overview
SignalR hubs provide real-time bidirectional communication between the .NET server and Flutter clients. All game state synchronization, player interactions, and tournament events are handled through these hubs.

## Hub Architecture

### Connection Flow
```
1. Client authenticates via JWT token
2. Client connects to GameHub with session token
3. Server validates session membership
4. Client joins session group
5. Real-time event broadcasting begins
```

## SignalR Hub Implementation

### GameHub - Main Game Hub
```csharp
[Authorize]
public class GameHub : Hub<IGameClient>
{
    private readonly IGameStateService _gameStateService;
    private readonly ISessionService _sessionService;
    private readonly ILogger<GameHub> _logger;

    public GameHub(
        IGameStateService gameStateService, 
        ISessionService sessionService, 
        ILogger<GameHub> logger)
    {
        _gameStateService = gameStateService;
        _sessionService = sessionService;
        _logger = logger;
    }

    public override async Task OnConnectedAsync()
    {
        var userId = Context.GetUserId();
        var sessionId = Context.GetHttpContext()?.Request.Query["sessionId"].ToString();
        
        if (!Guid.TryParse(sessionId, out var sessionGuid))
        {
            await Clients.Caller.ConnectionError("INVALID_SESSION_ID", "Invalid session ID provided");
            Context.Abort();
            return;
        }

        // Validate session membership
        var canJoin = await _sessionService.CanUserJoinSessionAsync(userId, sessionGuid);
        if (!canJoin)
        {
            await Clients.Caller.ConnectionError("SESSION_ACCESS_DENIED", "Access to session denied");
            Context.Abort();
            return;
        }

        // Add to session group
        await Groups.AddToGroupAsync(Context.ConnectionId, $"Session_{sessionGuid}");
        
        // Send current session state
        var sessionState = await _gameStateService.GetSessionStateAsync(sessionGuid);
        await Clients.Caller.SessionStateUpdate(sessionState);
        
        // Notify other players
        await Clients.OthersInGroup($"Session_{sessionGuid}")
            .PlayerConnected(userId, Context.ConnectionId);

        _logger.LogInformation("Player {UserId} connected to session {SessionId}", userId, sessionGuid);
        await base.OnConnectedAsync();
    }

    public override async Task OnDisconnectedAsync(Exception? exception)
    {
        var userId = Context.GetUserId();
        var sessionId = Context.GetSessionId();
        
        if (sessionId.HasValue)
        {
            await Groups.RemoveFromGroupAsync(Context.ConnectionId, $"Session_{sessionId}");
            await Clients.OthersInGroup($"Session_{sessionId}")
                .PlayerDisconnected(userId, Context.ConnectionId);
        }

        _logger.LogInformation("Player {UserId} disconnected from session {SessionId}", userId, sessionId);
        await base.OnDisconnectedAsync(exception);
    }

    // Game Actions
    public async Task PlayCard(PlayCardRequest request)
    {
        try
        {
            var userId = Context.GetUserId();
            var sessionId = Context.GetSessionId();
            
            if (!sessionId.HasValue) return;

            var result = await _gameStateService.PlayCardAsync(sessionId.Value, userId, request);
            
            if (result.IsSuccess)
            {
                // Broadcast to all players in session
                await Clients.Group($"Session_{sessionId}")
                    .GameStateUpdate(result.GameState!);
                    
                // Send individual player hands (private data)
                foreach (var player in result.GameState!.Players)
                {
                    var connectionId = await GetPlayerConnectionId(player.Id);
                    if (!string.IsNullOrEmpty(connectionId))
                    {
                        await Clients.Client(connectionId)
                            .PlayerHandUpdate(player.Hand);
                    }
                }
            }
            else
            {
                await Clients.Caller.ActionError(result.Error!, result.Message!);
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error playing card for user {UserId}", Context.GetUserId());
            await Clients.Caller.ActionError("INTERNAL_ERROR", "An error occurred while playing the card");
        }
    }

    public async Task DrawCard()
    {
        try
        {
            var userId = Context.GetUserId();
            var sessionId = Context.GetSessionId();
            
            if (!sessionId.HasValue) return;

            var result = await _gameStateService.DrawCardAsync(sessionId.Value, userId);
            
            if (result.IsSuccess)
            {
                await Clients.Group($"Session_{sessionId}")
                    .GameStateUpdate(result.GameState!);
                    
                // Send the drawn card only to the player who drew it
                await Clients.Caller.CardDrawn(result.DrawnCard!);
            }
            else
            {
                await Clients.Caller.ActionError(result.Error!, result.Message!);
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error drawing card for user {UserId}", Context.GetUserId());
            await Clients.Caller.ActionError("INTERNAL_ERROR", "An error occurred while drawing the card");
        }
    }

    public async Task ChooseSuit(ChooseSuitRequest request)
    {
        try
        {
            var userId = Context.GetUserId();
            var sessionId = Context.GetSessionId();
            
            if (!sessionId.HasValue) return;

            var result = await _gameStateService.ChooseSuitAsync(sessionId.Value, userId, request.Suit);
            
            if (result.IsSuccess)
            {
                await Clients.Group($"Session_{sessionId}")
                    .SuitChosen(userId, request.Suit, result.GameState!);
            }
            else
            {
                await Clients.Caller.ActionError(result.Error!, result.Message!);
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error choosing suit for user {UserId}", Context.GetUserId());
            await Clients.Caller.ActionError("INTERNAL_ERROR", "An error occurred while choosing the suit");
        }
    }

    // Session Management
    public async Task StartGame()
    {
        try
        {
            var userId = Context.GetUserId();
            var sessionId = Context.GetSessionId();
            
            if (!sessionId.HasValue) return;

            var result = await _gameStateService.StartGameAsync(sessionId.Value, userId);
            
            if (result.IsSuccess)
            {
                await Clients.Group($"Session_{sessionId}")
                    .GameStarted(result.GameState!);
            }
            else
            {
                await Clients.Caller.ActionError(result.Error!, result.Message!);
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error starting game for user {UserId}", Context.GetUserId());
            await Clients.Caller.ActionError("INTERNAL_ERROR", "An error occurred while starting the game");
        }
    }

    public async Task LeaveSession()
    {
        try
        {
            var userId = Context.GetUserId();
            var sessionId = Context.GetSessionId();
            
            if (!sessionId.HasValue) return;

            await _sessionService.RemovePlayerFromSessionAsync(sessionId.Value, userId);
            
            await Groups.RemoveFromGroupAsync(Context.ConnectionId, $"Session_{sessionId}");
            await Clients.OthersInGroup($"Session_{sessionId}")
                .PlayerLeft(userId);
                
            await Clients.Caller.SessionLeft();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error leaving session for user {UserId}", Context.GetUserId());
        }
    }

    // Utility methods
    private async Task<string?> GetPlayerConnectionId(Guid playerId)
    {
        // Implementation to get connection ID from player ID
        // This could be cached in Redis for performance
        return null; // Placeholder
    }
}
```

### Client Interface Definition
```csharp
public interface IGameClient
{
    // Connection Events
    Task ConnectionEstablished(string connectionId);
    Task ConnectionError(string errorCode, string message);
    
    // Session Events
    Task SessionStateUpdate(SessionStateDto sessionState);
    Task PlayerConnected(Guid playerId, string connectionId);
    Task PlayerDisconnected(Guid playerId, string connectionId);
    Task PlayerJoined(SessionPlayerDto player);
    Task PlayerLeft(Guid playerId);
    Task SessionLeft();
    
    // Game Events
    Task GameStarted(GameStateDto gameState);
    Task GameStateUpdate(GameStateDto gameState);
    Task GameFinished(GameResultDto result);
    
    // Player Action Events
    Task PlayerHandUpdate(List<CardDto> hand);
    Task CardDrawn(CardDto card);
    Task SuitChosen(Guid playerId, CardSuit suit, GameStateDto gameState);
    
    // Tournament Events
    Task PlayerEliminated(Guid playerId, GameStateDto gameState);
    Task TournamentFinished(TournamentResultDto result);
    
    // Error Handling
    Task ActionError(string errorCode, string message);
    
    // Heartbeat
    Task Ping(DateTime serverTime);
}
```

## Data Transfer Objects

### Request Models
```csharp
public record PlayCardRequest(
    CardDto Card,
    CardSuit? ChosenSuit = null // For Jack cards
);

public record ChooseSuitRequest(
    CardSuit Suit
);

public record DrawCardRequest(); // Empty - no parameters needed
```

### Response Models
```csharp
public record SessionStateDto(
    Guid SessionId,
    string? Name,
    SessionStatus Status,
    List<SessionPlayerDto> Players,
    GameStateDto? CurrentGame,
    TournamentStateDto Tournament
);

public record GameStateDto(
    Guid GameId,
    int GameNumber,
    GameStatus Status,
    List<GamePlayerDto> Players,
    CardDto CurrentCard,
    int DrawPileSize,
    int DiscardPileSize,
    Guid CurrentPlayerId,
    int TurnDirection,
    int AttackStack,
    CardSuit? ChosenSuit,
    bool SkipNextPlayer,
    DateTime LastUpdated
);

public record GamePlayerDto(
    Guid Id,
    string Username,
    int HandSize,
    int PlayOrder,
    bool IsCurrentPlayer,
    bool IsEliminated,
    List<CardDto>? Hand = null // Only sent to the owning player
);

public record CardDto(
    string Id,
    CardSuit Suit,
    CardRank Rank,
    CardColor Color
);

public record GameResultDto(
    Guid GameId,
    Guid WinnerId,
    Guid LoserId,
    TimeSpan Duration,
    List<PlayerResultDto> FinalStandings
);

public record PlayerResultDto(
    Guid PlayerId,
    string Username,
    int FinalHandSize,
    int Placement
);

public record TournamentResultDto(
    Guid SessionId,
    Guid WinnerId,
    List<PlayerResultDto> FinalRankings,
    int TotalGames,
    TimeSpan TotalDuration
);

public record TournamentStateDto(
    int GamesPlayed,
    List<Guid> EliminatedPlayers,
    List<Guid> ActivePlayers,
    int CurrentRound
);
```

## Hub Extensions and Utilities

### Context Extensions
```csharp
public static class HubContextExtensions
{
    public static Guid GetUserId(this HubCallerContext context)
    {
        var userIdClaim = context.User?.FindFirst(ClaimTypes.NameIdentifier);
        return Guid.TryParse(userIdClaim?.Value, out var userId) ? userId : Guid.Empty;
    }
    
    public static Guid? GetSessionId(this HubCallerContext context)
    {
        var sessionId = context.GetHttpContext()?.Request.Query["sessionId"].ToString();
        return Guid.TryParse(sessionId, out var sessionGuid) ? sessionGuid : null;
    }
    
    public static string? GetSessionToken(this HubCallerContext context)
    {
        return context.GetHttpContext()?.Request.Query["sessionToken"].ToString();
    }
}
```

### Connection Manager
```csharp
public interface IConnectionManager
{
    Task AddConnectionAsync(Guid userId, Guid sessionId, string connectionId);
    Task RemoveConnectionAsync(string connectionId);
    Task<string?> GetConnectionIdAsync(Guid userId, Guid sessionId);
    Task<List<string>> GetSessionConnectionsAsync(Guid sessionId);
}

public class RedisConnectionManager : IConnectionManager
{
    private readonly IDatabase _database;
    private readonly ILogger<RedisConnectionManager> _logger;

    public async Task AddConnectionAsync(Guid userId, Guid sessionId, string connectionId)
    {
        var key = $"connection:{userId}:{sessionId}";
        await _database.StringSetAsync(key, connectionId, TimeSpan.FromHours(24));
        
        var sessionKey = $"session_connections:{sessionId}";
        await _database.SetAddAsync(sessionKey, connectionId);
    }

    public async Task RemoveConnectionAsync(string connectionId)
    {
        // Implementation to remove connection from all relevant keys
        // This would involve scanning or maintaining reverse lookup
    }

    public async Task<string?> GetConnectionIdAsync(Guid userId, Guid sessionId)
    {
        var key = $"connection:{userId}:{sessionId}";
        return await _database.StringGetAsync(key);
    }

    public async Task<List<string>> GetSessionConnectionsAsync(Guid sessionId)
    {
        var key = $"session_connections:{sessionId}";
        var connections = await _database.SetMembersAsync(key);
        return connections.Select(c => c.ToString()).ToList();
    }
}
```

## Hub Configuration

### Startup Configuration
```csharp
public static class SignalRConfiguration
{
    public static IServiceCollection AddCheckGameSignalR(
        this IServiceCollection services, 
        IConfiguration configuration)
    {
        services.AddSignalR(options =>
        {
            options.EnableDetailedErrors = true; // Only in development
            options.MaximumReceiveMessageSize = 102400; // 100KB
            options.StreamBufferCapacity = 10;
            options.MaximumParallelInvocationsPerClient = 2;
        })
        .AddStackExchangeRedis(configuration.GetConnectionString("Redis")!, options =>
        {
            options.Configuration.ChannelPrefix = "CheckGame";
        })
        .AddJsonProtocol(options =>
        {
            options.PayloadSerializerOptions.PropertyNamingPolicy = JsonNamingPolicy.CamelCase;
            options.PayloadSerializerOptions.DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull;
        });

        return services;
    }
}

// In Program.cs
builder.Services.AddCheckGameSignalR(builder.Configuration);

// Map hub
app.MapHub<GameHub>("/gameHub", options =>
{
    options.Transports = HttpTransportType.WebSockets | HttpTransportType.LongPolling;
});
```

### Authentication Middleware
```csharp
public class SignalRAuthenticationMiddleware
{
    private readonly RequestDelegate _next;

    public async Task InvokeAsync(HttpContext context)
    {
        if (context.Request.Path.StartsWithSegments("/gameHub"))
        {
            var token = context.Request.Query["access_token"];
            if (!string.IsNullOrEmpty(token))
            {
                context.Request.Headers.Authorization = $"Bearer {token}";
            }
        }

        await _next(context);
    }
}
```

## Error Handling and Resilience

### Hub Error Handling
```csharp
public class GameHubErrorHandler
{
    private readonly ILogger<GameHubErrorHandler> _logger;

    public async Task HandleErrorAsync(HubCallerContext context, Exception exception)
    {
        var userId = context.GetUserId();
        var sessionId = context.GetSessionId();
        
        _logger.LogError(exception, 
            "SignalR error for user {UserId} in session {SessionId}", 
            userId, sessionId);

        var errorCode = exception switch
        {
            GameRuleViolationException => "INVALID_MOVE",
            SessionNotFoundException => "SESSION_NOT_FOUND",
            UnauthorizedAccessException => "ACCESS_DENIED",
            _ => "INTERNAL_ERROR"
        };

        var client = GlobalHost.ConnectionManager.GetHubContext<GameHub, IGameClient>()
            .Clients.Client(context.ConnectionId);
            
        await client.ActionError(errorCode, exception.Message);
    }
}
```

### Connection Recovery
```csharp
public class ConnectionRecoveryService
{
    public async Task HandleReconnectionAsync(Guid userId, Guid sessionId, string newConnectionId)
    {
        // Remove old connection
        var oldConnectionId = await _connectionManager.GetConnectionIdAsync(userId, sessionId);
        if (!string.IsNullOrEmpty(oldConnectionId))
        {
            await _connectionManager.RemoveConnectionAsync(oldConnectionId);
        }

        // Add new connection
        await _connectionManager.AddConnectionAsync(userId, sessionId, newConnectionId);

        // Send current game state to reconnected client
        var gameState = await _gameStateService.GetGameStateAsync(sessionId);
        if (gameState != null)
        {
            var hubContext = _serviceProvider.GetRequiredService<IHubContext<GameHub, IGameClient>>();
            await hubContext.Clients.Client(newConnectionId).GameStateUpdate(gameState);
        }
    }
}
```

## Performance Optimization

### Message Batching
```csharp
public class BatchedGameUpdates
{
    private readonly ConcurrentDictionary<Guid, GameStateUpdateBatch> _batches = new();
    private readonly Timer _flushTimer;

    public BatchedGameUpdates()
    {
        _flushTimer = new Timer(FlushBatches, null, TimeSpan.FromMilliseconds(50), TimeSpan.FromMilliseconds(50));
    }

    public void AddUpdate(Guid sessionId, GameStateDto gameState)
    {
        _batches.AddOrUpdate(sessionId, 
            new GameStateUpdateBatch(sessionId, gameState),
            (key, existing) => existing with { GameState = gameState, LastUpdated = DateTime.UtcNow });
    }

    private async void FlushBatches(object? state)
    {
        var batchesToFlush = _batches.Values.Where(b => 
            DateTime.UtcNow - b.LastUpdated > TimeSpan.FromMilliseconds(16)) // ~60fps
            .ToList();

        foreach (var batch in batchesToFlush)
        {
            if (_batches.TryRemove(batch.SessionId, out _))
            {
                var hubContext = _serviceProvider.GetRequiredService<IHubContext<GameHub, IGameClient>>();
                await hubContext.Clients.Group($"Session_{batch.SessionId}")
                    .GameStateUpdate(batch.GameState);
            }
        }
    }
}

public record GameStateUpdateBatch(
    Guid SessionId,
    GameStateDto GameState,
    DateTime LastUpdated = default
)
{
    public DateTime LastUpdated { get; init; } = LastUpdated == default ? DateTime.UtcNow : LastUpdated;
}
```

### Connection Scaling
```csharp
// Redis backplane configuration for horizontal scaling
services.AddSignalR()
    .AddStackExchangeRedis(connectionString, options =>
    {
        options.Configuration.ChannelPrefix = "CheckGame";
        options.Configuration.DefaultDatabase = 1;
    });

// Sticky sessions configuration for load balancer
services.Configure<ForwardedHeadersOptions>(options =>
{
    options.ForwardedHeaders = ForwardedHeaders.XForwardedFor | ForwardedHeaders.XForwardedProto;
});
```

This SignalR hub specification provides high-performance, real-time communication with proper error handling, connection management, and scalability features for the Check-Game multiplayer experience.