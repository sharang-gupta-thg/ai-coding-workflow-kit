---
name: defensive-programming
description: "Defensive programming: validate input at boundaries, fail fast, assert invariants, defensive copies and null safety. Use when code accepts external input, exposes a public API, or must not be misused by callers."
user-invocable: true
argument-hint: "[validation|assertions|boundaries] - Example: 'Add defensive checks to this function'"
---

# Defensive Programming

**Philosophy**: Assume the worst and check for it. Defensive code catches bugs early and fails with clarity.

## Core Principles

### 1. Validate All Input
Never assume input is valid — always check.

```java
// ❌ Trusts input
public double divide(double a, double b) {
  return a / b; // What if b is 0?
}

// ✅ Validates input
public double divide(double a, double b) {
  if (b == 0) {
    throw new IllegalArgumentException("Divisor cannot be zero");
  }
  return a / b;
}
```

**Rules**:
- Check null references immediately
- Validate ranges and bounds
- Verify format and type correctness
- Reject invalid data at entry points
- Provide clear error messages

### 2. Fail Fast, Fail Hard
When something goes wrong, fail immediately with a clear error.

```java
// ❌ Fails silently or much later
public void processOrder(Order order) {
  String name = order.getCustomer().getName(); // NPE later if null
  // ... 50 lines of processing
  // Error appears far from source
}

// ✅ Fails immediately
public void processOrder(Order order) {
  Objects.requireNonNull(order, "Order cannot be null");
  Objects.requireNonNull(order.getCustomer(), "Customer cannot be null");
  // Errors caught immediately
}
```

### 3. Use Assertions for Invariants
Assert things that should always be true.

```java
public class Stack {
  private int size;
  
  public void push(Object item) {
    // ... implementation
    assert size >= 0 : "Stack size cannot be negative";
  }
}
```

**When to Assert**:
- Internal assumptions (this should never happen)
- State invariants (object should always be in this state)
- Return value consistency
- Never use for user input validation

### 4. Check Boundaries
Always verify array indices and collection sizes.

```java
// ❌ Risky
int value = array[index];

// ✅ Safe
if (index < 0 || index >= array.length) {
  throw new IndexOutOfBoundsException("Invalid index: " + index);
}
int value = array[index];
```

### 5. Defensive Copying
Prevent external code from corrupting internal state.

```java
// ❌ Exposes internal list
public List<User> getUsers() {
  return users; // Caller can modify it!
}

// ✅ Returns defensive copy
public List<User> getUsers() {
  return new ArrayList<>(users); // Safe to modify
}

// ✅ Or use immutable collections
public List<User> getUsers() {
  return Collections.unmodifiableList(users);
}
```

### 6. Handle Nulls Explicitly
Never let null values flow through your code unexamined.

```java
// ❌ Might get NPE
String value = getValue();
String result = value.toUpperCase();

// ✅ Handle null explicitly
String value = getValue();
if (value == null) {
  throw new IllegalStateException("Value cannot be null");
}
String result = value.toUpperCase();

// ✅ Or use Optional
Optional<String> value = getValue();
String result = value.orElseThrow(() -> 
  new IllegalStateException("Value required")
).toUpperCase();
```

### 7. Document Assumptions
Make assumptions explicit so they can be verified.

```java
/**
 * Calculates the average of non-empty arrays only.
 * 
 * @param numbers must not be null and must contain at least one element
 * @return average value, never NaN
 * @throws IllegalArgumentException if array is null or empty
 */
public double average(int[] numbers) {
  if (numbers == null || numbers.length == 0) {
    throw new IllegalArgumentException("Array must not be null or empty");
  }
  // ...
}
```

## Defensive Patterns

### Pattern 1: Contract Validation
```java
public class PaymentProcessor {
  public void processPayment(Payment payment) {
    // Preconditions (validate input)
    Objects.requireNonNull(payment);
    if (payment.getAmount() <= 0) {
      throw new IllegalArgumentException("Amount must be positive");
    }
    
    // Process...
    
    // Postconditions (verify results)
    assert payment.isProcessed();
  }
}
```

### Pattern 2: Guard Clauses
```java
public String getDescription(User user) {
  if (user == null) {
    return "Unknown user";
  }
  if (user.getProfile() == null) {
    return "User with no profile";
  }
  return user.getProfile().getDescription();
}
```

### Pattern 3: Try-Catch for Recovery
```java
public void loadConfiguration() {
  try {
    // Attempt to load
    config = loadFromFile();
  } catch (FileNotFoundException e) {
    logger.warn("Config file not found, using defaults", e);
    config = loadDefaults();
  } catch (IOException e) {
    throw new RuntimeException("Failed to load configuration", e);
  }
}
```

## Checklist

- [ ] All public method parameters validated
- [ ] Null checks at entry points
- [ ] Boundary conditions checked
- [ ] Invalid states impossible (through design)
- [ ] Errors fail fast with clear messages
- [ ] Assertions document internal assumptions
- [ ] Defensive copies prevent external mutation
- [ ] Exceptions provide context for debugging

## Balance

Defensive programming prevents bugs but adds code:
- **Over-defensive**: Every line checks everything, code becomes unreadable
- **Under-defensive**: Bugs slip through, hard to debug
- **Balanced**: Check at boundaries, trust internal code

**Rule of Thumb**: Validate public APIs heavily, trust internal code paths.
