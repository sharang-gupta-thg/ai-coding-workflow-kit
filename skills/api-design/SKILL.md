---
name: api-design
description: "API design principles — REST, GraphQL, and gRPC best practices for versioning, naming, documentation, and developer experience."
user-invocable: true
argument-hint: "[endpoint|versioning|documentation] - Example: 'Design a REST endpoint for user creation'"
---

# API Design

**Scope**: Public and internal APIs (REST, GraphQL, gRPC)  
**Goal**: Clear contracts, discoverability, backward compatibility

## REST API Principles

### Naming Conventions

```
✓ Use nouns for resources
  GET /users           (collection)
  GET /users/123       (single resource)
  GET /users/123/posts (related resources)

✓ Use verbs in query parameters for actions
  POST /users/123/send-email
  POST /payments/process
  POST /reports/generate

✗ Don't use verbs in paths
  GET /getUser         ❌
  POST /createUser     ❌
  DELETE /deleteUser   ❌
```

### HTTP Methods

| Method | Action | Idempotent | Safe |
|--------|--------|-----------|------|
| GET | Retrieve | Yes | Yes |
| POST | Create/Action | No | No |
| PUT | Replace | Yes | No |
| PATCH | Partial update | No | No |
| DELETE | Remove | Yes | No |

```java
// ✓ Correct usage
GET /users/123              // Retrieve
POST /users                 // Create
PUT /users/123              // Replace entire resource
PATCH /users/123            // Partial update
DELETE /users/123           // Delete

// ✗ Wrong
GET /users/123/delete       // Use DELETE method
POST /users/get             // Use GET method
```

### Status Codes

```
2xx Success
  200 OK - General success
  201 Created - Resource created
  204 No Content - Success, no body

3xx Redirection
  301 Moved Permanently
  302 Found (temporary)
  304 Not Modified

4xx Client Error
  400 Bad Request - Invalid input
  401 Unauthorized - Authentication required
  403 Forbidden - Authenticated but not allowed
  404 Not Found - Resource doesn't exist
  409 Conflict - Can't fulfill request (e.g., duplicate)
  422 Unprocessable Entity - Validation failed

5xx Server Error
  500 Internal Server Error
  503 Service Unavailable
```

### Response Format

```json
{
  "data": {
    "id": "123",
    "name": "John",
    "email": "john@example.com"
  },
  "meta": {
    "timestamp": "2026-07-07T12:00:00Z"
  }
}
```

## API Versioning

### Strategy 1: URI Versioning
```
GET /v1/users
GET /v2/users
```
**Pros**: Easy to discover, clear separation  
**Cons**: Pollutes URL space, multiple implementations

### Strategy 2: Header Versioning
```
GET /users
Accept: application/vnd.myapi.v2+json
```
**Pros**: Clean URLs  
**Cons**: Not discoverable, hard to test in browser

### Strategy 3: Query Parameter
```
GET /users?api-version=2
```
**Pros**: Flexible  
**Cons**: Verbose

**Recommendation**: URI versioning for clarity, maintain backward compatibility for 2 versions

## Pagination, Filtering, Sorting

```
# Pagination
GET /users?page=1&limit=20

# Filtering
GET /users?status=active&role=admin

# Sorting
GET /users?sort=-created_at,name

# Response includes pagination metadata
{
  "data": [...],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 500,
    "pages": 25
  }
}
```

## Error Responses

```json
{
  "error": {
    "code": "VALIDATION_FAILED",
    "message": "Request validation failed",
    "details": [
      {
        "field": "email",
        "message": "Invalid email format"
      },
      {
        "field": "age",
        "message": "Must be at least 18"
      }
    ]
  }
}
```

## GraphQL Principles

### Benefits Over REST
- Single endpoint
- Exactly the fields needed (no over/under fetching)
- Strong typing
- Built-in introspection

### Schema Example
```graphql
type User {
  id: ID!
  name: String!
  email: String!
  posts: [Post!]!
}

type Query {
  user(id: ID!): User
  users(limit: Int, offset: Int): [User!]!
}

type Mutation {
  createUser(input: CreateUserInput!): User
  updateUser(id: ID!, input: UpdateUserInput!): User
  deleteUser(id: ID!): Boolean
}
```

### Versioning in GraphQL
- Avoid version numbers
- Mark deprecated fields with `@deprecated`
- Add new fields, don't change existing ones
- Migration guides for deprecated fields

```graphql
type User {
  id: ID!
  name: String!
  email: String! @deprecated(reason: "Use emailAddress instead")
  emailAddress: String!
}
```

## gRPC (Internal Services)

- HTTP/2 based
- Protocol Buffers for serialization
- 5-10x more efficient than JSON
- Strongly typed

```protobuf
service UserService {
  rpc GetUser(GetUserRequest) returns (User);
  rpc CreateUser(CreateUserRequest) returns (User);
  rpc ListUsers(ListUsersRequest) returns (ListUsersResponse);
}

message User {
  string id = 1;
  string name = 2;
  string email = 3;
}
```

## Authentication & Authorization

### API Key
```
Authorization: Bearer sk_live_abc123def456
```
Simple, suitable for non-sensitive operations

### OAuth 2.0
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```
Industry standard for delegated access

### Mutual TLS (mTLS)
For service-to-service authentication

## Documentation

### Auto-Generated (Best)
- OpenAPI/Swagger for REST
- GraphQL Schema Introspection
- Protocol Buffers for gRPC

### Manual (Supplement)
- Examples for common use cases
- Migration guides for versions
- Authentication setup
- Rate limits and quotas

## Rate Limiting

```
HTTP/1.1 200 OK
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 234
X-RateLimit-Reset: 1234567890
```

## Backward Compatibility

**Rules**:
- Never remove fields
- Never change field types
- Never rename fields
- Always make new fields optional
- Support multiple versions during transition

```java
// ✓ Compatible change
public class User {
  private String email;
  private String emailAddress;  // New field, old one stays
}

// ✗ Breaking change
// Removing 'email' field or changing its type
```

## Checklist

- [ ] Resources named as nouns
- [ ] HTTP methods used correctly
- [ ] Status codes appropriate
- [ ] Error responses informative
- [ ] Pagination for large collections
- [ ] Filtering and sorting supported
- [ ] Versioning strategy documented
- [ ] Authentication method clear
- [ ] Rate limiting communicated
- [ ] Documentation auto-generated
- [ ] Backward compatibility maintained
- [ ] Examples provided for each endpoint
