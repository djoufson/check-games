using CheckGame.Api.Contracts.Requests;
using CheckGame.Api.Services;
using FluentValidation;
using Microsoft.AspNetCore.Mvc;

namespace CheckGame.Api.Endpoints.GameSession;

public partial class GameSessions
{
    public static async Task<IResult> LeaveSession(
        [FromBody] LeaveGameSessionRequest request,
        [FromQuery] string playerName,
        IGameSessionService gameSessionService,
        IValidator<LeaveGameSessionRequest> validator)
    {
        await validator.ValidateAndThrowAsync(request);

        if (string.IsNullOrEmpty(playerName))
        {
            return Results.BadRequest("Player name is required");
        }

        var success = await gameSessionService.LeaveSessionAsync(request.SessionId, playerName);
        if (!success)
        {
            return Results.BadRequest("Could not leave session. Session might not exist or player not found.");
        }

        return Results.Ok();
    }
}