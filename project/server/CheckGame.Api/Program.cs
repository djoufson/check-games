using CheckGame.Api.Endpoints.Auth;
using CheckGame.Api.Extensions;
using CheckGame.Api.Hubs;

var builder = WebApplication.CreateBuilder(args);

builder.Services.RegisterServices(builder.Configuration);

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseExceptionHandler();
app.UseHttpsRedirection();

app.UseAuthentication();
app.UseAuthorization();

app
    .MapGroup("api")
    .MapAuthEndpoints();

// Map SignalR Hub
app.MapHub<GameHub>("/gamehub");

app.Run();
