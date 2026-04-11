# Jon's OpenCode Config

Personal opencode configuration synced to GitHub.

## Structure

- `opencode.json` - Main config: providers, permissions, plugins, MCP tools
- `opencode-minimax-easy-vision.json` - MiniMax vision plugin config
- `tui.json` + `themes/custom.json` - Catppuccin Mocha-inspired TUI theme
- `AGENTS.md` - Engineering conventions and agent rules
- `agents/` - Custom agent definitions (review agent with restricted tools)
- `commands/` - Slash commands (`/commit`, `/test`)
- `skills/` - Specialized workflows

## Skills

| Skill                   | Purpose                                    |
| ----------------------- | ------------------------------------------ |
| `browser-control-basics`| Shared Chromium control rules              |
| `systematic-debugging`  | Root-cause-first debugging methodology     |
| `browser-testing`       | Browser-based web app testing in Chromium  |
| `ui-guidelines-review`  | Web Interface Guidelines compliance review |
| `web-inspector-editing` | Temporary live-browser CSS and JS testing  |

## MCP Tools

- `MiniMax` - Local MCP server via `uvx`
- `chrome-devtools` - Browser debugging at `localhost:9222`
- `context7` - Documentation search
- `gh_grep` - GitHub code search
- `figma` - Figma integration (requires auth, see below)

### Chrome DevTools MCP

I created a wrapper around `chrome-devtools` using flock. The original mcp
configuration it replaced looked like this:

```json
"chrome-devtools": {
  "enabled": true,
  "type": "local",
  "command": [
    "npx",
    "-y",
    "chrome-devtools-mcp@latest",
    "--browser-url=http://127.0.0.1:9222",
    "--no-usage-statistics"
  ]
},
```

### Figma MCP Setup

Figma MCP rejects non-whitelisted agents. Authenticate first:

```bash
cd /tmp && git clone https://github.com/gberaudo/opencode-mcp-figma && cd opencode-mcp-figma
npm i && npm run build && npm start https://mcp.figma.com/mcp
# Move mcp-auth.json to ~/.local/share/opencode/mcp-auth.json
```

## Plugins

- `opencode-minimax-easy-vision` - Vision support
- `@simonwjackson/opencode-direnv` - Direnv integration
- `@slkiser/opencode-quota` - Quota tracking

## Setup

```bash
cp .env.example .env
# Edit .env with your API keys
```

Uses direnv for automatic env loading. Run `nix develop` or `npm i opencode-ai`
to get the binary.

## Current models reference

- `minimax-coding-plan/MiniMax-M2.7`
- `openai/gpt-5.4`
- `opencode/claude-opus-4-6`
- `openrouter/google/gemini-3-pro-preview`
