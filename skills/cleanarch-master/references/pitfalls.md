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
