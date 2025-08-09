using CheckGame.Api.Options;
using Microsoft.Extensions.Caching.Distributed;
using Microsoft.Extensions.Options;
using System.Text.Json;

namespace CheckGame.Api.Services.Impl;

public class ConnectionCacheService(
    IDistributedCache cache,
    ILogger<ConnectionCacheService> logger,
    IOptions<RedisCacheOptions> redisCacheOptions) : IConnectionCacheService
{
    private readonly IDistributedCache _cache = cache;
    private readonly ILogger<ConnectionCacheService> _logger = logger;
    private readonly RedisCacheOptions _redisCacheOptions = redisCacheOptions.Value;

    public async Task AddUserConnectionAsync(string userId, string connectionId)
    {
        try
        {
            var userConnectionsKey = _redisCacheOptions.UserConnectionsKeyPrefix + userId;

            // Get existing connections for the user
            var existingConnections = await GetConnectionsAsync(userId);

            // Add new connection if not already present
            if (!existingConnections.Contains(connectionId))
            {
                existingConnections.Add(connectionId);
                var serializedConnections = JsonSerializer.Serialize(existingConnections);

                var options = new DistributedCacheEntryOptions();
                options.SetSlidingExpiration(_redisCacheOptions.ConnectionSlidingExpiration);

                await _cache.SetStringAsync(userConnectionsKey, serializedConnections, options);
            }

            _logger.LogDebug("Added connection {ConnectionId} for user {UserId}", connectionId, userId);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error adding connection {ConnectionId} for user {UserId}", connectionId, userId);
        }
    }

    public async Task RemoveConnectionAsync(string userId, string connectionId)
    {
        try
        {
            var userConnectionsKey = _redisCacheOptions.UserConnectionsKeyPrefix + userId;

            // Get existing connections for the user
            var existingConnections = await GetConnectionsAsync(userId);

            // Remove the connection
            if (existingConnections.Remove(connectionId))
            {
                if (existingConnections.Count > 0)
                {
                    // Update the list with remaining connections
                    var serializedConnections = JsonSerializer.Serialize(existingConnections);
                    var options = new DistributedCacheEntryOptions();
                    options.SetSlidingExpiration(_redisCacheOptions.ConnectionSlidingExpiration);
                    await _cache.SetStringAsync(userConnectionsKey, serializedConnections, options);
                }
                else
                {
                    // Remove the key if no connections left
                    await _cache.RemoveAsync(userConnectionsKey);
                }
            }

            _logger.LogDebug("Removed connection {ConnectionId} for user {UserId}", connectionId, userId);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error removing connection {ConnectionId} for user {UserId}", connectionId, userId);
        }
    }

    public async Task<List<string>> GetConnectionsAsync(string userId)
    {
        try
        {
            var userConnectionsKey = _redisCacheOptions.UserConnectionsKeyPrefix + userId;
            var serializedConnections = await _cache.GetStringAsync(userConnectionsKey);

            if (string.IsNullOrEmpty(serializedConnections))
            {
                return [];
            }

            return JsonSerializer.Deserialize<List<string>>(serializedConnections) ?? [];
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting connections for user {UserId}", userId);
            return [];
        }
    }
}