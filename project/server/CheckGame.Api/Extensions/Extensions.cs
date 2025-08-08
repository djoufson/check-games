using CheckGame.Api.Persistence;
using CheckGame.Api.Persistence.Models;
using FluentValidation;
using Microsoft.Extensions.DependencyInjection;

namespace CheckGame.Api.Extensions;

public static class Extensions
{
    public static IServiceCollection RegisterServices(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddOpenApi();
        services.AddAuthentication();
        services.AddAuthorization();
        services.AddIdentityCore<User>()
            .AddEntityFrameworkStores<AppDbContext>();
        services.AddNpgsql<AppDbContext>(configuration.GetConnectionString("PgSql"));
        services.AddValidatorsFromAssembly(typeof(Program).Assembly, includeInternalTypes: true);
        return services;
    }
}
