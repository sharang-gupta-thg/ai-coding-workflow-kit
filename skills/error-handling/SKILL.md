---
name: error-handling
description: "Error handling strategies — choosing between checked/unchecked exceptions, result types, and error recovery patterns."
user-invocable: true
argument-hint: "[exception|recovery|strategy] - Example: 'Should this throw or return a result?'"
---

# Error Handling

**Goal**: Propagate information about failures clearly while enabling recovery

## Exception Types

### Checked Exceptions
- Represent recoverable conditions (file not found, network timeout)
- Caller must handle or declare
- Use sparingly — they can make APIs cluttered

```java
public class FileReader {
  public String read(String path) throws FileNotFoundException, IOException {
    // Caller must handle these
  }
}
```

### Unchecked Exceptions
- Represent programming errors (null pointer, illegal argument)
- Don't require declaration
- Use for conditions the caller can't reasonably handle

```java
public void setAge(int age) {
  if (age < 0) {
    throw new IllegalArgumentException("Age cannot be negative");
  }
  this.age = age;
}
```

## Error Handling Strategies

### Strategy 1: Throw Specific Exceptions
```java
// ❌ Generic exception
throw new Exception("Something went wrong");

// ✅ Specific exception with context
if (amount <= 0) {
  throw new IllegalArgumentException(
    "Amount must be positive, got: " + amount
  );
}
if (!fileExists(path)) {
  throw new FileNotFoundException(
    "Configuration file not found: " + path
  );
}
```

### Strategy 2: Try-Catch-Finally
```java
InputStream stream = null;
try {
  stream = new FileInputStream(path);
  // process stream
} catch (FileNotFoundException e) {
  logger.error("File not found: " + path, e);
  return defaultValue;
} catch (IOException e) {
  throw new RuntimeException("Failed to read file", e);
} finally {
  if (stream != null) {
    stream.close();
  }
}
```

### Strategy 3: Try-With-Resources (ARM)
```java
// ✅ Automatic resource management
try (InputStream stream = new FileInputStream(path)) {
  return readContent(stream);
} catch (FileNotFoundException e) {
  logger.error("File not found", e);
  return defaultValue;
} catch (IOException e) {
  throw new RuntimeException("Failed to read", e);
}
```

### Strategy 4: Result Type (Functional Approach)
```java
public class Result<T> {
  private final T value;
  private final Exception error;
  
  private Result(T value, Exception error) {
    this.value = value;
    this.error = error;
  }
  
  public static <T> Result<T> success(T value) {
    return new Result<>(value, null);
  }
  
  public static <T> Result<T> failure(Exception error) {
    return new Result<>(null, error);
  }
  
  public boolean isSuccess() { return error == null; }
  public T getValue() { return value; }
  public Exception getError() { return error; }
}

// Usage
Result<Data> result = loadData();
if (result.isSuccess()) {
  processData(result.getValue());
} else {
  handleError(result.getError());
}
```

### Strategy 5: Optional for Missing Values
```java
// ❌ Throws NPE if not found
public User findUser(int id) {
  return userMap.get(id); // May be null
}

// ✅ Explicit about missing value
public Optional<User> findUser(int id) {
  return Optional.ofNullable(userMap.get(id));
}

// Usage
findUser(42)
  .ifPresentOrElse(
    user -> processUser(user),
    () -> handleNotFound()
  );
```

## Error Recovery Patterns

### Pattern 1: Retry with Backoff
```java
public <T> T retryWithBackoff(
    Supplier<T> operation, 
    int maxRetries, 
    long delayMs) {
  for (int attempt = 0; attempt < maxRetries; attempt++) {
    try {
      return operation.get();
    } catch (TemporaryException e) {
      if (attempt == maxRetries - 1) throw e;
      Thread.sleep(delayMs * (long) Math.pow(2, attempt));
    }
  }
  throw new RuntimeException("Operation failed after " + maxRetries + " attempts");
}
```

### Pattern 2: Fallback Value
```java
public String getConfig(String key) {
  try {
    return configFile.getValue(key);
  } catch (ConfigurationException e) {
    logger.warn("Config key not found: " + key, e);
    return getDefaultValue(key);
  }
}
```

### Pattern 3: Circuit Breaker
```java
public class CircuitBreaker {
  private State state = State.CLOSED;
  private int failures = 0;
  
  public <T> T call(Supplier<T> operation) {
    if (state == State.OPEN) {
      throw new CircuitBreakerOpenException();
    }
    
    try {
      T result = operation.get();
      onSuccess();
      return result;
    } catch (Exception e) {
      onFailure();
      throw e;
    }
  }
}
```

## Exception Chains

**Problem**: You catch a low-level exception but need to throw a high-level one
**Solution**: Chain exceptions to preserve context

```java
// ❌ Loses original error
try {
  connectToDatabase();
} catch (SQLException e) {
  throw new RuntimeException("Database error");
}

// ✅ Chains exceptions
try {
  connectToDatabase();
} catch (SQLException e) {
  throw new RuntimeException("Failed to connect to database", e);
}
```

## Checklist

- [ ] Exceptions are specific (not generic)
- [ ] Exceptions include context (message, cause)
- [ ] Checked exceptions are truly recoverable
- [ ] Unchecked exceptions for programming errors
- [ ] Errors logged with full context
- [ ] Resources cleaned up (try-finally or ARM)
- [ ] No swallowing exceptions (catch without action)
- [ ] Proper exception ordering (specific before general)

## Anti-Patterns

- ❌ Empty catch blocks
- ❌ Catching Exception or Throwable
- ❌ Logging and rethrowing (duplicate logs)
- ❌ Throwing generic Exception
- ❌ Ignoring InterruptedException
- ❌ Using exceptions for control flow
- ❌ Not including original exception (loses stack trace)
