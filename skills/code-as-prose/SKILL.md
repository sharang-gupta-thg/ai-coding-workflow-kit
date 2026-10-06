---
name: code-as-prose
description: "Grady Booch's code-as-prose philosophy: code should read top to bottom like well-written prose, with clarity over cleverness. Use when code works but is hard to follow, when choosing between a clever and a plain solution, or when reviewing readability."
user-invocable: true
argument-hint: "[readability|clarity|simplicity] - Example: 'Is this code readable like prose?'"
---

# Code as Well-Written Prose

**Advocate**: Grady Booch  
**Philosophy**: Code is read far more often than it is written. Write code that reads like well-written prose — clear, simple, and eloquent.

## Core Principles

### 1. Code is Literature
- **Code is communication first, execution second** — prioritize readability
- Your code will be read by humans (including future you) far more than it will be executed
- Each line should flow naturally and be easily understood
- Write for the reader, not the compiler
- Excellence in code is about expression, not just functionality

### 2. Simplicity Above All
- **Avoid cleverness** — clever code is hard to understand and maintain
- Simple code is not lazy code — it's well-thought-out and purposeful
- Express ideas in the most straightforward way possible
- One clear way > multiple clever ways
- If you need a comment to explain what code does, the code isn't simple enough

### 3. Flow and Rhythm
- **Code should have natural flow** — like paragraphs in a well-written essay
- Related concepts should be grouped together (vertical density)
- Unrelated concepts should be separated (vertical distance)
- Function length should match the complexity of ideas it expresses
- There should be a cadence to how you read through the code

### 4. Naming is Everything
- **Names are the primary tool for communication** — choose them carefully
- A good name should immediately convey intent and purpose
- Names should be self-documenting — no cryptic abbreviations
- Consistent terminology throughout the codebase
- When naming is hard, it often signals design problems

### 5. Eliminate Cognitive Load
- **Every extra symbol, line, or complexity adds mental burden** on the reader
- Remove every unnecessary element
- Use language features to reduce visual noise
- Structure code to minimize the amount reader must hold in mind
- The goal: anyone should understand the code in one read-through

### 6. Visual Clarity
- **Formatting creates the visual experience** — it matters deeply
- Whitespace is not wasted space — it organizes ideas
- Use consistent indentation and spacing
- Related code should be near each other
- Break long constructs into readable chunks
- Visual structure should mirror logical structure

### 7. Context and Circumstance
- **Express the problem domain clearly** — code should reflect the real world
- Use domain language and terminology
- Make the context of a piece of code explicit
- Readers shouldn't need to hunt through files to understand a concept
- One idea per function, one function per idea

### 8. Clarity Over Compression
- **Be explicit rather than implicit**
- Avoid dense one-liners when a few clear lines work better
- Use intermediate variables with clear names instead of nesting
- Favor readability over brevity
- The time saved by short code is lost when someone tries to understand it

### 9. Words Matter
- **Choose words as carefully as a writer chooses them**
- `fetch` vs `get` — each has a specific meaning
- `destroy` vs `delete` vs `remove` — connotations matter
- Synonyms should have different meanings in your code
- Consistency in terminology makes code feel polished

### 10. Narrative Structure
- **Code tells a story** — structure it so the story flows naturally
- Put the high-level story first, details later
- Constants and configuration at the top
- Helper functions below main logic
- Follow the narrative from business logic down to implementation
- Readers should understand the "what" before the "how"

## The Prose Mindset

### Ask These Questions
- **Would I want to read this code?** — Is it engaging, clear, and well-structured?
- **Does it read naturally?** — Or does it require constant mental translation?
- **Could a colleague understand this without asking?** — Is context explicit?
- **Does form follow function?** — Or is cleverness getting in the way?
- **Is every element here for a reason?** — Or could something be removed?

### Prose vs Code
- Essays have introductions, body, and conclusions — code should too
- Paragraphs develop one idea — functions should do the same
- Writers eliminate unnecessary words — coders should eliminate unnecessary symbols
- Good prose is a pleasure to read — good code should be too
- Both require multiple revisions — first draft is rarely the best

## Anti-Patterns to Avoid

- **Over-compression** — `if(x==1&&y==2)` vs `if (isValid && isReady)`
- **Clever tricks** — using bitwise operations when simple logic is clearer
- **Inconsistent style** — mixing naming conventions and patterns
- **Hidden complexity** — burying important logic in obscure places
- **Noise** — unnecessary variables, parameters, or abstractions
- **Scattered context** — related concepts spread across many files
- **Cryptic abbreviations** — `usr`, `ctx`, `cfg` vs `user`, `context`, `configuration`

## Example: Prose Principles in Action

### Before (Dense, Hard to Read)
```java
public int calc(int[] a) {
  int s = 0;
  for (int i = 0; i < a.length; i++) {
    if (a[i] % 2 == 0) s += a[i];
  }
  return s;
}
```

### After (Reads Like Prose)
```java
public int sumEvenNumbers(int[] numbers) {
  int sum = 0;
  for (int number : numbers) {
    if (isEven(number)) {
      sum += number;
    }
  }
  return sum;
}

private boolean isEven(int number) {
  return number % 2 == 0;
}
```

### Even Better (Functional Style, Clear Intent)
```java
public int sumEvenNumbers(int[] numbers) {
  return Arrays.stream(numbers)
    .filter(this::isEven)
    .sum();
}

private boolean isEven(int number) {
  return number % 2 == 0;
}
```

Each version is clearer than the last — easier to read and understand at a glance.

## Code Review Questions

When evaluating code as prose:

- [ ] **Clarity**: Could someone understand this without comments?
- [ ] **Simplicity**: Is every element necessary? Could it be simpler?
- [ ] **Flow**: Does the code read naturally from top to bottom?
- [ ] **Naming**: Are names self-explanatory and consistent?
- [ ] **Structure**: Are related concepts grouped together?
- [ ] **Rhythm**: Does the code have good visual cadence?
- [ ] **Context**: Is domain knowledge clear from the code itself?
- [ ] **Elegance**: Does the solution feel naturally expressed?

## Key Insight

> "Code is poetry. It should be written with care and thought, just as one would write any literature."

Writing code as prose means:
- Respect your readers
- Eliminate the unnecessary
- Express ideas clearly
- Use language (variable names, structure, formatting) intentionally
- Revise and refine until it reads well

The best code feels inevitable — like it couldn't be written any other way. That's the goal of writing code as prose.
