---
name: code-review-practices
description: "Code review practice: what to look for, how to write specific and constructive feedback, how to size a PR and how to respond to review comments. Use when reviewing a pull request, writing review comments, or preparing a change for review."
user-invocable: true
argument-hint: "[feedback|standards|improvement] - Example: 'Review this PR for quality issues'"
---

# Code Review Practices

**Goal**: Improve code quality, knowledge sharing, and team standards  
**Culture**: Collaborative improvement, not gatekeeping

## What to Review

### Architecture & Design (High Impact)
- ✓ Does the solution match the architecture?
- ✓ Are dependencies structured correctly?
- ✓ Does it follow SOLID principles?
- ✓ Are there cleaner approaches?

### Correctness (Critical)
- ✓ Are all edge cases handled?
- ✓ Is error handling appropriate?
- ✓ Are there off-by-one errors?
- ✓ Are there null pointer risks?

### Performance (Important)
- ✓ Any N+1 queries?
- ✓ Unnecessary database calls?
- ✓ Inefficient algorithms?
- ✓ Memory leaks or resource leaks?

### Security (Critical)
- ✓ Input validation present?
- ✓ Authentication/authorization correct?
- ✓ Secrets in code? (No!)
- ✓ SQL injection possible?
- ✓ XSS vulnerability?

### Testing (Important)
- ✓ Tests present and meaningful?
- ✓ Edge cases covered?
- ✓ Tests are isolated?
- ✓ Clear test names?

### Maintainability (Important)
- ✓ Code is clear and readable?
- ✓ Comments explain WHY, not WHAT?
- ✓ Names are intention-revealing?
- ✓ Functions do one thing?

## What NOT to Review

❌ Style issues that linters catch (use autoformat)  
❌ Personal code style preferences  
❌ Things already addressed in previous comments  
❌ Things outside scope of PR  

## Size Guidelines

**PR Size**:
- **Small (< 100 LoC)**: Can review thoroughly
- **Medium (100-400 LoC)**: Acceptable, good balance
- **Large (400-1000 LoC)**: Fatigue, miss rate increases
- **Huge (> 1000 LoC)**: Request smaller PRs

**Fatigue Effect**: After 400 lines, reviewers catch 25% fewer defects per additional line.

## How to Give Feedback

### Good Feedback (Constructive)
```
"I'm concerned this might cause an N+1 query issue. 
When there are many users, this could loop through 
the results list and query per user. Consider using 
an eager load or batch query instead."
```

### Poor Feedback (Dismissive)
```
"This is inefficient" ❌
```

### Good Feedback (Offers Help)
```
"This looks good overall. One thing I'd suggest: 
we could extract this logic into a helper method 
to reduce duplication with the similar code in 
UserService. Want me to show an example?"
```

### Formula for Constructive Feedback

1. **Acknowledge** what's good
2. **State** the concern specifically
3. **Explain** why it matters
4. **Suggest** an alternative
5. **Invite** discussion

### Examples

**Architecture Concern**:
```
"The service layer is creating the repository directly 
instead of injecting it. This makes testing harder and 
violates dependency inversion. Consider passing the 
repository as a constructor parameter."
```

**Performance Concern**:
```
"I see this queries the user table in a loop. This is 
likely an N+1 problem. Consider loading all users upfront 
with findByIds() or eager loading in the initial query."
```

**Security Concern**:
```
"This endpoint accepts user input and passes it directly 
to a database query. We need to parameterize this or use 
an ORM. Vulnerable to SQL injection."
```

## How to Receive Feedback

### Do
✓ Thank the reviewer  
✓ Ask clarifying questions  
✓ Consider the feedback seriously  
✓ Explain your reasoning if disagreeing  
✓ Make requested changes promptly  

### Don't
❌ Take it personally  
❌ Be defensive  
❌ Ignore serious concerns  
❌ Dismiss without thinking  
❌ Make excuses ("I was in a hurry")  

### Responding to Feedback

**Good Response**:
```
"Good point about the N+1 query. I'll refactor 
to use eager loading. Let me push an update."
```

**Good Disagreement**:
```
"I considered this approach, but I think the 
loop is clearer for now since there are typically 
only 5-10 items. Once we hit scale, we can optimize. 
What do you think?"
```

## Review Checklist

### Architecture & Design
- [ ] Follows project conventions
- [ ] No unnecessary complexity
- [ ] Components properly separated
- [ ] No circular dependencies
- [ ] Follows SOLID principles

### Correctness & Safety
- [ ] Edge cases handled
- [ ] Error handling present
- [ ] No null pointer risks
- [ ] No security vulnerabilities
- [ ] No off-by-one errors

### Performance
- [ ] No N+1 queries
- [ ] No unnecessary computations
- [ ] Appropriate caching
- [ ] Resource cleanup

### Testing
- [ ] Tests present
- [ ] Tests meaningful
- [ ] Edge cases covered
- [ ] Tests isolated

### Code Quality
- [ ] Readable and clear
- [ ] Well-named variables
- [ ] Appropriate comments
- [ ] Functions focused (SRP)
- [ ] Proper error messages

### Maintainability
- [ ] Documentation updated
- [ ] Follows code style
- [ ] Version compatibility
- [ ] Backwards compatible

## Common Issues to Watch For

| Issue | Impact | Fix |
|-------|--------|-----|
| N+1 queries | High performance degradation | Eager loading, batch queries |
| Missing error handling | Silent failures | Add try-catch, assert |
| No input validation | Security vulnerability | Validate at boundaries |
| Unclear names | Hard to understand | Rename for clarity |
| Functions too long | Hard to test/understand | Extract smaller functions |
| Magic numbers | Unclear intent | Extract as constants |
| No tests | Unknown correctness | Add test cases |
| Comments that repeat code | Unhelpful | Remove, improve code clarity |

## PR Template

```markdown
## Description
What changes did you make?

## Type of Change
- [ ] Bug fix
- [ ] Feature
- [ ] Refactoring
- [ ] Documentation

## Testing
What testing did you do?

## Checklist
- [ ] Code follows style guide
- [ ] Self-review done
- [ ] Comments provided
- [ ] Documentation updated
- [ ] Tests added/updated
- [ ] All tests pass
- [ ] No console errors/warnings
```

## Culture Notes

**Good Code Review Culture**:
- Feedback is about code, not person
- Everyone gives and receives reviews
- Accepting feedback shows wisdom, not weakness
- Disagreements are discussed, not battles
- Goal is better code, not proving you're smart

**Red Flags**:
- ❌ Reviews feel like gatekeeping
- ❌ Reviewer regularly goes on tangents
- ❌ Author gets defensive
- ❌ Reviews take days for small changes
- ❌ Large PRs get waved through ("looks good")
