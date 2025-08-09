namespace CheckGame.Api.Endpoints.GameSession;

public static class GameSessionEndpoints
{
    public static IEndpointRouteBuilder MapGameSessionEndpoints(this IEndpointRouteBuilder route)
    {
        var group = route.MapGroup("/sessions");

        // Session management endpoints
        group.MapPost("/", GameSessions.CreateSession)
             .RequireAuthorization()
             .WithName("CreateGameSession")
             .WithSummary("Create a new game session")
             .WithDescription("Creates a new game session. Only authenticated users can create sessions.");

        group.MapPost("/{sessionId}/join", GameSessions.JoinSession)
             .AllowAnonymous()
             .WithName("JoinGameSession")
             .WithSummary("Join a game session")
             .WithDescription("Join a game session. Both authenticated and anonymous users can join.");

        group.MapGet("/{sessionId}/join", GameSessions.JoinSessionByUrl)
             .AllowAnonymous()
             .WithName("JoinGameSessionByUrl")
             .WithSummary("Join a game session via URL")
             .WithDescription("Join a game session by clicking a shared URL link. Supports optional playerName query parameter.");

        group.MapPost("/{sessionId}/leave", GameSessions.LeaveSession)
             .AllowAnonymous()
             .WithName("LeaveGameSession")
             .WithSummary("Leave a game session")
             .WithDescription("Leave a game session by providing the player name.");

        // Query endpoints
        group.MapGet("/{sessionId}", GameSessions.GetSession)
             .AllowAnonymous()
             .WithName("GetGameSession")
             .WithSummary("Get game session details")
             .WithDescription("Get detailed information about a specific game session.");

        group.MapGet("/active", GameSessions.GetActiveSessions)
             .AllowAnonymous()
             .WithName("GetActiveGameSessions")
             .WithSummary("Get active game sessions")
             .WithDescription("Get a paginated list of active game sessions that can be joined.");

        group.MapGet("/my-sessions", GameSessions.GetUserSessions)
             .RequireAuthorization()
             .WithName("GetMyGameSessions")
             .WithSummary("Get user's game sessions")
             .WithDescription("Get a paginated list of game sessions created by the authenticated user.");

        return route;
    }
}