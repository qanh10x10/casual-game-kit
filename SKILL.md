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

1. Identify the target Unity project by path. Read scripts, scenes, prefabs, ScriptableObjects, CSVs, package manifest, and local guidance first. Record paths.
   Treat `references/project-audit.md` as example evidence only; for another project, audit its own files first.
2. **Do not call Unity MCP unless the current user request explicitly asks for it** (Editor hierarchy, Play Mode, Console, prefab/scene mutation through Unity). File evidence is the default. A connected Unity editor is not permission.
3. Map the real flow end to end. Separate definition data from player state and view state.
4. Reuse existing UGUI, `TextMeshProUGUI`, button, safe-area, localization, animation, pooling, and save patterns before adding code.
5. State unknowns explicitly. Unread YAML, unobserved Play Mode, or an unused MCP connection is not proof of runtime readiness.
6. For implementation requests, present the contract and mutation boundary first. Only then edit the smallest responsible files.
7. Validate the requested surface, its empty/loading/locked/claimable/error states, and the changed data path. Do not claim Play Mode or device validation without evidence.
8. For a central `UIManager` prefab request, read `references/ui-manager-blueprint.md` and `references/ui-code-layout.md`, then return the `ui_root` mapping before creating or reorganizing any prefab.
9. For popup/controller/item behavior, read `references/ui-popup-script-contracts.md` and return the button -> intent -> domain -> persistence -> event -> refresh trace before writing UI scripts.
10. For ScriptableObjects, data models, CSV, loading, or `Assets` folder organization, read `references/data-and-assets-blueprint.md` and return its `data_contract` mapping before creating or moving files.
11. For Canvas, anchors, pivots, safe area, `ScrollRect`, `ContentSizeFitter`, or layout groups, read `references/ugui-layout-blueprint.md` and return its `layout_contract` before changing a scene or prefab.

## Modes

- **Audit:** evidence map only; no edits.
- **Specify:** write a complete contract and prefab/data recipe; no runtime edits.
- **Implement:** execute one approved surface contract, then validate.
- **Verify:** inspect current work against a contract; do not expand scope.

## Default evidence path (no MCP)

```text
script owners -> prefab/scene YAML -> serialized fields/GUID -> callers -> save keys
```

Inspect `.cs`, `.prefab`, `.unity`, `.asset`, and `.cs.meta` GUIDs. A similarly named prefab is not the live scene owner. Scene instance overrides beat standalone prefab defaults. Source field initializers do not overwrite Inspector values.

When Unity MCP **is** explicitly requested, read `references/unity-mcp-workflow.md` and identify the exact project path plus editor PID before any call.

## UI code layout AI must follow

Match the project's existing split. Do not invent a second router.

```text
Home coordinator (UIManager)
  owns startup, safe-area, Home/gameplay visibility, level select, Navigate/SetVisualRoute
  does not own economy rules or item layout

Compatibility facade (e.g. UIHome : UIManager)
  empty subclass that keeps the serialized component type and UnityEvent targets
  does not duplicate routing

Gameplay facade (UiManager — different type)
  serialized HUD/result/booster/settings references
  focused components on the same GameObject own behavior (UIGameplay, UIWin, UILose)

Focused route handlers
  MonoBehaviour on a screen root when that root has its own prefab/bindings
    (UIShop, UICollection, UIDailyLogin, UISetting)
  plain class owned by the coordinator when it only binds coordinator fields
    (UIHomePanel, UIProfile, UIRemoveAds, UIMasterPass, UIGameRule)
  Initialize(owner) once; OnOpen/OnClose for enter/exit; Refresh from events

Domain / persistence
  Home progress, claims, streaks, collection: one Home state owner
  Coins, inventory, settings, current level: existing GameData/save owner
  UI never writes PlayerPrefs or grants rewards itself
```

Prefab sections under `SafeArea` are named by owner (`UIHome`, `UIShop`, `UICollection`, …). Shared modal lives in one dialog root. Gameplay Canvas is a separate scene root; Home hides it so the board/timer do not run underneath.

Routes:

```text
Navigate(destination)     open popup/screen, close others, refresh
SetVisualRoute(route)     mutually exclusive Home | Shop | Collection | Gameplay
                          dual-guard persistent HUD (NavigationBar) here AND in OnOpen/OnClose
```

Opening the active route must not duplicate listeners, tweens, or list items.

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
- Use resilient property accessors with dynamic `transform.Find` fallbacks for popup UI references (level text, coin amounts, continue buttons) rather than assuming Inspector references are wired.
- Guard hierarchy uniqueness: verify no duplicate GameObjects (e.g. multiple gauges or buttons) stack under `ScreenContent` or card containers.
- Enforce progression deduplication: event-driven level completion handlers must guard against duplicate calls within the same level.
- Auto-provision missing components (`GetComponent<Button>() ?? gameObject.AddComponent<Button>()`) during binding and sanitize listeners (`RemoveListener` before `AddListener`) to prevent duplicate callbacks.
- Dual-guard persistent HUD elements (e.g. `NavigationBar` visibility) in both the sub-screen controller (`OnOpen`/`OnClose`) and the central route orchestrator (`SetVisualRoute`).
- Structure milestone chests with timed auto-closing preview tooltips (1.0s) and permanent interaction lockout (`btn.interactable = false`) once claimed.
- Force visual mesh updates on Spine `SkeletonGraphic` multi-skin assets by calling `Initialize(true)` when dynamically changing `initialSkinName`.
- Prevent Unity editor crashes in TMP mesh modifiers: never call `ForceMeshUpdate()` in `TEXT_CHANGED_EVENT` (causes infinite recursion stack overflow) or `OnValidate()`; use dirty flags in `LateUpdate()`.
- Disambiguate project manager names (e.g. `UIManager` vs `UiManager`) and verify SFX method signatures from source before coding.
- Scale complete visual assemblies synchronously in attention animations (e.g. head, tail, line width) via DOTween scalar rather than animating isolated sub-parts.
- Prefer a source build / file diff for C# checks. Do not reimport, poll compile state, or read the Unity Console through MCP unless the user asked for Unity MCP.

## Required output

For each requested surface, return:

1. Evidence map with source paths.
2. Surface contract using `references/ai-spec-template.md`.
3. State matrix and user flow.
4. Code ownership and exact data bindings.
5. Prefab hierarchy recipe.
6. Validation commands/evidence, including what remains unverified.

Read supporting references only as needed:

- UI script/prefab ownership and route split: `references/ui-code-layout.md`
- Project-specific evidence: `references/project-audit.md`
- Framework and code boundaries: `references/framework.md`
- Data schemas and transactions: `references/data-contracts.md`
- UX recipes for each surface: `references/ux-surfaces.md`
- Central UIManager prefab ownership and script mapping: `references/ui-manager-blueprint.md`
- Popup, screen, item, domain, persistence, and event boundaries: `references/ui-popup-script-contracts.md`
- ScriptableObject, runtime state, view-model, CSV, Resources, and Assets folder guidance: `references/data-and-assets-blueprint.md`
- 1080x1920 Canvas, anchors, pivots, scrolling, layout groups, item sizing, and popup composition: `references/ugui-layout-blueprint.md`
- Unity MCP (opt-in only): `references/unity-mcp-workflow.md`
- Copy-paste contract template: `references/ai-spec-template.md`
- Completion gates: `references/validation.md`
