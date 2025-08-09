using CheckGame.Api.Contracts.Responses;
using CheckGame.Api.Persistence.Models;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace CheckGame.Api.Endpoints.Auth;
public partial class Auth
{
    public static async Task<IResult> Me(
        HttpContext httpContext,
        UserManager<User> userManager)
    {
        var userId = httpContext.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(userId))
        {
            return Results.Unauthorized();
        }

        var user = await userManager.FindByIdAsync(userId);
        if (user == null)
        {
            return Results.NotFound();
        }

        var response = new UserResponse(
            user.Id,
            user.UserName ?? string.Empty,
            user.Email ?? string.Empty,
            user.FirstName,
            user.LastName);

        return Results.Ok(response);
    }
}