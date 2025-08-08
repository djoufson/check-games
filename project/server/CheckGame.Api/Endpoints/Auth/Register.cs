using CheckGame.Api.Contracts.Requests;
using CheckGame.Api.Persistence;
using CheckGame.Api.Persistence.Models;
using FluentValidation;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace CheckGame.Api.Endpoints.Auth;

public class Auth
{
    public static async Task<IResult> Register(
        [FromBody] RegisterRequest request,
        UserManager<User> userManager,
        AppDbContext dbContext,
        IValidator<RegisterRequest> validator)
    {
        await validator.ValidateAndThrowAsync(request);
        if (await dbContext.Users.AnyAsync(u => u.Email == request.Email))
        {
            return Results.Conflict();
        }

        var user = User.Create(request.UserName, request.FirstName, request.LastName, request.Email);
        var result = await userManager.CreateAsync(user, request.Password);
        if (!result.Succeeded)
        {
            return Results.BadRequest();
        }

        return Results.Ok(user.Id);
    }
}
