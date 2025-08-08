using CheckGame.Api.Middleware;
using CheckGame.Api.Options;
using CheckGame.Api.Persistence;
using CheckGame.Api.Persistence.Models;
using CheckGame.Api.Services;
using CheckGame.Api.Services.Impl;
using FluentValidation;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.IdentityModel.Tokens;
using System.Text;

namespace CheckGame.Api.Extensions;

public static class Extensions
{
    public static IServiceCollection RegisterServices(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddOpenApi();

        // Configure JWT options
        services.Configure<JwtOptions>(configuration.GetSection(JwtOptions.SectionName));
        var jwtOptions = configuration.GetSection(JwtOptions.SectionName).Get<JwtOptions>() ?? new JwtOptions();

        // JWT Authentication Configuration
        services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
            .AddJwtBearer(options =>
            {
                options.TokenValidationParameters = new TokenValidationParameters
                {
                    ValidateIssuer = true,
                    ValidateAudience = true,
                    ValidateLifetime = true,
                    ValidateIssuerSigningKey = true,
                    ValidIssuer = jwtOptions.Issuer,
                    ValidAudience = jwtOptions.Audience,
                    IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtOptions.Key)),
                    ClockSkew = TimeSpan.Zero
                };
            });

        services.AddAuthorization();
        services.AddIdentityCore<User>()
            .AddSignInManager()
            .AddEntityFrameworkStores<AppDbContext>();

        services.AddNpgsql<AppDbContext>(configuration.GetConnectionString("PgSql"));
        services.AddValidatorsFromAssembly(typeof(Program).Assembly, includeInternalTypes: true);

        // Register custom services
        services.AddScoped<IJwtService, JwtService>();
        
        // Register exception handling
        services.AddExceptionHandler<GlobalExceptionHandler>();
        services.AddProblemDetails();

        return services;
    }
}
