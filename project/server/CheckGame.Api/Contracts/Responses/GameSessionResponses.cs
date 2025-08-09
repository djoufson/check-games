using CheckGame.Api.Persistence.Models;

namespace CheckGame.Api.Contracts.Responses;

public readonly record struct GameSessionResponse(
    string Id,
    string Name,
    int MaxPlayers,
    int CurrentPlayerCount,
    GameSessionStatus Status,
    string[] Players,
    string CreatedByUserId,
    string? CreatedByUserName,
    DateTime CreatedAt,
    DateTime? StartedAt,
    DateTime? EndedAt,
    bool CanJoin,
    bool IsFull);

public readonly record struct GameSessionListResponse(
    GameSessionResponse[] Sessions,
    int TotalCount,
    int Page,
    int PageSize);

public readonly record struct JoinSessionResponse(
    string SessionId,
    string AssignedPlayerName,
    GameSessionResponse Session);