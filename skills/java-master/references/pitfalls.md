# Java Common Pitfalls & Best Practices

## 1. String Comparison with `==`

- **Problem**: `==` checks for reference equality. `new String("a") == new String("a")` is false.
- **Fix**: Always use `.equals()`. `str1.equals(str2)`.

## 2. Resource Leaks

- **Problem**: Forgetting to close streams/connections in `finally` blocks.
- **Fix**: Use Try-with-Resources (Java 7+).

    ```java
    try (BufferedReader br = new BufferedReader(new FileReader(path))) {
        return br.readLine();
    }
    ```

## 3. Generic Type Erasure

- **Problem**: Checking run-time types of generics `instanceof List<String>` is illegal because `<String>` is erased.
- **Fix**: Pass `Class<T>` explicitly if needed for runtime checks.

## 4. NullPointerExceptions (NPE)

- **Problem**: Returning `null` or assuming non-null.
- **Fix**:
- Return `Optional<T>` for public APIs that might lack a value.
- Return empty collections `Collections.emptyList()` instead of `null`.
- Use `@Nullable`/`@NonNull` annotations (JSR 305/Checker Framework).

## 5. ConcurrentModificationException

- **Problem**: Modifying a collection while iterating with foreach.
- **Fix**: Use `Iterator.remove()` or iterating over a copy. Or use `CopyOnWriteArrayList` / concurrent collections.

## 6. BigDecimal Usage

- **Problem**: `new BigDecimal(0.1)` results in an imprecise value.
- **Fix**: Use `new BigDecimal("0.1")` (String constructor) or `BigDecimal.valueOf(0.1)`.
