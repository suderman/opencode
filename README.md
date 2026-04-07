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
| `systematic-debugging`  | Root-cause-first debugging methodology     |
| `chromium-cdp-testing`  | Browser-based web app testing via CDP      |
| `web-design-guidelines` | Web Interface Guidelines compliance review |

## MCP Tools

- `MiniMax` - Local MCP server via `uvx`
- `chrome-devtools` - Browser debugging at `localhost:9222`
- `context7` - Documentation search
- `gh_grep` - GitHub code search
- `figma` - Figma integration (requires auth, see below)

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
