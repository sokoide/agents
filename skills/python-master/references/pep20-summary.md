# The Zen of Python (PEP 20) - Local Summary

Goal: Prioritize "readability and clarity" in design decisions.

## Practical Interpretations (How to Apply)

- **Readability Counts**: Avoid excessive abstraction or metaprogramming; prefer control flows that can be read once.
- **Explicit > Implicit**: Indicate intentions (types, names, boundaries) in code rather than relying on omissions or implicit conversions.
- **Simple > Complex**: Establish a simple design first and generalize only when necessary.
- **Errors Should Not Pass Silently**: Do not swallow exceptions or return values; decide on log/conversion/re-throwing policies at boundaries.
- **Namespaces are One Honking Great Idea**: Be mindful of import boundaries and avoid circular dependencies or "all-in-one util" modules.

## Review Smells

- Stuffing too much into one-liners (Prioritizing brevity over readability).
- Swallowing exceptions with `except Exception: pass`.
- Hard-to-trace (undebuggable) "clever" decorators or metaclasses.

## Optional Source

Refer to the original source only when necessary (external links are not maintained in this repository).
