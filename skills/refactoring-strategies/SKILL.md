---
name: refactoring-strategies
description: "Systematic refactoring patterns — L1-L6 refactoring levels, safe techniques, and when to refactor."
user-invocable: true
argument-hint: "[simplification|safety|technique] - Example: 'Refactor this for clarity'"
---

# Refactoring Strategies

**Goal**: Improve code quality without changing behavior  
**Principle**: Refactor in small, safe steps with tests

## When to Refactor

### Good Times
✓ After tests pass (safety net)  
✓ While code is fresh in mind  
✓ When preparing to add similar code  
✓ When code is blocking other work  
✓ During code review (small refactorings)  

### Bad Times
❌ When tests don't exist (add tests first)  
❌ While debugging (finish debugging first)  
❌ Right before a deadline  
❌ During active feature development (finish feature first)  

## Refactoring Levels (L1-L6)

### L1: Dead Code Removal
**Impact**: Low  
**Risk**: Very low  

```java
// ❌ Remove unused code
private int unusedVariable = 0;
public void unusedMethod() { }
```

### L2: Name Improvements
**Impact**: High (improves understanding)  
**Risk**: Very low  

```java
// ❌ Unclear
int d = 5;  // days

// ✓ Clear
int daysUntilExpiration = 5;
```

### L3: Extract Functions
**Impact**: High  
**Risk**: Low  

```java
// ❌ Complex function
public void processUser(User user) {
  validate(user);
  saveToDatabase(user);
  sendEmail(user);
  logMetrics(user);
}

// ✓ Extracted
public void processUser(User user) {
  validateUser(user);
  persistUser(user);
  notifyUser(user);
  recordMetrics(user);
}

private void validateUser(User user) { /* ... */ }
private void persistUser(User user) { /* ... */ }
private void notifyUser(User user) { /* ... */ }
private void recordMetrics(User user) { /* ... */ }
```

### L4: Replace Conditionals with Polymorphism
**Impact**: High (improves extensibility)  
**Risk**: Medium  

```java
// ❌ Conditional logic
public double calculateDiscount(Customer customer) {
  if (customer.getType() == PREMIUM) {
    return amount * 0.2;
  } else if (customer.getType() == STANDARD) {
    return amount * 0.1;
  }
  return 0;
}

// ✓ Polymorphism
interface DiscountStrategy {
  double calculate(double amount);
}
class PremiumDiscount implements DiscountStrategy {
  public double calculate(double amount) { return amount * 0.2; }
}
class StandardDiscount implements DiscountStrategy {
  public double calculate(double amount) { return amount * 0.1; }
}
```

### L5: Replace Data With Domain Objects
**Impact**: High  
**Risk**: High  

```java
// ❌ Primitives everywhere
Map<String, String> user = new HashMap<>();
user.put("name", "John");
user.put("email", "john@example.com");

// ✓ Domain object
class User {
  private String name;
  private String email;
}
```

### L6: Strategic Redesign
**Impact**: Very high  
**Risk**: Very high  

```
Monolith
├─ Module A
├─ Module B
└─ Module C

becomes

Microservices
├─ Service A (owns Module A)
├─ Service B (owns Module B)
└─ Service C (owns Module C)
```

## Safe Refactoring Techniques

### Technique 1: Rename Variable/Function
```java
// Safe because: compiler catches misses
int d = 5;
// Select all → Rename to: daysUntilExpiration
int daysUntilExpiration = 5;
```

### Technique 2: Extract Function
```java
// Safe because: behavior unchanged, tests verify
public void oldLongMethod() {
  // ... 50 lines

  newHelperMethod();

  // ... more code
}

private void newHelperMethod() {
  // Extracted code (same behavior)
}
```

### Technique 3: Inline Function
```java
// Safe because: replacing call with body (compiler checks)
calculateDiscount(customer);

becomes

return amount * 0.2; // (assuming inlining to this)
```

### Technique 4: Move Function to Class
```java
// Safe because: just moving, behavior unchanged
// PersonUtils.getTaxableIncome(person);
becomes
// person.getTaxableIncome();
```

### Technique 5: Replace Loop with Stream
```java
// ❌ Imperative loop
List<String> names = new ArrayList<>();
for (User user : users) {
  if (user.isActive()) {
    names.add(user.getName());
  }
}

// ✓ Functional stream (same behavior)
List<String> names = users.stream()
  .filter(User::isActive)
  .map(User::getName)
  .collect(toList());
```

## Refactoring Workflow

### Step 1: Understand Current Behavior
```bash
# Make sure tests pass first
mvn test
```

### Step 2: Make One Small Refactoring
```java
// Change one thing only
// e.g., Rename a variable
```

### Step 3: Verify Behavior Unchanged
```bash
# Run tests
mvn test
# If tests fail, revert immediately
```

### Step 4: Commit or Move to Next Refactoring
```bash
git add <file>
git commit -m "Refactor: rename d to daysUntilExpiration"
```

**Never** do: Extract method AND rename AND restructure in one go.

## Refactoring Patterns

### Pattern 1: Extract Method
```java
public void bookConcert(List<Reservation> reservations) {
  // ... setup code
  
  // Extract this
  for (Reservation reservation : reservations) {
    sendConfirmation(reservation);
    updateInventory(reservation);
    recordMetrics(reservation);
  }
}

// becomes

public void bookConcert(List<Reservation> reservations) {
  // ... setup code
  reservations.forEach(this::processReservation);
}

private void processReservation(Reservation reservation) {
  sendConfirmation(reservation);
  updateInventory(reservation);
  recordMetrics(reservation);
}
```

### Pattern 2: Replace Magic Number
```java
// ❌ Magic
if (user.getAge() > 21) { }

// ✓ Named constant
private static final int LEGAL_DRINKING_AGE = 21;
if (user.getAge() > LEGAL_DRINKING_AGE) { }
```

### Pattern 3: Move Responsibility
```java
// ❌ Validation in multiple places
if (user.getEmail().contains("@")) { }
// ... elsewhere
if (user.getEmail().contains("@")) { }

// ✓ Move to domain object
class User {
  private String email;
  
  public boolean hasValidEmail() {
    return email.contains("@");
  }
}

if (user.hasValidEmail()) { }
```

## Refactoring Metrics

### Code Complexity
```
Cyclomatic Complexity (CC):
- CC < 5:     Good
- CC 5-10:    Moderate (extract functions)
- CC > 10:    Dangerous (must refactor)
```

### Code Duplication
```
If same pattern appears 3+ times:
- Extract to function/class
- Use inheritance or composition
```

### Function Length
```
Lines per function:
- < 20:  Good
- 20-50: Consider extracting
- > 50:  Almost always too long
```

## Checklist

- [ ] Tests pass before refactoring
- [ ] Refactor one thing at a time
- [ ] Tests pass after each change
- [ ] Behavior is unchanged
- [ ] Commit frequently
- [ ] Code review refactoring carefully
- [ ] No "while I'm here" refactorings (scope creep)
- [ ] Can explain the improvement

## Anti-Patterns

❌ Refactoring without tests  
❌ Changing behavior while refactoring  
❌ Large refactoring that changes multiple things  
❌ Refactoring too early (premature)  
❌ "Refactoring" performance without profiling first  
❌ Refactoring for personal preference
