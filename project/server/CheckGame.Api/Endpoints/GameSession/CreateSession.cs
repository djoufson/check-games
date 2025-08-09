using CheckGame.Api.Contracts.Requests;
using CheckGame.Api.Services;
using FluentValidation;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace CheckGame.Api.Endpoints.GameSession;

public partial class GameSessions
{
    public static async Task<IResult> CreateSession(
        [FromBody] CreateGameSessionRequest request,
        IGameSessionService gameSessionService,
        IValidator<CreateGameSessionRequest> validator,
        ClaimsPrincipal user)
    {
        await validator.ValidateAndThrowAsync(request);
        
        var userId = user.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(userId))
        {
            return Results.Unauthorized();
        }

        var response = await gameSessionService.CreateSessionAsync(userId, request);
        return Results.Created($"/api/game-sessions/{response.Id}", response);
    }
}