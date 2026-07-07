---
name: clean-code-martin
description: "Uncle Bob's Clean Code principles — comprehensive guide to writing maintainable, professional code based on Robert C. Martin's Clean Code book."
user-invocable: true
argument-hint: "[code-review|principle|best-practice] - Example: 'Review this function for naming issues'"
---

# Clean Code: Uncle Bob's Principles

**Author**: Robert C. Martin  
**Focus**: Professional code craftsmanship, maintainability, and technical excellence

## Core Principles

### 1. Meaningful Names
- **Names reveal intent** — a name should answer why it exists, what it does, and how it's used
- Avoid disinformation — don't use variables like `O` (letter oh) or `l` (letter ell)
- Make pronounceable names — `generationTimestamp` not `genymdhms`
- Use searchable names — avoid magic numbers and constants without names
- Avoid encoding — no `a1, a2, a3` or Hungarian notation like `strName`
- Class names should be nouns: `Customer`, `Account`, `Address`
- Method names should be verbs: `postPayment()`, `deletePage()`, `save()`

### 2. Functions Should Do One Thing
- **Single Responsibility Principle applied to functions**
- A function should do one thing, do it well, and do it only
- If a function does more than one thing, it's too complex
- Refactor until every function describes a single level of abstraction
- Functions should be small — typically under 20 lines

### 3. Function Arguments
- **Three or fewer arguments is ideal**
- Avoid boolean flags as arguments (use method names instead)
- Consider using parameter objects to group related arguments
- Output arguments (modifying parameters) confuse readers — avoid them
- Functions with many parameters often need refactoring

### 4. DRY: Don't Repeat Yourself
- Duplication is the primary enemy of well-designed code
- Extract repeated patterns into reusable functions
- Use inheritance, composition, or higher-order functions
- Eliminate duplicate logic immediately upon discovery

### 5. Error Handling
- Prefer exceptions to error codes
- Use try-catch-finally to establish normal flow
- Create custom exception types for specific failure scenarios
- Don't catch generic exceptions — catch specific ones
- Provide context in exceptions — include information that helps debugging
- Clean up resources in finally blocks or use try-with-resources

### 6. Comments
- **Good code needs few comments** — comments are a failure to express intention clearly
- Prefer well-named functions and clear code structure
- Use comments only for WHY, not WHAT or HOW
- Keep comments up to date — outdated comments are worse than no comments
- Avoid redundant comments that just repeat the code
- No commented-out code — delete it and use version control

### 7. Formatting
- Code formatting matters — it communicates professionalism
- Choose consistent indentation (spaces or tabs, 2-4 spaces per level)
- Keep lines reasonably short (80-120 characters typical)
- Use blank lines to separate logical sections
- Related code should be grouped together
- Dependent functions should be close (caller above callee)

### 8. Objects and Data Structures
- **Objects hide implementation behind a public interface** — expose behavior
- Data structures expose data — keep them simple
- Don't mix objects and data structures in the same codebase
- Avoid feature envy — objects shouldn't know too much about other objects
- Law of Demeter: call methods on objects you own, not on returned objects

### 9. Error Boundaries
- Use checked exceptions for recoverable conditions
- Use unchecked exceptions for programming errors
- Wrap third-party APIs in your own exception types
- Create wrapper classes to standardize error handling across your system

### 10. Unit Tests
- Tests must be as clean as production code
- Write tests first (TDD) or immediately after
- One assertion per test method (ideally)
- Use clear, descriptive test names that explain the scenario
- Keep tests isolated — no dependencies between tests
- Tests should run fast

### 11. Concurrency
- Keep concurrency code simple and isolated
- Know your library's concurrency primitives (locks, semaphores, etc.)
- Use thread-safe collections and utilities
- Write tests for concurrent code with varying loads
- Understand thread starvation, deadlock, and race conditions

### 12. Class Design
- Classes should be small — measured by responsibilities
- One reason to change = one responsibility
- Cohesion should be high — methods and variables closely related
- Maintain isolation from other classes
- Encapsulation: keep data private, expose only what's necessary

## Code Review Checklist

When reviewing code against these principles:

- [ ] Are all names meaningful and intention-revealing?
- [ ] Does each function do exactly one thing?
- [ ] Are function parameters ≤ 3?
- [ ] Is there duplication that should be extracted?
- [ ] Is error handling explicit and appropriate?
- [ ] Are comments explaining WHY, not WHAT?
- [ ] Is formatting consistent and readable?
- [ ] Are objects and data structures used correctly?
- [ ] Are unit tests present, clean, and isolated?
- [ ] Is the code free of magic numbers and unexplained constants?

## Anti-Patterns to Avoid

- **Flag arguments** — methods with boolean parameters that change behavior
- **Long parameter lists** — more than 3-4 arguments usually indicates poor design
- **Magic numbers** — unexplained constants scattered through code
- **Comment graveyards** — large blocks of commented-out code
- **God classes** — classes doing too many things
- **Feature envy** — methods using methods of other objects excessively
- **Data clumps** — groups of variables that always appear together

## Example: Before and After

### Before (Violates principles)
```java
public List<int[]> getThem() {
  List<int[]> list1 = new ArrayList<>();
  for (int[] x : theList)
    if (x[0] == 4)
      list1.add(x);
  return list1;
}
```

### After (Follows principles)
```java
public List<Cell> getFlaggedCells() {
  List<Cell> flaggedCells = new ArrayList<>();
  for (Cell cell : gameBoard)
    if (cell.isFlagged())
      flaggedCells.add(cell);
  return flaggedCells;
}
```

## When to Apply

- Code reviews — evaluate against these principles
- Refactoring sessions — use as guidance for improvements
- Design discussions — reference these principles for architecture decisions
- Mentoring — teach junior developers with these principles
- Personal development — internalize these standards for all new code
