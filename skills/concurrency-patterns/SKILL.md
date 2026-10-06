---
name: concurrency-patterns
description: "Concurrency and thread-safety patterns: shared state, synchronization, locks and atomics, race and deadlock prevention, concurrent collections and async patterns. Use when code runs in parallel, shares mutable state, or you need to ask 'is this thread-safe?'."
user-invocable: true
argument-hint: "[pattern|thread-safety|synchronization] - Example: 'Is this code thread-safe?'"
---

# Concurrency Patterns

**Focus**: Writing safe, efficient multi-threaded code  
**Scope**: Threading, synchronization, concurrent collections, async patterns

## Core Concepts

### 1. The Visibility Problem
Changes made by one thread aren't visible to others without synchronization.

```java
// ❌ Not thread-safe
class Counter {
  private int count = 0;
  public void increment() { count++; } // Lost updates
  public int getCount() { return count; }
}

// ✅ Thread-safe
class Counter {
  private volatile int count = 0;
  public synchronized void increment() { count++; }
  public synchronized int getCount() { return count; }
}

// ✅ Or use AtomicInteger
class Counter {
  private AtomicInteger count = new AtomicInteger(0);
  public void increment() { count.incrementAndGet(); }
  public int getCount() { return count.get(); }
}
```

### 2. The Atomicity Problem
Operations that look atomic aren't (check-then-act, read-modify-write).

```java
// ❌ Race condition
if (!list.contains(item)) {
  list.add(item); // Another thread might add same item between check and add
}

// ✅ Atomic operation
synchronized(list) {
  if (!list.contains(item)) {
    list.add(item);
  }
}
```

## Synchronization Strategies

### Strategy 1: Locks (synchronized, ReentrantLock)
```java
// Simple lock
class BankAccount {
  private double balance;
  
  public synchronized void withdraw(double amount) {
    if (balance >= amount) {
      balance -= amount;
    }
  }
}

// Fine-grained locking
class BankAccount {
  private final Lock lock = new ReentrantLock();
  private double balance;
  
  public void withdraw(double amount) {
    lock.lock();
    try {
      if (balance >= amount) {
        balance -= amount;
      }
    } finally {
      lock.unlock();
    }
  }
}
```

### Strategy 2: Immutability
```java
// ✅ Thread-safe by design
final class ImmutablePoint {
  private final int x;
  private final int y;
  
  public ImmutablePoint(int x, int y) {
    this.x = x;
    this.y = y;
  }
  
  public int getX() { return x; }
  public int getY() { return y; }
}
```

### Strategy 3: Thread-Confined Objects
```java
// Objects belong to specific threads
class UserSession {
  private final ThreadLocal<User> currentUser = new ThreadLocal<>();
  
  public void setUser(User user) { currentUser.set(user); }
  public User getUser() { return currentUser.get(); }
}
```

### Strategy 4: Concurrent Collections
```java
// Use thread-safe collections
ConcurrentHashMap<String, Value> map = new ConcurrentHashMap<>();
CopyOnWriteArrayList<Item> list = new CopyOnWriteArrayList<>();
```

## Common Patterns

### Pattern 1: Producer-Consumer
```java
class Buffer {
  private final BlockingQueue<Item> queue = new LinkedBlockingQueue<>();
  
  public void produce(Item item) throws InterruptedException {
    queue.put(item);
  }
  
  public Item consume() throws InterruptedException {
    return queue.take();
  }
}
```

### Pattern 2: Read-Write Lock
```java
class Cache {
  private final ReadWriteLock lock = new ReentrantReadWriteLock();
  private Map<String, Data> data = new HashMap<>();
  
  public Data get(String key) {
    lock.readLock().lock();
    try {
      return data.get(key);
    } finally {
      lock.readLock().unlock();
    }
  }
  
  public void put(String key, Data value) {
    lock.writeLock().lock();
    try {
      data.put(key, value);
    } finally {
      lock.writeLock().unlock();
    }
  }
}
```

### Pattern 3: Future/Promise
```java
ExecutorService executor = Executors.newFixedThreadPool(10);
Future<Result> future = executor.submit(() -> {
  return doExpensiveWork();
});

Result result = future.get(); // Blocks until ready
```

## Deadlock Prevention

### What Causes Deadlock
Two threads wait for each other:
```java
// Thread 1        | Thread 2
// lock A          | lock B
// wait for B      | wait for A
// DEADLOCK!
```

### How to Prevent

1. **Lock Ordering** — Always acquire locks in the same order
2. **Timeout** — Use locks with timeouts
3. **Single Lock** — Use one lock for related data
4. **Avoid Nested Locks** — Acquire all needed locks at once

```java
// ✅ Lock ordering
public synchronized void transferMoney(Account from, Account to, double amount) {
  Account first = from.getId() < to.getId() ? from : to;
  Account second = from.getId() < to.getId() ? to : from;
  
  synchronized(first) {
    synchronized(second) {
      from.withdraw(amount);
      to.deposit(amount);
    }
  }
}
```

## Performance Tips

### Use Volatile for Flags
```java
class Worker {
  private volatile boolean running = true;
  
  public void stop() { running = false; }
  public void work() {
    while (running) { /* do work */ }
  }
}
```

### Use Atomic Variables for Counters
```java
private AtomicInteger counter = new AtomicInteger(0);
counter.incrementAndGet();
```

### Minimize Lock Scope
```java
// ❌ Lock too much
public synchronized Map<String, Data> getAll() {
  // lots of processing while holding lock
  return new HashMap<>(data);
}

// ✅ Lock only what's necessary
public Map<String, Data> getAll() {
  Map<String, Data> copy;
  synchronized(this) {
    copy = new HashMap<>(data);
  }
  // processing happens without lock
  return copy;
}
```

## Checklist

- [ ] Shared state is synchronized or immutable
- [ ] No lost updates (use synchronized or atomic)
- [ ] Visibility guaranteed (synchronized, volatile, or atomics)
- [ ] No deadlocks (consistent lock ordering)
- [ ] Exception safety (try-finally or ARM)
- [ ] Appropriate synchronization level (fine vs coarse)
- [ ] No priority inversion issues
- [ ] Performance acceptable (minimal lock contention)

## Red Flags

- ❌ Shared mutable state without synchronization
- ❌ Long operations while holding locks
- ❌ Nested locks without ordering
- ❌ Catching InterruptedException and ignoring it
- ❌ Spin loops instead of wait/notify
- ❌ Over-synchronization (everything synchronized)
- ❌ ThreadLocal without cleanup
