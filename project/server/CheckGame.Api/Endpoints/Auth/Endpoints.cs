namespace CheckGame.Api.Endpoints.Auth;
public static class Endpoints
{
    public static IEndpointRouteBuilder MapAuthEndpoints(this IEndpointRouteBuilder route)
    {
        var group = route.MapGroup("/auth");
        group.MapPost("register", Auth.Register);
        group.MapPost("login", Auth.Login);
        group.MapPost("refresh-token", Auth.RefreshToken);
        group.MapGet("me", Auth.Me).RequireAuthorization();
        return route;
    }
}
