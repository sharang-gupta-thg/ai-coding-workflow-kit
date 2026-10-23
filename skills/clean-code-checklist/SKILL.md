---
name: clean-code-checklist
description: "Per-principle checklist for Robert C. Martin's Clean Code and Grady Booch's code-as-prose: every principle as a question you can answer about a file. Use while writing code to avoid violations, before raising a PR, and when reviewing a PR file by file."
user-invocable: true
argument-hint: "[martin|booch|all] - Example: 'Check this file against every Martin principle'"
---

# Clean Code Checklist

Use this as a test sheet, not as reading material. For each changed file, go through
every item and answer it. An item with no violation is recorded as "clean"; an item with a
violation becomes a finding with `file:line`, the principle name, and a fix.

## Part 1: Robert C. Martin, *Clean Code*

### Meaningful names
1. **Intention-revealing**: does each name say why it exists, what it does and how it is used?
2. **No disinformation**: does any name suggest a type, scope or meaning it does not have?
3. **Meaningful distinctions**: are `a1`/`a2`, `data`/`info`, `Manager`/`Processor` distinct in meaning?
4. **Pronounceable**: could you say the name aloud in a code review?
5. **Searchable**: are single letters and unnamed numbers limited to tiny scopes?
6. **No encodings**: is there no type prefix, member prefix or Hungarian notation?
7. **Classes are nouns, methods are verbs**: do names follow that split?
8. **One word per concept**: is the same concept called the same thing everywhere (`fetch` vs `get` vs `retrieve` only if they differ in meaning)?
9. **No cute names**: are there no puns or jokes that need context to decode?
10. **Solution-domain and problem-domain names**: are names from the problem domain where possible, with technical terms only where they are the real concept?

### Functions
11. **Small**: is each function short enough to read without scrolling (about 20 lines)?
12. **Does one thing**: can its body be described in one sentence with no "and"?
13. **One level of abstraction**: do all statements sit at the same level of detail?
14. **No flag arguments**: does no boolean parameter switch the function's behaviour (split it instead)?
15. **Few arguments**: are there at most three parameters, with a value object beyond that?
16. **No side effects**: does a function do only what its name says, with no hidden writes?
17. **Command-query separation**: does a function either change state or answer a question, not both?
18. **Exceptions over error codes**: are failures signalled by exceptions rather than sentinel return values?
19. **Extract try/catch blocks**: is the body of a `try` or `catch` pulled into its own function?
20. **No repetition**: is any logic duplicated, including near-duplicates that differ by one value?
21. **Structured**: does each function read top to bottom with early returns rather than deep nesting?

### Comments
22. **Explains why**: does every comment say why, not what the code does?
23. **No redundancy**: does any comment restate the code or a method name?
24. **Accurate**: is any comment now wrong after this change?
25. **No commented-out code**: is there any dead code left behind in a comment?
26. **No noise**: are there journal entries, attributions, closing-brace markers or banners?
27. **Warnings and intent are kept**: are the genuinely useful comments (warnings of consequences, intent behind a non-obvious choice) present?

### Formatting
28. **Vertical order**: does the file read top-down, with the caller above the callee?
29. **Vertical density**: are related lines together and unrelated blocks separated by blank lines?
30. **Consistent openness**: is spacing around operators and inside blocks uniform?
31. **Team rules followed**: does the code match the formatter and style of the surrounding file?

### Objects and data
32. **Hide data behind behaviour**: do objects expose behaviour rather than public fields?
33. **Law of Demeter**: does code avoid chains like `a.getB().getC().doThing()`?
34. **No feature envy**: does a method use another object's data more than its own?
35. **Data structures stay plain**: are DTOs and records free of logic that belongs elsewhere?

### Error handling
36. **Exceptions carry context**: do thrown exceptions say what failed and with which input?
37. **Not swallowed**: is every caught exception rethrown, logged with context, or handled on purpose?
38. **Specific catches**: is nothing caught as `Exception` or `Throwable` without reason?
39. **No null returned**: does a method return an empty collection or `Optional` instead of `null`?
40. **No null passed**: are null arguments rejected at the boundary rather than passed on?
41. **Resources closed**: are streams, connections and locks released in `finally` or try-with-resources?

### Tests
42. **Tests are clean**: do test names state the scenario and the expected result?
43. **One concept per test**: does each test check one behaviour, even if it has several asserts?
44. **F.I.R.S.T.**: are tests fast, independent, repeatable, self-validating and timely?
45. **Tests exist for the change**: is every new behaviour and every rejection path covered?

### Classes and systems
46. **Single responsibility**: does the class have one reason to change?
47. **Open for extension, closed for modification**: does a new variant need a new class rather than an edited `if`/`switch`?
48. **Depends on abstractions**: do high-level classes depend on interfaces, not concrete infrastructure?
49. **Cohesive**: do the fields and methods of the class all use each other?
50. **Construction separated from use**: are dependencies injected rather than built inside the logic?
51. **Cross-cutting concerns separated**: are logging, transactions and security kept out of business logic?

### Emergence (Kent Beck's rules that Martin adopts)
52. **Passes its tests**: does the change keep the test suite green?
53. **Expresses intent**: could a reader tell what the code is for from its names and structure?
54. **No duplication**: is every piece of knowledge stated once?
55. **Minimal**: has every class, method and abstraction been justified by a current need?

### Concurrency
56. **Separated**: is concurrency code separate from other logic?
57. **Shared state limited**: is mutable state shared as little as possible, and guarded where it is?
58. **Library primitives used**: are the library's thread-safe types used instead of hand-rolled locking?
59. **Concurrent paths tested**: is code that runs concurrently exercised under load or contention?

## Part 2: Grady Booch, code as well-written prose

Read each changed function top to bottom as if it were a paragraph of an essay.

1. **Reads in one pass**: can a colleague understand the function without a comment or a second file?
2. **Story first**: does the high-level intent come first and the detail follow?
3. **One idea per function**: does each function develop exactly one idea?
4. **Plain over clever**: is there a simpler way to write the same thing (no bit tricks, no dense ternary chains, no nested one-liners)?
5. **Explicit over compressed**: are intermediate values named rather than packed into a single expression?
6. **Words are chosen**: do verbs such as `fetch`, `remove`, `destroy` match what the code does?
7. **Consistent vocabulary**: is the domain term used the same way across the change?
8. **Cognitive load**: could any variable, parameter or abstraction be removed without losing meaning?
9. **Visual rhythm**: does blank-line spacing separate paragraphs of logic?
10. **Domain context explicit**: is the business rule visible in the code rather than hidden in a helper elsewhere?
11. **Inevitable**: does the solution look like the only natural way to write it, or does it need explaining?

## How to record a result

Write one line per item that has a violation, grouped under its principle. Items with no
violation need no line. A finding looks like this:

```
Functions 14 (no flag arguments) · src/Pricing.java:42
`applyDiscount(order, true)` changes behaviour through a boolean.
Fix: split into `applyMemberDiscount` and `applyStandardDiscount`.
```

Confirm each violation by reading the code before you record it. Drop anything you cannot
show in the code.
