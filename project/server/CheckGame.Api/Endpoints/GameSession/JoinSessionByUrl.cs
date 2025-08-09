using CheckGame.Api.Contracts.Requests;
using CheckGame.Api.Services;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace CheckGame.Api.Endpoints.GameSession;

public partial class GameSessions
{
    // GET endpoint for URL-based joining (e.g., clicking a shared link)
    public static async Task<IResult> JoinSessionByUrl(
        [FromRoute] string sessionId,
        [FromQuery] string? playerName,
        IGameSessionService gameSessionService,
        ClaimsPrincipal? user)
    {
        if (string.IsNullOrEmpty(sessionId))
        {
            return Results.BadRequest("Session ID is required");
        }

        // Get user ID if authenticated, otherwise null for anonymous users
        var userId = user?.FindFirst(ClaimTypes.NameIdentifier)?.Value;

        // Create request object for the service
        var request = new JoinGameSessionRequest(sessionId, playerName);

        var response = await gameSessionService.JoinSessionAsync(userId, request);
        if (response == null)
        {
            return Results.BadRequest("Cannot join session. Session might be full, not found, or already started.");
        }

        return Results.Ok(response);
    }
}