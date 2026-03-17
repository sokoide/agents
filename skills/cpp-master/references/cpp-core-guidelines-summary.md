# C++ Core Guidelines (Local Summary)

Goal: A set of practical rules to "avoid undefined behavior and make exception safety, resource safety, and concurrency safety the default."

## What to Check First (Review Priorities)

- **Lifetime/Ownership**: Is the owner clear? Are reference/pointer lifetimes safe (avoiding dangling references)?
- **Bounds**: Is there a risk of out-of-bounds access for arrays/slices (index/pointer arithmetic)?
- **Resource Safety**: Are resources released even upon exceptions or early returns (RAII)?
- **Concurrency**: Are data races, lock ordering, and shared mutable states controlled?

## Defaults (Expert Baselines)

- **Rule of Zero**: Prioritize designs that don't require custom destructors, copies, or moves.
- **Prefer Value Types**: Prioritize value or single ownership (`unique_ptr`) over shared ownership; limit sharing to cases where necessity can be justified.
- **Express Intent in Types**: If representing nullability with `T*`, clarify the reason for it being "nullable"; otherwise, prioritize `T&` for non-nullables.
- **Minimize Raw Loops When Helpful**: However, don't force everything into `<algorithm>` if it degrades readability.

## Common “Stop the Line” Issues

- Lifetime violations in returning references/`string_view`/`span` (returning local or temporary references).
- Misuse of moved-from objects, double frees, or duplication of ownership.
- Throwing exceptions from destructors or ambiguity in exception boundaries (Basic/Strong/No-throw unknown).
- Unlimited exposure of shared mutable state (e.g., `shared_ptr<T>` where `T` is mutable).

## Optional Source

Refer to the original source only when necessary (external links are not maintained in this repository).
