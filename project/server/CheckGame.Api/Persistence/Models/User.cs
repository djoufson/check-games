using Microsoft.AspNetCore.Identity;

namespace CheckGame.Api.Persistence.Models;

public class User : IdentityUser
{
    public string FirstName { get; private set; } = string.Empty;
    public string LastName { get; private set; } = string.Empty;

    private User(string userName, string firstName, string lastName, string email)
    {
        UserName = userName;
        Email = email;
        FirstName = firstName;
        LastName = lastName;
    }

    public static User Create(string userName, string firstName, string lastName, string email)
    {
        return new(userName, firstName, lastName, email);
    }
}
