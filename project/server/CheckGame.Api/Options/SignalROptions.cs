namespace CheckGame.Api.Options;

public class SignalROptions
{
    public const string SectionName = "SignalR";

    public bool EnableDetailedErrors { get; set; } = false;
    public TimeSpan KeepAliveInterval { get; set; } = TimeSpan.FromSeconds(15);
    public TimeSpan ClientTimeoutInterval { get; set; } = TimeSpan.FromSeconds(60);
    public TimeSpan HandshakeTimeout { get; set; } = TimeSpan.FromSeconds(15);
    public int MaximumReceiveMessageSize { get; set; } = 32 * 1024; // 32KB
}