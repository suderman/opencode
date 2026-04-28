---
name: perplexity-browser
description: Ask Perplexity questions through the user's logged-in perplexity.ai browser session using opencode-browser.
---

# Perplexity Browser Skill

Use this skill when the user asks you to consult Perplexity, ask Perplexity a question, get a sourced web answer, or retrieve an answer from the user's logged-in Perplexity browser session.

This skill assumes the `@different-ai/opencode-browser` plugin is installed and available.

## Browser control priority

**Primary:** Use opencode-browser tools (`browser_*`) for normal browser control.

**Fallbacks:**
1. Direct CDP / `chrome-devtools_*` only when opencode-browser cannot perform the needed UI action
2. `webfetch` only for read-only content retrieval when browser control is unavailable

Do not use MCP/chrome-devtools tools as the primary path while opencode-browser works.

## Entry URL

Always enter Perplexity through:

```text
https://www.perplexity.ai/
```

Use the main Perplexity home/search page. Do not use Spaces by default.

## Core rules

- Use the user's existing logged-in Perplexity browser session.
- If Perplexity is not logged in, stop. Ask the user to log in manually and create an active logged-in session, then retry.
- Dismiss overlays, popups, cookie banners, onboarding dialogs, upgrade prompts, and similar interruptions before proceeding.
- Default Perplexity mode is fine. Do not try to change model/search mode unless the user asks.
- Ask directly as the user. Do **not** prepend disclosure text like "I am using you as a second-opinion assistant".
- Preserve the user's exact question unless minimal context is needed to make it self-contained.
- Do not send secrets, credentials, private keys, tokens, client-private data, or sensitive personal/financial material unless the user explicitly approves that exact prompt.
- Do not pretend Perplexity's answer is your own work. Clearly separate what Perplexity said from your own assessment.
- Perplexity answers may cite sources. Preserve important citations/source names when summarizing.

## opencode-browser constraints

- Use `browser_snapshot` for accessibility/DOM snapshots.
- Use `browser_query mode="page_text"` for page text extraction.
- Do **not** call `browser_query mode="snapshot"`; that mode does not exist.
- Do **not** use `browser_query mode="page_text" selector="role:textbox"` to decide whether a textbox exists. `page_text` extracts visible text; it is not a selector existence check.
- Do not use Playwright-only selector syntax such as `button:has-text("...")` unless verified supported. Prefer `text:...`, `aria:...`, `role:textbox`, and simple CSS selectors.
- If a selector fails, inspect with `browser_snapshot` and retry with supported selectors.

## Basic workflow

### 1. Check browser availability

Use:

```text
browser_status
browser_get_tabs
```

If unavailable, report the browser/plugin problem directly.

### 2. Open or reuse Perplexity

Prefer an existing relevant Perplexity tab for follow-up questions.

For unrelated questions, open or navigate to:

```text
browser_open_tab url="https://www.perplexity.ai/"
```

or:

```text
browser_navigate url="https://www.perplexity.ai/"
```

### 3. Dismiss overlays

After page load, inspect:

```text
browser_snapshot
browser_query mode="page_text"
```

Dismiss harmless overlays that block the page or composer.

Common dismissal selectors:

```text
aria:Close
aria:Dismiss
aria:Not now
aria:Maybe later
aria:Skip
aria:Got it
aria:Continue
aria:OK
text:Close
text:Dismiss
text:Not now
text:Maybe later
text:Skip
text:Got it
text:Continue
css:button[aria-label="Close"]
css:button[aria-label="Dismiss"]
```

Do not click destructive or account-changing actions. Avoid anything that subscribes, upgrades, purchases, changes account settings, enables sharing, connects accounts, or changes privacy settings.

### 4. Verify logged-in state

Use:

```text
browser_query mode="page_text"
browser_snapshot
```

If the page shows login/signup state, stop and tell the user:

```text
Perplexity is not logged in in this browser session. Please log in manually and create an active logged-in session, then I can retry.
```

Login indicators may include:

```text
Sign in
Log in
Continue with Google
Continue with Apple
Continue with email
```

If Perplexity shows human verification, CAPTCHA, unusual activity, or an account prompt requiring the human, stop and ask the user to complete it manually.

### 5. Use the main Perplexity composer

By default, use the main Perplexity home/search composer at `https://www.perplexity.ai/`.

Workflow:

1. Navigate to `https://www.perplexity.ai/`.
2. Use the main textbox, usually labeled or placeholdered like `Ask anything...`.
3. Ignore Spaces and any `Computer`/task-oriented Space UI unless the user explicitly asks for it.

Do not navigate to `/spaces` or open the `opencode` Space by default. It can expose a task/computer UI and confuse the flow.

Do not open unrelated existing threads for unrelated questions just because a draft exists. Clear stale drafts in place.

Before typing, clear stale composer text:

```text
browser_type selector="role:textbox" text="" clear=true
```

Fallback composer selectors:

```text
css:textarea
css:[contenteditable="true"]
```

If stale text cannot be cleared, stop and report that the stale draft could not be cleared. Do not append the new prompt to stale text.

### 6. Type the prompt

Prepare a concise, self-contained prompt. Type it directly as the user.

Prompt template:

```text
<USER_TASK>
```

Use:

```text
browser_type selector="role:textbox" text="<PROMPT>" clear=true
```

If typing fails, inspect with `browser_snapshot` and retry with the visible composer selector.

### 7. Submit the prompt

The submit button has `aria-label="Submit"`, but it may not exist until after text has been successfully entered into the textbox. Do not look for or click submit before typing.

After typing, verify the typed prompt appears in the composer or page text if possible, then click:

```text
browser_click selector="button[aria-label=\"Submit\"]"
```

Fallback selectors:

```text
browser_click selector="aria:Submit"
browser_click selector="aria:Send"
browser_click selector="aria:Ask"
browser_click selector="button[aria-label=\"Send\"]"
```

If the visible submit button has a different accessible name, use the exact name from `browser_snapshot`.

If `button[aria-label="Submit"]` is not found after typing, the text may not have entered the real composer. Re-inspect with `browser_snapshot`, retry typing into `role:textbox`, then `css:textarea`, then `css:[contenteditable="true"]`.

If the UI remains difficult, a reliable fallback is to navigate directly to a Perplexity search URL:

```text
https://www.perplexity.ai/search?q=<URL_ENCODED_QUERY>&source=web
```

Use this URL fallback instead of repeated Enter attempts or chrome-devtools keypresses.

Do not spam submissions. One successful click is sufficient.

### 8. Wait for completion

Allow 30 seconds to 5 minutes.

Poll periodically:

```text
browser_wait
browser_query mode="page_text"
browser_snapshot
```

The response is probably still streaming if:

- a Stop button is visible
- response text is still changing
- spinner/progress indicator is visible
- composer is disabled
- send button has not returned

Consider the answer complete when:

- stop/progress indicators disappear
- composer/send control returns
- page text is stable across two polls
- source/citation cards have loaded, if present

### 9. Extract the final answer

Prefer the cleanest extraction available.

Best option:

1. Use `browser_snapshot` to locate the Copy button nearest the latest Perplexity answer.
2. Click that Copy button.
3. Read clipboard with shell if available:

```bash
wl-paste
```

Fallbacks:

```bash
xclip -selection clipboard -o
xsel -b
```

If clipboard extraction is unavailable, use:

```text
browser_query mode="page_text"
browser_snapshot
```

Then extract the latest Perplexity answer after the submitted prompt. Avoid returning noisy full-page text.

Preserve source names/URLs when useful.

### 10. Return the result

Use:

```text
Perplexity said:

<concise summary of Perplexity's answer>

Relevant sources:

- <source name / URL if available>

My read:

<brief assessment, uncertainty, or recommended next step>
```

If the user asked only to fetch Perplexity's answer, keep `My read` short.

## Troubleshooting

### Perplexity is logged out

Stop and say:

```text
Perplexity is not logged in in this browser session. Please log in manually and create an active logged-in session, then I can retry.
```

### Human verification / CAPTCHA

Stop and say:

```text
Perplexity is asking for human verification. Please complete it manually in the browser, then I can continue.
```

### Overlay blocks the page

Dismiss harmless overlays with Close, Dismiss, Not now, Maybe later, Skip, Got it, Continue, or OK.

Do not click upgrade, subscribe, buy, connect account, share, or privacy-sensitive account actions.

### Prompt typed but did not submit

Inspect with `browser_snapshot`, identify the exact visible submit/send button accessible name, then click it once.

Known behavior: Perplexity's submit button appears as `button[aria-label="Submit"]` only after text is entered.

If submit is still not visible after typing, retry typing into the real composer. If that still fails, use direct search URL fallback:

```text
https://www.perplexity.ai/search?q=<URL_ENCODED_QUERY>&source=web
```

Do not use repeated Enter attempts or `chrome-devtools_press_key`; they are slow and unreliable in this environment.

### Unsupported opencode-browser tool calls

Known invalid call:

```text
browser_query mode="snapshot"
```

Use instead:

```text
browser_snapshot
browser_query mode="page_text"
```
