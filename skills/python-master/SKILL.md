---
name: python-master
description: >
    Master of Pythonic design and performance. Expert in PEP standards, type hinting,
    async I/O, and the modern Python ecosystem (Pydantic, Pytest, FastAPI). Use for:
    (1) Python implementation/improvement/review (type hints, exceptions, async, performance).
    (2) Backend/automation/library design (public API, package boundaries).
    (3) Modern ecosystem consultation (Pydantic/pytest/FastAPI).
---

# Python Master

This skill provides expert-level Python guidance for building scalable backends, automation scripts, and high-quality library development.

## Related Tools

This skill uses: Bash (for python/pip/poetry/uv commands), Glob, Grep, Read, Edit, Write

## First Questions (Ask Up Front)

- Python version, execution form (Library/CLI/Web), deployment environment.
- Type checking policy (mypy/pyright, strictness), formatter/linter (black/ruff).
- Necessity of `async` (I/O-bound or CPU-bound?), means of parallelization (asyncio / multiprocessing).

## Output Contract (How to Respond)

- **Review**: Classify points as "Correctness / Types / API / Exceptions / Async / Performance / Style."
- **Proposed Correction**: First solidify the public API and types, then organize error and I/O boundaries (Avoid unnecessary dependency additions).
- **Boundary Data**: Always provide a validation strategy (e.g., Pydantic) for external inputs (JSON/HTTP/DB).

## Design & Coding Rules (Expert Defaults)

1. **Readability First**: PEP 8 + clear naming. Avoid tricks or excessive metaprogramming.
2. **Typed Public Surface**: Add type hints to public functions/methods/models and prevent the proliferation of `Any`.
3. **Explicit Error Boundaries**: Do not swallow exceptions; separate domain exceptions from infrastructure exceptions.
4. **Async Correctness**: Limit `async` to I/O-bound tasks and offload blocking I/O to an executor.
5. **Modern Typing**: In Python 3.10+, use `list`/`dict` instead of `List`/`Dict`, and `|` instead of `Union`.
6. **Logging Hygiene**: Prohibit `print`. Use the standard `logging` or `structlog`, managing levels and formats.
7. **Dependency Management**: Recommend `uv` or `poetry` for project management to ensure reproducibility.

## Review Checklist (High-Signal)

- **Types**: Consistency of `Optional`/`Union`, applicability of `Protocol`, intrusion of `Any` at boundaries.
- **Exceptions**: Exception types/granularity, re-throwing/wrapping, separation of user-facing messages from logs.
- **Resources**: Guaranteed closing with `with`, release of files/connections/locks.
- **Async**: Missing `await`, cancellation propagation, intrusion of blocking calls, timeouts.
- **Performance**: Redundant intermediate lists, N+1 queries, choice of data structures, profiling strategy.
- **Tests**: pytest fixtures/parametrize, boundary cases, mocking strategy for I/O.

## Common Pitfalls

### ❌ Bad Examples

```python
# NG: Overuse of Any
from typing import Any
def process(data: Any) -> Any:  # No type information
    return data

# NG: Swallowing exceptions
try:
    risky_operation()
except:  # Catches all exceptions
    pass

# NG: Blocking I/O in an async function
async def fetch():
    import time
    time.sleep(5)  # Blocks the event loop

# NG: Leaking resources
f = open("file.txt")
data = f.read()
# Not closed
```

### ✅ Good Examples

```python
# OK: Specific types (Modern Python)
def process(data: list[str]) -> dict[str, int]:
    return {s: len(s) for s in data}

# OK: Handle exceptions appropriately
try:
    risky_operation()
except ValueError as e:
    logger.error("Invalid value: %s", e)
    raise  # Re-throw

# OK: Asynchronous I/O with async
import asyncio
async def fetch():
    await asyncio.sleep(5)  # Asynchronous

# OK: Resource management with with
with open("file.txt") as f:
    data = f.read()
# Automatically closed
```

## AI-Specific Guidelines (Priorities for Implementation)

1. **Always Provide Type Hints**: Mandatory for public APIs. Use `Any` only at boundaries and narrow down internally.
2. **Validate with Pydantic**: Validate external inputs (JSON/API) with Pydantic.
3. **Explicit Exceptions**: Do not swallow; define as domain exceptions and propagate.
4. **Async for I/O-bound Only**: Consider `ProcessPoolExecutor` for CPU-bound tasks.
5. **Resources via with**: Always manage files, DB connections, and locks with `with`.
6. **Modern Syntax**: Prioritize built-in types (`list`, `dict`) and the `|` operator for type hints.

## Resources & Scripts

- **[Common Pitfalls](references/pitfalls.md)**: Common mistakes and best practices.
- **[Check Script](scripts/check.sh)**: Automated checks (`ruff`, `mypy`, `black`).

## References

- [The Zen of Python (PEP 20)](references/pep20-summary.md)
