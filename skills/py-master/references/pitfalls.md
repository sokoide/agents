# Python Common Pitfalls & Best Practices

## 1. Mutable Default Arguments

- **Problem**: Default arguments are evaluated only once at definition time.

    ```python
    def append_to(element, target=[]):
        target.append(element)
        return target
    ```

- **Fix**: Use `None` and check inside the function.

    ```python
    def append_to(element, target=None):
        if target is None:
            target = []
        target.append(element)
        return target
    ```

## 2. Late Binding Closures

- **Problem**: Closures bind to variables, not values.

    ```python
    funcs = [lambda: i for i in range(3)]
    # All funcs return 2
    ```

- **Fix**: Use a default argument to bind the value immediately.

    ```python
    funcs = [lambda i=i: i for i in range(3)]
    ```

## 3. `is` vs `==`

- **Problem**: `is` checks for object identity (memory address), `==` checks for value equality. Small integers and strings might work with `is` due to interning, but it's not guaranteed.
- **Fix**: Always use `==` for value comparisons (strings, numbers). Use `is` only for `None` checks (`if x is None`).

## 4. Modifying List While Iterating

- **Problem**: Removing items from a list while iterating over it causes skip/index errors.
- **Fix**: Iterate over a copy (`for item in list[:]:`) or use list comprehension to create a new list.

## 5. Bare `except:`

- **Problem**: Catching `SystemExit` and `KeyboardInterrupt` makes it hard to kill the program.
- **Fix**: Use `except Exception:` to catch only standard errors.

## 6. Type Hints Ignored

- **Guideline**: Python is dynamic, but modern Python relies heavily on type hints for maintainability. Use `mypy` or `pyright`.
