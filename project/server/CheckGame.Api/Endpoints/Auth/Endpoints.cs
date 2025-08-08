namespace CheckGame.Api.Endpoints.Auth;
public static class Endpoints
{
    public static IEndpointRouteBuilder MapAuthEndpoints(this IEndpointRouteBuilder route)
    {
        var group = route.MapGroup("/auth");
        group.MapPost("register", Auth.Register);
        group.MapPost("login", Auth.Login);
        return route;
    }
}
