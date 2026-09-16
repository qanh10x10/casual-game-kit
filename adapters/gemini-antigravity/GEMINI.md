# Gemini & Antigravity - Unity Puzzle Game UI Skill

When performing tasks related to Unity UI (Home, HUD, Popups, Quests, Rewards, Shop, Upgrades):

## Core Contract (Required before mutating code or prefabs)
```text
surface -> user job -> states -> actions -> data source -> hierarchy -> bindings
        -> owner -> persistence -> events -> validation evidence
```

## Immutable Architecture Rules
1. **Definitions vs State:** Definitions (ScriptableObjects, CSVs) are immutable at runtime. Player progress, currencies, and item claims live in dedicated runtime state models. Never bind UI directly to mutate definitions.
2. **Idempotent Claims:** Validate claim eligibility -> Apply all reward items once -> Persist state to storage -> Emit event for UI refresh.
3. **Hierarchy Standard:** Semantic and shallow: `Screen` -> `SafeArea` -> `Header`, `Content`, `Footer`, `Overlay`.
4. **Detailed Blueprints:** Consult skill references in `~/.agents/skills/casual-game-kit/references/` or `./.agents/skills/casual-game-kit/references/`:
   - `ui-code-layout.md`: Home coordinator vs gameplay facade, routes, prefab ownership.
   - `ugui-layout-blueprint.md`: 1080x1920 reference resolution, Safe Area, ScrollRect.
   - `ui-manager-blueprint.md`: UIManager hierarchy and script ownership.
   - `ui-popup-script-contracts.md`: Button -> intent -> domain -> persistence -> event flow.
   - `data-contracts.md`: Currency and reward data schemas.
   - `validation.md`: Verification gates.
5. **File-first:** Do not call Unity MCP unless the current request explicitly asks for it.
