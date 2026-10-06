---
name: solid-principles
description: "SOLID design principles: single responsibility, open/closed, Liskov substitution, interface segregation and dependency inversion. Use when designing classes and module boundaries, deciding where logic should live, or reviewing a class that does too much."
user-invocable: true
argument-hint: "[principle|design-review] - Example: 'Review this class for SRP violations'"
---

# SOLID Principles

**Foundation**: Five core design principles for professional software architecture  
**Author**: Robert C. Martin and others  
**Scope**: Object-oriented design and architecture

## The Five Principles

### 1. Single Responsibility Principle (SRP)
A class should have only one reason to change — one responsibility.

**Why**: Classes with multiple responsibilities are fragile and hard to test.

**Example**:
```java
// ❌ Violates SRP — mixed concerns
class User {
  public void save() { /* database logic */ }
  public void sendEmail() { /* email logic */ }
  public void generateReport() { /* reporting */ }
}

// ✅ Follows SRP — single responsibility
class User { /* user data only */ }
class UserRepository { /* persistence */ }
class UserEmailService { /* email notifications */ }
class UserReporter { /* reporting */ }
```

**How to Apply**:
- Each class should model a single concept
- If you can't describe a class in one sentence, it has multiple responsibilities
- Classes that are hard to name likely have SRP issues
- Test isolation reveals SRP violations

### 2. Open/Closed Principle (OCP)
Software entities should be open for extension but closed for modification.

**Why**: Avoid breaking existing code when adding features.

**Example**:
```java
// ❌ Violates OCP — must modify existing code to extend
class PaymentProcessor {
  public void process(String type, double amount) {
    if (type.equals("credit")) { /* credit logic */ }
    else if (type.equals("paypal")) { /* paypal logic */ }
  }
}

// ✅ Follows OCP — extend without modifying
interface PaymentMethod {
  void process(double amount);
}
class CreditPayment implements PaymentMethod { }
class PayPalPayment implements PaymentMethod { }
```

**How to Apply**:
- Use abstraction (interfaces, abstract classes)
- Use polymorphism to handle variations
- Design for extensibility before the need arises
- Avoid hardcoded type checks

### 3. Liskov Substitution Principle (LSP)
Derived classes must be substitutable for their base classes without breaking behavior.

**Why**: Ensures inheritance hierarchies are logically consistent.

**Example**:
```java
// ❌ Violates LSP — derived class breaks contract
class Bird {
  public void fly() { }
}
class Penguin extends Bird {
  @Override
  public void fly() { throw new UnsupportedOperationException(); }
}

// ✅ Follows LSP — proper hierarchy
interface Animal { }
interface Flyable { void fly(); }
class Eagle implements Animal, Flyable { public void fly() { } }
class Penguin implements Animal { }
```

**How to Apply**:
- Ensure derived classes honor base class contracts
- Don't override methods to do something completely different
- Use composition over inheritance when hierarchy doesn't fit
- If you need to check types before calling methods, LSP is violated

### 4. Interface Segregation Principle (ISP)
Clients should not be forced to depend on methods they don't use.

**Why**: Prevents bloated interfaces and unnecessary dependencies.

**Example**:
```java
// ❌ Violates ISP — forced to implement unused methods
interface Worker {
  void work();
  void eat();
}
class Robot implements Worker {
  public void work() { }
  public void eat() { throw new UnsupportedOperationException(); }
}

// ✅ Follows ISP — segregated interfaces
interface Workable { void work(); }
interface Eatable { void eat(); }
class Robot implements Workable { }
class Human implements Workable, Eatable { }
```

**How to Apply**:
- Create small, focused interfaces
- Avoid "god interfaces" with many methods
- A class should only implement what it needs
- If implementing an interface means implementing unused methods, segregate

### 5. Dependency Inversion Principle (DIP)
High-level modules should not depend on low-level modules. Both should depend on abstractions.

**Why**: Reduces coupling and makes code more flexible.

**Example**:
```java
// ❌ Violates DIP — high-level depends on low-level
class UserService {
  private MySQLDatabase db = new MySQLDatabase();
  public void saveUser(User u) { db.save(u); }
}

// ✅ Follows DIP — both depend on abstraction
interface Database { void save(User u); }
class MySQLDatabase implements Database { }
class UserService {
  private Database db;
  public UserService(Database db) { this.db = db; }
}
```

**How to Apply**:
- Depend on abstractions (interfaces), not concrete implementations
- Use dependency injection to provide dependencies
- Inject dependencies through constructors
- Allow implementations to be swapped without changing high-level code

## SOLID in Practice

### Benefits
- ✓ Code is easier to understand
- ✓ Classes are easier to test
- ✓ Changes are localized to relevant classes
- ✓ New features can be added without modifying existing code
- ✓ Code is more flexible and reusable

### Common Violations

| Principle | Violation | Sign |
|-----------|-----------|------|
| SRP | Multiple responsibilities | Hard to name class, many reasons to change |
| OCP | Modification instead of extension | Adding features requires modifying existing code |
| LSP | Broken inheritance contract | Derived class can't replace base class |
| ISP | Bloated interfaces | Classes implement unused methods |
| DIP | Direct concrete dependencies | High-level depends on low-level, tight coupling |

## When to Apply

- **Architecture decisions** — Shape your class hierarchies
- **Design reviews** — Evaluate proposed designs
- **Refactoring** — Identify and fix design issues
- **Code reviews** — Provide constructive feedback
- **New projects** — Set the right foundation

## Relationship to Clean Code

SOLID extends Clean Code principles into architecture:
- **Clean Code** addresses implementation quality (functions, naming, formatting)
- **SOLID** addresses design quality (class relationships, dependencies, extensibility)

Together they create professional, maintainable software.
