using CheckGame.Api.Contracts.Requests;
using CheckGame.Api.Services;
using FluentValidation;
using Microsoft.AspNetCore.Mvc;

namespace CheckGame.Api.Endpoints.Auth;

public partial class Auth
{
    public static async Task<IResult> RefreshToken(
        [FromBody] RefreshTokenRequest request,
        IJwtService jwtService,
        IValidator<RefreshTokenRequest> validator)
    {
        await validator.ValidateAndThrowAsync(request);

        var jwtResponse = await jwtService.RefreshTokenAsync(request.AccessToken, request.RefreshToken);
        if (jwtResponse == null)
        {
            return Results.Unauthorized();
        }

        return Results.Ok(jwtResponse);
    }
}