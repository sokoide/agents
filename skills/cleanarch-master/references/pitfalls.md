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
