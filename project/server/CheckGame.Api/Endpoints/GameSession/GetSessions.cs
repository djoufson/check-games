using CheckGame.Api.Services;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace CheckGame.Api.Endpoints.GameSession;

public partial class GameSessions
{
    public static async Task<IResult> GetSession(
        [FromRoute] string sessionId,
        IGameSessionService gameSessionService)
    {
        var response = await gameSessionService.GetSessionAsync(sessionId);
        if (response == null)
        {
            return Results.NotFound();
        }

        return Results.Ok(response);
    }

    public static async Task<IResult> GetActiveSessions(
        IGameSessionService gameSessionService,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 20)
    {
        // Validate pagination parameters
        page = Math.Max(1, page);
        pageSize = Math.Max(1, Math.Min(100, pageSize));

        var response = await gameSessionService.GetActiveSessionsAsync(page, pageSize);
        return Results.Ok(response);
    }

    public static async Task<IResult> GetUserSessions(
        IGameSessionService gameSessionService,
        ClaimsPrincipal user,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 20)
    {
        var userId = user.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(userId))
        {
            return Results.Unauthorized();
        }

        // Validate pagination parameters
        page = Math.Max(1, page);
        pageSize = Math.Max(1, Math.Min(100, pageSize));

        var response = await gameSessionService.GetUserSessionsAsync(userId, page, pageSize);
        return Results.Ok(response);
    }
}