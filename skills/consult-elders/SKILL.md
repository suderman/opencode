---
name: consult-elders
description: Ask Claude, ChatGPT, Copilot, and Perplexity the same question through their logged-in browser sessions, wait for answers, then synthesize a combined answer.
---

# Skill: Consult Elders

Use this skill when the user asks to "consult the elders", ask multiple web assistants, get external opinions, compare model answers, or synthesize answers from Claude, ChatGPT, Copilot, and Perplexity.

This skill assumes the `@different-ai/opencode-browser` plugin is installed and available.

## Goal

Ask the same user question to:

- Claude, inside the Claude `opencode` project
- ChatGPT, inside the ChatGPT `opencode` project
- Copilot, in a new/global Copilot chat with Think deeper enabled
- Perplexity, from the main Perplexity home/search page

Then wait for all available responses and return a synthesized answer that separates:

- what Claude said
- what ChatGPT said
- what Copilot said
- what Perplexity said
- agreement / disagreement
- combined recommendation

## Core rules

- Use the user's existing logged-in browser sessions.
- Use opencode-browser tools (`browser_*`) as the primary browser-control path.
- Do not use MCP/chrome-devtools tools unless opencode-browser cannot perform the needed action.
- Do not send secrets, credentials, private keys, tokens, client-private data, or sensitive personal/financial information unless the user explicitly approves that exact prompt.
- Ask all sites the same prompt, typed directly as the user. Do **not** prepend disclosure text like "I am using you as a second-opinion assistant".
- Keep Claude and ChatGPT inside their respective `opencode` projects. Copilot and Perplexity do not need project scoping.
- Do not decide project membership from URL alone. Verify visible project context.
- If any site is logged out, blocked by CAPTCHA, or requires human verification, report which site is blocked.
- If one elder fails and others succeed, return the successful answers plus the failure reason.

## Related skills

This skill combines the operational rules from:

- `claude-browser`
- `chatgpt-browser`
- `copilot-browser`
- `perplexity-browser`

When in doubt about a site-specific detail, follow that site's dedicated skill.

## Prompt handling

Use the user's question directly.

Good prompt:

```text
<USER_QUESTION>
```

Do not use:

```text
I am using you as a second-opinion assistant...
Task: ...
```

For code review or answer comparison, rewrite only enough to make the request self-contained while still sounding like Jon asked it directly.

## Browser setup

Use:

```text
browser_status
browser_get_tabs
```

Use existing tabs when useful, but for unrelated new questions prefer clean project entry flows instead of old chat threads.

## Claude flow

Preferred project entry:

1. Navigate to `https://claude.ai/projects`.
2. Click the project named `opencode`.
3. Verify project context is visible, such as:

```text
opencode
Memory
Instructions
Files
Project content
```

4. Use the large rounded composer on the project page directly.
5. If it contains stale draft text such as `hello`, clear it in place. Do not click `New chat`, do not navigate to `/new`, and do not open an existing project chat for an unrelated question.
6. Type the prompt with:

```text
browser_type selector="role:textbox" text="<PROMPT>" clear=true
```

7. Submit with:

```text
browser_click selector="aria:Send message"
```

8. Wait until Claude finishes streaming.

Claude red flags:

- `https://claude.ai/new`
- generic home composer text like `Good afternoon, Jon` / `How can I help you today?` without visible `opencode` project context
- clicking global/sidebar `New chat` after entering the project

If a red flag appears, navigate back to `https://claude.ai/projects`, click `opencode`, verify context, and use the project composer.

## ChatGPT flow

Preferred project entry:

1. Navigate to `https://chatgpt.com/`.
2. Find and click the project named `opencode` in the sidebar.
3. Verify visible project context shows `opencode`.
4. Use the project-scoped composer/chat controls from there.
5. If the composer contains stale draft text, clear it in place. Do not open unrelated existing chats as a workaround.
6. Type the prompt with:

```text
browser_type selector="role:textbox" text="<PROMPT>" clear=true
```

7. Submit with:

```text
browser_click selector="button[aria-label=\"Send prompt\"]"
```

Fallback submit selectors:

```text
browser_click selector="aria:Send prompt"
browser_click selector="button[aria-label=\"Send\"]"
browser_click selector="aria:Send"
```

8. Wait until ChatGPT finishes streaming.

ChatGPT red flags:

- project context `opencode` is no longer visible
- opening an unrelated existing chat from recents
- using `chrome-devtools_press_key` to submit while opencode-browser is available

## Copilot flow

Preferred entry:

1. Navigate to `https://copilot.microsoft.com/`.
2. Verify logged-in state. Logged-in page usually shows account information such as `Jon` / `Microsoft 365 Family`.
3. Use the visible Copilot composer. New global chats are fine.
4. Enable `Think deeper` before submitting.

Think deeper requirement:

- Copilot defaults to `Smart` mode.
- Try normal opencode-browser clicks first.
- If clicking `Smart` does not open the menu, use the bundled direct-CDP fallback script from `copilot-browser`:

```bash
python3 /home/jon/.config/opencode/skills/copilot-browser/scripts/enable_think_deeper.py
```

Expected successful verification includes:

```text
verify: [{'label': 'Think deeper', ...}]
```

If Think deeper cannot be enabled or verified, ask the user whether to continue in Smart mode. Do not silently proceed in Smart mode.

Type the prompt with:

```text
browser_type selector="role:textbox" text="<PROMPT>" clear=true
```

Submit with:

```text
browser_click selector="button[aria-label=\"Submit message\"]"
```

Fallback submit selectors:

```text
browser_click selector="aria:Submit message"
browser_click selector="button[aria-label=\"Send\"]"
browser_click selector="aria:Send"
```

Copilot red flags:

- staying in `Smart` mode without user approval
- using repeated Enter/keypress attempts instead of the submit button
- spending time debugging blocked Sentry/profile-photo/CSP console noise

## Perplexity flow

Preferred entry:

1. Navigate to `https://www.perplexity.ai/`.
2. Verify logged-in state if possible.
3. Use the main Perplexity home/search composer. Do **not** use Spaces by default.
4. Default mode is fine; do not change model/search mode unless the user asks.

Type the prompt with:

```text
browser_type selector="role:textbox" text="<PROMPT>" clear=true
```

Fallback composer selectors:

```text
css:textarea
css:[contenteditable="true"]
```

Submit behavior:

- Perplexity's submit button has `aria-label="Submit"`.
- It may not exist until after text is entered.

After typing, submit with:

```text
browser_click selector="button[aria-label=\"Submit\"]"
```

Fallback submit selectors:

```text
browser_click selector="aria:Submit"
browser_click selector="aria:Send"
browser_click selector="aria:Ask"
```

If submit is not found after typing, use the direct search URL fallback:

```text
https://www.perplexity.ai/search?q=<URL_ENCODED_QUERY>&source=web
```

Perplexity red flags:

- navigating to `/spaces` by default
- opening the `opencode` Space by default
- getting distracted by `Computer` / task Space UI
- repeated Enter or `chrome-devtools_press_key` attempts

## opencode-browser constraints

- Use `browser_snapshot` for accessibility/DOM snapshots.
- Use `browser_query mode="page_text"` for page text extraction.
- Do **not** call `browser_query mode="snapshot"`; that mode does not exist.
- Do **not** use `browser_query mode="page_text" selector="role:textbox"` to decide whether a textbox exists. `page_text` extracts visible text; it is not a selector existence check.
- Do not use Playwright-only selector syntax such as `button:has-text("New chat")` unless verified supported. Prefer `text:...`, `aria:...`, `role:textbox`, and simple CSS selectors.
- If a selector fails, inspect with `browser_snapshot` and retry with supported selectors.

## Waiting for answers

After submitting to each site, wait and poll periodically:

```text
browser_wait
browser_query mode="page_text"
browser_snapshot
```

Streaming indicators may include:

- visible `Stop` control
- response text still changing
- spinner/progress indicator
- disabled composer
- send button not returned

Consider a response complete when:

- stop/progress indicators disappear
- composer/send control returns
- page text is stable across two polls
- a Copy button appears near the latest assistant message

Wait up to about 5 minutes per site for complex questions.

## Extraction

Prefer the cleanest extraction available.

Best option:

1. Use `browser_snapshot` to locate the Copy button nearest the latest assistant response.
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

Then extract the latest assistant answer after the submitted prompt. Avoid returning noisy full-page text.

## Synthesis format

Return a compact synthesis, not two raw transcripts.

Use this structure:

```text
Claude said:
- <key points>

ChatGPT said:
- <key points>

Copilot said:
- <key points>

Perplexity said:
- <key points, including important source names if useful>

Agreement:
- <where they align>

Differences:
- <where they disagree or emphasize different things>

Combined answer:
<your concise synthesized answer>

Notes / risks:
- <blocked site, uncertainty, outdated info risk, or skipped verification>
```

If the user asked for only the final result, keep individual elder sections very short and put most value in `Combined answer`.

## Failure handling

If one elder fails but others succeed:

```text
<Successful elders> answered, but <failed elder> could not be consulted: <reason>.

<Successful elder summaries>:
...

My synthesis:
...
```

If multiple elders fail, report each failure reason and synthesize from the successful answers.

If all elders fail, report all failure reasons and ask whether to retry after the user fixes login/verification/browser state.
