---
name: browser-control-basics
description: Use Chromium safely and predictably in this environment. Covers MCP versus direct CDP, what counts as real browser control, and the minimum verification/reporting rules.
license: CC0-1.0
---

# Browser Control Basics

Use this skill when a task involves driving, inspecting, or validating behavior
in Chromium.

This skill defines the shared environment rules for browser control. Load it
before using more specialized browser skills.

## Environment note

In this environment, `chrome-devtools` MCP may be unavailable or disconnected
even when Chromium is running and reachable over CDP.

Treat MCP availability and browser controllability as separate concerns.

## Allowed control paths

If the user asks for browser automation or inspection:

- use MCP when it is available and appropriate
- if MCP is unavailable, direct CDP fallback is allowed when possible
- prefer the existing running Chromium session over launching a separate browser
  stack

## What does not prove control

Do not assume browser control just because:

- a Chromium process exists
- a URL opens in the browser
- a page is visible on screen

Real browser control should be verified with an actual inspection or browser
action, such as:

- listing or selecting targets
- reading DOM state, console output, or network failures
- evaluating script in the page
- clicking, typing, navigating, or taking a screenshot

## Reporting rule

Briefly state which control path you used:

- MCP
- direct CDP fallback

## Scope discipline

Use the smallest capable control path for the task.

Do not build a fresh automation stack unless:

- browser control paths are unavailable
- the task genuinely needs a dedicated scripted runner
- repeated execution makes scripting clearly worthwhile
