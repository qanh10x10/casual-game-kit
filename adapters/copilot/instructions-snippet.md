<!-- Add this section to .github/copilot-instructions.md in any Unity repo -->

## Unity Puzzle Game UI Skill
When designing, modifying, or refactoring Unity UI:
- Load skill `puzzle-game-ui` (located in `.agents/skills/puzzle-game-ui` or global `~/.agents/skills/puzzle-game-ui`).
- Output a Surface Contract (job, states, actions, data source, hierarchy, bindings, persistence, events) before changing code or prefabs.
- Enforce strict separation between authoring definitions (ScriptableObjects/CSVs) and mutable player state.
- Keep reward claims idempotent and UI hierarchies semantic (`Screen/SafeArea/Header|Content|Footer|Overlay`).
