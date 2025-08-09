using FluentValidation;

namespace CheckGame.Api.Contracts.Requests;

public readonly record struct CreateGameSessionRequest(
    string? Description,
    int MaxPlayersLimit);

public readonly record struct JoinGameSessionRequest(
    string? PlayerName);

public readonly record struct LeaveGameSessionRequest(
    string SessionId);

// Validators
public class CreateGameSessionRequestValidator : AbstractValidator<CreateGameSessionRequest>
{
    public CreateGameSessionRequestValidator()
    {
        RuleFor(x => x.Description)
            .MaximumLength(500).WithMessage("Description cannot exceed 500 characters");
    }
}

public class JoinGameSessionRequestValidator : AbstractValidator<JoinGameSessionRequest>
{
    public JoinGameSessionRequestValidator()
    {
        RuleFor(x => x.PlayerName)
            .Length(1, 50).When(x => !string.IsNullOrEmpty(x.PlayerName))
            .WithMessage("Player name must be between 1 and 50 characters")
            .Matches("^[a-zA-Z0-9\\s\\-_']+$").When(x => !string.IsNullOrEmpty(x.PlayerName))
            .WithMessage("Player name can only contain letters, numbers, spaces, hyphens, underscores, and apostrophes");
    }
}

public class LeaveGameSessionRequestValidator : AbstractValidator<LeaveGameSessionRequest>
{
    public LeaveGameSessionRequestValidator()
    {
        RuleFor(x => x.SessionId)
            .NotEmpty().WithMessage("Session ID is required");
    }
}