# Agent Rules and Engineering Conventions

## Purpose

This document defines baseline conventions and expectations for all agents
contributing to a project.

Treat it as a default operating guide, not a substitute for project-specific
documentation, code conventions, or direct user instructions.

---

## Core principles

- Complexity is the primary enemy. Prefer simple, clear, maintainable solutions
  over clever or abstract ones.
- Write code for humans first.
- Prefer explicit behavior over implicit assumptions.
- Prefer boring, well-understood solutions unless novelty is explicitly
  required.
- Prefer reversible, incremental changes over large rewrites.
- Avoid premature optimization.
- Treat warnings and errors as bugs, not noise.
- Preserve the principle of least surprise: code should behave as a reasonable
  maintainer would expect.

---

## Decision and permission model

- If uncertainty materially affects architecture, security, data integrity,
  public APIs, or destructive operations, ask for clarification.
- Otherwise, proceed with the smallest safe and reversible change.
- Prefer incremental changes over large refactors unless explicitly requested.
- If progress would otherwise stall, make the smallest meaningful forward change
  and state any assumptions clearly.

---

## Problem framing before implementation

Before making non-trivial changes:

- State the concrete objective.
- Separate required work from incidental details and nice-to-haves.
- Identify relevant constraints, including technical, security, architectural,
  performance, deployment, and project-convention constraints.
- Solve the smallest meaningful subproblem first.
- Avoid solving problems that were not explicitly asked for.

If the task is ambiguous, state assumptions clearly or ask a targeted question
before proceeding.

---

## Change discipline

- Prefer minimal diffs over broad rewrites.
- Do not refactor unrelated code unless explicitly requested.
- Preserve existing project conventions unless explicitly instructed to change
  them.
- When multiple solutions exist, choose the simplest viable one.
- Explain reasoning briefly before making non-trivial changes.
- Avoid introducing new dependencies unless clearly justified.
- Prefer existing libraries, project utilities, and standard library features
  over new abstractions.
- Do not perform speculative cleanup, renaming, or restructuring unless it is
  necessary to complete the task.

---

## Verification and debugging

- When fixing a bug, reproduce or clearly identify the failure before changing
  code when feasible.
- Base fixes on evidence, not guesses.
- After making a change, verify that the requested behavior works in the real
  execution path relevant to the task.
- Do not assume a change is correct merely because it compiles or looks
  reasonable.
- Check for obvious regressions in nearby behavior when practical.

---

## Tool usage

- Prefer repository context, existing project documentation, and nearby code
  before fetching external references.
- Prefer Context7 when working with unfamiliar libraries, APIs, frameworks, or
  unclear documentation.
- Use Context7 to resolve `libraryId` and retrieve authoritative documentation
  when needed.
- Use `gh_grep` when official documentation is insufficient, ambiguous, or
  incomplete.
- Do not fetch external documentation unnecessarily when the answer is already
  clear from project context.

---

## Commit message conventions

Follow Conventional Commits unless the project defines its own rules.

Guidelines:

- Use the imperative mood.
- Use lowercase in the summary line.
- Do not end the summary with a period.
- Keep the summary concise and ideally under 72 characters.
- Use plain ASCII characters in commit messages.
- Add a body when rationale, tradeoffs, or consequences are not obvious.

### Examples

#### Commit message with no body

```text
docs: correct spelling of changelog
```

#### Commit message with scope

```text
feat(lang): add polish language
```

#### Commit message with body and footers

```text
fix: prevent request race conditions

Introduce request ids and track the latest request. Ignore responses
from outdated requests.

Remove timeouts that previously masked the issue.

Reviewed-by: Z
Refs: #123
```

---

## Security considerations

- Never log sensitive data, including credentials, secrets, tokens, or PII.
- Treat all external input as untrusted until validated.
- Validate data for correctness, not merely absence of errors.
- Avoid adding new dependencies when existing libraries or the standard library
  are sufficient.
- Do not assume code is secure without explicit reasoning.
- Do not destroy or mutate data unless it has been explicitly verified as safe
  to discard.
- Use assertions where appropriate and supported, but do not rely on them as a
  substitute for real validation.

---

## Default engineering bias

- Prefer clarity over cleverness.
- Prefer local reasoning over global abstraction.
- Prefer explicitness over magic.
- Prefer maintainability over micro-optimizations.
- Prefer small, understandable changes over sweeping redesigns.
