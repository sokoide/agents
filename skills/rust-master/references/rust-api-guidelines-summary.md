# Rust API Guidelines - Local Summary

Goal: Structure public APIs to be "readable, hard to misuse, and easy to avoid breaking changes."

## Public API Review Checklist

- **Naming**: Are names for types, functions, and features consistent? Are abbreviations, verbs, and singular/plural forms intuitive?
- **Ownership**: Is ownership of arguments and return values natural? (Does it avoid forcing unnecessary clones?)
- **Error Design**: Provide meaningful error types (enums or structs) for public APIs; keep `anyhow` confined to internal logic.
- **Builder Patterns**: When there are many optional arguments, use builders, `Default`, or method chains to reduce misuse.
- **Trait Impls**: Are derives for `Debug`, `Clone`, `Eq`, `Hash`, etc., appropriate? Are `Send`/`Sync` boundaries as intended?
- **Docs**: Explicitly state conditions for safety, complexity, and panics, and ensure examples are minimal and functional.
- **SemVer**: Do not underestimate changes that affect compatibility (e.g., public traits, struct fields, or return types).

## Common “API Smells”

- Over-exposing internal details with "pub everywhere" (Excessive exposure of fields or types).
- Ambiguous errors like `Result<T, String>` (Lack of structure).
- `unwrap/expect` remains at library boundaries.

## Optional Source

Refer to the original source only when necessary (external links are not maintained in this repository).
