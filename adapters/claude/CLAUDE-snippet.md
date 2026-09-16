<!-- Add this section to CLAUDE.md in any Unity repo -->

## Unity Puzzle Game UI
For Unity UI work (Home, HUD, Popups, Quests, Rewards, Shop, Upgrades):
- Follow skill `puzzle-game-ui` (in `~/.claude/skills/puzzle-game-ui` or `.claude/skills/puzzle-game-ui` or `.agents/skills/puzzle-game-ui`).
- Produce a Surface Contract before mutating code or prefabs.
- Never bind UI directly to mutate authoring assets (ScriptableObjects/CSVs).
- See `references/` for blueprints on layout, UIManager, popup contracts, and validation.
- Follow `references/ui-code-layout.md` for Home coordinator vs gameplay facade (`UIManager` vs `UiManager`).
- Do not call Unity MCP unless the current request explicitly asks for it. File evidence is the default.
