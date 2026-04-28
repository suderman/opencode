---
name: chatgpt-browser
description: Ask ChatGPT questions through the user's logged-in chatgpt.com Project using opencode-browser. Use when the user wants a second opinion, comparison answer, or asks to "ask ChatGPT".
---

# ChatGPT Browser Skill

Use this skill when the user asks you to consult ChatGPT through the browser, ask ChatGPT a question, get a second opinion from ChatGPT, compare your answer with ChatGPT, or retrieve an answer from the user's logged-in ChatGPT web session.

This skill assumes the `@different-ai/opencode-browser` plugin is installed and available.

Use the visible/shared browser controlled by `opencode-browser`. Do not use an MCP browser unless the user explicitly asks for a separate worker browser.

## opencode-browser tool constraints

Use only actual opencode-browser modes and controls.

- Use `browser_snapshot` for accessibility/DOM snapshots.
- Use `browser_query mode="page_text"` for page text extraction.
- Do **not** call `browser_query mode="snapshot"`; that mode does not exist.
- Do **not** use `browser_query mode="page_text" selector="role:textbox"` to decide whether a textbox exists. `page_text` extracts visible text; it is not a selector existence check.
- Do **not** use `chrome-devtools_press_key` to submit ChatGPT prompts while opencode-browser is available.
- Use `browser_click selector="button[aria-label=\"Send prompt\"]"` to submit ChatGPT prompts.
- If a selector fails, inspect with `browser_snapshot`; do not invent unsupported query modes or tools.

## Entry URL

For the most reliable project-scoped flow, start from the ChatGPT home page:

```text
https://chatgpt.com/
```

Then find the project named `opencode` in the sidebar and click it.

Direct project URL, useful as a fallback or verification target:

```text
https://chatgpt.com/g/g-p-69efac46be008191ac624f637e3d8bdf/project?tab=chats
```

This is the user's ChatGPT Project named `opencode`. Automated ChatGPT chats should live inside this project.

## Core Rules

- Use the user's existing logged-in ChatGPT browser session.
- If ChatGPT is not logged in, stop. Ask the user to log in manually and create an active logged-in session, then retry.
- Dismiss overlays, popups, marketing banners, "What's new" dialogs, cookie banners, upgrade prompts, or similar interruptions before proceeding.
- Ensure Thinking effort is enabled and set to `Extended` before submitting a prompt.
- Submit the prompt by clicking ChatGPT's send button with opencode-browser. Prefer `button[aria-label="Send prompt"]`; do not use `chrome-devtools_press_key` while opencode-browser is available.
- Allow ChatGPT enough time to generate the answer. This may take 30 seconds to 5 minutes depending on complexity and network speed.
- Summarize the final answer and any relevant details when returning the result to the user.
- Keep track of the browser tab for follow-up questions. Continue in the same tab when the user's next request is a follow-up. For unrelated questions, return to `https://chatgpt.com/`, click the `opencode` project in the sidebar, and use the project-scoped composer/chat controls.
- Do not send secrets, credentials, private keys, tokens, client-private data, or sensitive personal/financial material to ChatGPT unless the user explicitly approves that exact prompt.
- Do not pretend ChatGPT's answer is your own work. Clearly separate what ChatGPT said from your own assessment.

## Tab Continuity

Prefer the current ChatGPT project tab if it is already open and still relevant.

Use `browser_get_tabs` to find an existing tab whose URL contains one of:

```text
chatgpt.com/g/g-p-69efac46be008191ac624f637e3d8bdf/project
chatgpt.com/c/
chatgpt.com/
```

If the current task is a follow-up, reuse the existing active ChatGPT tab from the previous request.

If the task is unrelated, do not click an existing chat title from the project chat list. Existing chats are old threads. Start from ChatGPT home and click the `opencode` project in the sidebar.

If the previous tab is lost, closed, unresponsive, or clearly unrelated, open a new tab and navigate to ChatGPT home, then click the `opencode` project in the sidebar.

For unrelated new questions, create a fresh chat inside the `opencode` project rather than polluting an existing thread. Do not decide project membership from the URL alone; verify visible project context.

## Project-scoped chat verification

ChatGPT project chats may use URLs that do not obviously show the project. Do not decide project membership from the URL alone.

Use visible page evidence instead. A valid project-scoped page/chat should show the `opencode` project context somewhere in the sidebar, header, project panel, or chat list.

Most reliable project flow for unrelated questions:

1. Navigate to `https://chatgpt.com/`.
2. Find and click the project named `opencode` in the sidebar.
3. Verify visible project context shows `opencode`.
4. Use the project-scoped composer/chat controls from there.
5. If the composer contains stale draft text from a previous session, clear it instead of leaving project scope.
6. Type the prompt.
7. Submit with `browser_click selector="button[aria-label=\"Send prompt\"]"`.

If the project composer already contains text, that is not a reason to leave the project, click a global new-chat control, or open an unrelated existing chat. Clear the composer and reuse the project-scoped flow.

Fast path when a project tab is already open but uncertain: navigate that tab to `https://chatgpt.com/`, click `opencode` in the sidebar, verify project context, then type and submit. Do not spend time opening old chats to inspect them.

## Basic Workflow

### 1. Check browser availability

Use:

```text
browser_status
```

If unavailable, report the browser/plugin problem directly.

### 2. Open or reuse the ChatGPT project tab

First inspect existing tabs:

```text
browser_get_tabs
```

If there is a relevant ChatGPT tab for this session and the user is asking a follow-up, use it.

Otherwise open a new tab and navigate to ChatGPT home:

```text
browser_open_tab
browser_navigate url="https://chatgpt.com/"
```

Then find the project named `opencode` in the sidebar and click it. Use the direct project URL only as a fallback if the sidebar route is unavailable.

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
Sign up
Continue with Google
Continue with Apple
Continue with Microsoft
```

stop and tell the user:

```text
ChatGPT is not logged in in this browser session. Please log in manually and create an active logged-in session, then I can retry.
```

If ChatGPT shows human verification, CAPTCHA, unusual activity, Cloudflare challenge, or account prompt that requires the human, stop and ask the user to complete it manually.

### 5. Create or choose the right project chat

For follow-up questions, stay in the existing ChatGPT chat only if it is clearly the same conversation.

For unrelated new questions:

1. Navigate to `https://chatgpt.com/`.
2. Find and click the project named `opencode` in the sidebar.
3. Verify visible project context shows `opencode`.
4. Create or use a fresh project-scoped chat from there.
5. If using any new-chat control, verify `opencode` remains visible afterward before typing.

Do not open an unrelated existing chat from the project recents list just because the project page has a stale draft. Existing chats are old threads.

Before typing, clear any pre-existing unsubmitted text from the input field:

Use:

```text
browser_snapshot
browser_type selector="role:textbox" text="" clear="true"
```

Then verify stale draft text is gone or no stale prompt appears near the composer:

```text
browser_snapshot
browser_query mode="page_text"
```

If stale text cannot be cleared, stop and report that the stale draft could not be cleared. Do not leave project scope as a workaround.

### 6. Ensure Thinking effort is Extended

Before submitting, inspect the composer/model controls:

```text
browser_snapshot
browser_query mode="page_text"
```

Find the Thinking / reasoning effort control. Ensure:

```text
Thinking effort: Extended
```

or equivalent UI state.

Possible workflow:

1. Open the model/tools/thinking selector near the composer.
2. Choose `Thinking` if it is disabled.
3. Choose `Extended` as the effort level.
4. Verify the visible state indicates Extended thinking.

Selector ideas will change as ChatGPT's UI changes. Prefer ARIA/snapshot-driven interaction over hard-coded CSS.

Look for controls or labels such as:

```text
Thinking
Think
Reason
Reasoning
Effort
Extended
More
Tools
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

Focus the ChatGPT input field.

Prefer selectors in this order:

```text
role:textbox
aria:Message ChatGPT
placeholder:Message ChatGPT
css:textarea
css:[contenteditable="true"]
```

Use:

```text
browser_type selector="role:textbox" text="<PROMPT>"
```

If typing fails, use `browser_snapshot` to find the composer element and retry with a more specific selector.

### 8. Submit the prompt

After the input field has focus and the prompt text is present, submit by clicking ChatGPT's send button with opencode-browser.

Primary submit method:

```text
browser_click selector="button[aria-label=\"Send prompt\"]"
```

Fallback selectors:

```text
browser_click selector="aria:Send prompt"
browser_click selector="button[aria-label=\"Send\"]"
browser_click selector="aria:Send"
```

Do **not** use `chrome-devtools_press_key` as the submit path while opencode-browser is available. It can time out and is slower than clicking the real send button.

Do not spam submissions. One successful click is sufficient.

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
ChatGPT said:

<concise summary of ChatGPT's final answer>

Relevant details:

<any specific commands, caveats, URLs, or reasoning points worth preserving>

My read:

<your brief assessment, agreement/disagreement, missing caveats, or recommended next step>
```

If the user asked only to fetch ChatGPT's answer, keep your own assessment short.

## Troubleshooting

### ChatGPT is logged out

Stop and say:

```text
ChatGPT is not logged in in this browser session. Please log in manually and create an active logged-in session, then I can retry.
```

### Human verification / CAPTCHA

Stop and say:

```text
ChatGPT is asking for human verification. Please complete it manually in the browser, then I can continue.
```

### Overlay blocks the page

Dismiss harmless overlays with Close, Dismiss, Not now, Maybe later, Skip, Got it, Continue, or OK.

Do not click upgrade, subscribe, enable, buy, connect account, share, or privacy-sensitive account actions.

### Extended thinking is unavailable

Stop and say:

```text
I cannot find or enable Extended thinking in this ChatGPT session. Do you want me to continue without it?
```

### Prompt typed but did not submit

Click the send button directly:

```text
browser_click selector="button[aria-label=\"Send prompt\"]"
```

Fallbacks:

```text
browser_click selector="aria:Send prompt"
browser_click selector="button[aria-label=\"Send\"]"
browser_click selector="aria:Send"
```

Do not use `chrome-devtools_press_key` or repeated Enter attempts while opencode-browser is available. Do not spam submissions.

### Stale text in ChatGPT project composer

The project composer may retain a draft from a previous browser session.

Correct behavior:

1. Stay in the verified `opencode` project context.
2. Clear `role:textbox` with `browser_type clear=true`.
3. Verify stale text is gone with `browser_snapshot` or `browser_query mode="page_text"`.
4. Type the new user prompt.

Incorrect behavior:

- Do not leave the `opencode` project just because the composer has stale text.
- Do not append the new prompt to stale text.
- Do not open an unrelated existing chat from the project recents list for an unrelated question.
- Do not decide project scope from URL alone; verify visible `opencode` context.

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

### Multiple ChatGPT tabs exist

Use `browser_get_tabs`. Prefer the tab already used for this OpenCode session when the user asks a follow-up. For unrelated questions, return to `https://chatgpt.com/`, click the `opencode` project in the sidebar, and verify project context before typing.

### The conversation is too long or off-topic

Return to `https://chatgpt.com/`, click the `opencode` project in the sidebar, and start from verified project context.
