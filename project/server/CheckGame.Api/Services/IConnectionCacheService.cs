namespace CheckGame.Api.Services;

/// <summary>
/// Service for managing SignalR connection mappings in Redis cache
/// </summary>
public interface IConnectionCacheService
{
    /// <summary>
    /// Adds a SignalR connection ID for a user
    /// </summary>
    /// <param name="userId">The authenticated user ID</param>
    /// <param name="connectionId">The SignalR connection ID</param>
    Task AddUserConnectionAsync(string userId, string connectionId);

    /// <summary>
    /// Removes a specific connection ID for a user
    /// </summary>
    /// <param name="userId">The authenticated user ID</param>
    /// <param name="connectionId">The SignalR connection ID to remove</param>
    Task RemoveConnectionAsync(string userId, string connectionId);

    /// <summary>
    /// Gets all connection IDs for a specific user
    /// </summary>
    /// <param name="userId">The authenticated user ID</param>
    /// <returns>List of connection IDs for the user</returns>
    Task<List<string>> GetConnectionsAsync(string userId);
}