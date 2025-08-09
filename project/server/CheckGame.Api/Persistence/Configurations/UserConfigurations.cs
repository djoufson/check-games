using CheckGame.Api.Persistence.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace CheckGame.Api.Persistence.Configurations;

public class UserConfigurations : IEntityTypeConfiguration<User>
{
    public void Configure(EntityTypeBuilder<User> builder)
    {
        // Property configurations
        builder.Property(e => e.FirstName)
            .HasMaxLength(100)
            .IsRequired();

        builder
            .HasMany(u => u.GameSessions)
            .WithOne(u => u.CreatedByUser)
            .HasForeignKey(e => e.CreatedByUserId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.Property(e => e.LastName)
            .HasMaxLength(100)
            .IsRequired();

        // Unique indexes
        builder.HasIndex(e => e.Email)
            .IsUnique();

        builder.HasIndex(e => e.UserName)
            .IsUnique();
    }
}
