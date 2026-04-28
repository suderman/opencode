---
name: copilot-browser
description: Ask Microsoft Copilot questions through the user's logged-in copilot.microsoft.com browser session using opencode-browser.
---

# Copilot Browser Skill

Use this skill when the user asks you to consult Microsoft Copilot through the browser, ask Copilot a question, get a second opinion from Copilot, compare your answer with Copilot, or retrieve an answer from the user's logged-in Copilot web session.

This skill assumes the `@different-ai/opencode-browser` plugin is installed and available.

## Browser control priority

**Primary:** Use opencode-browser tools (`browser_*`) for all browser control.

**Fallbacks (in order):**
1. `chrome-devtools_*` tools — use only when opencode-browser cannot perform the needed action
2. `webfetch` — use only for read-only content retrieval when browser control is unavailable

Do not use MCP/chrome-devtools tools as the primary path while opencode-browser works.

## opencode-browser constraints

- Use `browser_snapshot` for accessibility/DOM snapshots.
- Use `browser_query mode="page_text"` for page text extraction.
- Do **not** call `browser_query mode="snapshot"`; that mode does not exist.
- Do **not** use `browser_query mode="page_text" selector="role:textbox"` to decide whether a textbox exists. `page_text` extracts visible text; it is not a selector existence check.
- Do not use Playwright-only selector syntax such as `button:has-text("...")` unless verified supported. Prefer `text:...`, `aria:...`, `role:textbox`, and simple CSS selectors.
- If a selector fails, inspect with `browser_snapshot` and retry with supported selectors.

## Entry URL

Always enter Copilot through:

```text
https://copilot.microsoft.com/
```

New global chats are fine. No project scoping is required.

## Core rules

- Use the user's existing logged-in Copilot browser session.
- If Copilot is not logged in, stop. Ask the user to log in manually and create an active logged-in session, then retry.
- Dismiss overlays, popups, marketing banners, cookie banners, upgrade prompts, onboarding dialogs, and similar interruptions before proceeding.
- Enable `Think deeper` before submitting a prompt. Treat this as a hard gate: do not proceed in `Smart` mode unless the user explicitly approves continuing without Think deeper.
- Submit by clicking Copilot's send button: `aria-label="Submit message"`.
- Ask directly as the user. Do **not** prepend disclosure text like "I am using you as a second-opinion assistant".
- Allow Copilot enough time to generate the answer. This may take 30 seconds to 5 minutes depending on complexity and network speed.
- Do not send secrets, credentials, private keys, tokens, client-private data, or sensitive personal/financial material unless the user explicitly approves that exact prompt.
- Do not pretend Copilot's answer is your own work. Clearly separate what Copilot said from your own assessment.

## Basic workflow

### 1. Check browser availability

Use:

```text
browser_status
browser_get_tabs
```

If unavailable, report the browser/plugin problem directly.

### 2. Open or reuse Copilot

Prefer an existing relevant Copilot tab for follow-up questions.

For unrelated questions, open or navigate to:

```text
browser_open_tab url="https://copilot.microsoft.com/"
```

or:

```text
browser_navigate url="https://copilot.microsoft.com/"
```

New global chats are acceptable.

### 3. Dismiss overlays

After page load, inspect the page:

```text
browser_snapshot
browser_query mode="page_text"
```

Dismiss harmless overlays that block the composer.

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

After each dismissal, inspect again. Continue until the prompt composer is reachable or until blocked by login/verification.

### 4. Verify logged-in state

Use:

```text
browser_query mode="page_text"
browser_snapshot
```

If the page shows a login/signup state, stop and tell the user:

```text
Copilot is not logged in in this browser session. Please log in manually and create an active logged-in session, then I can retry.
```

Login indicators may include:

```text
Sign in
Log in
Continue with Microsoft
Microsoft account
```

If Copilot shows human verification, CAPTCHA, unusual activity, or an account prompt requiring the human, stop and ask the user to complete it manually.

### 5. Start or use a chat

New global chats are fine. If Copilot lands on a usable composer, use it directly.

If the composer contains stale draft text, clear it in place before typing:

```text
browser_type selector="role:textbox" text="" clear=true
```

If `role:textbox` fails, inspect with `browser_snapshot` and retry with likely composer selectors:

```text
css:textarea
css:[contenteditable="true"]
```

Do not append the new prompt to stale draft text.

### 6. Enable Think deeper

Before submitting, inspect the composer controls:

```text
browser_snapshot
browser_query mode="page_text"
```

Copilot may default to `Smart`, which is the simpler mode. The composer mode toggle button has `aria-label="Smart"`, `title="Smart"`, and `data-testid="composer-chat-mode-smart-button"` when Smart is active. After switching, the active mode should be `Think deeper`. Do **not** submit while the composer mode button still has `aria-label="Smart"`.

If a `Think deeper` option/control is visible, enable it before submitting. This is a required step, not optional, unless the control cannot be found after inspection.

Possible selectors:

```text
button[aria-label="Smart"]
css:button[data-testid="composer-chat-mode-smart-button"]
css:button[data-testid="composer-chat-mode-smart-button"][aria-label="Smart"]:not([role="menuitem"])
css:button[title="Smart"]
css:button[aria-label="Smart"]
button[aria-label^="Think deeper"]
css:#popoverPortal button[data-testid="composer-chat-mode-reasoning-button"]
css:button[data-testid="composer-chat-mode-reasoning-button"]
css:button[title="Think deeper"]
css:button[aria-label^="Think deeper"]
aria:Think deeper
text:Think deeper
role:button[name="Think deeper"]
```

Likely workflow:

1. Inspect the mode toggle.
2. If the composer mode button has `aria-label="Smart"`, click it using the exact simple selector `button[aria-label="Smart"]`. This mirrors the browser-console command that works: `$('button[aria-label="Smart"]').click()`.
3. The mode menu is rendered elsewhere in the DOM under `#popoverPortal`; it may not look visually attached to the composer in the snapshot.
4. Wait briefly, then immediately click the Think deeper option with `button[aria-label^="Think deeper"]`.
5. If that fails, try `css:#popoverPortal button[data-testid="composer-chat-mode-reasoning-button"]`, then `css:button[data-testid="composer-chat-mode-reasoning-button"]`, then `css:button[aria-label^="Think deeper"]`, then `css:button[title="Think deeper"]`, then `aria:Think deeper`.
6. Inspect again with `browser_snapshot` / `browser_query mode="page_text"`.
7. Verify the composer mode button now has `aria-label="Think deeper"` and `data-testid="composer-chat-mode-reasoning-button"`, not `aria-label="Smart"`.

Avoid the broad selector `aria:Smart` as the first choice. It can be ambiguous. Prefer the exact simple CSS selector `button[aria-label="Smart"]`.

Do not give up just because `Think deeper` is not found in `page_text` after opening the Smart menu. The menu option has stable DOM selector `css:button[data-testid="composer-chat-mode-reasoning-button"]`; click that selector directly.

If opencode-browser clicks do not open the menu after two attempts, use the bundled direct-CDP fallback script. It does the same thing that works manually in the browser console: click `button[aria-label="Smart"]`, wait briefly, then click `button[aria-label^="Think deeper"]`.

Run:

```bash
python3 /home/jon/.config/opencode/skills/copilot-browser/scripts/enable_think_deeper.py
```

The script connects to Chromium at `http://127.0.0.1:9222/json`, finds a Copilot page, runs JavaScript directly in that page, and prints verification. Expected successful verification includes:

```text
verify: [{'label': 'Think deeper', ...}]
```

If `Think deeper` still cannot be enabled or verified after this fallback, stop and ask the user whether to continue in Smart mode. Do not silently proceed in Smart mode.

### 7. Type the prompt

Prepare a concise, self-contained prompt. Type it directly as the user.

Prompt template:

```text
<USER_TASK>
```

Focus and type:

```text
browser_type selector="role:textbox" text="<PROMPT>" clear=true
```

Fallback selectors:

```text
css:textarea
css:[contenteditable="true"]
```

If typing fails, inspect with `browser_snapshot` and retry with the visible composer selector.

### 8. Submit the prompt

Primary submit method:

```text
browser_click selector="button[aria-label=\"Submit message\"]"
```

Fallback selectors:

```text
browser_click selector="aria:Submit message"
browser_click selector="button[aria-label=\"Send\"]"
browser_click selector="aria:Send"
```

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
- response text is still changing
- a spinner/progress indicator is visible
- composer is disabled
- send button has not returned

Consider the answer complete when:

- stop/progress indicators disappear
- composer/send control returns
- page text is stable across two polls
- a Copy button appears near the latest assistant message

### 10. Extract the final answer

Prefer the cleanest extraction available.

Best option:

1. Use `browser_snapshot` to locate the Copy button nearest the latest Copilot response.
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

Then extract the latest Copilot answer after the submitted prompt. Avoid returning noisy full-page text.

### 11. Return the result

Use:

```text
Copilot said:

<concise summary of Copilot's answer>

Relevant details:

<specific facts, commands, caveats, URLs, or reasoning worth preserving>

My read:

<brief assessment, agreement/disagreement, uncertainty, or recommended next step>
```

If the user asked only to fetch Copilot's answer, keep `My read` short.

## Troubleshooting

### Copilot is logged out

Stop and say:

```text
Copilot is not logged in in this browser session. Please log in manually and create an active logged-in session, then I can retry.
```

### Human verification / CAPTCHA

Stop and say:

```text
Copilot is asking for human verification. Please complete it manually in the browser, then I can continue.
```

### Overlay blocks the page

Dismiss harmless overlays with Close, Dismiss, Not now, Maybe later, Skip, Got it, Continue, or OK.

Do not click upgrade, subscribe, buy, connect account, share, or privacy-sensitive account actions.

### Think deeper unavailable

If Copilot remains in `Smart` mode, do not immediately proceed. First:

1. Inspect the composer controls with `browser_snapshot`.
2. Click the exact composer mode button:

```text
browser_click selector="button[aria-label=\"Smart\"]"
```

3. Wait briefly, then click the Think deeper menu option:

```text
browser_click selector="button[aria-label^=\"Think deeper\"]"
```

4. If opening Smart fails, try:

```text
browser_click selector="css:button[aria-label=\"Smart\"]"
browser_click selector="css:button[title=\"Smart\"]"
browser_click selector="css:button[data-testid=\"composer-chat-mode-smart-button\"]"
```

5. If clicking the reasoning menu option fails, try:

```text
browser_click selector="css:#popoverPortal button[data-testid=\"composer-chat-mode-reasoning-button\"]"
browser_click selector="css:button[data-testid=\"composer-chat-mode-reasoning-button\"]"
browser_click selector="css:button[aria-label^=\"Think deeper\"]"
browser_click selector="css:button[title=\"Think deeper\"]"
browser_click selector="aria:Think deeper"
```

6. Inspect again and verify the mode button now has `aria-label="Think deeper"`.

If the menu still does not open after two opencode-browser attempts, use the bundled direct-CDP fallback script from Section 6:

```bash
python3 /home/jon/.config/opencode/skills/copilot-browser/scripts/enable_think_deeper.py
```

If `Think deeper` is unavailable or cannot be verified after this, stop and ask the user whether to continue in Smart mode. Do not silently proceed.

### Prompt typed but did not submit

Click the submit button directly:

```text
browser_click selector="button[aria-label=\"Submit message\"]"
```

Fallbacks:

```text
browser_click selector="aria:Submit message"
browser_click selector="button[aria-label=\"Send\"]"
browser_click selector="aria:Send"
```

Do not spam submissions.

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

### Console noise

These console/network messages are usually not relevant to Copilot mode switching unless the UI is visibly broken:

- blocked Sentry telemetry, e.g. `sentry.io ... ERR_BLOCKED_BY_CLIENT`
- Microsoft Graph profile photo 404, e.g. `/me/photo/$value 404`
- CSP violation reports such as `wasm-eval`

Do not spend time debugging these for normal Copilot chat automation. Focus on visible UI state and whether the Smart / Think deeper buttons can be clicked.
