using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CheckGame.Api.Migrations
{
    /// <inheritdoc />
    public partial class AddCodeToSedssions : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "Code",
                table: "GameSessions",
                type: "character varying(6)",
                maxLength: 6,
                nullable: false,
                defaultValue: "");

            migrationBuilder.CreateIndex(
                name: "IX_GameSessions_Code",
                table: "GameSessions",
                column: "Code",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_GameSessions_Code",
                table: "GameSessions");

            migrationBuilder.DropColumn(
                name: "Code",
                table: "GameSessions");
        }
    }
}
