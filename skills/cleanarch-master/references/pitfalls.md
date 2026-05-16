# Common Pitfalls in Clean Architecture

## 1. Domain Depending on Framework Details (Dependency Rule Violation)

The inner layer (Domain) must not know technical details from Presentation, Infra Adapters, frameworks, DBs, transports, or SDKs.

**❌ Bad:**

```go
// In domain/user.go
import "github.com/gin-gonic/gin" // Framework dependency!

type User struct {
    Ctx *gin.Context // Leaking framework details
}
```

**✅ Good:**

```go
// In domain/user.go
import "context"

type User struct {
    ID string
}
```

If cancellation is needed for I/O, pass `context.Context` through UseCase or Port methods, not through Entity fields.

```go
// In usecase/user_repository.go
type UserRepository interface {
    FindByID(ctx context.Context, id string) (domain.User, error)
}
```

## 2. Logic Leaking to Controller

Presentation controllers/handlers should only unmarshal input, call the UseCase, and marshal output. Business logic should stay in UseCases or Domain.

**❌ Bad:**

```go
func (c *UserController) Create(ctx *gin.Context) {
    if req.Age < 18 { // Business rule in controller!
        ctx.JSON(400, "Too young")
        return
    }
    usecase.Create(req)
}
```

**✅ Good:**

```go
func (c *UserController) Create(ctx *gin.Context) {
    err := usecase.Create(req)
    if errors.Is(err, domain.ErrTooYoung) {
        ctx.JSON(400, err.Error())
        return
    }
}
```

## 3. Database Models in Domain

Using ORM tags or specific DB types in Domain Entities binds the domain to the infrastructure.

**❌ Bad:**

```go
type User struct {
    ID        uint `gorm:"primaryKey"` // ORM specific
    CreatedAt time.Time
}
```

**✅ Good:**
Separate models.

```go
// In domain/user.go
type User struct {
    ID        string
    CreatedAt time.Time
}

// In infra/persistence/user_model.go
type UserModel struct {
    ID        uint `gorm:"primaryKey"`
    // ... mapping needed
}
```

## 4. Fat UseCases (Anemic Domain)

Putting _all_ non-trivial business rules in UseCases and treating Domain objects as data bags makes the Domain hard to protect and reuse.
This is a warning sign for complex domains, not a universal ban on anemic models. CRUD-heavy applications and deliberate transaction-script designs can still be valid Clean Architecture if dependencies, policies, and data boundaries remain clear.

**❌ Bad:**

```go
// In UseCase
func Update(u *User) {
    if u.Name == "" { return Error } // Validation logic
    u.Status = "Active" // State change logic
    repo.Save(u)
}
```

**✅ Good:**
Rich Domain Model.

```go
// In Domain
func (u *User) Activate() error {
    if u.Name == "" { return ErrInvalidName }
    u.Status = "Active"
    return nil
}

// In UseCase
func Update(u *User) {
    if err := u.Activate(); err != nil { return err }
    repo.Save(u)
}
```


**✅ Also valid for CRUD-heavy systems:**
UseCase-centered transaction script with clear boundaries.

```go
func (uc *UpdateUserUseCase)Execute(ctx context.Context, in UpdateUserInput) error {
    if strings.TrimSpace(in.Name) == "" { return ErrInvalidName }

    user, err := uc.users.FindByID(ctx, in.ID)
    if err != nil { return err }

    user.Name = in.Name
    return uc.users.Save(ctx, user)
}
```

## 5. Adding / Changing Business Rules — Inner → Outer

When a business rule changes (e.g., "only thread owner can post"):

1. **Domain**: Add flag or method to Entity, define business rule and domain error.
2. **UseCases**: Add 1-2 lines to apply the rule (e.g., `if !thread.CanPost() { return ErrNotThreadOwner }`).
3. **Infra Adapters**: Update DB schema and mapping logic for the new data.
4. **Presentation**: Update input DTO and add domain error → transport error mapping (e.g., 403).

**Anti-pattern**: Hardcoding business rules in HTTP handlers or SQL queries.

## 6. Swapping Infrastructure — Infra Adapters + Composition Root Only

When changing DB (SQLite → PostgreSQL) or external service:

1. **Infra Adapters**: Create a new struct implementing the existing Domain or UseCase Port interface.
2. **Composition Root** (`main.go`): Swap the injected concrete implementation.
3. **Domain / UseCases**: Zero changes needed — they depend on interfaces.

## 7. Adding External Service Integration — New Port + Adapter

When adding notification, logging, or other external integrations:

1. **Domain or UseCases**: Define an interface (e.g., `NotificationGateway`). Do NOT name it after the concrete service (e.g., not `SlackGateway`).
2. **Infra Adapters**: Implement the concrete adapter (e.g., `SlackGateway` using webhooks).
3. **UseCases**: Call the gateway after success logic. Call outside DB transaction to prevent rollback on notification failure.
4. **Testing**: Mock the interface with a NoOp implementation — no real notifications needed.

## 8. Adding Cross-Cutting Concerns — Decorator / Middleware

**Caching**: Use the Decorator pattern.

```go
// CachingRepository wraps the real repository
type CachingRepository struct {
    inner domain.Repository
    cache map[string]domain.Entity
}

func (r *CachingRepository) FindByID(id string) (domain.Entity, error) {
    if v, ok := r.cache[id]; ok {
        return v, nil
    }
    v, err := r.inner.FindByID(id)
    if err != nil { return nil, err }
    r.cache[id] = v
    return v, nil
}
```

UseCase code remains unchanged — the decorator is transparent.

**Authentication**: Use Presentation-layer middleware.

- Verify JWT / API key in middleware.
- Extract user ID and pass it via UseCase Input DTO.
- UseCase remains unaware of authentication technology (JWT vs API key vs OAuth).

## 9. Changing Communication Protocol — Presentation Swap Only

When switching REST → gRPC (or adding a new protocol):

1. **Presentation**: Create new gRPC handler alongside the existing REST handler.
2. Both call the same UseCase.
3. **Domain / UseCases / Infra Adapters**: Zero changes.

## 10. Testing Boundaries

Clean Architecture enables targeted testing at each layer:

**Domain unit tests**: Test entities and domain services with no mocks needed. Domain depends on nothing external.

```go
func TestUserActivate(t *testing.T) {
    u := domain.User{Name: "Alice"}
    err := u.Activate()
    assert.NoError(t, err)
    assert.Equal(t, "Active", u.Status)
}
```

**UseCase unit tests**: Mock or stub boundary interfaces (ports) defined in Domain or UseCases.

```go
type stubUserRepo struct {
    saved *domain.User
}

func (s *stubUserRepo) Save(ctx context.Context, u *domain.User) error {
    s.saved = u
    return nil
}

func TestCreateUser(t *testing.T) {
    repo := &stubUserRepo{}
    uc := usecase.NewCreateUser(repo)
    err := uc.Execute(ctx, usecase.CreateUserInput{Name: "Alice"})
    assert.NoError(t, err)
    assert.Equal(t, "Alice", repo.saved.Name)
}
```

**Infra Adapter integration tests**: Use a real database or test container. Verify mapping, queries, and error conversion.

**Presentation tests**: Mock UseCase entry points. Verify request parsing, response mapping, and transport error conversion.
