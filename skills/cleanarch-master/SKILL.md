---
name: cleanarch-master
description: >
    Clean Architecture master for Go-style 4-layer architecture. Enforces strict
    dependency rules, domain ownership of ports, and clear separation between Framework
    and Infra Adapters. Use for:
    (1) Clean Architecture design/review/refactoring in Go.
    (2) Resolving layer boundary violations (Domain with external deps, UseCase with DB/HTTP).
    (3) Dependency injection (Composition Root) and Port/Adapter separation.
    (4) Enforcing 4-layer strict dependency rules.
---

# Clean Architecture Master

This skill provides Clean Architecture (4-layer) guidance for Go applications, enforcing strict dependency rules and domain ownership of ports.

## Related Tools

This skill uses: Bash (for go commands), Glob, Grep, Read, Edit, Write

## Core Philosophy

This skill **strictly follows the rules defined in** [`references/clean-arch-4layer.md`](references/clean-arch-4layer.md).

All reviews, judgments, and refactoring advice **MUST conform to that document**.

1. **Domain-Centricity**
   Software value lies in the Domain (business rules).
   DB, HTTP, and Framework are interchangeable details.

2. **Strict Dependency Rule**
   Dependencies always point from outer layers toward the inner layers.
   The Domain depends on nothing.

3. **Explicit Outer Layers**
   Outer parts are separated into two types:
    - **Framework Layer** (Web / gRPC / CLI)
    - **Infra Adapter Layer** (DB / External API / Files)

## Output Contract (How to Respond)

- **Diagnosis**: List dependency violations (imports/references), responsibility mixing, and breaches of data/error boundaries.
- **Correction**: Propose incremental steps in the order of "Port definition → Adapter extraction → Thinning the Framework."
- **Condition for Assertiveness**: In this skill, determine "contract violations" based on references rather than "preferences."

## Layer Definitions (Summary)

> Refer to **references/clean-arch-4layer.md** for detailed definitions.

### Domain Layer

- Entity
- Domain Service
- **Repository / Gateway Interface (Port)**
- No dependencies on external libraries or external error types.

### UseCase Layer

- Application-specific procedures (Orchestration).
- Utilizes Domain Ports.
- Agnostic of technical details.

### Infra Adapter Layer

- Concrete implementation of Ports defined by the Domain.
- Contains technical details like DB / External API / File system.
- Converts Driver Errors into a format suitable for Domain / UseCase.

### Framework Layer

- Web / gRPC / CLI / Job Runner.
- Input conversion, authentication, response formatting.
- Simply calls the UseCase.
- Does not directly handle Infra Adapter details.

## Review Checklist (Required Output)

- **Dependency Direction**: Check if Domain imports external packages, UseCase depends directly on Infra Adapter, or Framework operates directly on the Domain.
- **Responsibility Boundaries**: Check if Entity contains I/O or procedures, UseCase has too many business rules, or Infra Adapter has decision logic.
- **Port Design**: Check if Repository / Gateway interfaces are defined in the Domain and if they leak technical details like SQL / HTTP.
- **Error Boundary**: Check if Infra Adapter returns driver errors directly, if Domain / UseCase returns domain errors, and if Framework converts them into transport errors (HTTP status, etc.).
- **Data Boundary**: Check if UseCase input / output are clearly defined, if Entity is mixed with Framework DTOs, and if Mapping responsibility is consistent.
- **Transaction Management**: Check if the UseCase layer controls transaction boundaries and if technical details like `sql.Tx` leak into Domain / UseCase.
- **Configuration Injection**: Check if configuration values (Config struct) are injected into UseCase / Adapter, leaving the Domain unaware of them.

## Common Violations (Fast Smell List)

- Domain leaks types like `database/sql`, `net/http`, or ORM/SDK.
- UseCase handles SQL / HTTP / File I/O directly (Adapters not separated).
- Framework persists/converts Entity directly, bypassing the UseCase.
- Infra Adapter contains domain decisions (business logic).
- Driver errors (e.g., SQL errors) leak through boundaries to upper layers.

## AI-Specific Guidelines (Priorities for Implementation)

1. **Dependency Direction First**: Prioritize adherence to layer boundaries and dependency direction over technical ease (e.g., library convenience features).
2. **Avoid Lazy Type Sharing**: When crossing layers, define DTOs and Mapping even if it's tedious, to ensure Entity is not tainted by external (Framework/Infra) concerns.
3. **Domain Defines Ports**: The Domain decides "what is needed," and the Adapter decides "how to achieve it." Do not misplace interface definitions.
4. **Abstract Errors**: Do not leak database-specific errors (e.g., `sql.ErrNoRows`) above the UseCase. Always convert them to Domain Errors.
5. **Context Propagation**: Use `context.Context` correctly for propagating transaction or tracing information, maintaining consistent function signatures.

## Positioning

- This skill enforces **architectural correctness**, not coding style.
- **Prioritize reference conventions** over Framework or ORM idiomatic styles.

## References

- [Clean Arch](references/clean-arch-4layer.md)
- [Common Pitfalls](references/pitfalls.md)

## Resources & Scripts

- [Code Check Script](../scripts/check.sh)
