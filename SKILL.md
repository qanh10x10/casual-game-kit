---
name: casual-game-kit
description: "Audit and build Unity casual & puzzle game UI surfaces from evidence-backed code, hierarchy, state, and data contracts. Use for Home, Gameplay HUD, Daily Reward, Daily Quest, Collection, Shop, upgrade, and result UI work."
---

# Casual Game Kit (Unity UI)

Use this skill when a Unity casual or puzzle game needs code structure, UGUI prefab composition, or data-driven UI. Preserve the project's architecture and dirty worktree. Do not fix unrelated bugs.

## Operating contract

Every task produces a **surface contract** before code or prefab mutation:

```text
surface -> user job -> states -> actions -> data source -> hierarchy -> bindings
        -> owner -> persistence -> events -> validation evidence
```

1. Identify the target Unity project by path and editor instance. Use Unity MCP first when available.
2. Read existing scripts, scenes, prefabs, ScriptableObjects, CSVs, package manifest, and local guidance. Record paths and line numbers.
   Treat `references/project-audit.md` as TowerDefense example evidence only; for another project, audit its own files first.
3. Map the real flow end to end. Separate definition data from player state and view state.
4. Reuse existing UGUI, `TextMeshProUGUI`, button, safe-area, localization, animation, pooling, and save patterns before adding code.
5. State unknowns explicitly. A missing Unity MCP connection, unobserved Play Mode, or unverified target is not proof of runtime readiness.
6. For implementation requests, present the contract and mutation boundary first. Only then edit the smallest responsible files.
7. Validate the requested surface, its empty/loading/locked/claimable/error states, and the changed data path. Do not claim Play Mode or device validation without evidence.
8. For a central `UIManager` prefab request, read `references/ui-manager-blueprint.md` and return its `ui_root` mapping before creating or reorganizing any prefab.
9. For popup/controller/item behavior, read `references/ui-popup-script-contracts.md` and return the button -> intent -> domain -> persistence -> event -> refresh trace before writing UI scripts.
10. For ScriptableObjects, data models, CSV, loading, or `Assets` folder organization, read `references/data-and-assets-blueprint.md` and return its `data_contract` mapping before creating or moving files.
11. For Canvas, anchors, pivots, safe area, `ScrollRect`, `ContentSizeFitter`, or layout groups, read `references/ugui-layout-blueprint.md` and return its `layout_contract` before changing a scene or prefab.

## Modes

- **Audit:** evidence map only; no edits.
- **Specify:** write a complete contract and prefab/data recipe; no runtime edits.
- **Implement:** execute one approved surface contract, then validate.
- **Verify:** inspect current work against a contract; do not expand scope.

## Rules AI must follow

- Definitions live in authoring assets (`ScriptableObject`, CSV, or existing project source). Player progress, ownership, claims, currencies, and settings live in a separate state model.
- UI reads a view model or state snapshot. UI never mutates authoring definitions directly.
- Reward claims are idempotent: validate availability, apply all reward entries once, persist state, then emit refresh events.
- Every action has a disabled reason and a visible state. Never use color alone to communicate locked, ready, claimed, or error.
- Every list item has explicit states: loading, empty, locked, available, selected, owned, claimed, and error where relevant.
- Use one primary action per surface. Secondary actions close, navigate, preview, or open help.
- Keep hierarchy semantic and shallow: `Screen`, `SafeArea`, `Header`, `Content`, `Footer`, `Overlay`. Name repeated prefabs by role, not by screenshot position.
- Use existing dependency direction. Do not introduce a framework, service locator, event bus, or database for one surface.
- Preserve GUIDs and serialized references when reorganizing prefabs. Validate scene instances separately from prefab assets.
- Treat localization keys, currency IDs, reward IDs, item IDs, and quest IDs as stable contracts.

## Required output

For each requested surface, return:

1. Evidence map with source paths.
2. Surface contract using `references/ai-spec-template.md`.
3. State matrix and user flow.
4. Code ownership and exact data bindings.
5. Prefab hierarchy recipe.
6. Validation commands/evidence, including what remains unverified.

Read supporting references only as needed:

- Project-specific evidence: `references/project-audit.md`
- Framework and code boundaries: `references/framework.md`
- Data schemas and transactions: `references/data-contracts.md`
- UX recipes for each surface: `references/ux-surfaces.md`
- Central UIManager prefab ownership and script mapping: `references/ui-manager-blueprint.md`
- Popup, screen, item, domain, persistence, and event boundaries: `references/ui-popup-script-contracts.md`
- ScriptableObject, runtime state, view-model, CSV, Resources, and Assets folder guidance: `references/data-and-assets-blueprint.md`
- 1080x1920 Canvas, anchors, pivots, scrolling, layout groups, item sizing, and popup composition: `references/ugui-layout-blueprint.md`
- Unity MCP target/read/verify workflow: `references/unity-mcp-workflow.md`
- Copy-paste contract template: `references/ai-spec-template.md`
- Completion gates: `references/validation.md`
