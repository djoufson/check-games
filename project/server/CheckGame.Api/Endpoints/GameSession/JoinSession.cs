using CheckGame.Api.Contracts.Requests;
using CheckGame.Api.Services;
using FluentValidation;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace CheckGame.Api.Endpoints.GameSession;

public partial class GameSessions
{
    public static async Task<IResult> JoinSession(
        [FromBody] JoinGameSessionRequest request,
        IGameSessionService gameSessionService,
        IValidator<JoinGameSessionRequest> validator,
        ClaimsPrincipal? user)
    {
        await validator.ValidateAndThrowAsync(request);

        // Get user ID if authenticated, otherwise null for anonymous users
        var userId = user?.FindFirst(ClaimTypes.NameIdentifier)?.Value;

        var response = await gameSessionService.JoinSessionAsync(userId, request);
        if (response == null)
        {
            return Results.BadRequest("Cannot join session. Session might be full, not found, or already started.");
        }

        return Results.Ok(response);
    }
}