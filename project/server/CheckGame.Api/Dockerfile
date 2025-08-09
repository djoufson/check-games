# Use the official .NET 9 runtime as base image
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS base
WORKDIR /app
EXPOSE 8080
EXPOSE 8081

# Use the SDK image to build the application
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Copy csproj files and restore dependencies
COPY ["CheckGame.Api/CheckGame.Api.csproj", "CheckGame.Api/"]
COPY ["CheckGame.Engine/CheckGame.Engine.csproj", "CheckGame.Engine/"]
COPY ["Directory.Build.props", ""]
RUN dotnet restore "CheckGame.Api/CheckGame.Api.csproj"

# Copy all source files
COPY . .

# Build the application
WORKDIR "/src/CheckGame.Api"
RUN dotnet build "CheckGame.Api.csproj" -c Release -o /app/build

# Publish the application
FROM build AS publish
RUN dotnet publish "CheckGame.Api.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Final stage/image
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .

# Create a non-root user
RUN adduser --disabled-password --home /app --gecos '' appuser && chown -R appuser /app
USER appuser

ENTRYPOINT ["dotnet", "CheckGame.Api.dll"]