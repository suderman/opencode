---
name: claude-browser
description: Ask Claude questions through the user's logged-in claude.ai Project using opencode-browser. Use when the user wants a second opinion, comparison answer, or asks to "ask Claude".
---

# Claude Browser Skill

Use this skill when the user asks you to consult Claude through the browser, ask Claude a question, get a second opinion from Claude, compare your answer with Claude, or retrieve an answer from the user's logged-in Claude web session.

This skill assumes the `@different-ai/opencode-browser` plugin is installed and available.

## Browser control priority

**Primary:** Use opencode-browser tools (`browser_*`) for all browser control.

**Fallbacks (in order):**
1. `chrome-devtools_*` tools — use only when an opencode-browser tool does not support the needed action
2. `webfetch` — use only for read-only content retrieval when browser control is unavailable

**Do not use MCP browser tools as the primary path.** Only use them if the opencode-browser plugin is genuinely unavailable and the user explicitly requests a separate worker browser.

## opencode-browser tool constraints

Use only actual opencode-browser modes and controls.

- Use `browser_snapshot` for accessibility/DOM snapshots.
- Use `browser_query mode="page_text"` for page text extraction.
- Do **not** call `browser_query mode="snapshot"`; that mode does not exist.
- Do **not** use `browser_query mode="page_text" selector="role:textbox"` to decide whether a textbox exists. `page_text` extracts visible text; it is not a selector existence check.
- Use `browser_type selector="role:textbox" ...` for Claude's composer.
- Use `browser_click selector="aria:Send message"` to submit.
- If a selector fails, inspect with `browser_snapshot`; do not invent unsupported query modes or tools.

## Entry URL

For the most reliable project-scoped flow, start from the Claude projects index:

```text
https://claude.ai/projects
```

Then click the project named:

```text
opencode
```

Direct project URL, useful as a fallback or verification target:

```text
https://claude.ai/project/019dd048-be96-755c-8349-f76d8c66ed29
```

Automated Claude chats should live inside this project.

## Core Rules

- Use the user's existing logged-in Claude browser session.
- If Claude is not logged in, stop. Ask the user to log in manually and create an active logged-in session, then retry.
- Dismiss overlays, popups, marketing banners, "What's new" dialogs, cookie banners, upgrade prompts, or similar interruptions before proceeding.
- Ensure Extended thinking / extended reasoning is enabled before submitting a prompt, if the Claude UI exposes such a setting for the current model/session.
- Submit the prompt by clicking `aria:Send message`; Return/Enter is not reliable in this environment.
- Allow Claude enough time to generate the answer. This may take 30 seconds to 5 minutes depending on complexity and network speed.
- Summarize the final answer and any relevant details when returning the result to the user.
- Keep track of the browser tab for follow-up questions. Continue in the same tab when the user's next request is a follow-up. For unrelated questions, return to `https://claude.ai/projects`, click `opencode`, and use that project page composer. Do not use the global `New chat` button.
- Do not send secrets, credentials, private keys, tokens, client-private data, or sensitive personal/financial material to Claude unless the user explicitly approves that exact prompt.
- Do not pretend Claude's answer is your own work. Clearly separate what Claude said from your own assessment.

## Tab Continuity

Prefer the current Claude project tab if it is already open and still relevant.

Use `browser_get_tabs` to find an existing tab whose URL contains one of:

```text
claude.ai/project/019dd048-be96-755c-8349-f76d8c66ed29
claude.ai/chat/
claude.ai/
```

If the current task is a follow-up, reuse the existing active Claude tab from the previous request.

If the previous tab is lost, closed, unresponsive, or clearly unrelated, open a new tab and navigate to the projects index, then click the `opencode` project.

For unrelated new questions, return to the projects index, click `opencode`, and use the project page composer rather than polluting an existing thread.

## Project-scoped chat verification

Claude project chats may end up at URLs like `https://claude.ai/chat/<uuid>`, even when they belong to a project. Do not decide project membership from the URL alone.

Use visible page evidence instead. A valid project-scoped chat/page should show project context such as:

```text
opencode
Project content
Project content
opencode
Memory
Instructions
Files
```

On the project landing page, the valid project composer is the large rounded input box under the `opencode` title. It may already contain stale draft text such as `hello`. This is still the correct composer. The stale text is not a previous message and is not a reason to leave the page.

Most reliable project flow for unrelated questions:

1. Navigate to `https://claude.ai/projects`.
2. Click the project named `opencode`.
3. Verify project context is visible (`opencode`, and ideally `Project content / opencode`).
4. Inspect the composer. If it contains stale draft text from a previous session, clear it.
5. Type the user's prompt into the composer on that project page.
6. Submit.

Do **not** click the sidebar `New chat` button after entering the project. On Claude, that control can route to `/new` and create a non-project chat.

If the project composer already contains text, that is not a reason to click `New chat`. Clear the composer and reuse it. Leaving project scope is worse than dealing with stale input.

Do **not** navigate to an existing chat for an unrelated question just because the project landing composer has stale text. That pollutes an old thread. Clear the project composer instead.

Red flags that you left project scope:

```text
https://claude.ai/new
Good afternoon, Jon
How can I help you today?
Write
Learn
Code
Life stuff
```

If you see `/new` or the generic home composer after clicking `New chat`, stop. Navigate back to `https://claude.ai/projects`, click `opencode`, verify project context, and use the project composer.

## Basic Workflow

### 1. Check browser availability

Use:

```text
browser_status
```

If unavailable, report the browser/plugin problem directly.

### 2. Open or reuse the Claude project tab

First inspect existing tabs:

```text
browser_get_tabs
```

If there is a relevant Claude tab for this session and the user is asking a follow-up, use it.

Otherwise open a new tab and navigate to the projects index:

```text
browser_open_tab
browser_navigate url="https://claude.ai/projects"
```

Then click the project named `opencode`. This is more reliable than starting from `/new` or using global chat controls because it gives a visible project-selection step.

If `browser_snapshot` on an existing Claude tab fails with a browser permission error, do not infer login or page state from it. Navigate that tab to `https://claude.ai/projects`, then inspect again.

### 3. Dismiss overlays

After initial page load, inspect the page:

```text
browser_snapshot
browser_query mode="page_text"
```

Dismiss any overlay, modal, banner, or marketing prompt that blocks the input.

Common dismiss controls may include:

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

Do not click destructive or account-changing actions. Avoid anything that subscribes, upgrades, changes plans, enables sharing, or modifies account settings.

After each dismissal, inspect again. Continue until the prompt composer is reachable or until blocked by login/verification.

### 4. Verify logged-in state

Use:

```text
browser_query mode="page_text"
browser_snapshot
```

If the page shows login/signup state, examples:

```text
Log in
Sign in
Sign up
Continue with Google
Continue with Apple
Continue with email
```

stop and tell the user:

```text
Claude is not logged in in this browser session. Please log in manually and create an active logged-in session, then I can retry.
```

If Claude shows human verification, CAPTCHA, unusual activity, Cloudflare challenge, or account prompt that requires the human, stop and ask the user to complete it manually.

### 5. Choose the right project composer

For follow-up questions, stay in the existing Claude chat only if it is clearly the same conversation.

For unrelated new questions, do **not** open an existing chat from the project recents list. Existing chats are old threads. Use the project landing page composer instead.

For unrelated new questions:

1. Navigate to `https://claude.ai/projects`.
2. Click the project named `opencode`.
3. Verify the resulting page shows project context (`opencode`, and ideally `Project content / opencode`).
4. Use the large rounded composer on that project page directly, even if it contains stale draft text like `hello`.

Selector ideas for selecting the project:

```text
text:opencode
aria:opencode
```

Do not click the sidebar/global `New chat` control. It commonly routes to `https://claude.ai/new`, which loses project scope. If the composer already has a stale draft, clear it; do not navigate to `/new`.

Before typing, verify you are not on the generic home composer:

```text
browser_query mode="page_text"
```

If the page text contains `Good afternoon, Jon`, `How can I help you today?`, and no visible `Project content / opencode`, you are probably on `/new`. Navigate back to `https://claude.ai/projects` and click `opencode` again.

If the page text contains `opencode` plus `Memory`, `Instructions`, and `Files`, and the visible page shows a large rounded input box under the `opencode` title, that is the correct project composer. Do not search for another textbox. Clear and type into it.

Before typing, always clear any pre-existing unsubmitted text from the input field:

```text
browser_type selector="role:textbox" text="" clear="true"
```

If `role:textbox` fails but the project composer is visibly present, retry these selectors in order:

```text
css:[contenteditable="true"]
css:textarea
```

Then verify the input is empty or no stale prompt appears near the composer:

```text
browser_snapshot
browser_query mode="page_text"
```

If `clear="true"` does not clear the composer, use keyboard selection after focusing the textbox:

```text
browser_click selector="role:textbox"
browser_type selector="role:textbox" text="" clear="true"
```

If it is still not clear, stop and report that the stale draft could not be cleared. Do **not** click global `New chat` as a workaround.

### 6. Ensure Extended thinking is enabled

Before submitting, inspect the composer/model controls:

```text
browser_snapshot
browser_query mode="page_text"
```

Find the model/thinking/reasoning controls. Ensure Extended thinking / extended reasoning is enabled if available.

Possible workflow:

1. Open the model/tools/thinking selector near the composer.
2. Choose the current model option that supports extended thinking, if model selection is exposed.
3. Choose or enable `Extended thinking`, `Extended`, `Think`, `Thinking`, or equivalent.
4. Verify the visible state indicates extended thinking is active.

Selector ideas will change as Claude's UI changes. Prefer ARIA/snapshot-driven interaction over hard-coded CSS.

Look for controls or labels such as:

```text
Thinking
Think
Reason
Reasoning
Extended
Extended thinking
More
Tools
Model
```

If Extended thinking is not available in the current model/project/session, do not silently proceed. Report the limitation and ask the user whether to continue without Extended thinking.

### 7. Type the prompt

Prepare a concise, self-contained prompt. Type it directly as the user — do **not** prepend any disclosure about being an agent, second-opinion assistant, coding workflow, or similar framing. The user is asking directly; present it that way.

Prompt template — use directly, verbatim:

```text
<USER_TASK>
```

For code review:

```text
Review this code and identify bugs, risks, and improvements:

<CODE>

Context: <CONTEXT>
```

For answer comparison:

```text
Compare these two approaches and tell me which is better and why:

Approach A: <A>

Approach B: <B>
```

Focus the Claude input field.

Prefer selectors in this order:

```text
role:textbox
aria:Message Claude
placeholder:Message Claude
placeholder:How can Claude help you
css:textarea
css:[contenteditable="true"]
```

Use:

```text
browser_type selector="role:textbox" text="<PROMPT>"
```

If typing fails, use `browser_snapshot` to find the composer element and retry with a more specific selector.

### 8. Submit the prompt

After the input field has focus and the prompt text is present, submit by clicking the Send button.

**Primary submit method:**

```text
browser_click selector="aria:Send message"
```

The `aria:Send message` button is the reliable submit control on claude.ai. Pressing Return/Enter via keyboard tools does not reliably trigger submission in this environment.

If `aria:Send message` is not found, fall back to:

```text
browser_click selector="text:Send"
browser_click selector="aria:Send"
css:button[aria-label="Send message"]
```

### 9. Wait for completion

Allow 30 seconds to 5 minutes.

Poll periodically:

```text
browser_wait
browser_query mode="page_text"
browser_snapshot
```

The response is probably still streaming if:

- a Stop button is visible
- the latest assistant response is still changing
- a spinner/progress indicator is visible
- the composer is disabled
- the Send button has not returned
- the latest response has no Copy button yet

Consider the answer complete when:

- the Stop button disappears
- the Send button or composer returns
- page text is stable across two polls
- a Copy button appears under the latest assistant message
- no progress indicator is visible

For complex prompts, keep waiting up to about 5 minutes unless there is an obvious error.

### 10. Extract the final answer

Prefer the cleanest extraction method available.

Best option:

1. Use `browser_snapshot` to locate the Copy button nearest the latest assistant response.
2. Click that Copy button.
3. Read the clipboard with shell if allowed:

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

Then extract the latest assistant message after the submitted prompt.

Avoid returning the entire noisy page. Return the final answer and relevant details only.

### 11. Return the result to the user

Use this format:

```text
Claude said:

<concise summary of Claude's final answer>

Relevant details:

<any specific commands, caveats, URLs, or reasoning points worth preserving>

My read:

<your brief assessment, agreement/disagreement, missing caveats, or recommended next step>
```

If the user asked only to fetch Claude's answer, keep your own assessment short.

## Fallback tools (when opencode-browser is unavailable)

If opencode-browser tools are unavailable, fall back in this order:

1. **`chrome-devtools_*` tools** — for direct CDP actions (click, navigate, evaluate script, press key)
2. **`webfetch`** — for read-only content retrieval only

Avoid using `chrome-devtools_*` as the primary path when opencode-browser tools work. Their CDP sessions may conflict with the opencode-browser plugin.

## Troubleshooting

### Claude is logged out

Stop and say:

```text
Claude is not logged in in this browser session. Please log in manually and create an active logged-in session, then I can retry.
```

### Human verification / CAPTCHA

Stop and say:

```text
Claude is asking for human verification. Please complete it manually in the browser, then I can continue.
```

### Overlay blocks the page

Dismiss harmless overlays with Close, Dismiss, Not now, Maybe later, Skip, Got it, Continue, or OK.

Do not click upgrade, subscribe, enable, buy, connect account, share, or privacy-sensitive account actions.

### Extended thinking is unavailable

Stop and say:

```text
I cannot find or enable Extended thinking in this Claude session. Do you want me to continue without it?
```

### Prompt typed but did not submit

If the prompt was typed but not submitted:

1. Click the Send button directly: `browser_click selector="aria:Send message"`
2. Do not rely on Return/Enter keypresses — they do not reliably trigger submission on claude.ai
3. Do not spam submissions. One click is sufficient.

### Stale text in Claude composer

The project composer may retain a draft from a previous browser session.

Example: the `opencode` project page may show a large rounded composer containing `hello`. This is the correct place to type after clearing it.

Correct behavior:

1. Stay on the verified `opencode` project page.
2. Clear `role:textbox` with `browser_type clear=true`.
3. Verify stale text is gone with `browser_snapshot` or `browser_query mode="page_text"`.
4. Type the new user prompt.

Incorrect behavior:

- Do not click global `New chat` just because the composer has stale text.
- Do not navigate to `/new` as a workaround.
- Do not append the new prompt to stale text.
- Do not open an existing chat from the project recents list for an unrelated question.
- Do not treat stale text in the project composer as a previous chat message.

### Unsupported opencode-browser tool calls

If a tool call fails with an unsupported mode or selector, inspect with `browser_snapshot` and retry with supported primitives.

Known invalid call:

```text
browser_query mode="snapshot"
```

Use instead:

```text
browser_snapshot
browser_query mode="page_text"
```

### Response extraction is messy

Use the Copy button nearest the latest response. This is usually cleaner than parsing all page text.

### Multiple Claude tabs exist

Use `browser_get_tabs`. Prefer the tab already used for this OpenCode session when the user asks a follow-up. For unrelated questions, start a new chat inside the Claude project.

### The conversation is too long or off-topic

Start a new chat inside the Claude project.
