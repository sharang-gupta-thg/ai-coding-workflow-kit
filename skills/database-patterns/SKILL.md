---
name: database-patterns
description: "Database design patterns — N+1 queries, indexing, transactions, caching, and CQRS for performance and scalability."
user-invocable: true
argument-hint: "[query|index|performance] - Example: 'Optimize this N+1 query'"
---

# Database Patterns

**Goal**: Fast queries, scalable systems, data consistency

## The N+1 Problem

**What is it**: Fetching parent records then querying child records for each parent

```java
// ❌ N+1 Problem
List<User> users = userRepository.findAll(); // 1 query
for (User user : users) {
  List<Post> posts = postRepository.findByUserId(user.getId()); // N queries (1 per user!)
}
```

**Solutions**:

### Solution 1: Eager Loading (Join)
```java
// ✓ 1 query with JOIN
@Query("SELECT u FROM User u LEFT JOIN FETCH u.posts WHERE u.id IN :ids")
List<User> findWithPosts(@Param("ids") List<Integer> ids);
```

### Solution 2: Batch Loading
```java
// ✓ 2 queries (1 users, 1 posts with IN clause)
List<User> users = userRepository.findAll();
List<Post> posts = postRepository.findByUserIdIn(
  users.stream().map(User::getId).collect(toList())
);
```

### Solution 3: CQRS (Read Model)
```java
// ✓ Pre-denormalized query
@Query("SELECT new UserWithPosts(u.id, u.name, COUNT(p)) FROM User u LEFT JOIN Post p ON u.id = p.userId GROUP BY u.id")
List<UserWithPosts> findUsersWithPostCount();
```

## Indexing Strategy

### When to Index

```sql
-- Index columns you query on
CREATE INDEX idx_user_email ON users(email);
CREATE INDEX idx_post_user_id ON posts(user_id);

-- Index columns you sort by
CREATE INDEX idx_post_created_at ON posts(created_at DESC);

-- Composite index for common filters
CREATE INDEX idx_post_user_status ON posts(user_id, status);
```

### Index Dos and Don'ts

✓ Index WHERE clause columns  
✓ Index JOIN columns  
✓ Index ORDER BY columns  
✓ Use composite indexes wisely  
✗ Index low-cardinality columns (status, boolean)  
✗ Over-index (too many indexes slow inserts)  

## Query Analysis

### EXPLAIN PLANS
```sql
EXPLAIN ANALYZE SELECT * FROM users WHERE email = 'user@example.com';

-- Output:
-- Index Scan using idx_user_email on users
-- Index Cond: (email = 'user@example.com')
```

### Red Flags in EXPLAIN
- Sequential Scan (Seq Scan) when index available
- High rows estimate vs actual (missing statistics)
- Nested Loop joins when hash joins possible
- Full table scans for large tables

## Transaction Isolation Levels

| Level | Dirty Reads | Non-Repeatable | Phantom | Concurrency |
|-------|-------------|----------------|---------|-------------|
| Read Uncommitted | Possible | Possible | Possible | High |
| Read Committed | No | Possible | Possible | Medium |
| Repeatable Read | No | No | Possible | Low |
| Serializable | No | No | No | Very Low |

**Default**: Read Committed (suitable for most applications)  
**Finance**: Serializable (prevent phantom reads)

```java
// Set isolation level
@Transactional(isolation = Isolation.SERIALIZABLE)
public void transferMoney(Account from, Account to, double amount) {
  // Financial transaction
}
```

## Connection Pooling

**Problem**: Creating new connections is expensive

**Solution**: Maintain a pool of reusable connections

```
Config (HikariCP):
- Maximum pool size: 20
- Minimum idle: 5
- Connection timeout: 30s
- Idle timeout: 10 minutes
```

```java
@Configuration
public class DataSourceConfig {
  @Bean
  public DataSource dataSource() {
    HikariConfig config = new HikariConfig();
    config.setMaximumPoolSize(20);
    config.setMinimumIdle(5);
    return new HikariDataSource(config);
  }
}
```

## Caching Patterns

### Pattern 1: Cache-Aside
```java
public User getUser(int id) {
  User user = cache.get(id);
  if (user == null) {
    user = database.find(id);
    cache.put(id, user);
  }
  return user;
}
```

### Pattern 2: Write-Through Cache
```java
public void updateUser(User user) {
  database.save(user);
  cache.put(user.getId(), user);
}
```

### Pattern 3: Write-Behind Cache
```java
public void updateUser(User user) {
  cache.put(user.getId(), user);
  // Asynchronously write to database
  asyncWriter.write(user);
}
```

## Cache Invalidation

```java
// Pub/Sub based invalidation
public void updateUser(User user) {
  userRepository.save(user);
  // Publish event to all cache nodes
  eventPublisher.publish(new UserUpdatedEvent(user.getId()));
}

// Cache listener
@CacheEvict(value = "users", key = "#event.userId")
@EventListener
public void onUserUpdated(UserUpdatedEvent event) {
  // Cache automatically evicted
}
```

## CQRS Pattern

Separate read and write models

```
Write Side (Commands):
┌─────────────┐
│   Command   │
└──────┬──────┘
       │
    Normalized Schema
    (ACID, transactions)
       │
  Event Sourcing
       │
    Event Stream
       │
Read Models (Denormalized):
   PostgreSQL, Redis, Elasticsearch
```

**Benefits**:
- Optimized queries (denormalized for reads)
- Audit trail (event sourcing)
- Eventual consistency for performance

**Costs**:
- Complexity (eventual consistency)
- Dual maintenance
- Synchronization lag

## Anti-Patterns

- ❌ Querying all columns when you need one
- ❌ N+1 queries
- ❌ No indexes on join columns
- ❌ Too many indexes (slows inserts)
- ❌ Infinite caching (no expiration)
- ❌ Caching invalid data
- ❌ Transactions holding locks too long
- ❌ SELECT * in production code

## Checklist

- [ ] Query plans analyzed (EXPLAIN)
- [ ] Indexes on JOIN and WHERE columns
- [ ] No N+1 queries (use batch or eager loading)
- [ ] Connection pooling configured
- [ ] Appropriate transaction isolation
- [ ] Cache invalidation strategy
- [ ] Slow query monitoring enabled
- [ ] Read replicas for scale (if needed)
