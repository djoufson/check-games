namespace CheckGame.Api.Contracts.Responses;

public readonly record struct UserResponse(
    string Id,
    string UserName,
    string Email,
    string FirstName,
    string LastName);