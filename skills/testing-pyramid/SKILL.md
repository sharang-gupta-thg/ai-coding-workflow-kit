---
name: testing-pyramid
description: "Testing pyramid strategy — the right balance of unit, integration, and end-to-end tests for confidence and speed."
user-invocable: true
argument-hint: "[level|strategy|coverage] - Example: 'What tests should cover this feature?'"
---

# Testing Pyramid

**Model**: Layer tests by scope and cost  
**Goal**: Fast feedback + complete coverage + manageable test count

## The Pyramid Structure

```
        ╔═══════════════════╗
        ║   End-to-End      ║  Few, slow, expensive
        ║   (UI, Full App)  ║  Real environment
        ╠═══════════════════╣
        ║   Integration     ║  More, moderate speed
        ║   (Components)    ║  Some real resources
        ╠═══════════════════╣
        ║   Unit Tests      ║  Many, fast, cheap
        ║   (Functions)     ║  Isolated, mocked
        ╚═══════════════════╝
```

**Rule**: Build wider base (unit tests), narrower top (E2E tests)

## Unit Tests (Base of Pyramid)

**Scope**: Single function/method in isolation  
**Mocks**: External dependencies  
**Speed**: Milliseconds  
**Cost**: Cheap to write and run

```java
// Unit test — tests one method
@Test
public void calculateDiscount_shouldReturnTenPercent_whenCustomerIsVIP() {
  // Arrange
  Customer customer = new Customer("VIP");
  double purchaseAmount = 100.0;
  
  // Act
  double discount = discountCalculator.calculate(customer, purchaseAmount);
  
  // Assert
  assertEquals(10.0, discount);
}
```

**Characteristics**:
- Fast (< 100ms typically)
- No database, network, or file I/O
- Dependencies are mocked
- One assertion per test (usually)
- Descriptive test names

## Integration Tests (Middle of Pyramid)

**Scope**: Multiple components working together  
**Setup**: Real database, real services (or in-memory)  
**Speed**: Seconds  
**Cost**: Moderate

```java
// Integration test — tests service with real database
@SpringBootTest
public class UserServiceIntegrationTest {
  @Autowired private UserService userService;
  @Autowired private UserRepository userRepository;
  
  @Test
  public void saveUser_shouldPersistToDatabase() {
    // Arrange
    User user = new User("john@example.com", "John");
    
    // Act
    User saved = userService.save(user);
    
    // Assert
    User retrieved = userRepository.findById(saved.getId()).orElseThrow();
    assertEquals("John", retrieved.getName());
  }
}
```

**When to Use**:
- Testing service layer with data access
- Multiple components together
- Testing against test database
- Validating API contract

## End-to-End Tests (Top of Pyramid)

**Scope**: Full application flow  
**Setup**: Real environment or realistic simulation  
**Speed**: Minutes  
**Cost**: Expensive to write and run

```java
// E2E test — tests full user journey
@Test
public void userFlow_shouldCompleteCheckout() {
  // Arrange
  selenium.navigateTo("http://localhost:8080");
  
  // Act
  selenium.click("login-button");
  selenium.typeEmail("user@example.com");
  selenium.typePassword("password");
  selenium.click("submit");
  selenium.click("add-to-cart");
  selenium.click("checkout");
  selenium.typeCardInfo("1234-5678-9012-3456");
  selenium.click("confirm-purchase");
  
  // Assert
  assertTrue(selenium.textContains("Order confirmed"));
}
```

**When to Use**:
- Critical user journeys
- Smoke tests for deployments
- Validating browser compatibility
- Testing real infrastructure

## The Icecream Anti-Pattern

❌ **DON'T**: Many E2E tests, few unit tests

```
    ╔═══════════════╗
    ║   E2E Tests   ║  Too many!
    ╠═══════════════╣
    ║ Integration   ║  Few
    ╠═══════════════╣
    ║ Unit Tests    ║  Too few!
    ╚═══════════════╝
```

**Problems**:
- Slow test suite (hours to run)
- Hard to find what's broken
- Expensive to maintain
- Flaky tests (environmental issues)

## Test Coverage Strategy

### 100% Coverage of Business Logic
- Every decision path tested
- Both success and error cases
- Boundary conditions

```java
@Test
public void isEligible_shouldReturnTrue_whenAgeIsExactlyThreshold() {
  assertTrue(ageValidator.isEligible(18)); // Boundary
}

@Test
public void isEligible_shouldReturnFalse_whenAgeIsBelowThreshold() {
  assertFalse(ageValidator.isEligible(17)); // Below
}
```

### Avoid: Trivial Code Coverage
- Don't test getters/setters
- Don't test constructors with no logic
- Don't test auto-generated code
- Don't test frameworks

## Pyramid in Practice

### For a Feature: What Tests?

**Feature**: User registration with email verification

**Unit Tests** (Many):
- Email validation logic
- Password strength validation
- User entity creation
- Token generation

**Integration Tests** (Several):
- User service with database
- Email sending (with mock SMTP)
- Database query performance

**E2E Tests** (One or two):
- Complete registration flow
- Email delivery and link following

## Test Organization

```
src/
├── main/
│   └── User.java
└── test/
    ├── unit/
    │   └── UserValidatorTest.java
    ├── integration/
    │   └── UserServiceIT.java
    └── e2e/
        └── RegistrationFlowTest.java
```

## Performance Tips

### Unit Tests Should Be Fast
```java
// ✅ Fast — no I/O
@Test(timeout = 100)
public void process_shouldComplete_quickly() {
  // ... test
}
```

### Integration Tests Can Be Slower
```java
// ✅ Acceptable — but not excessive
@Test(timeout = 5000)
public void save_shouldPersist_toDatabase() {
  // ... test
}
```

### E2E Tests Run Separately
```bash
# Run only unit tests (fast feedback)
mvn test

# Run integration tests (when committing)
mvn verify

# Run E2E tests (before deployment)
mvn test -Pend-to-end
```

## Checklist

- [ ] Unit tests cover all business logic
- [ ] Integration tests verify component interaction
- [ ] E2E tests cover critical user paths
- [ ] Tests are independent (no dependencies between them)
- [ ] Tests are deterministic (same result every run)
- [ ] Test names clearly describe scenario
- [ ] Arrange-Act-Assert pattern followed
- [ ] Database state cleaned between tests
- [ ] Mocks and stubs used appropriately
- [ ] Test suite runs in reasonable time (< 10 minutes)

## Anti-Patterns

- ❌ Testing implementation, not behavior
- ❌ Tests with side effects on other tests
- ❌ Too many E2E tests, too few unit tests
- ❌ Flaky tests that pass sometimes
- ❌ Tests that don't actually assert anything
- ❌ Testing framework code instead of your code
