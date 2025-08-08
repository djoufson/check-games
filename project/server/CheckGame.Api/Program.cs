using CheckGame.Api.Endpoints.Auth;
using CheckGame.Api.Extensions;

var builder = WebApplication.CreateBuilder(args);

builder.Services.RegisterServices(builder.Configuration);

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseHttpsRedirection();

app.UseAuthentication();

app.UseAuthorization();

app
    .MapGroup("api")
    .MapAuthEndpoints();

app.Run();
