# Clean Architecture (Go-style 4-Layer)

This document is the **single source of truth** for `cleanarch-master`. Any structure that contradicts this is handled as a **contract violation**, not a "preference."

## 1. Non-Negotiable Rules

- **Framework only calls the UseCase** (Limited to Input / Auth / Response Formatting).
- **Infra Adapter implements Ports defined by the Domain** (No implementations in Domain or UseCase).
- **Domain depends on nothing external** (No imports for DB / HTTP / ORM / SDK / Framework types).
- **Dependency direction is always from Outer to Inner** (Framework → UseCase → Domain ← Infra Adapter).

## 2. Layer Definitions & Responsibilities

### Domain (Domain Layer)

#### Domain Definition

The business rules themselves (irreplaceable value).

#### Domain Components

- Entity
- Domain Service
- Repository / Gateway Interface (Port)

#### Domain Responsibilities

- Defining business rules.
- Abstract contract for persistence and external integration (Port).

#### Domain Dependencies

- Zero external dependencies (Standard library only within the range "necessary for domain representation").

### UseCase (UseCase Layer)

#### UseCase Definition

Procedures for specific application functions (Orchestration).

#### UseCase Responsibilities

- Manipulation of the Domain and control of procedures.
- Application control like transactions and retries ("policies" rather than technical details).
- Defining UseCase Input/Output (DTOs).

#### UseCase Dependencies

- Depends only on the Domain (Unaffected by Infra / Framework).

### Infra Adapter (Infra Adapter Layer)

#### Infra Adapter Definition

Bridge to external systems (DB, external API, Files, etc.).

#### Infra Adapter Responsibilities

- Concrete implementation of Domain Ports.
- Converting driver errors into domain/usecase error formats.
- Encapsulating technical details (SQL, HTTP, SDK, serializers, etc.).

#### Infra Adapter Dependencies

- Domain (Port/Entity/Domain Error).
- External resources (DB, HTTP, SDK, Files).

### Framework (Framework Layer)

#### Framework Definition

The outermost I/O layer (Web / gRPC / CLI / Job Runner).

#### Framework Responsibilities

- Input conversion (Request → UseCase Input).
- Authentication, authorization, and routing.
- Calling the UseCase.
- Output conversion (UseCase Output → Response, HTTP status, etc.).

#### Framework Dependencies

- Depends only on the UseCase (No direct manipulation of Domain or Infra).

## 3. Dependency Matrix (Permissible Dependencies)

- **Domain →** Self-written code + minimal standard library (e.g., `time`, `errors`). I/O systems like `database/sql`, `net/http` are prohibited in principle.
- **UseCase →** Domain only (Minimal control-related standard library allowed).
- **Infra Adapter →** Domain + external drivers/SDKs (Encapsulated).
- **Framework →** UseCase (No direct touch of Infra concrete logic; instead via Composition Root).

## 4. Error Boundary Rules

- **Infra Adapter does not return driver errors directly.**
- **Domain/UseCase returns domain/usecase errors** (Carrying application meaning).
- **Framework converts them to transport errors** (HTTP status, gRPC status, exit codes, etc.).

## 5. Data Boundary Rules

- **UseCase Input/Output are defined by explicit structures.**
- **Entity is not mixed with Framework DTOs.**
- **Responsibility for Mapping is fixed** (Unified in either Framework or UseCase).

## 6. context.Context (Go) Handling

- **Role**: Cross-cutting information like cancellations, timeouts, and tracing.
- **Rule**: `context.Context` may be passed at the entrance of UseCase/Port, but Domain's Entity/ValueObject does not depend on `context` (Pass necessary data through arguments).

## 7. DI / Composition Root

- Assembly of concrete instances is concentrated in **Main/Composition Root** (e.g., `cmd/<app>/main.go`).
- Framework does not know about Port implementations (Infra Adapter); it calls them through the UseCase.

## 8. Typical Directory Layout (Go)

```text
cmd/app/main.go                  // composition root
internal/domain/...              // entity, domain service, ports, domain errors
internal/usecase/...             // interactors + input/output DTO
internal/infra/...               // db, external api, repo implementations
internal/framework/http/...      // handlers, middleware, routing
```

## 9. Anti-Patterns (Immediate Disqualification)

- Domain leaks types like DB / HTTP / ORM / SDK.
- UseCase directly performs SQL / HTTP (Missing Port/Adapter separation).
- Framework circumvents UseCase to directly manipulate Domain / Infra.
- Infra Adapter holds business decisions (the core logic for conditional branching).
