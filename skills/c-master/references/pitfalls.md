# Common Pitfalls in C

## 1. Memory Management

### Buffer Overflows

Writing past the end of an allocated buffer is a classic C vulnerability.

**❌ Bad:**

```c
char buf[8];
strcpy(buf, "TooLongString"); // Undefined behavior
```

**✅ Good:**

```c
char buf[8];
snprintf(buf, sizeof(buf), "%s", "TooLongString"); // Safe truncation or check return value
```

### Memory Leaks within Error Paths

Forgetting to free resources when returning early due to an error.

**❌ Bad:**

```c
int process() {
    char *ptr = malloc(100);
    if (!ptr) return -1;
    if (do_something() == ERROR) {
        return -1; // Leaks ptr
    }
    free(ptr);
    return 0;
}
```

**✅ Good:**

```c
int process() {
    char *ptr = malloc(100);
    if (!ptr) return -1;
    int ret = 0;
    if (do_something() == ERROR) {
        ret = -1;
        goto cleanup;
    }
cleanup:
    free(ptr);
    return ret;
}
```

## 2. Undefined Behavior (UB)

### Signed Integer Overflow

In C, signed integer overflow is UB, meaning the compiler can assume it never happens and optimize checks away.

**❌ Bad:**

```c
if (a + b < a) { // Compiler may optimize this away if a, b are signed
    // Handle overflow
}
```

**✅ Good:**

```c
if (b > INT_MAX - a) {
    // Handle overflow beforehand
}
```

### Uninitialized Variables

Reading an uninitialized variable is UB.

**❌ Bad:**

```c
int x;
if (condition) x = 5;
return x; // UB if condition is false
```

**✅ Good:**

```c
int x = 0; // Always initialize
if (condition) x = 5;
return x;
```

## 3. Pointer Arithmetic

### Pointer Aliasing

Two pointers of different types pointing to the same address (strict aliasing violation).

**❌ Bad:**

```c
int i = 42;
float *f = (float*)&i; // Strict aliasing violation (UB)
printf("%f\n", *f);
```

**✅ Good:**

```c
int i = 42;
float f;
memcpy(&f, &i, sizeof(float)); // Safe way to reinterpret bits
printf("%f\n", f);
```

## 4. Macrology

### Operator Precedence in Macros

Macros are text substitution. Always wrap arguments and the whole expression in parentheses.

**❌ Bad:**

```c
#define SQUARE(x) x * x
int val = SQUARE(1 + 2); // Expands to 1 + 2 * 1 + 2 = 5, not 9
```

**✅ Good:**

```c
#define SQUARE(x) ((x) * (x))
```

### Side Effects in Macros

Avoid using arguments with side effects in macros that evaluate them multiple times.

**❌ Bad:**

```c
#define MAX(a, b) ((a) > (b) ? (a) : (b))
int x = 5;
int y = MAX(x++, 0); // x increments twice!
```

**✅ Good:**
Use inline functions instead of macros whenever possible.

```c
static inline int safe_max(int a, int b) {
    return (a > b) ? a : b;
}
```
