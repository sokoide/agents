# Clean Architecture for Go (Practical 3-Layer Variant)

This document defines a practical 3-layer Clean Architecture variant for Go: **Adapters, UseCases, and Domain**.

The Adapters layer is conceptually one layer but split into **Presentation Adapters** (inbound/driving) and **Infrastructure Adapters** (outbound/driven). This split prevents the adapter layer from becoming monolithic and clarifies the side-effect boundary.

This variant borrows from:
- **Bob Martin's Clean Architecture** for the dependency rule.
- **Hexagonal Architecture (Ports & Adapters)** for the driving/driven adapter distinction.
- **Pragmatic Go backend** for directory structure.

## 1. Layer Overview

```text
Layers

1. Adapters
   - Presentation Adapters (inbound / driving)
   - Infrastructure Adapters (outbound / driven)

2. UseCases
   - Application orchestration
   - Ports
   - Transaction boundary

3. Domain
   - Business rules
   - Invariants
   - Entities / Value Objects
```

Dependency direction:

```text
Presentation Adapters ---→ UseCases ---→ Domain
                             ↑              ↑
                             +--------------+-- Infrastructure Adapters
        implements ports owned by UseCases or Domain
```

## 2. Mapping to Original Architectures

| Original Clean Architecture | This Variant's Placement                                                       |
| --------------------------- | ------------------------------------------------------------------------------ |
| Entities                    | Domain                                                                         |
| Use Cases                   | UseCases                                                                       |
| Interface Adapters          | Adapters (Presentation + Infrastructure)                                       |
| Frameworks & Drivers        | Concrete mechanisms used by Adapters and Composition Root                      |

| Hexagonal Architecture         | This Variant's Placement                                                       |
| ------------------------------ | ------------------------------------------------------------------------------ |
| Driving (Inbound) Adapters     | Presentation Adapters                                                          |
| Application (Ports & Use Cases)| UseCases                                                                       |
| Driven (Outbound) Adapters     | Infrastructure Adapters                                                        |
| Domain                         | Domain                                                                         |

The names differ, but the main rule stays the same: source-code dependencies point inward toward higher-level policies.

## 3. Core Rules

- **Dependencies point inward**: outer layers depend on inner policies, not the other way around.
- **Domain stays independent of technical details**: no DB, HTTP, ORM, SDK, web framework, generated transport type, or request context in domain models or domain rules.
- **UseCases express application-specific policies**: orchestration only — coordinate Domain objects and boundary interfaces without direct SQL / HTTP / file / SDK calls.
- **Adapters = side-effect boundary**: all I/O, external integrations, and framework interactions are confined to the Adapters layer.
- **Presentation Adapters handle delivery concerns**: HTTP, gRPC, CLI, controllers, presenters, request parsing, response mapping, authentication entry points, and transport error mapping.
- **Infrastructure Adapters implement external mechanisms**: persistence, external APIs, files, queues, and SDK integrations implement inner ports.

## 4. Layer Definitions & Responsibilities

### Domain

#### Definition

Enterprise-wide or domain-level business rules: the concepts that remain valuable even if UI, database, or external services change.

#### Typical Components

- Entity / Aggregate / Value Object
- Domain Service
- Domain Error
- Domain-owned Port only when the abstraction is part of the domain language

#### Responsibilities

- Define business invariants and behavior.
- Keep domain vocabulary independent from adapter concerns such as transport, persistence, framework, and SDK details.

#### Dependencies

- Self-written domain code and minimal standard library needed to represent the domain.
- No technical dependencies such as `database/sql`, `net/http`, ORM tags, web contexts, SDK clients, or generated transport types.

### UseCases

#### Definition

Application-specific procedures that coordinate a user goal or system action. **Orchestration only.**

#### Responsibilities

- Orchestrate Domain objects and domain services.
- Define input/output boundaries and application DTOs where useful.
- Define ports/gateways needed by the use case, especially for persistence or external capabilities that are not domain vocabulary.
- Control application policies such as transactions, retries, idempotency, and authorization decisions that belong to the use case.

#### Dependencies

- Domain.
- Boundary interfaces owned by the UseCases layer.
- No direct dependency on concrete Adapters, web frameworks, database drivers, SDK clients, or serializers.

### Adapters

#### Definition

**adapter = side-effect boundary.** All I/O, external integrations, and framework interactions are confined here.

Conceptually one layer; split into Presentation (inbound) and Infrastructure (outbound) for clarity and to prevent monolithic growth.

#### Presentation Adapters (Inbound / Driving)

Adapters that deliver application behavior to users or external callers.

**Typical Components:**

- HTTP handlers / controllers
- gRPC handlers
- CLI commands
- Job or message handlers
- Presenters / response mappers
- Request DTOs and response DTOs

**Responsibilities:**

- Convert incoming requests into UseCase input.
- Run authentication and authorization entry-point checks when they are delivery concerns.
- Call UseCase entry points.
- Convert UseCase output and errors into transport-specific responses.
- Keep transport, routing, and rendering details out of Domain and UseCases.

**Dependencies:**

- UseCases entry points and DTOs.
- Presentation frameworks such as HTTP routers, gRPC runtimes, CLI libraries, or schedulers.
- Must not call Infrastructure Adapters directly for application workflow or persistence decisions.

#### Infrastructure Adapters (Outbound / Driven)

Adapters that connect UseCases or Domain-owned ports to external systems.

**Typical Components:**

- Repository implementations
- Gateway implementations
- Persistence models
- External-service DTOs
- File, queue, cache, payment, search, notification, and SDK adapters

**Responsibilities:**

- Implement inner ports using databases, APIs, files, queues, caches, or SDKs.
- Convert persistence and external-service data into inner-layer models.
- Convert driver errors into domain or application errors with meaning.
- Keep technical details out of Domain and UseCases.

**Dependencies:**

- Inner layer interfaces and models they implement or map.
- External libraries and drivers needed by the adapter.
- Must not be depended on by Domain or UseCases code.

## 5. Dependency Matrix (Permissible Dependencies)

- **Domain →** self-written domain code + minimal standard library only.
- **UseCases →** Domain + UseCase-owned boundary interfaces.
- **Adapters (Presentation) →** UseCases + presentation frameworks and transport DTOs.
- **Adapters (Infrastructure) →** Domain / UseCases interfaces and models + external drivers/SDKs.
- **Composition Root →** concrete Adapters, frameworks, drivers, configuration, and UseCases for wiring only.

### Conceptual Matrix

| From / To                    | Domain | UseCases | Adapters |
| ---------------------------- | ------ | -------- | -------- |
| Domain                       | yes    | no       | no       |
| UseCases                     | yes    | yes      | no       |
| Adapters (Presentation)      | maybe  | yes      | self     |
| Adapters (Infrastructure)    | yes    | yes      | self     |
| Composition Root             | yes    | yes      | yes      |

`Presentation → Domain` is `maybe` because response mapping may read domain values returned by UseCases for serialization only. Presentation must not invoke Domain methods to make workflow or business decisions, and must not bypass UseCases for persistence or application workflow.

`Adapters (Presentation)` and `Adapters (Infrastructure)` are in the same conceptual layer but must not depend on each other directly: Presentation must not call Infrastructure (bypasses UseCases), and Infrastructure must not call Presentation.

## 6. Port Ownership Guidance

- Put a port in **Domain** when the abstraction is part of the domain language and would exist independently of this application.
- Put a port in **UseCases** when the abstraction exists because an application workflow needs persistence, notification, authorization, payment, search, or another external capability.
- Keep concrete implementations in **Adapters** regardless of which inner layer owns the interface.
- Treat exact port placement as a design decision; the Clean Architecture requirement is that concrete mechanisms do not point inward through concrete types.

## 7. Error Boundary Rules

- **Infrastructure Adapters should not leak driver errors inward as policy.** Convert them to domain/usecase errors or adapter-level results with application meaning.
- **Domain / UseCases errors carry business or application meaning**, not HTTP status codes, SQL sentinel errors, or SDK-specific exceptions.
- **Presentation converts application errors to transport errors** such as HTTP status, gRPC status, CLI exit codes, or message acknowledgements.

## 8. Data Boundary Rules

- **UseCase Input/Output should be explicit** when it protects the inner policy from transport or persistence details.
- **Domain objects are not Presentation DTOs or ORM records.** Avoid transport annotations, ORM tags, generated API types, and request-context fields in domain objects.
- **Mapping responsibility should be consistent**. Presentation maps request/response data; Infrastructure Adapters map persistence and external-service data; UseCases may map application DTOs when that keeps policy clear.

## 9. context.Context (Go-Specific Handling)

- **Role**: Propagate cancellation, deadlines, and tracing across I/O boundaries.
- **Rule**: `context.Context` may be passed into UseCase entry points and Port methods when operations may block or perform I/O.
- **Boundary**: Domain Entities and Value Objects should not store or depend on `context.Context`.
- **Do not smuggle resources**: do not hide `sql.Tx`, DB handles, request objects, or SDK clients inside `context.Context` to cross architectural boundaries.

## 10. DI / Composition Root

- Concrete object assembly belongs in the application entry point / Composition Root (for example `cmd/<app>/main.go`).
- Composition Root may import concrete Adapters, frameworks, drivers, configuration, and UseCases to assemble the graph.
- Presentation handlers call UseCase entry points. They may depend on a UseCase interface or a concrete UseCase type; this is a testability and coupling trade-off, not a Clean Architecture requirement by itself.
- Keep concrete Infrastructure Adapter references out of Domain, UseCases, and ordinary Presentation flow. Presentation receives configured UseCases, not repositories or database clients.

## 11. Typical Directory Layout (Go Example)

This is one common layout. Follow the existing project structure when it preserves the Dependency Rule and keeps the responsibilities discoverable.

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

## 12. Anti-Patterns

- Domain leaks DB / HTTP / ORM / SDK / framework types.
- UseCases directly perform SQL / HTTP / file I/O instead of depending on a boundary interface.
- Presentation bypasses UseCases to run business workflow or persistence decisions directly.
- Infrastructure Adapter code owns business decisions that belong in Domain or UseCases.
- Transport DTOs, ORM records, or generated API models are reused as Domain objects.
- Presentation and Infrastructure Adapters are merged in a way that makes request handling, response rendering, persistence, and external integration hard to find.

## 13. Dependency Direction Diagram

```text
Presentation Adapters  ──→  UseCases  ──→  Domain
                              ↑              ↑
Infrastructure Adapters ─────┘──────────────┘
        implements ports owned by UseCases or Domain
```

### Key Points

1. **UseCases → Domain**: normal inward dependency on business rules.
2. **Presentation → UseCases**: delivery code calls application workflows and maps request/response data.
3. **Infrastructure → UseCases / Domain ports**: implements inner contracts; must not depend on interactor workflow code except interface contracts it implements.
4. **Concrete mechanisms**: web frameworks, DB drivers, SDKs, and runtimes are details used by Adapters and Composition Root.

### Implementation Order: Inner Policy First

When adding features, prefer working from policy to mechanism:

1. **Domain** — define business concepts and invariants when the feature has domain behavior.
2. **UseCases** — define the application workflow, input/output boundary, and required ports.
3. **Infrastructure Adapters** — implement ports and map persistence/external data.
4. **Presentation Adapters** — wire handlers, request parsing, response mapping, and transport errors.
5. **Composition Root** — connect concrete frameworks, drivers, configuration, UseCases, and adapters.
