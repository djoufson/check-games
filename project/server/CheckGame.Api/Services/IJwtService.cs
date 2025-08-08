using CheckGame.Api.Contracts.Responses;
using CheckGame.Api.Persistence.Models;
using System.Security.Claims;

namespace CheckGame.Api.Services;

public interface IJwtService
{
    JwtResponse GenerateJwtToken(User user);
    string GenerateRefreshToken();
    ClaimsPrincipal? GetPrincipalFromExpiredToken(string token);
}
