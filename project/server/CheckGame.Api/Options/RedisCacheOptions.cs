namespace CheckGame.Api.Options;

public class RedisCacheOptions
{
    public const string SectionName = "RedisCache";

    /// <summary>
    /// Sliding expiration time for user connection cache entries
    /// </summary>
    public TimeSpan ConnectionSlidingExpiration { get; init; } = TimeSpan.FromHours(2);

    /// <summary>
    /// Redis connection string (can also be configured via ConnectionStrings:Redis)
    /// </summary>
    public string? ConnectionString { get; init; }

    /// <summary>
    /// Redis instance name for the distributed cache
    /// </summary>
    public string InstanceName { get; init; } = "CheckGameApi";

    /// <summary>
    /// Key prefix for user connections
    /// </summary>
    public string UserConnectionsKeyPrefix { get; init; } = "user_connections:";
}