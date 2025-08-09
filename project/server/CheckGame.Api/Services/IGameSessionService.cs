using CheckGame.Api.Contracts.Requests;
using CheckGame.Api.Contracts.Responses;
using CheckGame.Api.Persistence.Models;

namespace CheckGame.Api.Services;

public interface IGameSessionService
{
    Task<CreateSessionResponse> CreateSessionAsync(string createdByUserId, CreateGameSessionRequest request);
    Task<JoinSessionResponse?> JoinSessionAsync(string? userId, JoinGameSessionRequest request);
    Task<bool> LeaveSessionAsync(string sessionId, string playerName);
    Task<GameSessionResponse?> GetSessionAsync(string sessionId);
    Task<GameSessionListResponse> GetActiveSessionsAsync(int page = 1, int pageSize = 20);
    Task<GameSessionListResponse> GetUserSessionsAsync(string userId, int page = 1, int pageSize = 20);
    Task<bool> StartGameAsync(string sessionId, string userId);
    Task<bool> EndGameAsync(string sessionId, string userId);
}