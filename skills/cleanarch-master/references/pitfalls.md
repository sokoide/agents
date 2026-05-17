# Common Pitfalls in Clean Architecture

## 1. Domain Depending on Adapter Details (Dependency Rule Violation)

The inner layer (Domain) must not know technical details from Adapters, frameworks, DBs, transports, or SDKs.

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

// In adapters/infra/persistence/user_model.go
type UserModel struct {
    ID        uint `gorm:"primaryKey"`
    // ... mapping needed
}
```

## 4. Fat UseCases (Anemic Domain)

Putting _all_ non-trivial business rules in UseCases and treating Domain objects as data bags makes the Domain hard to protect and reuse.
This is a warning sign for complex domains, not a universal ban on anemic models. Applications dealing primarily with **entities without meaningful invariants** (lookup tables, display models, tags) can still use a transaction-script style and remain valid Clean Architecture if dependencies, policies, and data boundaries stay clear.

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


**✅ Also valid for entities without meaningful invariants:**
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
3. **Infrastructure Adapters**: Update DB schema and mapping logic for the new data.
4. **Presentation Adapters**: Update input DTO and add domain error → transport error mapping (e.g., 403).

**Anti-pattern**: Hardcoding business rules in HTTP handlers or SQL queries.

## 6. Swapping Infrastructure — Infrastructure Adapters + Composition Root Only

When changing DB (SQLite → PostgreSQL) or external service:

1. **Infrastructure Adapters**: Create a new struct implementing the existing Domain or UseCase Port interface.
2. **Composition Root** (`main.go`): Swap the injected concrete implementation.
3. **Domain / UseCases**: Zero changes needed — they depend on interfaces.

## 7. Adding External Service Integration — New Port + Adapter

When adding notification, logging, or other external integrations:

1. **Domain or UseCases**: Define an interface (e.g., `NotificationGateway`). Prefer capability-oriented names over concrete service names (e.g. `NotificationGateway` rather than `SlackGateway`) so the inner contract does not depend on a replaceable vendor detail.
2. **Infrastructure Adapters**: Implement the concrete adapter (e.g., `SlackGateway` using webhooks).
3. **UseCases**: Call the gateway after success logic. Call outside DB transaction to prevent rollback on notification failure.
4. **Testing**: Mock the interface with a NoOp implementation — no real notifications needed.

## 8. Adding Cross-Cutting Concerns — Decorator / Middleware

**Caching**: Use the Decorator pattern.

```go
// CachingRepository wraps the real repository (UseCase Port)
type CachingRepository struct {
    inner usecase.UserRepository
    cache map[string]*domain.User
}

func (r *CachingRepository) FindByID(ctx context.Context, id string) (*domain.User, error) {
    if v, ok := r.cache[id]; ok {
        return v, nil
    }
    v, err := r.inner.FindByID(ctx, id)
    if err != nil { return nil, err }
    r.cache[id] = v
    return v, nil
}
```

The decorator implements `usecase.UserRepository` (a UseCase-owned port), keeping UseCase code unchanged.

**Authentication**: Use Presentation Adapter middleware.

- Verify JWT / API key in middleware.
- Extract user ID and pass it via UseCase Input DTO.
- UseCase remains unaware of authentication technology (JWT vs API key vs OAuth).

## 9. Changing Communication Protocol — Presentation Swap Only

When switching REST → gRPC (or adding a new protocol):

1. **Presentation Adapters**: Create new gRPC handler alongside the existing REST handler.
2. Both call the same UseCase.
3. **Domain / UseCases / Infrastructure Adapters**: Zero changes.

## 10. Testing Boundaries

Clean Architecture enables targeted testing at each layer:

**Domain unit tests**: Test entities, value objects, and pure domain logic with no mocks. Domain Services that depend on Domain Ports require port stubs.

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

**Infrastructure Adapter integration tests**: Use a real database or test container. Verify mapping, queries, and error conversion.

**Presentation Adapter tests**: Mock UseCase entry points. Verify request parsing, response mapping, and transport error conversion.

## 11. Transaction Boundary

UseCases must control transaction boundaries without referencing database-specific types.

**❌ Bad — DB type in UseCase signature:**

```go
func (uc *OrderUseCase) Create(tx *sql.Tx, order OrderInput) error {
    // sql.Tx leaks infrastructure detail into UseCase
}
```

**❌ Bad — Hidden dependency via context:**

```go
func (uc *OrderUseCase) Create(ctx context.Context, order OrderInput) error {
    tx := ctx.Value("tx").(*sql.Tx) // UseCase reads tx from context
}
```

**✅ Good — TxRunner Port:**

```go
// In usecase/ports/tx_runner.go
type TxRunner interface {
    WithinTransaction(ctx context.Context, fn func(ctx context.Context) error) error
}

// In UseCase
func (uc *OrderUseCase) Create(ctx context.Context, order OrderInput) error {
    return uc.txRunner.WithinTransaction(ctx, func(ctx context.Context) error {
        // Multiple port calls are now atomic
        if err := uc.orders.Save(ctx, &order); err != nil {
            return err
        }
        return uc.events.Publish(ctx, OrderCreatedEvent{OrderID: order.ID})
    })
}
```

**Single Port call**: If only one Port is called and atomicity across multiple operations is not required, the TxRunner can be skipped — the Infrastructure Adapter manages its own transaction scope internally.

**Nested transactions**: When UseCases call other UseCases within a transaction, nested transaction semantics are defined by the TxRunner implementation (savepoint, join existing, panic, etc.). Document the chosen semantics.

## 12. Boundary Simplification Checklist

When evaluating pragmatic mode (direct Domain exposure, mapping omission), verify:

- Does the DTO prevent external contract coupling?
- Does the mapping reduce leakage of transport concerns?
- Would direct domain exposure create versioning constraints?
- Can the consumer be coordinated-deployed with the domain changes?
- Does entity construction preserve invariants?
- Is each port owned by the correct layer?

When in doubt, keep the DTO. Omitting mapping is an exception that should be a deliberate, documented decision.
