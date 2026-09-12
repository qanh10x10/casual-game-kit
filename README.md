# Casual Game Kit (Unity UI)

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Agent Skills Specification](https://img.shields.io/badge/Standard-Agent%20Skills-brightgreen.svg)](SKILL.md)

A universal, cross-platform AI agent skill for auditing, architecting, and building Unity casual and puzzle game UI (Home, HUD, Daily Reward, Quests, Shop, Popups, Results) following the open **Agent Skills** specification.

### Supported Platforms & AI Agents
- **GitHub Copilot** (VS Code, Visual Studio, Copilot CLI)
- **Claude Code** (Anthropic CLI & Desktop)
- **OpenAI Codex** (Codex CLI & OpenAgent)
- **Google Antigravity & Gemini CLI**
- **Cursor**
- **Windsurf** (Cascade)
- **Cline & Roo Code**
- **Continue.dev**

Repository: [https://github.com/qanh10x10/casual-game-kit.git](https://github.com/qanh10x10/casual-game-kit.git)

---

## 1. Quick Start via NPX (Recommended)

The skill kit includes a zero-dependency Node.js CLI installer that runs immediately with `npx`:

### A. Run remotely (No clone required)
```bash
# Install globally across all IDEs and agents on your machine:
npx github:qanh10x10/casual-game-kit --global

# Or install directly into the current Unity project directory:
npx github:qanh10x10/casual-game-kit
```

### B. Run after cloning the repository
```bash
git clone https://github.com/qanh10x10/casual-game-kit.git
cd casual-game-kit

# Global install (for current user profile):
node ./bin/cli.js --global

# Or project-level install into any Unity repository:
node ./bin/cli.js -p /path/to/MyUnityProject
```

---

## 2. Alternative Installation Scripts

If Node.js is not available, shell scripts are provided out of the box:

### Windows (PowerShell)
```powershell
# Global user install:
powershell -ExecutionPolicy Bypass -File .\install.ps1 -Scope Global

# Project install:
powershell -ExecutionPolicy Bypass -File .\install.ps1 -Scope Project -TargetPath "D:\Projects\MyGame"
```

### macOS / Linux (Bash)
```bash
# Global user install:
chmod +x ./install.sh
./install.sh global

# Project install:
./install.sh project /path/to/MyGame
```

---

## 3. Directory Layout

```text
casual-game-kit/
├── SKILL.md                          # Open Agent Skills specification
├── bin/cli.js                        # Zero-dependency Node.js CLI installer
├── package.json                      # npm package configuration
├── agents/
│   └── openai.yaml                   # Model and runtime configuration
├── references/                       # 11 comprehensive architecture blueprints
│   ├── ai-spec-template.md           # Surface Contract copy-paste template
│   ├── data-and-assets-blueprint.md  # ScriptableObject, CSV, and runtime state boundaries
│   ├── data-contracts.md             # Currency, reward, and transaction schemas
│   ├── framework.md                  # Architectural boundaries and code limits
│   ├── project-audit.md              # Project audit evidence template
│   ├── ugui-layout-blueprint.md      # 1080x1920 layout, SafeArea, ScrollRect standards
│   ├── ui-manager-blueprint.md       # Central UIManager prefab and root composition
│   ├── ui-popup-script-contracts.md  # Popup controller and item contracts
│   ├── unity-mcp-workflow.md         # Unity MCP integration workflow
│   ├── ux-surfaces.md                # Recipes for each surface (Home, Shop, Quests, etc.)
│   └── validation.md                 # Acceptance criteria and completion gates
├── adapters/                         # Ready-to-use IDE and Agent rule adapters
│   ├── cursor/casual-game-kit.mdc    # Cursor Rules (.cursor/rules/)
│   ├── windsurf/.windsurfrules       # Windsurf Cascade rules
│   ├── gemini-antigravity/           # GEMINI.md & rules.md for Gemini & Antigravity
│   ├── cline/.clinerules             # Cline & Roo Code instructions
│   ├── continue/casual-game-kit.prompt # Continue.dev slash command prompt
│   ├── codex/AGENTS-snippet.md       # AGENTS.md snippet for OpenAI Codex
│   ├── copilot/instructions-snippet.md # .github/copilot-instructions.md snippet
│   └── claude/CLAUDE-snippet.md      # CLAUDE.md snippet for Claude Code
├── install.ps1                       # Windows PowerShell installer
├── install.sh                        # Unix Bash installer
└── README.md
```

---

## 4. Usage by AI Assistant

### GitHub Copilot (VS Code & CLI)
Invoke explicitly in chat or allow automatic trigger:
```text
@casual-game-kit Create a surface contract for the Daily Reward popup.
```

### Claude Code (CLI & Desktop)
In your terminal `claude` session:
```text
Review the Shop UI architecture against the casual-game-kit skill.
```

### OpenAI Codex (CLI & OpenAgent)
Codex automatically detects the skill from `~/.codex/skills/casual-game-kit/SKILL.md` or `.agents/skills/`.

### Cursor
The `.cursor/rules/casual-game-kit.mdc` rule automatically activates whenever editing `.cs`, `.prefab`, or `.unity` files. You can also mention it explicitly:
```text
@casual-game-kit.mdc Design the HUD layout for 1080x1920 portrait.
```

### Google Antigravity & Gemini CLI
The workspace `GEMINI.md` and `~/.agents/skills/casual-game-kit` supply the full contract rules to Gemini models.

### Windsurf, Cline & Continue.dev
Use their corresponding adapter rules (`.windsurfrules`, `.clinerules`, `.continue/prompts`).

---

## 5. Core Architectural Principles

Every UI task must produce a **Surface Contract** before mutating code or prefabs:

```text
surface -> user job -> states -> actions -> data source -> hierarchy -> bindings
        -> owner -> persistence -> events -> validation evidence
```

1. **Definitions vs Runtime State:**
   Authoring definitions (`ScriptableObject`, CSV) are immutable at runtime. Player progress, currencies, item claims, and settings live in dedicated runtime state models. UI views never mutate authoring assets directly.

2. **Idempotent Claim Transactions:**
   Always follow: Validate availability -> Apply reward entries once -> Persist state -> Emit refresh event.

3. **Semantic Hierarchy:**
   Keep layout semantic and shallow:
   `Screen` -> `SafeArea` -> `Header` / `Content` / `Footer` / `Overlay`.

4. **Explicit Visual States:**
   Every button and interactive element must account for all states: normal, loading, empty, locked, available, selected, owned, claimed, and error. Never use color alone to communicate state.

---

## 6. Blueprint Documentation Map

| Document | Purpose |
|---|---|
| [`ai-spec-template.md`](references/ai-spec-template.md) | Standard copy-paste surface contract template |
| [`data-and-assets-blueprint.md`](references/data-and-assets-blueprint.md) | ScriptableObjects, runtime view-models, CSV importing |
| [`data-contracts.md`](references/data-contracts.md) | Schemas for currency, quests, rewards, and transactions |
| [`framework.md`](references/framework.md) | Architecture boundaries and layer separation |
| [`ugui-layout-blueprint.md`](references/ugui-layout-blueprint.md) | 1080x1920 reference resolution, Safe Area, anchors, pivots |
| [`ui-manager-blueprint.md`](references/ui-manager-blueprint.md) | Root prefab UIManager ownership and script mapping |
| [`ui-popup-script-contracts.md`](references/ui-popup-script-contracts.md) | Popup, controller, and item boundary contracts |
| [`unity-mcp-workflow.md`](references/unity-mcp-workflow.md) | Best practices when using Unity AI MCP |
| [`ux-surfaces.md`](references/ux-surfaces.md) | Implementation recipes for Home, HUD, Daily Reward, Quests, Shop |
| [`validation.md`](references/validation.md) | Acceptance criteria, completion gates, and verification |

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
