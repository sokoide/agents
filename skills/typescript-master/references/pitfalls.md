# TypeScript Common Pitfalls & Best Practices

## 1. The `any` Trap

- **Problem**: Using `any` disables type checking, defeating the purpose of TypeScript.

    ```typescript
    function process(data: any) {
        return data.value; // No error if value doesn't exist, runtime crash potential
    }
    ```

- **Fix**: Use `unknown` if the type is truly not known yet, and narrow it down. Or use generic types.

    ```typescript
    function process(data: unknown) {
        if (typeof data === "object" && data !== null && "value" in data) {
            return (data as { value: any }).value;
        }
    }
    ```

## 2. Floating Point Math

- **Problem**: `0.1 + 0.2 !== 0.3` in JavaScript/TypeScript.
- **Fix**: Use integers for currency (cents), or a library like `decimal.js`.

## 3. Accidental Mutations (React/Redux)

- **Problem**: Mutating state directly prevents re-renders or causes bugs.

    ```typescript
    const [items, setItems] = useState([1, 2, 3]);
    const addItem = () => {
        items.push(4); // NG: Mutates existing array, React won't see change
        setItems(items);
    };
    ```

- **Fix**: Always create new objects/arrays.

    ```typescript
    const addItem = () => {
        setItems([...items, 4]); // OK
    };
    ```

## 4. `useEffect` Dependency Lies

- **Problem**: Omitting variables used inside `useEffect` from the dependency array to "fix" infinite loops. This leads to stale closures.
- **Fix**: Include all dependencies. If that causes loops, use `useCallback` for functions or `useRef` for values that shouldn't trigger effects but are needed.

## 5. Non-Null Assertion (!) Abuse

- **Problem**: Using `!` to shut up the compiler. `item!.value`
- **Fix**: Use optional chaining `?.` or explicit type guards. `item?.value` or `if (item) ...`

## 6. `interface` vs `type` for Libraries

- **Guideline**: Use `interface` for public APIs (supports merging), `type` for unions/intersections and internal logic.
