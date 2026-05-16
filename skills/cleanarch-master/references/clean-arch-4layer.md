# Clean Architecture for Go (Practical 4-Layer Variant)

This document uses a common practical Clean Architecture variant for Go: **Domain, UseCases, Infra Adapters, and Presentation**.

The variant is compatible with the original Clean Architecture circles, but it splits the original **Interface Adapters** circle into **Presentation** and **Infra Adapters**. This split is intentional: grouping input handlers, output presenters, persistence adapters, and external-service adapters under one Interface Adapters label makes code navigation and ownership crowded.

## 1. Mapping to Original Clean Architecture

| Original Clean Architecture | This Skill's Practical Variant / Placement                                     |
| --------------------------- | ------------------------------------------------------------------------------ |
| Entities                    | Domain                                                                         |
| Use Cases                   | UseCases                                                                       |
| Interface Adapters          | Presentation + Infra Adapters                                                  |
| Frameworks & Drivers        | Concrete mechanisms used by Presentation, Infra Adapters, and Composition Root |

`Frameworks & Drivers` is listed here only as the original Clean Architecture term. In this skill, it is not used as a layer name; web frameworks, DB drivers, SDKs, runtimes, and similar details live at the edge through Presentation, Infra Adapters, or the Composition Root.

The names differ, but the main rule stays the same: source-code dependencies point inward toward higher-level policies.

## 2. Core Rules

- **Dependencies point inward**: outer layers depend on inner policies, not the other way around.
- **Domain stays independent of technical details**: no DB, HTTP, ORM, SDK, web framework, generated transport type, or request context in domain models or domain rules.
- **UseCases express application-specific policies**: they orchestrate Domain objects and boundary interfaces without direct SQL / HTTP / file / SDK calls.
- **Infra Adapters implement external mechanisms**: persistence, external APIs, files, queues, and SDK integrations implement inner ports.
- **Presentation handles delivery concerns**: HTTP, gRPC, CLI, controllers, presenters, request parsing, response mapping, authentication entry points, and transport error mapping.

## 3. Layer Definitions & Responsibilities

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
- Keep domain vocabulary independent from Presentation and Infra Adapter concerns such as transport, persistence, framework, and SDK details.

#### Dependencies

- Self-written domain code and minimal standard library needed to represent the domain.
- No technical dependencies such as `database/sql`, `net/http`, ORM tags, web contexts, SDK clients, or generated transport types.

### UseCases

#### Definition

Application-specific procedures that coordinate a user goal or system action.

#### Responsibilities

- Orchestrate Domain objects and domain services.
- Define input/output boundaries and application DTOs where useful.
- Define ports/gateways needed by the use case, especially for persistence or external capabilities that are not domain vocabulary.
- Control application policies such as transactions, retries, idempotency, and authorization decisions that belong to the use case.

#### Dependencies

- Domain.
- Boundary interfaces owned by the UseCases layer.
- No direct dependency on concrete Presentation, Infra Adapters, web frameworks, database drivers, SDK clients, or serializers.

### Infra Adapters

#### Definition

Adapters that connect UseCases or Domain-owned ports to external systems.

#### Typical Components

- Repository implementations
- Gateway implementations
- Persistence models
- External-service DTOs
- File, queue, cache, payment, search, notification, and SDK adapters

#### Responsibilities

- Implement inner ports using databases, APIs, files, queues, caches, or SDKs.
- Convert persistence and external-service data into inner-layer models.
- Convert driver errors into domain or application errors with meaning.
- Keep technical details out of Domain and UseCases.

#### Dependencies

- Inner layer interfaces and models they implement or map.
- External libraries and drivers needed by the adapter.
- They should not be depended on by Domain or UseCases code.

### Presentation

#### Definition

Adapters that deliver application behavior to users or external callers.

#### Typical Components

- HTTP handlers / controllers
- gRPC handlers
- CLI commands
- Job or message handlers
- Presenters / response mappers
- Request DTOs and response DTOs

#### Responsibilities

- Convert incoming requests into UseCase input.
- Run authentication and authorization entry-point checks when they are delivery concerns.
- Call UseCase entry points.
- Convert UseCase output and errors into transport-specific responses.
- Keep transport, routing, and rendering details out of Domain and UseCases.

#### Dependencies

- UseCases entry points and DTOs.
- Presentation frameworks such as HTTP routers, gRPC runtimes, CLI libraries, or schedulers.
- It should not call Infra Adapters directly for application workflow or persistence decisions.

## 4. Dependency Matrix (Permissible Dependencies)

- **Domain ->** self-written domain code + minimal standard library only.
- **UseCases ->** Domain + UseCase-owned boundary interfaces.
- **Infra Adapters ->** Domain / UseCases interfaces and models + external drivers/SDKs as needed.
- **Presentation ->** UseCases + presentation frameworks and transport DTOs.
- **Composition Root ->** concrete Presentation, Infra Adapters, frameworks, drivers, configuration, and UseCases for wiring only.

### Conceptual Matrix

| From / To        | Domain | UseCases | Infra Adapters | Presentation |
| ---------------- | ------ | -------- | -------------- | ------------ |
| Domain           | yes    | no       | no             | no           |
| UseCases         | yes    | yes      | no             | no           |
| Infra Adapters   | yes    | yes      | yes            | no           |
| Presentation     | maybe  | yes      | no             | yes          |
| Composition Root | yes    | yes      | yes            | yes          |

`Presentation -> Domain` is `maybe` because response mapping may read domain values returned by UseCases for serialization only. Presentation must not invoke Domain methods to make workflow or business decisions, and must not bypass UseCases for persistence or application workflow.

## 5. Port Ownership Guidance

- Put a port in **Domain** when the abstraction is part of the domain language and would exist independently of this application.
- Put a port in **UseCases** when the abstraction exists because an application workflow needs persistence, notification, authorization, payment, search, or another external capability.
- Keep concrete implementations in **Infra Adapters** regardless of which inner layer owns the interface.
- Treat exact port placement as a design decision; the Clean Architecture requirement is that concrete mechanisms do not point inward through concrete types.

## 6. Error Boundary Rules

- **Infra Adapters should not leak driver errors inward as policy.** Convert them to domain/usecase errors or adapter-level results with application meaning.
- **Domain / UseCases errors carry business or application meaning**, not HTTP status codes, SQL sentinel errors, or SDK-specific exceptions.
- **Presentation converts application errors to transport errors** such as HTTP status, gRPC status, CLI exit codes, or message acknowledgements.

## 7. Data Boundary Rules

- **UseCase Input/Output should be explicit** when it protects the inner policy from transport or persistence details.
- **Domain objects are not Presentation DTOs or ORM records.** Avoid transport annotations, ORM tags, generated API types, and request-context fields in domain objects.
- **Mapping responsibility should be consistent**. Presentation maps request/response data; Infra Adapters map persistence and external-service data; UseCases may map application DTOs when that keeps policy clear.

## 8. context.Context (Go-Specific Handling)

- **Role**: Propagate cancellation, deadlines, and tracing across I/O boundaries.
- **Rule**: `context.Context` may be passed into UseCase entry points and Port methods when operations may block or perform I/O.
- **Boundary**: Domain Entities and Value Objects should not store or depend on `context.Context`.
- **Do not smuggle resources**: do not hide `sql.Tx`, DB handles, request objects, or SDK clients inside `context.Context` to cross architectural boundaries.

## 9. DI / Composition Root

- Concrete object assembly belongs in the application entry point / Composition Root (for example `cmd/<app>/main.go`).
- Composition Root may import concrete Presentation, Infra Adapters, frameworks, drivers, configuration, and UseCases to assemble the graph.
- Presentation handlers call UseCase entry points. They may depend on a UseCase interface or a concrete UseCase type; this is a testability and coupling trade-off, not a Clean Architecture requirement by itself.
- Keep concrete Infra Adapter references out of Domain, UseCases, and ordinary Presentation flow. Presentation receives configured UseCases, not repositories or database clients.

## 10. Typical Directory Layout (Go Example)

This is only one common layout. Follow the existing project structure when it preserves the Dependency Rule and keeps the four responsibilities discoverable.

```text
cmd/app/main.go                    // composition root
internal/domain/...                // entities, value objects, domain services, domain errors
internal/usecase/...               // interactors, input/output DTOs, usecase-owned ports
internal/infra/persistence/...     // repository implementations, DB models, mapping
internal/infra/external/...        // external API gateway implementations
internal/presentation/http/...     // handlers/controllers/presenters
internal/presentation/grpc/...     // gRPC handlers and transport mapping
internal/presentation/cli/...      // CLI commands and output formatting
```

## 11. Anti-Patterns

- Domain leaks DB / HTTP / ORM / SDK / framework types.
- UseCases directly perform SQL / HTTP / file I/O instead of depending on a boundary interface.
- Presentation bypasses UseCases to run business workflow or persistence decisions directly.
- Infra Adapter code owns business decisions that belong in Domain or UseCases.
- Transport DTOs, ORM records, or generated API models are reused as Domain objects.
- Presentation and Infra Adapters are merged in a way that makes request handling, response rendering, persistence, and external integration hard to find.

## 12. Dependency Direction Diagram

Original Clean Architecture circles:

```text
Frameworks & Drivers -> Interface Adapters -> Use Cases -> Entities
```

This skill's practical split:

```text
Presentation  -> UseCases -> Domain
Infra Adapters -> UseCases / Domain ports
```

Expanded view:

```text
Presentation  -----> UseCases -----> Domain
                       ^              ^
Infra Adapters --------+--------------+
       implement ports owned by UseCases or Domain
```

### Key Points

1. **UseCases -> Domain**: normal inward dependency on business rules.
2. **Presentation -> UseCases**: delivery code calls application workflows and maps request/response data.
3. **Infra Adapters -> UseCases / Domain ports**: infrastructure implements inner contracts; it must not depend on interactor workflow code except interface contracts it implements.
4. **Concrete mechanisms**: web frameworks, DB drivers, SDKs, and runtimes are details used by Presentation, Infra Adapters, and Composition Root.


### Implementation Order: Inner Policy First

When adding features, prefer working from policy to mechanism:

1. **Domain** — define business concepts and invariants when the feature has domain behavior.
2. **UseCases** — define the application workflow, input/output boundary, and required ports.
3. **Infra Adapters** — implement ports and map persistence/external data.
4. **Presentation** — wire handlers, request parsing, response mapping, and transport errors.
5. **Composition Root** — connect concrete frameworks, drivers, configuration, UseCases, and adapters.

