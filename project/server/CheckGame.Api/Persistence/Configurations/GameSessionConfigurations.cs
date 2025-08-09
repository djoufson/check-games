using System.Text.Json;
using CheckGame.Api.Persistence.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.ChangeTracking;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace CheckGame.Api.Persistence.Configurations;

public class GameSessionConfigurations : IEntityTypeConfiguration<GameSession>
{
    public void Configure(EntityTypeBuilder<GameSession> builder)
    {
        // Primary key
        builder.HasKey(e => e.Id);

        // Table name
        builder.ToTable("GameSessions");

        // Property configurations
        builder.Property(e => e.Id)
            .HasMaxLength(36)
            .IsRequired();

        builder.Property(e => e.CreatedByUserId)
            .IsRequired();

        builder.Property(e => e.Name)
            .HasMaxLength(100)
            .IsRequired();

        builder.Property(e => e.MaxPlayers)
            .IsRequired();

        builder.Property(e => e.Status)
            .HasConversion<int>()
            .IsRequired();

        builder.Property(e => e.Players)
            .HasConversion(
                v => Serialize(v),
                v => Deserialize(v))
            .IsRequired()
            .Metadata.SetValueComparer(
                new ValueComparer<List<string>>(
                    (c1, c2) => c1!.SequenceEqual(c2!),
                    c => c.Aggregate(0, (a, v) => HashCode.Combine(a, v.GetHashCode())),
                    c => c.ToList()));
 
        builder.Property(e => e.CreatedAt)
            .IsRequired()
            .HasDefaultValueSql("CURRENT_TIMESTAMP");

        builder.Property(e => e.StartedAt);

        builder.Property(e => e.EndedAt);

        // Relationships
        builder.HasOne(e => e.CreatedByUser)
            .WithMany(u => u.GameSessions)
            .HasForeignKey(e => e.CreatedByUserId)
            .OnDelete(DeleteBehavior.Restrict);

        // Indexes for performance
        builder.HasIndex(e => e.Status);

        builder.HasIndex(e => e.CreatedAt)
            .HasDatabaseName("IX_GameSessions_CreatedAt");
    }

    private static string Serialize(List<string> collection)
    {
        return JsonSerializer.Serialize(collection);
    }

    private static List<string> Deserialize(string collection)
    {
        return JsonSerializer.Deserialize<List<string>>(collection) ?? [];
    }
}
