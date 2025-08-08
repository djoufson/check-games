using CheckGame.Api.Contracts.Requests;
using CheckGame.Api.Persistence.Models;
using CheckGame.Api.Services;
using FluentValidation;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;

namespace CheckGame.Api.Endpoints.Auth;
public partial class Auth
{
    public static async Task<IResult> Login(
        [FromBody] LoginRequest request,
        UserManager<User> userManager,
        SignInManager<User> signInManager,
        IJwtService jwtService,
        IValidator<LoginRequest> validator)
    {
        await validator.ValidateAndThrowAsync(request);

        var user = await userManager.FindByEmailAsync(request.Email);
        if (user == null)
        {
            return Results.Unauthorized();
        }

        var result = await signInManager.CheckPasswordSignInAsync(user, request.Password, lockoutOnFailure: false);
        if (!result.Succeeded)
        {
            return Results.Unauthorized();
        }

        var jwtResponse = jwtService.GenerateJwtToken(user);
        return Results.Ok(jwtResponse);
    }
}