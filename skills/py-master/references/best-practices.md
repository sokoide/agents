# Pythonic Idioms & Type Safety

## 1. Zen of Python (PEP 20)

- "Simple is better than complex."
- "Readability counts."
- Use explicit code over magic (where possible).
- Prefer list comprehensions and generator expressions for concise iterations.

## 2. Type Hinting & Validation (Modern Python)

- Use `typing` module (or built-in types in 3.9+) for all function signatures.
- Leverage `Pydantic` or `attrs` for data validation and settings.
- Use `TypeGuard` and `TypeAlias` for complex type logic.
- Run static analysis with `mypy` or `pyright`.

## 3. Resource Management & Concurrency

- Use `with` statements (Context Managers) for I/O and locks.
- Prefer `asyncio` for I/O-bound tasks and `multiprocessing` for CPU-bound tasks.
- Use `contextlib` to create lightweight context managers.
- Manage dependencies with `Poetry`, `uv`, or `pipenv`.

## 4. Design Patterns & Decorators

- Use `Decorators` for cross-cutting concerns (logging, auth, caching).
- Leverage `Dataclasses` for boilerplate-free data structures.
- Implement `Protocols` (PEP 544) for structural subtyping (Static Duck Typing).
- Use `abc.ABC` for formal interface definitions.

## 5. Testing & Documentation

- Use `pytest` for robust testing (fixtures, parametrization).
- Write `Google-style` or `NumPy-style` docstrings.
- Automate code formatting with `black` and linting with `ruff`.
