# C# / .NET Common Pitfalls & Best Practices

## 1. Async Deadlocks

- **Problem**: Using `.Result` or `.Wait()` on async methods can cause deadlocks in UI/ASP.NET contexts.

    ```csharp
    // NG: Causes deadlock
    var result = GetDataAsync().Result;
    ```

- **Fix**: Use `await` consistently throughout the call chain.

    ```csharp
    // OK
    var result = await GetDataAsync();
    ```

## 2. Disposing Resources

- **Problem**: Not disposing of `IDisposable` objects leads to resource leaks.

    ```csharp
    // NG: DbContext not disposed
    var db = new AppDbContext();
    var users = db.Users.ToList();
    ```

- **Fix**: Use `using` statements or dependency injection with proper lifecycle.

    ```csharp
    // OK
    using var db = new AppDbContext();
    var users = db.Users.ToList();
    ```

## 3. EF Core N+1 Problem

- **Problem**: Lazy loading causes a separate query for each related entity.

    ```csharp
    // NG: N+1 queries
    foreach (var user in db.Users.ToList())
    {
        Console.WriteLine(user.Orders.Count);  // Query per user
    }
    ```

- **Fix**: Use `Include()` for eager loading.

    ```csharp
    // OK: Single query with join
    var users = db.Users.Include(u => u.Orders).ToList();
    ```

## 4. Incorrect DI Lifetime

- **Problem**: Registering scoped services as singletons causes captive dependencies.

    ```csharp
    // NG: DbContext captured in singleton
    services.AddSingleton<ISomeService, SomeService>();  // Injects DbContext
    services.AddScoped<AppDbContext>();
    ```

- **Fix**: Match lifetimes appropriately.

    ```csharp
    // OK
    services.AddScoped<ISomeService, SomeService>();
    services.AddScoped<AppDbContext>();
    ```

## 5. Null Reference in Collections

- **Problem**: Returning `null` instead of empty collections.

    ```csharp
    // NG
    public List<User> GetUsers() => condition ? users : null;
    ```

- **Fix**: Return empty collections.

    ```csharp
    // OK
    public List<User> GetUsers() => condition ? users : [];
    ```

## 6. String Concatenation in Loops

- **Problem**: Using `+` for string concatenation in loops is inefficient.

- **Fix**: Use `StringBuilder` for multiple concatenations.
