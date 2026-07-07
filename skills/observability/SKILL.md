---
name: observability
description: "Observability practices — structured logging, metrics, distributed tracing, and SLO/SLI frameworks for production systems."
user-invocable: true
argument-hint: "[logging|tracing|metrics] - Example: 'What should we log here?'"
---

# Observability

**Framework**: Three pillars — Logs, Metrics, Traces  
**Goal**: Understand system behavior, debug issues, measure reliability

## Structured Logging

### Anti-Pattern: Unstructured Logs
```
2026-07-07 12:34:56 ERROR User authentication failed
2026-07-07 12:34:57 ERROR Database connection timeout
2026-07-07 12:34:58 ERROR User authentication failed
```
Hard to search, parse, and correlate.

### Best Practice: Structured Logging
```json
{
  "timestamp": "2026-07-07T12:34:56Z",
  "level": "ERROR",
  "logger": "com.example.auth.UserAuthenticator",
  "message": "User authentication failed",
  "userId": "user-123",
  "traceId": "a1b2c3d4-e5f6",
  "context": "login-attempt",
  "error": {
    "type": "InvalidCredentialsException",
    "message": "Password mismatch"
  }
}
```

### Implementation
```java
// Using structured logging
logger.error("User authentication failed", 
  "userId", userId,
  "traceId", traceId,
  "attemptCount", attemptCount,
  "reason", reason);
```

### Log Levels
- **DEBUG**: Development only, verbose information
- **INFO**: Important events (user login, job started)
- **WARN**: Unexpected but recoverable (retry, fallback)
- **ERROR**: Errors that need attention (failed transaction)
- **CRITICAL**: System-wide failures

### What NOT to Log
❌ Passwords, API keys, tokens  
❌ Personally identifiable information (PII)  
❌ Credit card numbers  
❌ Sensitive business data (internal pricing)

## Distributed Tracing

### Problem
In microservices, a user request spans multiple services. Where does it slow down?

### Solution: Trace IDs
```
User Request
    ↓
[API Gateway] traceId=abc123
    ↓ 
[User Service] traceId=abc123
    ↓
[Payment Service] traceId=abc123
    ↓
[Notification Service] traceId=abc123
```

Each service logs with the same traceId, enabling end-to-end correlation.

### Implementation
```java
// Generate trace ID at entry point
String traceId = UUID.randomUUID().toString();

// Add to logs
MDC.put("traceId", traceId);
logger.info("Request started", "path", request.getPath());

// Pass to downstream services
httpClient.setHeader("X-Trace-ID", traceId);

// Downstream services extract and use it
String traceId = request.getHeader("X-Trace-ID");
MDC.put("traceId", traceId);
```

### OpenTelemetry (Standard)
```java
// OpenTelemetry auto-instruments most frameworks
Tracer tracer = GlobalTracer.get();
Span span = tracer.spanBuilder("process-payment").startSpan();
try (Scope scope = span.makeCurrent()) {
  // Your code - automatically traced
  processPayment();
} catch (Exception e) {
  span.setStatus(StatusCode.ERROR, e.getMessage());
  throw e;
} finally {
  span.end();
}
```

## Metrics

### Key Metrics for Services

**Request Metrics**:
- Request rate (req/sec)
- Response time (latency percentiles: p50, p95, p99)
- Error rate (%)

**System Metrics**:
- CPU usage
- Memory usage
- Disk I/O
- Network I/O

**Business Metrics**:
- Revenue per minute
- Conversions
- Feature adoption

```
// Prometheus format
http_requests_total{method="GET",path="/users",status="200"} 1234
http_request_duration_seconds{method="GET",quantile="0.95"} 0.25
database_query_duration_seconds{query="users_by_id"} 0.005
```

## SLO/SLI/SLA Framework

### Definitions

**SLI (Service Level Indicator)**: Measurable metric  
Example: "99% of requests complete within 500ms"

**SLO (Service Level Objective)**: Target for SLI  
Example: "We aim for 99.9% uptime"

**SLA (Service Level Agreement)**: Contract with penalties  
Example: "If uptime < 99%, customers get a refund"

### Error Budget

```
SLO: 99.9% uptime
= 99.9% reliability
= 0.1% can fail
= 8.64 seconds of downtime per day
= 43 minutes per month (error budget)
```

**What to do with error budget**:
- Use for risky deployments (can afford failures)
- Use for performance experimentation
- When exhausted, focus on reliability (no risky changes)

### Implementation
```
Month Start
├─ Budget: 43.2 minutes
├─ Day 1: Incident (5 min downtime) → Budget: 38.2 min remaining
├─ Day 15: Deploy new feature (risky, acceptable) → Downtime: 2 min
├─ Budget remaining: 36.2 minutes
└─ Remainder: Can still take 36 minutes of downtime
```

## Alerting

### Good Alerts
- ✓ Alert on symptoms (high error rate), not causes (CPU spiking)
- ✓ Actionable (engineer knows what to do)
- ✓ Have runbooks
- ✓ Unlikely to fire while people sleep

### Bad Alerts
- ❌ Alert on every error (too noisy)
- ❌ Alert on predicted failure (too early)
- ❌ Alert on internal metrics you can't act on

```yaml
# Alert Levels
CRITICAL: Customer-facing service down
          → Wake someone up
          → Requires immediate action

MAJOR:    Degraded service, high latency
          → Page on-call during business hours
          → Investigate next business day if off-hours

MINOR:    Non-critical metric degraded
          → Log as ticket
          → Review in daily standup
```

## Correlation IDs

Essential for multi-service debugging:

```
Request arrives at API Gateway
  traceId = "abc-123"
  spanId = "span-1"
          ↓
    API Gateway logs: [traceId: abc-123, spanId: span-1]
          ↓
    Passes to User Service: X-Trace-ID: abc-123, X-Span-ID: span-2
          ↓
    User Service logs: [traceId: abc-123, spanId: span-2, parentSpan: span-1]
          ↓
    Passes to Payment Service: X-Trace-ID: abc-123, X-Span-ID: span-3
          ↓
    Payment Service logs: [traceId: abc-123, spanId: span-3, parentSpan: span-2]
```

**Query format**:
```bash
# Find all logs for this request
SELECT * FROM logs WHERE traceId = "abc-123"

# Result: Full request trace across all services
api-gateway [12:34:56.001] span-1
  → user-service [12:34:56.050] span-2
    → payment-service [12:34:56.100] span-3
    ← [12:34:56.200] complete
  ← [12:34:56.250] complete
← [12:34:56.300] complete
```

## Checklist

- [ ] Structured logging in all services
- [ ] Trace IDs propagated across services
- [ ] No secrets in logs
- [ ] Key business metrics measured
- [ ] SLO defined and monitored
- [ ] Error budget tracked
- [ ] Alerts actionable and tuned
- [ ] Runbooks for critical alerts
- [ ] OpenTelemetry or equivalent implemented
- [ ] Log retention policy defined
- [ ] PII handling policy enforced

## Tools

- **Logging**: ELK Stack, Splunk, CloudWatch
- **Metrics**: Prometheus, Grafana, DataDog
- **Tracing**: Jaeger, Zipkin, AWS X-Ray
- **Correlation**: OpenTelemetry, Log4j MDC
