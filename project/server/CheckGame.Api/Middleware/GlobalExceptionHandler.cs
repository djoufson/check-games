using FluentValidation;
using Microsoft.AspNetCore.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using System.Net;

namespace CheckGame.Api.Middleware;

public class GlobalExceptionHandler : IExceptionHandler
{
    private readonly ILogger<GlobalExceptionHandler> _logger;

    public GlobalExceptionHandler(ILogger<GlobalExceptionHandler> logger)
    {
        _logger = logger;
    }

    public async ValueTask<bool> TryHandleAsync(
        HttpContext httpContext, 
        Exception exception, 
        CancellationToken cancellationToken)
    {
        _logger.LogError(exception, "Exception occurred: {Message}", exception.Message);

        var problemDetails = exception switch
        {
            ValidationException validationException => CreateValidationProblemDetails(
                httpContext, validationException),
            ArgumentException argumentException => CreateProblemDetails(
                httpContext, "Bad Request", argumentException.Message, HttpStatusCode.BadRequest),
            UnauthorizedAccessException => CreateProblemDetails(
                httpContext, "Unauthorized", "Authentication is required", HttpStatusCode.Unauthorized),
            _ => CreateProblemDetails(
                httpContext, "Server Error", "An internal server error occurred", HttpStatusCode.InternalServerError)
        };

        httpContext.Response.StatusCode = problemDetails.Status ?? (int)HttpStatusCode.InternalServerError;
        httpContext.Response.ContentType = "application/problem+json";

        await httpContext.Response.WriteAsJsonAsync(problemDetails, cancellationToken);
        return true;
    }

    private static ProblemDetails CreateValidationProblemDetails(
        HttpContext httpContext, 
        ValidationException validationException)
    {
        var problemDetails = new ProblemDetails
        {
            Status = (int)HttpStatusCode.BadRequest,
            Title = "Validation Error",
            Detail = "One or more validation errors occurred",
            Instance = httpContext.Request.Path,
            Type = "https://tools.ietf.org/html/rfc7231#section-6.5.1"
        };

        // Group validation errors by property name
        var errors = validationException.Errors
            .GroupBy(e => e.PropertyName)
            .ToDictionary(
                g => g.Key,
                g => g.Select(e => e.ErrorMessage).ToArray()
            );

        problemDetails.Extensions["errors"] = errors;
        return problemDetails;
    }

    private static ProblemDetails CreateProblemDetails(
        HttpContext httpContext,
        string title,
        string detail,
        HttpStatusCode statusCode)
    {
        return new ProblemDetails
        {
            Status = (int)statusCode,
            Title = title,
            Detail = detail,
            Instance = httpContext.Request.Path,
            Type = statusCode switch
            {
                HttpStatusCode.BadRequest => "https://tools.ietf.org/html/rfc7231#section-6.5.1",
                HttpStatusCode.Unauthorized => "https://tools.ietf.org/html/rfc7235#section-3.1",
                HttpStatusCode.Forbidden => "https://tools.ietf.org/html/rfc7231#section-6.5.3",
                HttpStatusCode.NotFound => "https://tools.ietf.org/html/rfc7231#section-6.5.4",
                HttpStatusCode.Conflict => "https://tools.ietf.org/html/rfc7231#section-6.5.8",
                _ => "https://tools.ietf.org/html/rfc7231#section-6.6.1"
            }
        };
    }
}