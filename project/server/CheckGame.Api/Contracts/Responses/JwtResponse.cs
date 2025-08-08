namespace CheckGame.Api.Contracts.Responses;

public readonly record struct JwtResponse(
    string AccessToken,
    string RefreshToken,
    DateTime ExpiresAt);