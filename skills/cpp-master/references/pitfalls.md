# Common Pitfalls in C++

## 1. Object Slicing

Passing a derived object by value to a function expecting a base class slices off the derived part.

**❌ Bad:**

```cpp
void process(Base b) { ... } // Slicing happens here
Derived d;
process(d);
```

**✅ Good:**

```cpp
void process(const Base& b) { ... } // Pass by reference
Derived d;
process(d);
```

## 2. Shared Pointer Cycles

Reference cycles prevent memory from being freed.

**❌ Bad:**

```cpp
struct A { std::shared_ptr<B> b; };
struct B { std::shared_ptr<A> a; };
// If linked, neither A nor B will be deleted.
```

**✅ Good:**
Use `std::weak_ptr` for the back-reference.

```cpp
struct B { std::weak_ptr<A> a; };
```

## 3. Returning Reference to Local

Returning a reference to a stack-allocated variable results in a dangling reference.

**❌ Bad:**

```cpp
const std::string& getName() {
    std::string s = "Alice";
    return s; // Dangling reference!
}
```

**✅ Good:**
Return by value or use a static/member variable (if appropriate).

```cpp
std::string getName() {
    return "Alice"; // RVO/NRVO makes this efficient
}
```

## 4. Vector Invalidation

Adding elements to a vector may reallocate memory, invalidating existing iterators and references.

**❌ Bad:**

```cpp
std::vector<int> v = {1, 2, 3};
int& ref = v[0];
v.push_back(4); // May reallocate
std::cout << ref; // Use-after-free behavior
```

**✅ Good:**
Be aware of invalidation rules. Use indices if reallocations are possible, or `reserve` beforehand.

## 5. Wrong Delete

Mixing `new` with `free` or `new[]` with `delete`.

**❌ Bad:**

```cpp
int* arr = new int[5];
delete arr; // Undefined behavior (should be delete[])
```

**✅ Good:**
Use `std::vector` or smart pointers instead of manual management.

```cpp
std::vector<int> arr(5);
```
