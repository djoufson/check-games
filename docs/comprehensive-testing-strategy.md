# Comprehensive Testing Strategy

## Overview
Extensive testing strategy for the Check-Game .NET 8 API with high code coverage, performance testing, and real-time SignalR testing. Target: 90%+ code coverage with automated testing in CI/CD pipeline.

## Testing Pyramid

```
                    E2E Tests (5%)
                 Integration Tests (25%)
               Unit Tests (70%)
```

## Testing Stack

### Core Testing Frameworks
- **Unit Testing**: xUnit with NSubstitute and FluentAssertions
- **Integration Testing**: ASP.NET Core TestServer with Testcontainers
- **Performance Testing**: NBomber for load testing
- **SignalR Testing**: Microsoft.AspNetCore.SignalR.Client.Testing
- **Database Testing**: Entity Framework InMemory + Testcontainers PostgreSQL
- **E2E Testing**: Playwright for Flutter web client testing

## Unit Testing

### Test Project Structure
```
CheckGame.Tests/
├── Unit/
│   ├── Core/
│   │   ├── Services/
│   │   │   ├── GameEngineTests.cs
│   │   │   ├── GameStateServiceTests.cs
│   │   │   └── SessionServiceTests.cs
│   │   ├── Models/
│   │   │   └── GameStateTests.cs
│   │   └── Utilities/
│   │       └── CardDeckTests.cs
│   ├── Api/
│   │   ├── Controllers/
│   │   ├── Hubs/
│   │   │   └── GameHubTests.cs
│   │   └── Middleware/
│   └── Infrastructure/
│       ├── Repositories/
│       └── Services/
├── Integration/
│   ├── Api/
│   │   ├── AuthEndpointsTests.cs
│   │   ├── SessionEndpointsTests.cs
│   │   └── GameEndpointsTests.cs
│   ├── Hubs/
│   │   └── GameHubIntegrationTests.cs
│   └── Database/
│       └── RepositoryTests.cs
├── Performance/
│   ├── ApiLoadTests.cs
│   ├── SignalRLoadTests.cs
│   └── GameEnginePerformanceTests.cs
├── E2E/
│   └── GameFlowTests.cs
└── Fixtures/
    ├── TestFixtures.cs
    └── TestData.cs
```

### Unit Test Examples

#### Game Engine Tests
```csharp
public class GameEngineTests
{
    private readonly GameEngine _gameEngine;
    private readonly ILogger<GameEngine> _mockLogger;

    public GameEngineTests()
    {
        _mockLogger = Substitute.For<ILogger<GameEngine>>();
        _gameEngine = new GameEngine(_mockLogger);
    }

    [Theory]
    [InlineData(CardSuit.Hearts, CardRank.Two, CardSuit.Hearts, CardRank.Five, true)] // Same suit
    [InlineData(CardSuit.Hearts, CardRank.Two, CardSuit.Spades, CardRank.Two, true)] // Same rank
    [InlineData(CardSuit.Hearts, CardRank.Two, CardSuit.Spades, CardRank.Five, false)] // Different suit and rank
    [InlineData(CardSuit.Hearts, CardRank.Two, CardSuit.Spades, CardRank.Jack, true)] // Jack can be played on anything
    [InlineData(CardSuit.Hearts, CardRank.Two, CardSuit.Spades, CardRank.Two, true)] // Transparent 2
    public void IsValidPlay_ShouldValidateCardPlays_Correctly(
        CardSuit currentSuit, CardRank currentRank,
        CardSuit playedSuit, CardRank playedRank,
        bool expectedResult)
    {
        // Arrange
        var currentCard = new Card(currentSuit, currentRank, 1);
        var playedCard = new Card(playedSuit, playedRank, 2);

        // Act
        var result = _gameEngine.IsValidPlay(currentCard, playedCard, isUnderAttack: false);

        // Assert
        result.Should().Be(expectedResult);
    }

    [Fact]
    public void ProcessCardPlay_ShouldRemoveCardFromPlayerHand_WhenValidPlay()
    {
        // Arrange
        var gameState = TestFixtures.CreateGameState();
        var playerId = gameState.Players[0].Id;
        var cardToPlay = gameState.Players[0].Hand[0];

        // Act
        var result = _gameEngine.ProcessCardPlay(gameState, playerId, cardToPlay, null);

        // Assert
        result.IsSuccess.Should().BeTrue();
        result.NewGameState!.Players[0].Hand.Should().NotContain(cardToPlay);
        result.NewGameState.CurrentCard.Should().Be(cardToPlay);
        result.NewGameState.Version.Should().Be(gameState.Version + 1);
    }

    [Fact]
    public void ProcessCardPlay_ShouldApplySevenEffect_WhenSevenPlayed()
    {
        // Arrange
        var gameState = TestFixtures.CreateGameState();
        var playerId = gameState.Players[0].Id;
        var sevenCard = new Card(CardSuit.Hearts, CardRank.Seven, 99);
        
        // Add seven to player's hand
        var playerHand = gameState.Players[0].Hand.ToList();
        playerHand[0] = sevenCard;
        var updatedPlayer = gameState.Players[0] with { Hand = playerHand.ToArray() };
        var updatedPlayers = gameState.Players.ToList();
        updatedPlayers[0] = updatedPlayer;
        gameState = gameState with { Players = updatedPlayers };

        // Act
        var result = _gameEngine.ProcessCardPlay(gameState, playerId, sevenCard, null);

        // Assert
        result.IsSuccess.Should().BeTrue();
        result.NewGameState!.AttackStack.Should().Be(2);
    }

    [Fact]
    public void ProcessCardPlay_ShouldEliminatePlayer_WhenLastCardPlayed()
    {
        // Arrange
        var gameState = TestFixtures.CreateGameStateWithOneCard();
        var playerId = gameState.Players[0].Id;
        var lastCard = gameState.Players[0].Hand.First(c => !c.IsEmpty);

        // Act
        var result = _gameEngine.ProcessCardPlay(gameState, playerId, lastCard, null);

        // Assert
        result.IsSuccess.Should().BeTrue();
        result.NewGameState!.Players[0].IsEliminated.Should().BeTrue();
        result.NewGameState.Players[0].EliminatedAt.Should().BeCloseTo(DateTime.UtcNow, TimeSpan.FromSeconds(1));
    }

    [Theory]
    [InlineData(CardRank.Seven, 2)]
    [InlineData(CardRank.Joker, 4)]
    public void CalculateAttackStackIncrease_ShouldReturnCorrectValue_ForAttackCards(CardRank rank, int expectedIncrease)
    {
        // Arrange & Act
        var increase = _gameEngine.CalculateAttackStackIncrease(rank);

        // Assert
        increase.Should().Be(expectedIncrease);
    }
}
```

#### Game State Service Tests
```csharp
public class GameStateServiceTests
{
    private readonly IDatabase _mockDatabase;
    private readonly IGameEngine _mockGameEngine;
    private readonly ILogger<RedisGameStateService> _mockLogger;
    private readonly IMemoryPool<byte> _memoryPool;
    private readonly RedisGameStateService _gameStateService;

    public GameStateServiceTests()
    {
        _mockDatabase = Substitute.For<IDatabase>();
        _mockGameEngine = Substitute.For<IGameEngine>();
        _mockLogger = Substitute.For<ILogger<RedisGameStateService>>();
        _memoryPool = MemoryPool<byte>.Shared;

        var mockConnectionMultiplexer = Substitute.For<IConnectionMultiplexer>();
        mockConnectionMultiplexer.GetDatabase(Arg.Any<int>(), Arg.Any<object>()).Returns(_mockDatabase);

        _gameStateService = new RedisGameStateService(
            mockConnectionMultiplexer, 
            _mockGameEngine, 
            _mockLogger, 
            _memoryPool);
    }

    [Fact]
    public async Task GetGameStateAsync_ShouldReturnNull_WhenGameNotFound()
    {
        // Arrange
        var gameId = Guid.NewGuid();
        _mockDatabase.HashGetAllAsync(Arg.Any<RedisKey>())
                    .Returns(Array.Empty<HashEntry>());

        // Act
        var result = await _gameStateService.GetGameStateAsync(gameId);

        // Assert
        result.Should().BeNull();
    }

    [Fact]
    public async Task SetGameStateAsync_ShouldReturnTrue_WhenSuccessfullySet()
    {
        // Arrange
        var gameState = TestFixtures.CreateGameState();
        _mockDatabase.HashSetAsync(Arg.Any<RedisKey>(), Arg.Any<HashEntry[]>())
                    .Returns(Task.CompletedTask);
        _mockDatabase.KeyExpireAsync(Arg.Any<RedisKey>(), Arg.Any<TimeSpan>())
                    .Returns(Task.FromResult(true));

        // Act
        var result = await _gameStateService.SetGameStateAsync(gameState);

        // Assert
        result.Should().BeTrue();
        await _mockDatabase.Received(1).HashSetAsync(Arg.Any<RedisKey>(), Arg.Any<HashEntry[]>());
    }

    [Fact]
    public async Task PlayCardAsync_ShouldReturnFailure_WhenGameLocked()
    {
        // Arrange
        var sessionId = Guid.NewGuid();
        var playerId = Guid.NewGuid();
        var card = new Card(CardSuit.Hearts, CardRank.Two, 1);

        _mockDatabase.StringSetAsync(Arg.Any<RedisKey>(), Arg.Any<RedisValue>(), Arg.Any<TimeSpan>(), When.NotExists)
                    .Returns(Task.FromResult(false)); // Lock acquisition fails

        // Act
        var result = await _gameStateService.PlayCardAsync(sessionId, playerId, card, null);

        // Assert
        result.IsSuccess.Should().BeFalse();
        result.Error.Should().Be("GAME_LOCKED");
    }
}
```

#### SignalR Hub Tests
```csharp
public class GameHubTests
{
    private readonly IGameStateService _mockGameStateService;
    private readonly ISessionService _mockSessionService;
    private readonly ILogger<GameHub> _mockLogger;
    private readonly Mock<HubCallerContext> _mockContext;
    private readonly Mock<IClientProxy> _mockClientProxy;
    private readonly Mock<IHubCallerClients<IGameClient>> _mockClients;
    private readonly GameHub _gameHub;

    public GameHubTests()
    {
        _mockGameStateService = Substitute.For<IGameStateService>();
        _mockSessionService = Substitute.For<ISessionService>();
        _mockLogger = Substitute.For<ILogger<GameHub>>();
        _mockContext = new Mock<HubCallerContext>();
        _mockClientProxy = new Mock<IClientProxy>();
        _mockClients = new Mock<IHubCallerClients<IGameClient>>();

        _gameHub = new GameHub(_mockGameStateService, _mockSessionService, _mockLogger);
        
        // Setup hub context
        _gameHub.Context = _mockContext.Object;
        _gameHub.Clients = _mockClients.Object;
    }

    [Fact]
    public async Task PlayCard_ShouldBroadcastGameStateUpdate_WhenSuccessful()
    {
        // Arrange
        var request = new PlayCardRequest(new CardDto("1", CardSuit.Hearts, CardRank.Two, CardColor.Red), null);
        var gameState = TestFixtures.CreateGameStateDto();
        var result = GameActionResult.Success(TestFixtures.CreateGameState());

        SetupHubContext(Guid.NewGuid(), Guid.NewGuid());
        
        _mockGameStateService.PlayCardAsync(Arg.Any<Guid>(), Arg.Any<Guid>(), Arg.Any<Card>(), Arg.Any<CardSuit?>())
                            .Returns(result);

        var mockGroupClient = new Mock<IGameClient>();
        _mockClients.Setup(x => x.Group(It.IsAny<string>())).Returns(mockGroupClient.Object);

        // Act
        await _gameHub.PlayCard(request);

        // Assert
        mockGroupClient.Verify(x => x.GameStateUpdate(It.IsAny<GameStateDto>()), Times.Once);
    }

    [Fact]
    public async Task PlayCard_ShouldSendError_WhenActionFails()
    {
        // Arrange
        var request = new PlayCardRequest(new CardDto("1", CardSuit.Hearts, CardRank.Two, CardColor.Red), null);
        var result = GameActionResult.Failure("INVALID_MOVE", "Invalid card play");

        SetupHubContext(Guid.NewGuid(), Guid.NewGuid());
        
        _mockGameStateService.PlayCardAsync(Arg.Any<Guid>(), Arg.Any<Guid>(), Arg.Any<Card>(), Arg.Any<CardSuit?>())
                            .Returns(result);

        var mockCallerClient = new Mock<IGameClient>();
        _mockClients.Setup(x => x.Caller).Returns(mockCallerClient.Object);

        // Act
        await _gameHub.PlayCard(request);

        // Assert
        mockCallerClient.Verify(x => x.ActionError("INVALID_MOVE", "Invalid card play"), Times.Once);
    }

    private void SetupHubContext(Guid userId, Guid sessionId)
    {
        var claims = new[]
        {
            new Claim(ClaimTypes.NameIdentifier, userId.ToString())
        };
        var identity = new ClaimsIdentity(claims);
        var user = new ClaimsPrincipal(identity);

        var queryCollection = new QueryCollection(new Dictionary<string, StringValues>
        {
            ["sessionId"] = sessionId.ToString()
        });

        var mockHttpContext = new Mock<HttpContext>();
        var mockRequest = new Mock<HttpRequest>();
        
        mockRequest.Setup(x => x.Query).Returns(queryCollection);
        mockHttpContext.Setup(x => x.Request).Returns(mockRequest.Object);

        _mockContext.Setup(x => x.User).Returns(user);
        _mockContext.Setup(x => x.GetHttpContext()).Returns(mockHttpContext.Object);
    }
}
```

## Integration Testing

### Test Server Setup
```csharp
public class CheckGameWebApplicationFactory : WebApplicationFactory<Program>
{
    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        builder.ConfigureTestServices(services =>
        {
            // Remove the real database context
            services.RemoveAll(typeof(DbContextOptions<CheckGameDbContext>));
            services.RemoveAll(typeof(CheckGameDbContext));

            // Add in-memory database for testing
            services.AddDbContext<CheckGameDbContext>(options =>
            {
                options.UseInMemoryDatabase("TestDb");
            });

            // Replace Redis with mock
            services.RemoveAll(typeof(IConnectionMultiplexer));
            services.AddSingleton<IConnectionMultiplexer>(provider =>
            {
                var mock = Substitute.For<IConnectionMultiplexer>();
                var database = Substitute.For<IDatabase>();
                mock.GetDatabase(Arg.Any<int>(), Arg.Any<object>()).Returns(database);
                return mock;
            });

            // Override configuration
            services.Configure<JwtSettings>(options =>
            {
                options.SecretKey = "test-secret-key-that-is-long-enough-for-jwt";
                options.Issuer = "test-issuer";
                options.Audience = "test-audience";
                options.ExpiryInHours = 1;
            });
        });

        builder.UseEnvironment("Testing");
    }
}

[Collection("Integration Tests")]
public class AuthEndpointsTests : IClassFixture<CheckGameWebApplicationFactory>
{
    private readonly CheckGameWebApplicationFactory _factory;
    private readonly HttpClient _client;

    public AuthEndpointsTests(CheckGameWebApplicationFactory factory)
    {
        _factory = factory;
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task Register_ShouldReturnCreated_WhenValidInput()
    {
        // Arrange
        var request = new RegisterRequest(
            Username: "testuser",
            Email: "test@example.com",
            Password: "TestPassword123!",
            ConfirmPassword: "TestPassword123!"
        );

        // Act
        var response = await _client.PostAsJsonAsync("/api/v1/auth/register", request);

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.Created);
        var content = await response.Content.ReadFromJsonAsync<ApiResponse<AuthResponse>>();
        content.Should().NotBeNull();
        content!.Success.Should().BeTrue();
        content.Data!.User.Username.Should().Be("testuser");
        content.Data.User.Email.Should().Be("test@example.com");
        content.Data.Tokens.AccessToken.Should().NotBeNullOrEmpty();
    }

    [Theory]
    [InlineData("", "test@example.com", "TestPassword123!", "TestPassword123!")] // Empty username
    [InlineData("testuser", "invalid-email", "TestPassword123!", "TestPassword123!")] // Invalid email
    [InlineData("testuser", "test@example.com", "weak", "weak")] // Weak password
    [InlineData("testuser", "test@example.com", "TestPassword123!", "DifferentPassword123!")] // Passwords don't match
    public async Task Register_ShouldReturnBadRequest_WhenInvalidInput(
        string username, string email, string password, string confirmPassword)
    {
        // Arrange
        var request = new RegisterRequest(username, email, password, confirmPassword);

        // Act
        var response = await _client.PostAsJsonAsync("/api/v1/auth/register", request);

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.BadRequest);
    }

    [Fact]
    public async Task Login_ShouldReturnOk_WhenValidCredentials()
    {
        // Arrange - First register a user
        await RegisterTestUser();

        var loginRequest = new LoginRequest(
            Email: "test@example.com",
            Password: "TestPassword123!"
        );

        // Act
        var response = await _client.PostAsJsonAsync("/api/v1/auth/login", loginRequest);

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var content = await response.Content.ReadFromJsonAsync<ApiResponse<AuthResponse>>();
        content!.Data!.Tokens.AccessToken.Should().NotBeNullOrEmpty();
    }

    private async Task RegisterTestUser()
    {
        var request = new RegisterRequest(
            Username: "testuser",
            Email: "test@example.com",
            Password: "TestPassword123!",
            ConfirmPassword: "TestPassword123!"
        );

        await _client.PostAsJsonAsync("/api/v1/auth/register", request);
    }
}
```

### SignalR Integration Tests
```csharp
[Collection("SignalR Integration Tests")]
public class GameHubIntegrationTests : IClassFixture<CheckGameWebApplicationFactory>
{
    private readonly CheckGameWebApplicationFactory _factory;

    public GameHubIntegrationTests(CheckGameWebApplicationFactory factory)
    {
        _factory = factory;
    }

    [Fact]
    public async Task ConnectToGameHub_ShouldEstablishConnection_WhenValidToken()
    {
        // Arrange
        using var scope = _factory.Services.CreateScope();
        var context = scope.ServiceProvider.GetRequiredService<CheckGameDbContext>();
        
        var user = await SeedTestUser(context);
        var session = await SeedTestSession(context, user.Id);
        var token = GenerateJwtToken(user.Id);

        // Act
        var connection = new HubConnectionBuilder()
            .WithUrl($"ws://localhost/gameHub?sessionId={session.Id}&access_token={token}", 
                options => options.HttpMessageHandlerFactory = _ => _factory.Server.CreateHandler())
            .Build();

        await connection.StartAsync();

        // Assert
        connection.State.Should().Be(HubConnectionState.Connected);

        // Cleanup
        await connection.StopAsync();
        await connection.DisposeAsync();
    }

    [Fact]
    public async Task PlayCard_ShouldBroadcastToAllPlayers_WhenValidMove()
    {
        // Arrange
        using var scope = _factory.Services.CreateScope();
        var context = scope.ServiceProvider.GetRequiredService<CheckGameDbContext>();
        
        var user1 = await SeedTestUser(context, "player1@test.com");
        var user2 = await SeedTestUser(context, "player2@test.com");
        var session = await SeedTestSession(context, user1.Id);
        
        var token1 = GenerateJwtToken(user1.Id);
        var token2 = GenerateJwtToken(user2.Id);

        // Create connections for both players
        var connection1 = CreateHubConnection(session.Id, token1);
        var connection2 = CreateHubConnection(session.Id, token2);

        var gameStateReceived = new TaskCompletionSource<GameStateDto>();
        
        connection2.On<GameStateDto>("GameStateUpdate", gameState =>
        {
            gameStateReceived.SetResult(gameState);
        });

        await connection1.StartAsync();
        await connection2.StartAsync();

        // Act - Player 1 plays a card
        var cardToPlay = new CardDto("1", CardSuit.Hearts, CardRank.Two, CardColor.Red);
        var request = new PlayCardRequest(cardToPlay, null);
        
        await connection1.InvokeAsync("PlayCard", request);

        // Assert - Player 2 should receive the game state update
        var receivedGameState = await gameStateReceived.Task.WaitAsync(TimeSpan.FromSeconds(5));
        receivedGameState.Should().NotBeNull();

        // Cleanup
        await connection1.StopAsync();
        await connection2.StopAsync();
        await connection1.DisposeAsync();
        await connection2.DisposeAsync();
    }

    private HubConnection CreateHubConnection(Guid sessionId, string token)
    {
        return new HubConnectionBuilder()
            .WithUrl($"ws://localhost/gameHub?sessionId={sessionId}&access_token={token}",
                options => options.HttpMessageHandlerFactory = _ => _factory.Server.CreateHandler())
            .Build();
    }

    private string GenerateJwtToken(Guid userId)
    {
        // Implementation to generate test JWT token
        var jwtSettings = _factory.Services.GetRequiredService<IOptions<JwtSettings>>().Value;
        var tokenService = new JwtTokenService(jwtSettings);
        return tokenService.GenerateAccessToken(userId.ToString(), "testuser", "test@example.com");
    }
}
```

## Performance Testing

### NBomber Load Tests
```csharp
public class ApiLoadTests
{
    [Fact]
    public void AuthEndpoints_ShouldHandleHighLoad()
    {
        var scenario = Scenario.Create("login_load_test", async context =>
        {
            using var httpClient = new HttpClient();
            httpClient.BaseAddress = new Uri("https://localhost:7001");

            var loginRequest = new LoginRequest(
                Email: $"testuser{context.ScenarioInfo.ThreadId}@example.com",
                Password: "TestPassword123!"
            );

            var response = await httpClient.PostAsJsonAsync("/api/v1/auth/login", loginRequest);
            
            return response.IsSuccessStatusCode ? Response.Ok() : Response.Fail();
        })
        .WithLoadSimulations(
            Simulation.InjectPerSec(rate: 100, during: TimeSpan.FromMinutes(2)),
            Simulation.InjectPerSec(rate: 200, during: TimeSpan.FromMinutes(1)),
            Simulation.InjectPerSec(rate: 50, during: TimeSpan.FromMinutes(2))
        );

        var stats = NBomberRunner
            .RegisterScenarios(scenario)
            .Run();

        Assert.True(stats.AllOkCount > 0);
        Assert.True(stats.AllFailCount < stats.AllOkCount * 0.01); // Less than 1% failure rate
        Assert.True(stats.ScenarioStats[0].Ok.Response.Mean < 200); // Average response time under 200ms
    }

    [Fact]
    public void SignalRConnections_ShouldHandleConcurrentUsers()
    {
        var scenario = Scenario.Create("signalr_connection_test", async context =>
        {
            var connection = new HubConnectionBuilder()
                .WithUrl("ws://localhost:7001/gameHub?sessionId=test-session&access_token=test-token")
                .Build();

            try
            {
                await connection.StartAsync();
                
                // Keep connection alive for the duration of the test
                await Task.Delay(TimeSpan.FromSeconds(30));
                
                await connection.StopAsync();
                return Response.Ok();
            }
            catch
            {
                return Response.Fail();
            }
            finally
            {
                await connection.DisposeAsync();
            }
        })
        .WithLoadSimulations(
            Simulation.KeepConstant(copies: 1000, during: TimeSpan.FromMinutes(5))
        );

        var stats = NBomberRunner
            .RegisterScenarios(scenario)
            .Run();

        Assert.True(stats.AllFailCount < stats.AllOkCount * 0.05); // Less than 5% failure rate for connections
    }
}

public class GameEnginePerformanceTests
{
    [Fact]
    public void ProcessCardPlay_ShouldMeetPerformanceRequirements()
    {
        // Arrange
        var gameEngine = new GameEngine(Substitute.For<ILogger<GameEngine>>());
        var gameState = TestFixtures.CreateGameStateWithManyPlayers(8);
        var playerId = gameState.Players[0].Id;
        var card = gameState.Players[0].Hand[0];

        // Act & Assert
        var stopwatch = Stopwatch.StartNew();
        
        for (int i = 0; i < 10000; i++)
        {
            var result = gameEngine.ProcessCardPlay(gameState, playerId, card, null);
            result.IsSuccess.Should().BeTrue();
        }
        
        stopwatch.Stop();

        // Should process 10,000 card plays in under 100ms
        stopwatch.ElapsedMilliseconds.Should().BeLessThan(100);
        
        var avgTimePerOperation = stopwatch.Elapsed.TotalMicroseconds / 10000;
        avgTimePerOperation.Should().BeLessThan(10); // Under 10 microseconds per operation
    }

    [Fact]
    public void CardValidation_ShouldBeSubMicrosecond()
    {
        // Arrange
        var gameEngine = new GameEngine(Substitute.For<ILogger<GameEngine>>());
        var currentCard = new Card(CardSuit.Hearts, CardRank.Two, 1);
        var playedCard = new Card(CardSuit.Hearts, CardRank.Five, 2);

        // Act & Assert
        var stopwatch = Stopwatch.StartNew();
        
        for (int i = 0; i < 1000000; i++)
        {
            var isValid = gameEngine.IsValidPlay(currentCard, playedCard, false);
            isValid.Should().BeTrue();
        }
        
        stopwatch.Stop();

        var avgTimePerValidation = stopwatch.Elapsed.TotalNanoseconds / 1000000;
        avgTimePerValidation.Should().BeLessThan(500); // Under 500 nanoseconds per validation
    }
}
```

## Test Data and Fixtures

### Test Fixtures
```csharp
public static class TestFixtures
{
    public static GameState CreateGameState()
    {
        var player1 = CreateGamePlayer(Guid.NewGuid(), "Player1", 0);
        var player2 = CreateGamePlayer(Guid.NewGuid(), "Player2", 1);

        return new GameState
        {
            GameId = Guid.NewGuid(),
            SessionId = Guid.NewGuid(),
            GameNumber = 1,
            Status = GameStatus.Active,
            Players = [player1, player2],
            CurrentPlayerId = player1.Id,
            TurnDirection = 1,
            PlayOrder = [0, 1],
            DrawPile = CreateStandardDeck().Skip(14).ToArray(), // 52 - 14 dealt cards = 38 remaining
            DiscardPile = [new Card(CardSuit.Hearts, CardRank.Ace, 53)],
            CurrentCard = new Card(CardSuit.Hearts, CardRank.Ace, 53),
            AttackStack = 0,
            ChosenSuit = null,
            SkipNextPlayer = false,
            CreatedAt = DateTime.UtcNow,
            LastUpdated = DateTime.UtcNow,
            Version = 1
        };
    }

    public static GamePlayer CreateGamePlayer(Guid id, string username, int playOrder)
    {
        var hand = new Card[7];
        var deck = CreateStandardDeck();
        
        for (int i = 0; i < 7; i++)
        {
            hand[i] = deck[playOrder * 7 + i];
        }

        return new GamePlayer
        {
            Id = id,
            Username = username,
            Hand = hand,
            PlayOrder = playOrder,
            IsEliminated = false
        };
    }

    public static Card[] CreateStandardDeck()
    {
        var deck = new List<Card>();
        var cardId = 1;

        // Standard 52 cards
        foreach (CardSuit suit in Enum.GetValues<CardSuit>())
        {
            foreach (CardRank rank in Enum.GetValues<CardRank>())
            {
                if (rank != CardRank.Joker)
                {
                    deck.Add(new Card(suit, rank, cardId++));
                }
            }
        }

        // 2 Jokers
        deck.Add(new Card(CardSuit.Hearts, CardRank.Joker, cardId++));
        deck.Add(new Card(CardSuit.Spades, CardRank.Joker, cardId++));

        return deck.ToArray();
    }

    public static User CreateTestUser(string email = "test@example.com", string username = "testuser")
    {
        return new User
        {
            Id = Guid.NewGuid(),
            Username = username,
            Email = email,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword("TestPassword123!"),
            IsActive = true,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };
    }

    public static Session CreateTestSession(Guid createdBy, string name = "Test Session")
    {
        return new Session
        {
            Id = Guid.NewGuid(),
            Name = name,
            JoinCode = GenerateJoinCode(),
            MaxPlayers = 4,
            IsPrivate = false,
            Status = SessionStatus.Waiting,
            CreatedBy = createdBy,
            CreatedAt = DateTime.UtcNow
        };
    }

    private static string GenerateJoinCode()
    {
        const string chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        var random = new Random();
        return new string(Enumerable.Repeat(chars, 6)
            .Select(s => s[random.Next(s.Length)]).ToArray());
    }
}
```

## Test Configuration

### Test Settings
```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Warning",
      "Microsoft.AspNetCore": "Warning",
      "Microsoft.EntityFrameworkCore": "Warning"
    }
  },
  "ConnectionStrings": {
    "DefaultConnection": "Host=localhost;Database=checkgame_test;Username=postgres;Password=test",
    "Redis": "localhost:6379"
  },
  "JwtSettings": {
    "SecretKey": "test-secret-key-for-testing-that-is-long-enough",
    "Issuer": "checkgame-test",
    "Audience": "checkgame-test",
    "ExpiryInHours": 1
  }
}
```

### CI/CD Test Configuration
```yaml
- name: Test
  run: |
    dotnet test \
      --no-build \
      --configuration Release \
      --logger "trx;LogFileName=test-results.trx" \
      --logger "console;verbosity=detailed" \
      --collect:"XPlat Code Coverage" \
      --results-directory ./TestResults \
      --settings coverlet.runsettings \
      -- RunConfiguration.DisableAppDomain=true
  env:
    ConnectionStrings__DefaultConnection: Host=localhost;Database=checkgame_test;Username=postgres;Password=postgres
    ConnectionStrings__Redis: localhost:6379

- name: Generate Coverage Report
  run: |
    dotnet tool install --global dotnet-reportgenerator-globaltool
    reportgenerator \
      -reports:"TestResults/**/coverage.cobertura.xml" \
      -targetdir:"TestResults/CoverageReport" \
      -reporttypes:"Html;lcov;Cobertura"

- name: Upload Coverage to Codecov
  uses: codecov/codecov-action@v3
  with:
    files: ./TestResults/CoverageReport/lcov.info
    fail_ci_if_error: true
    verbose: true
```

This comprehensive testing strategy ensures high code quality, performance, and reliability across all components of the Check-Game API.