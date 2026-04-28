---
name: consult-elders
description: Ask Claude, ChatGPT, Copilot, and Perplexity the same question through their logged-in browser sessions using chrome-devtools MCP, wait for answers, then synthesize a combined answer.
---

# Skill: Consult Elders

Use this skill when the user asks to "consult the elders", ask multiple web assistants, get external opinions, compare model answers, or synthesize answers from Claude, ChatGPT, Copilot, and Perplexity.

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

## Browser control

Use chrome-devtools MCP tools as the primary control path for all four providers. Work from the latest snapshot and use UID values from that snapshot.

- Use `chrome-devtools_list_pages`, `chrome-devtools_select_page`, `chrome-devtools_new_page`, `chrome-devtools_navigate_page` for tab/page setup.
- Use `chrome-devtools_take_snapshot` for DOM/accessibility inspection.
- Use `chrome-devtools_click uid="..."` with snapshot UIDs for clicks.
- Use `chrome-devtools_fill uid="..."` with snapshot UIDs for text inputs.
- Use `chrome-devtools_evaluate_script` only when snapshot/click/fill cannot perform a stable action or for reading structured page state.
- Use `chrome-devtools_wait_for` or repeated snapshots for waiting.
- Use `chrome-devtools_press_key` only as a fallback when no send button is available.

## Core rules

- Use the user's existing logged-in browser sessions.
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

```
<USER_QUESTION>
```

Do not use:

```
I am using you as a second-opinion assistant...
Task: ...
```

For code review or answer comparison, rewrite only enough to make the request self-contained while still sounding like Jon asked it directly.

## Browser setup

Use `chrome-devtools_list_pages` to see open tabs. Open new tabs with `chrome-devtools_new_page` when needed.

## Claude flow

Preferred project entry:

1. Navigate to `https://claude.ai/projects`.
2. Click the project named `opencode` using the UID from a snapshot.
3. Verify project context is visible, such as `opencode`, "Memory", "Instructions", "Files", "Project content".
4. Use the large rounded composer on the project page directly.
5. If it contains stale draft text such as `hello`, clear it in place using `chrome-devtools_fill` with empty string. Do not click `New chat`, do not navigate to `/new`, and do not open an existing project chat for an unrelated question.
6. Type the prompt with `chrome-devtools_fill` using the textbox UID.
7. Submit with `chrome-devtools_click` using the send button UID.
8. Wait until Claude finishes streaming.

Claude red flags:

- `https://claude.ai/new`
- generic home composer text like `Good afternoon, Jon` / `How can I help you today?` without visible `opencode` project context
- clicking global/sidebar `New chat` after entering the project

If a red flag appears, navigate back to `https://claude.ai/projects`, click `opencode`, verify context, and use the project composer.

## ChatGPT flow

Preferred project entry:

1. Navigate to `https://chatgpt.com/`.
2. Find and click the project named `opencode` in the sidebar using the UID from a snapshot.
3. Verify visible project context shows `opencode`.
4. Use the project-scoped composer/chat controls from there.
5. If the composer contains stale draft text, clear it in place. Do not open unrelated existing chats as a workaround.
6. Type the prompt with `chrome-devtools_fill` using the textbox UID.
7. Submit with `chrome-devtools_click` using the send button UID (look for "Send prompt" or "Send").
8. Wait until ChatGPT finishes streaming.

ChatGPT red flags:

- project context `opencode` is no longer visible
- opening an unrelated existing chat from recents
- using `chrome-devtools_press_key` to submit when a send button is available

## Copilot flow

Preferred entry:

1. Navigate to `https://copilot.microsoft.com/`.
2. Verify logged-in state. Logged-in page usually shows account information such as `Jon` / `Microsoft 365 Family`.
3. Use the visible Copilot composer. New global chats are fine.
4. Enable `Think deeper` before submitting.

Think deeper requirement:

- Copilot defaults to `Smart` mode.
- Try snapshot-driven clicks first to click the Smart button and then the Think deeper option.
- If clicking does not open the menu, use the bundled direct-CDP fallback script:

```bash
python3 /home/jon/.config/opencode/skills/copilot-browser/scripts/enable_think_deeper.py
```

Expected successful verification includes:

```
verify: [{'label': 'Think deeper', ...}]
```

If Think deeper cannot be enabled or verified, ask the user whether to continue in Smart mode. Do not silently proceed in Smart mode.

Type the prompt with `chrome-devtools_fill` using the textbox UID.

Submit with `chrome-devtools_click` using the submit button UID (look for "Submit message" or "Send").

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

Type the prompt with `chrome-devtools_fill` using the textbox UID.

Submit behavior:

- Perplexity's submit button has `aria-label="Submit"`.
- It may not exist until after text is entered.

After typing, submit with `chrome-devtools_click` using the submit button UID.

If submit is not found after typing, use the direct search URL fallback:

```
https://www.perplexity.ai/search?q=<URL_ENCODED_QUERY>&source=web
```

Perplexity red flags:

- navigating to `/spaces` by default
- opening the `opencode` Space by default
- getting distracted by `Computer` / task Space UI
- repeated Enter or keypress attempts

## Waiting for answers

After submitting to each site, wait and poll periodically by taking snapshots:

```
chrome-devtools_take_snapshot
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

1. Use `chrome-devtools_take_snapshot` to locate the Copy button nearest the latest assistant response.
2. Click that Copy button using its UID.
3. Read clipboard with shell if available:

```bash
wl-paste
```

Fallbacks:

```bash
xclip -selection clipboard -o
xsel -b
```

If clipboard extraction is unavailable, use `chrome-devtools_take_snapshot` and `chrome-devtools_evaluate_script` to read page content, then extract the latest assistant answer after the submitted prompt. Avoid returning noisy full-page text.

## Synthesis format

Return a compact synthesis, not two raw transcripts.

Use this structure:

```
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

```
<Successful elders> answered, but <failed elder> could not be consulted: <reason>.

<Successful elder summaries>:

My synthesis:
...
```

If multiple elders fail, report each failure reason and synthesize from the successful answers.

If all elders fail, report all failure reasons and ask whether to retry after the user fixes login/verification/browser state.
