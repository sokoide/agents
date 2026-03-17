# Effective Go: Key Idioms and Conventions (Complete Version)

## 1. Formatting and Comments

* **`gofmt`**: Automatic formatting is mandatory. It eliminates style debates.
* **Semicolons**: Since they are automatically inserted at end-of-lines, do not place the opening brace `{` on the next line.
* **Doc Comments**: Add comments to all exported symbols. Comments should start with the name of the subject and form a complete sentence (e.g., `// Compile parses a regular expression...`).
* **Package Comments**: Place immediately before the `package` statement to provide an overview of the entire package.

## 2. Naming Conventions

* **Package Names**: Use a single lowercase word. Choose names that read naturally when imported, such as `search.String`.
* **Getters/Setters**: Do not use `Get` in Getters (`Owner()`, not `GetOwner()`). Setters are named `SetOwner()`.
* **Interface Names**: Add an `-er` suffix to the method name (e.g., `Reader`, `Writer`, `Formatter`).
* **MixedCaps**: Use `MixedCaps` (exported) or `mixedCaps` (unexported) instead of underscores.

## 3. Control Structures

* **`if`**: Actively use initialization statements (`if err := ...; err != nil`) to limit variable scope.
* **Early Return**: Do not indent the happy path; `return` early for error paths.
* **`switch`**: `fallthrough` is not automatic. Multiple cases can be listed separated by commas.
* **Type Switch**: Use `switch x := y.(type)` to perform type discrimination and casting simultaneously.

## 4. Functions and Methods

* **Multiple Return Values**: Returning a success value and an `error` (or `ok bool`) is standard.
* **Named Return Values**: Act as documentation. Particularly effective when there are many return values.
* **`defer`**: Executes upon function exit. Runs in LIFO (Last-In-First-Out) order. Arguments are evaluated when `defer` is executed.
* **Receiver Choice**:
  * `*T` (Pointer): Use when modifying the value within the method or if the struct is large.
  * `T` (Value): Basically for small immutable data. When in doubt, choosing a pointer receiver is a safe default.

## 5. Data Structures

* **`new`**: Returns a pointer `*T` to zero-initialized memory. Encourage designs where the "zero value" is usable (e.g., `sync.Mutex`).
* **Composite Literals**: Succinctly initialize structs or maps using the `field: value` format.
* **`make`**: Exclusive to slices, maps, and channels. Initializes internal structures and makes them ready for immediate use.
* **Arrays vs Slices**: Arrays are passed by value (copied). Typically use slices, which behave like references.
* **`append`**: Memory is reallocated when slice capacity is exceeded, so always assign the return value like `s = append(s, ...)`.

## 6. Interfaces and Types

* **Interface Conversion**: Safely check types with `str, ok := value.(string)` (Type Assertion).
* **Generality**: If a method set satisfies an interface, it can be treated as that type without explicit declaration (Duck Typing).

## 7. Blank Identifier (`_`)

* **Unused Imports/Variables**: Use during temporary debugging. Do not leave in persistent code.
* **Import for Side Effects**: Use `import _ "net/http/pprof"` to execute only the `init` function.
* **Interface Verification**: Check if a type implements an interface at compile-time, such as `var _ json.Marshaler = (*RawMessage)(nil)`.

## 8. Embedding

* **Struct Embedding**: Composition rather than inheritance. Methods of the embedded type are "promoted" and can be called directly from the outer type.
* **Interface Embedding**: Define a new interface by combining multiple interfaces.

## 9. Concurrency

* **Share by Communicating**: Do not communicate by sharing memory; instead, share memory by communicating (via channels).
* **Goroutines**: Started with `go f()`. Lightweight threads executed in the same address space.
* **Channels**: Handle both data passing and synchronization. Unbuffered channels represent "synchronous" interaction.

## 10. Error Handling, Panic, and Recover

* **Error**: Fundamentally return values that implement the `error` interface.
* **Panic**: Use only for unrecoverable fatal errors (e.g., library initialization failure). Do not use for normal flow control.
* **Recover**: Only effective within `defer`. Catches a `panic` to prevent program termination. Use cautiously at library boundaries.
