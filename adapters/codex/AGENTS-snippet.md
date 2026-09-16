<!-- Add this section to AGENTS.md in your repository for OpenAI Codex / OpenAgent -->

## Unity Puzzle Game UI Skill
When auditing or building Unity puzzle game UI:
- Follow skill `puzzle-game-ui` (located in `.agents/skills/puzzle-game-ui` or global `~/.codex/skills/puzzle-game-ui` / `~/.agents/skills/puzzle-game-ui`).
- Formulate a Surface Contract using `references/ai-spec-template.md` before changing code or prefabs.
- Enforce strict separation between authoring definitions (ScriptableObjects/CSVs) and mutable player state.
- Keep reward claims idempotent and UI hierarchies semantic (`Screen/SafeArea/Header|Content|Footer|Overlay`).
- Follow `references/ui-code-layout.md` for Home coordinator vs gameplay facade (`UIManager` vs `UiManager`).
- Do not call Unity MCP unless the current request explicitly asks for it. File evidence is the default.
