# Common Pitfalls in Clean Architecture

## 1. Domain Depending on Framework (Dependency Rule Violation)

The inner circle (Domain) must not know anything about the outer circles (Framework, DB).

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
// Context is passed via method arguments, standard lib only
```

## 2. Logic Leaking to Controller

Controllers should only unmarshal input, call the UseCase, and marshal usage. Business logic should stay in UseCase or Domain.

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
    ID        uint `gorm:"primaryKey"` // Framework specific
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

Putting _all_ logic in UseCases and treating Domain objects as data bags.

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

## 5. Scenario-Based Implementation Guide (WS1-WS7)

Practical approaches for common change scenarios, based on workshop exercises.

### A. Adding/Changing Business Rules — Inner → Outer (WS1, WS4)

When a business rule changes (e.g., "veteran = 5+ years tenure", "only thread owner can post"):

1. **Domain**: Add flag to Entity, define business rule method (`CanPost()`) and domain error.
2. **UseCase**: Add 1-2 lines to apply the rule (e.g., `if !thread.CanPost() { return ErrNotThreadOwner }`).
3. **Infra**: Update DB schema and SQL/mapping logic for the new data.
4. **Framework**: Update input DTO and add domain error → HTTP status mapping (e.g., 403).

**Anti-pattern**: Hardcoding business rules in HTTP handlers or SQL queries.

### B. Swapping Infrastructure — Infra + Composition Root Only (WS1, WS5)

When changing DB (SQLite → PostgreSQL) or external service (SQL → Active Directory):

1. **Infra**: Create a new struct implementing the existing Domain Port interface.
2. **Composition Root** (`main.go`): Swap the injected concrete implementation.
3. **Domain / UseCase**: Zero changes needed — they depend on interfaces.

### C. Adding External Service Integration — New Port + Adapter (WS2, WS6)

When adding notification, logging, or other external integrations:

1. **Domain**: Define an interface (e.g., `NotificationGateway`). Do NOT name it after the concrete service (e.g., not `SlackGateway`).
2. **Infra**: Implement the concrete adapter (e.g., `SlackGateway` using webhooks).
3. **UseCase**: Call the gateway after success logic. Call outside DB transaction to prevent rollback on notification failure.
4. **Testing**: Mock the interface with a NoOp implementation — no real notifications needed.

### D. Adding Cross-Cutting Concerns — Decorator / Middleware (WS2, WS7)

**Caching (WS2)**: Use the Decorator pattern.

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

**Authentication (WS7)**: Use Framework-layer middleware.

- Verify JWT / API key in middleware.
- Extract user ID and pass it via UseCase Input DTO.
- UseCase remains unaware of authentication technology (JWT vs API key vs OAuth).

### E. Changing Communication Protocol — Framework Swap Only (WS3)

When switching REST → gRPC (or adding a new protocol):

1. **Framework**: Create new gRPC server implementation alongside the existing REST handler.
2. Both call the same UseCase.
3. **Domain / UseCase / Infra**: Zero changes.
