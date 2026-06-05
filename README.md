# Jon's OpenCode Config

Personal OpenCode configuration synced to GitHub.

## Structure

- `opencode.json` - Main config: providers, permissions, plugins, MCP tools
- `tui.json` + `themes/custom.json` - Catppuccin Mocha-inspired TUI theme
- `AGENTS.md` - Engineering conventions and agent rules
- `dcp.jsonc` - Dynamic Context Pruning plugin settings
- `notification-ntfy.json` - ntfy.sh notification plugin settings
- `agents/` - Custom agent definitions (`mini`, `super`, `solo`, `scout`, `craft`)
- `commands/` - Slash commands (`/commit`, `/commitall`)
- `skills/` - Specialized workflows

## Skills

| Skill                    | Purpose                                    |
| ------------------------ | ------------------------------------------ |
| `browser-control-basics` | Shared Chromium control rules              |
| `systematic-debugging`   | Root-cause-first debugging methodology     |
| `browser-testing`        | Browser-based web app testing in Chromium  |
| `ui-guidelines-review`   | Web Interface Guidelines compliance review |
| `web-inspector-editing`  | Temporary live-browser CSS and JS testing  |
| `chatgpt-browser`        | Ask ChatGPT through browser                |
| `claude-browser`         | Ask Claude through browser                 |
| `copilot-browser`        | Ask Microsoft Copilot through browser      |
| `gemini-browser`         | Ask Gemini through browser                 |
| `perplexity-browser`     | Ask Perplexity through browser             |
| `consult-elders`         | Ask all AI assistants simultaneously       |
| `wordpress-master`       | WordPress theme, plugin, and block work     |

## Agents

| Agent   | Purpose                                         |
| ------- | ----------------------------------------------- |
| `mini`  | Default implementation agent (MiniMax-M3)     |
| `super` | Multi-agent coordination (GPT-5.5 medium)          |
| `scout` | Read-only investigation (GPT-5.4-mini subagent) |
| `craft` | Scoped implementation (GPT-5.4-mini subagent)   |
| `solo`  | Direct high-reasoning worker (GPT-5.5 medium)   |

## Commands

| Command      | Purpose                  |
| ------------ | ------------------------ |
| `/commit`    | Guided commit workflow   |
| `/commitall` | Commit everything in one |

## MCP

- `MiniMax` - Local MCP server via `uvx`
- `chrome-devtools` - Browser debugging at `localhost:9222`
- `context7` - Documentation search
- `gh_grep` - GitHub code search
- `figma` - Figma integration (requires auth, see below)

### Chrome DevTools MCP

My agents are expenting a chromium wrapper named `chromium-agent` with its own
user data directory and remote debugging port set. It should look something like
this:

```sh
#!/usr/bin/env
chromium --user-data-dir=$HOME/.config/chromium-agent --disk-cache-dir=/run/user/$UID/chromium-agent --remote-debugging-port=9222
```

### Figma MCP Setup

Figma MCP rejects non-whitelisted agents. Authenticate first:

```bash
cd /tmp && git clone https://github.com/gberaudo/opencode-mcp-figma && cd opencode-mcp-figma
npm i && npm run build && npm start https://mcp.figma.com/mcp
# Move mcp-auth.json to ~/.local/share/opencode/mcp-auth.json
```

## Plugins

- `opencode-ntfy.sh` - Push session notifications via ntfy.sh
- `@simonwjackson/opencode-direnv` - Direnv integration
- `@tarquinen/opencode-dcp@latest` - Dynamic context pruning

## Setup

```bash
cp .env.example .env
# Edit .env with your API keys
```

Uses direnv for automatic env loading. Run `nix develop` or `npm i opencode-ai`
to get the binary.

## Current models reference

- `minimax-coding-plan/MiniMax-M3`
- `minimax-coding-plan/MiniMax-M2.7`
- `openai/gpt-5.5`
- `openai/gpt-5.4`
- `openai/gpt-5.4-mini`
