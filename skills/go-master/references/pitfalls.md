# Go Common Pitfalls & Detailed Best Practices

## 1. Loop Variables (Pre-Go 1.22)

- **Problem**:

    ```go
    for _, v := range values {
        go func() { fmt.Println(v) }() // All goroutines might print the same last value
    }
    ```

- **Fix**:

    ```go
    for _, v := range values {
        v := v // Shadow variable
        go func() { fmt.Println(v) }()
    }
    ```

    _Note: Go 1.22+ fixes this behavior for `for` loops._

## 2. Nil Slices vs. Empty Slices

- **Nil**: `var s []int` (serialization: `null`)
- **Empty**: `s := []int{}` (serialization: `[]`)
- **Guideline**: Return `nil` for empty results unless a non-nil slice is explicitly required by the protocol.

## 3. Slice Re-slicing and Memory Leaks

- **Problem**: Re-slicing a huge array `huge[0:1]` keeps the entire `huge` array in memory.
- **Fix**: Copy the elements you need to a new slice.

    ```go
    res := make([]int, 1)
    copy(res, huge[0:1])
    ```

## 4. Defer in Loops

- **Problem**: `defer` executes only when the function returns, not when the loop iteration ends.

    ```go
    for _, f := range files {
        fd, _ := os.Open(f)
        defer fd.Close() // Resources leak until function returns
    }
    ```

- **Fix**: Use a function literal inside the loop.

    ```go
    for _, f := range files {
        func() {
            fd, _ := os.Open(f)
            defer fd.Close()
            // process
        }()
    }
    ```

## 5. Map Concurrent Access

- **Problem**: Maps are not thread-safe for concurrent writes.
- **Fix**: Use `sync.RWMutex` or `sync.Map`.

## 6. Interface Pointer

- **Problem**: `*MyInterface` is almost never what you want. Interfaces are already header pointers.
- **Fix**: Use `MyInterface`.

## 7. Shadowing `err`

- **Problem**: `if result, err := call(); err != nil` inside a loop or block might shadow a outer `err` that you intended to check later.
- **Check**: Use `go vet -shadow`.
