# Check-Game Simplified Database Schema

## Database: PostgreSQL 15+

### Overview
Simplified database design focused on high performance with minimal persistent storage. Game state is managed entirely in Redis for maximum speed, with only essential session metadata persisted to PostgreSQL.

## Schema Design Philosophy

### What We Store in Database
- ✅ User accounts and authentication
- ✅ Session metadata and basic information
- ✅ Tournament results summary
- ✅ Player statistics (aggregated)

### What We DON'T Store in Database
- ❌ Real-time game state (stored in Redis)
- ❌ Individual card plays/moves
- ❌ Turn-by-turn game history
- ❌ Player hands or deck state
- ❌ Game actions log

## Entity Framework Core Models

### Users
```csharp
[Table("users")]
public class User
{
    [Key]
    public Guid Id { get; set; } = Guid.NewGuid();
    
    [Required, MaxLength(20)]
    public required string Username { get; set; }
    
    [Required, MaxLength(255)]
    public required string Email { get; set; }
    
    [Required, MaxLength(255)]
    public required string PasswordHash { get; set; }
    
    public bool IsActive { get; set; } = true;
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    
    // Navigation properties
    public virtual ICollection<RefreshToken> RefreshTokens { get; set; } = [];
    public virtual ICollection<Session> CreatedSessions { get; set; } = [];
    public virtual PlayerStatistics? Statistics { get; set; }
    
    // Indexes
    [Index(nameof(Email), IsUnique = true)]
    [Index(nameof(Username), IsUnique = true)]
    [Index(nameof(CreatedAt))]
    public class UserIndexes;
}
```

### Refresh Tokens
```csharp
[Table("refresh_tokens")]
public class RefreshToken
{
    [Key]
    public Guid Id { get; set; } = Guid.NewGuid();
    
    [Required]
    public required Guid UserId { get; set; }
    
    [Required, MaxLength(255)]
    public required string TokenHash { get; set; }
    
    public DateTime ExpiresAt { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    
    public bool IsRevoked { get; set; } = false;
    public DateTime? RevokedAt { get; set; }
    
    // Navigation properties
    public virtual required User User { get; set; }
    
    [Index(nameof(UserId))]
    [Index(nameof(ExpiresAt))]
    public class RefreshTokenIndexes;
}
```

### Sessions (Minimal Metadata)
```csharp
[Table("sessions")]
public class Session
{
    [Key]
    public Guid Id { get; set; } = Guid.NewGuid();
    
    [MaxLength(50)]
    public string? Name { get; set; }
    
    [Required, MaxLength(6)]
    public required string JoinCode { get; set; }
    
    [Range(2, 8)]
    public int MaxPlayers { get; set; } = 4;
    
    public bool IsPrivate { get; set; } = false;
    
    public SessionStatus Status { get; set; } = SessionStatus.Waiting;
    
    [Required]
    public required Guid CreatedBy { get; set; }
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? StartedAt { get; set; }
    public DateTime? CompletedAt { get; set; }
    
    // Tournament summary (final results only)
    public int TotalGamesPlayed { get; set; } = 0;
    public Guid? WinnerId { get; set; }
    public TimeSpan? TotalDuration { get; set; }
    
    // Navigation properties
    public virtual required User Creator { get; set; }
    public virtual User? Winner { get; set; }
    
    [Index(nameof(JoinCode), IsUnique = true)]
    [Index(nameof(Status))]
    [Index(nameof(CreatedBy))]
    [Index(nameof(CreatedAt))]
    public class SessionIndexes;
}

public enum SessionStatus
{
    Waiting = 0,
    Active = 1,
    Completed = 2
}
```

### Player Statistics (Aggregated)
```csharp
[Table("player_statistics")]
public class PlayerStatistics
{
    [Key]
    public required Guid UserId { get; set; }
    
    public int TotalGames { get; set; } = 0;
    public int GamesWon { get; set; } = 0;
    public int GamesLost { get; set; } = 0;
    
    public int SessionsCreated { get; set; } = 0;
    public int SessionsJoined { get; set; } = 0;
    public int TournamentsWon { get; set; } = 0;
    
    public TimeSpan TotalPlayTime { get; set; } = TimeSpan.Zero;
    public TimeSpan? AverageGameDuration { get; set; }
    
    public DateTime? LastPlayedAt { get; set; }
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    
    // Computed property
    [NotMapped]
    public decimal WinRate => TotalGames > 0 ? (decimal)GamesWon / TotalGames : 0m;
    
    // Navigation properties
    public virtual required User User { get; set; }
    
    [Index(nameof(TotalGames), IsDescending = true)]
    [Index(nameof(GamesWon), IsDescending = true)]
    [Index(nameof(LastPlayedAt), IsDescending = true)]
    public class PlayerStatisticsIndexes;
}
```

## Database Configuration

### DbContext
```csharp
public class CheckGameDbContext : DbContext
{
    public CheckGameDbContext(DbContextOptions<CheckGameDbContext> options) : base(options) { }
    
    public DbSet<User> Users => Set<User>();
    public DbSet<RefreshToken> RefreshTokens => Set<RefreshToken>();
    public DbSet<Session> Sessions => Set<Session>();
    public DbSet<PlayerStatistics> PlayerStatistics => Set<PlayerStatistics>();
    
    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);
        
        // User configuration
        modelBuilder.Entity<User>(entity =>
        {
            entity.Property(e => e.CreatedAt)
                  .HasDefaultValueSql("NOW()");
            
            entity.Property(e => e.UpdatedAt)
                  .HasDefaultValueSql("NOW()");
        });
        
        // RefreshToken configuration
        modelBuilder.Entity<RefreshToken>(entity =>
        {
            entity.HasOne(rt => rt.User)
                  .WithMany(u => u.RefreshTokens)
                  .HasForeignKey(rt => rt.UserId)
                  .OnDelete(DeleteBehavior.Cascade);
        });
        
        // Session configuration
        modelBuilder.Entity<Session>(entity =>
        {
            entity.HasOne(s => s.Creator)
                  .WithMany(u => u.CreatedSessions)
                  .HasForeignKey(s => s.CreatedBy)
                  .OnDelete(DeleteBehavior.Cascade);
            
            entity.HasOne(s => s.Winner)
                  .WithMany()
                  .HasForeignKey(s => s.WinnerId)
                  .OnDelete(DeleteBehavior.SetNull);
        });
        
        // PlayerStatistics configuration
        modelBuilder.Entity<PlayerStatistics>(entity =>
        {
            entity.HasKey(ps => ps.UserId);
            
            entity.HasOne(ps => ps.User)
                  .WithOne(u => u.Statistics)
                  .HasForeignKey<PlayerStatistics>(ps => ps.UserId)
                  .OnDelete(DeleteBehavior.Cascade);
        });
    }
    
    public override async Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        // Automatically update UpdatedAt timestamp
        var entries = ChangeTracker.Entries()
            .Where(e => e.Entity is User && e.State == EntityState.Modified);
            
        foreach (var entry in entries)
        {
            if (entry.Entity is User user)
            {
                user.UpdatedAt = DateTime.UtcNow;
            }
        }
        
        return await base.SaveChangesAsync(cancellationToken);
    }
}
```

### Connection Configuration
```csharp
// Program.cs
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");

builder.Services.AddDbContext<CheckGameDbContext>(options =>
{
    options.UseNpgsql(connectionString, npgsqlOptions =>
    {
        npgsqlOptions.EnableRetryOnFailure(
            maxRetryCount: 3,
            maxRetryDelay: TimeSpan.FromSeconds(5),
            errorCodesToAdd: null);
        
        npgsqlOptions.CommandTimeout(30);
    });
    
    if (builder.Environment.IsDevelopment())
    {
        options.EnableSensitiveDataLogging();
        options.EnableDetailedErrors();
    }
});

// Connection pooling
builder.Services.AddDbContextPool<CheckGameDbContext>(options =>
{
    options.UseNpgsql(connectionString);
}, poolSize: 128); // Adjust based on expected load
```

## Migrations

### Initial Migration
```bash
dotnet ef migrations add Initial
dotnet ef database update
```

### Sample Migration
```csharp
public partial class Initial : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.CreateTable(
            name: "users",
            columns: table => new
            {
                Id = table.Column<Guid>(type: "uuid", nullable: false),
                Username = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                Email = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: false),
                PasswordHash = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: false),
                IsActive = table.Column<bool>(type: "boolean", nullable: false, defaultValue: true),
                CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false, defaultValueSql: "NOW()"),
                UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false, defaultValueSql: "NOW()")
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_users", x => x.Id);
            });

        migrationBuilder.CreateIndex(
            name: "IX_users_Email",
            table: "users",
            column: "Email",
            unique: true);

        migrationBuilder.CreateIndex(
            name: "IX_users_Username",
            table: "users",
            column: "Username",
            unique: true);
    }
}
```

## Data Seeding

### Development Seed Data
```csharp
public static class DatabaseSeeder
{
    public static async Task SeedAsync(CheckGameDbContext context)
    {
        if (await context.Users.AnyAsync())
            return; // Already seeded
        
        var testUsers = new[]
        {
            new User
            {
                Username = "testuser1",
                Email = "test1@example.com",
                PasswordHash = BCrypt.Net.BCrypt.HashPassword("TestPassword123!")
            },
            new User
            {
                Username = "testuser2",
                Email = "test2@example.com",
                PasswordHash = BCrypt.Net.BCrypt.HashPassword("TestPassword123!")
            }
        };
        
        await context.Users.AddRangeAsync(testUsers);
        await context.SaveChangesAsync();
        
        // Create statistics for test users
        var statistics = testUsers.Select(user => new PlayerStatistics
        {
            UserId = user.Id,
            User = user
        });
        
        await context.PlayerStatistics.AddRangeAsync(statistics);
        await context.SaveChangesAsync();
    }
}
```

## Performance Optimization

### Database Indexes
```sql
-- Composite indexes for common queries
CREATE INDEX IX_sessions_status_created_at ON sessions(status, created_at);
CREATE INDEX IX_refresh_tokens_user_expires ON refresh_tokens(user_id, expires_at);

-- Partial indexes for active records
CREATE INDEX IX_sessions_active ON sessions(created_at) WHERE status IN (0, 1);
CREATE INDEX IX_users_active ON users(created_at) WHERE is_active = true;
```

### Query Optimization
```csharp
public class SessionRepository
{
    private readonly CheckGameDbContext _context;
    
    public async Task<IEnumerable<Session>> GetActiveSessionsAsync(int page, int pageSize)
    {
        return await _context.Sessions
            .Where(s => s.Status == SessionStatus.Waiting)
            .OrderByDescending(s => s.CreatedAt)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .AsNoTracking() // Read-only queries
            .ToListAsync();
    }
    
    public async Task<Session?> GetSessionWithCreatorAsync(Guid sessionId)
    {
        return await _context.Sessions
            .Include(s => s.Creator)
            .FirstOrDefaultAsync(s => s.Id == sessionId);
    }
}
```

### Connection Pooling Best Practices
```csharp
// Use pooled DbContext for high-frequency operations
public class HighPerformanceSessionService
{
    private readonly IDbContextPool<CheckGameDbContext> _contextPool;
    
    public async Task<bool> SessionExistsAsync(Guid sessionId)
    {
        using var context = _contextPool.Get();
        
        return await context.Sessions
            .AsNoTracking()
            .AnyAsync(s => s.Id == sessionId);
    }
}
```

## Backup and Maintenance

### Automated Cleanup
```csharp
public class DatabaseCleanupService : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            await CleanupExpiredTokensAsync();
            await ArchiveOldSessionsAsync();
            
            // Run cleanup every hour
            await Task.Delay(TimeSpan.FromHours(1), stoppingToken);
        }
    }
    
    private async Task CleanupExpiredTokensAsync()
    {
        using var context = _contextFactory.CreateDbContext();
        
        var expiredTokens = await context.RefreshTokens
            .Where(rt => rt.ExpiresAt < DateTime.UtcNow || rt.IsRevoked)
            .ToListAsync();
        
        context.RefreshTokens.RemoveRange(expiredTokens);
        await context.SaveChangesAsync();
    }
    
    private async Task ArchiveOldSessionsAsync()
    {
        using var context = _contextFactory.CreateDbContext();
        
        var cutoffDate = DateTime.UtcNow.AddMonths(-3);
        
        // Only keep essential data for completed sessions older than 3 months
        await context.Sessions
            .Where(s => s.Status == SessionStatus.Completed && s.CompletedAt < cutoffDate)
            .ExecuteUpdateAsync(setters => setters
                .SetProperty(s => s.Name, (string?)null)); // Clear non-essential data
    }
}
```

## Monitoring Queries

### Health Check Queries
```csharp
public class DatabaseHealthCheck : IHealthCheck
{
    private readonly CheckGameDbContext _context;
    
    public async Task<HealthCheckResult> CheckHealthAsync(
        HealthCheckContext context, 
        CancellationToken cancellationToken = default)
    {
        try
        {
            // Simple connectivity test
            await _context.Database.ExecuteSqlRawAsync(
                "SELECT 1", cancellationToken);
            
            // Check critical tables
            var userCount = await _context.Users.CountAsync(cancellationToken);
            
            return HealthCheckResult.Healthy($"Database is healthy. Users: {userCount}");
        }
        catch (Exception ex)
        {
            return HealthCheckResult.Unhealthy("Database is unhealthy", ex);
        }
    }
}
```

This simplified schema eliminates the complexity of storing real-time game state in the database, focusing purely on essential metadata while maintaining all the necessary information for user management, session tracking, and statistics. The actual game state management is handled entirely in Redis for maximum performance.