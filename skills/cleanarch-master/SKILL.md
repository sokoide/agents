---
name: cleanarch-master
description: >
    Clean Architecture master for Go applications using a practical 3-layer variant: Adapters, UseCases, and Domain.
    Use for:
    (1) Clean Architecture design/review/refactoring in Go.
    (2) Resolving Dependency Rule violations such as Domain with external deps, UseCase with DB/HTTP, or adapters leaking inward.
    (3) Dependency inversion, boundary DTOs, Port/Adapter separation, and Composition Root wiring.
    (4) Separating Presentation Adapters from Infrastructure Adapters so inbound/outbound concerns remain distinct.
---

# Clean Architecture Master

This skill provides Clean Architecture guidance for Go applications using a practical **3-layer variant: Adapters, UseCases, and Domain**.

The Adapters layer is conceptually one layer but split into **Presentation Adapters** (inbound/driving) and **Infrastructure Adapters** (outbound/driven). This split prevents the adapter layer from becoming monolithic and clarifies the side-effect boundary.

This variant is compatible with the original Clean Architecture, Hexagonal Architecture (Ports & Adapters), and pragmatic Go backend patterns.

## Related Tools

This skill uses: Bash (for go commands), Glob, Grep, Read, Edit, Write

## Core Philosophy

This skill **uses the rules defined in** [`references/clean-arch-3layer.md`](references/clean-arch-3layer.md) **as Clean Architecture guidance for this practical Go variant**.

Reviews, judgments, and refactoring advice **MUST enforce the Dependency Rule and boundary separation**. Treat exact package layout, port placement, naming, and rich-vs-anemic domain style as context-dependent design choices unless the project has an explicit local rule.

1. **Domain-Centricity**
   Software value lies in the Domain (business rules).
   DBs, HTTP routers, CLIs, SDKs, drivers, and other external mechanisms are interchangeable details handled by Adapters or the Composition Root.

2. **Dependency Rule**
   Dependencies always point from outer layers toward the inner layers.
   The Domain depends on no technical outer mechanism.

3. **Practical Go Layer Mapping**
   Three conceptual layers with the Adapters layer split by direction:
   - **Adapters** = side-effect boundary
     - **Presentation Adapters** (inbound): HTTP / gRPC / CLI handlers, presenters, request / response mapping
     - **Infrastructure Adapters** (outbound): DB / External API / Files / queues / SDK integrations

## Layer Structure

```text
Presentation Adapters ---→ UseCases ---→ Domain
                             ↑              ↑
                             +--------------+-- Infrastructure Adapters
        implements ports owned by UseCases or Domain
```

## Output Contract (How to Respond)

- **Diagnosis**: List dependency violations (imports/references), responsibility mixing, and breaches of data/error boundaries.
- **Correction**: Propose incremental steps in the order of "Boundary definition → Adapter extraction → Thinning the outer layer."
- **Condition for Assertiveness**: Be assertive on Dependency Rule violations and technical details leaking inward. Label port placement, naming, UseCase interface choices, and rich-vs-anemic domain style as trade-offs unless the project defines them as rules.

## Layer Definitions (Summary)

> Refer to **references/clean-arch-3layer.md** for detailed definitions.

### Adapters Layer

**adapter = side-effect boundary.** All I/O, external integrations, and framework interactions are confined here.

Conceptually one layer; split into Presentation (inbound) and Infrastructure (outbound) to prevent monolithic growth.

#### Presentation Adapters (Inbound / Driving)

- HTTP / gRPC / CLI handlers, controllers, presenters, and request / response mapping.
- Converts incoming requests into UseCase input and UseCase output into transport responses.
- May use web or CLI frameworks as outer details, but does not own business workflow or persistence decisions.

#### Infrastructure Adapters (Outbound / Driven)

- Repository and gateway implementations for persistence, external APIs, files, queues, and SDKs.
- Converts persistence and external-service data into inner-layer models.
- Contains technical details like DB / External API / File system while keeping them out of Domain / UseCases.

### UseCases Layer

- **Orchestration only** — coordinates Domain objects and boundary interfaces.
- Defines input/output boundaries and application DTOs.
- Defines ports for application-specific external capabilities.
- Controls transaction boundaries and application policies.
- Agnostic of technical details.

### Domain Layer

- Entity / Aggregate / Value Object.
- Domain Service.
- Business rules, invariants, and domain errors.
- Ports only when the abstraction belongs to the Domain language.
- No dependencies on external libraries or external error types.

## Directory Layout (Go)

```text
cmd/app/main.go                                  // composition root
internal/domain/...                               // entities, value objects, domain services, domain errors
internal/usecase/...                              // interactors, input/output DTOs, usecase-owned ports
internal/adapters/presentation/http/...          // HTTP handlers/controllers/presenters
internal/adapters/presentation/grpc/...          // gRPC handlers and transport mapping
internal/adapters/presentation/cli/...           // CLI commands and output formatting
internal/adapters/infra/persistence/...          // repository implementations, DB models, mapping
internal/adapters/infra/external/...             // external API gateway implementations
```

## Review Checklist (Required Output)

- **Dependency Direction**: Check if Domain imports external packages, UseCases depend directly on concrete adapters/drivers, or Presentation bypasses UseCases for application workflows.
- **Responsibility Boundaries**: Check if Entity contains I/O or Adapter concerns, UseCases own domain invariants that belong in Entities, or adapters contain business decisions.
- **Port Design**: Check if Repository / Gateway interfaces are defined on the side that owns the policy or use case need, and if they leak technical details like SQL / HTTP.
- **Error Boundary**: Check if Infrastructure Adapter returns driver errors directly, if Domain / UseCases return domain or application errors, and if Presentation converts them into transport errors (HTTP status, etc.).
- **Data Boundary**: Check if UseCase input / output are clearly defined, if Entity is mixed with transport or persistence DTOs, and if Mapping responsibility is consistent.
- **Transaction Management**: Check if the UseCases layer controls transaction policy and if technical details like `sql.Tx` leak into Domain / UseCases.
- **Configuration Injection**: Check if configuration values (Config struct) are injected into UseCase / Adapter, leaving the Domain unaware of them.

## Common Violations (Fast Smell List)

- Domain leaks types like `database/sql`, `net/http`, or ORM/SDK.
- UseCases handle SQL / HTTP / File I/O directly (adapters not separated).
- Presentation persists Domain objects or drives business workflow directly, bypassing UseCases.
- Infrastructure Adapter contains domain decisions (business logic).
- Driver errors (e.g., SQL errors) leak through boundaries to upper layers.

## AI-Specific Guidelines (Priorities for Implementation)

1. **Dependency Direction First**: Prioritize adherence to layer boundaries and dependency direction over technical ease (e.g., library convenience features).
2. **Avoid Lazy Type Sharing**: When crossing layers, define DTOs and Mapping when it protects the inner policy from transport, persistence, or adapter concerns.
3. **Ports Belong to the Policy That Needs Them**: Define interfaces in an inner layer that expresses the required behavior. Domain-owned ports are valid for domain-language needs; UseCase-owned ports are common for application-specific integrations. Adapters decide "how to achieve it."
4. **Abstract Errors**: Do not leak database-specific errors (e.g., `sql.ErrNoRows`) above UseCases. Convert them to domain or application errors with business meaning.
5. **Go Context Propagation**: Use `context.Context` for cancellations, deadlines, and tracing. Do not use context as a hidden carrier for technical details such as `sql.Tx`.

## Positioning

- This skill enforces **general Clean Architecture boundaries**, not generic coding style.
- **Prioritize the Dependency Rule** over framework or ORM convenience features.
- Use **Adapters / UseCases / Domain** as the preferred vocabulary for this skill.
- For Go-specific layout, naming, and implementation pattern, adapt to the existing codebase unless they blur the responsibilities or break the Dependency Rule.

## References

- [Clean Arch (Rules & Dependency Diagram)](references/clean-arch-3layer.md)
- [Common Pitfalls](references/pitfalls.md)

## Resources & Scripts

- [Code Check Script](scripts/check.sh) - Run at the target Go project root during review to detect dependency direction and boundary violations.
