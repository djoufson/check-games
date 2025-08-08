namespace CheckGame.Api.Endpoints.Auth;
public class Auth
{
    public static async Task<IResult> Register()
    {
        await Task.CompletedTask;
        return Results.Ok();
    }
}
