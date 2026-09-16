# UI Code And Prefab Layout

Audit the target project first. This is the default split for a portrait casual
puzzle with Home + gameplay. Reuse existing class names; do not rename to match
this file.

## Two facades, one job each

| Type | Role | Typical path |
| --- | --- | --- |
| `UIManager` | Home coordinator: startup, safe-area, routes, level map | `.../Script/Other/UI/UIManager.cs` |
| `UIHome : UIManager` | Empty compatibility subclass. Keeps prefab script GUID and UnityEvent targets | `.../Script/Other/UIHome.cs` |
| `UiManager` | Gameplay facade. Serialized HUD / result / booster / settings refs | `.../Script/Other/UiManager.cs` |

`UIManager` and `UiManager` are different types. Verify the source file before
calling either. Do not merge them. Do not add a third router.

Startup: gameplay facade `SetupUI()`, then Home `Initialize(enterFirstLevel)`.
Without a Home controller, fall back to existing gameplay load. Home visible
disables the gameplay root and Canvas so the board/timer do not run underneath.

## Handler kinds

| Kind | When | Examples | Contract |
| --- | --- | --- | --- |
| MonoBehaviour on screen root | Root has its own prefab or serialized bindings | `UIShop`, `UICollection`, `UIDailyLogin`, `UISetting` | `Initialize(owner)` once; `OnOpen` / `OnClose`; `Refresh` |
| Plain class on coordinator | Binds coordinator fields only; no own prefab | `UIHomePanel`, `UIProfile`, `UIRemoveAds`, `UIMasterPass`, `UIGameRule` | Methods take the coordinator; no second MonoBehaviour |
| Focused component on gameplay facade | Same GameObject as `UiManager` | `UIGameplay`, `UIWin`, `UILose` | `Bind(owner)`; facade keeps serialized refs |

Do not promote a plain handler to MonoBehaviour to “look complete”. Do not fold
shop/collection logic back into `UIManager`.

## Prefab / scene ownership

```text
UIManager.prefab
  UIHomePanel
    SafeArea
      UIHome                 map / play / streak / coins
      UIShop                 shop root + UIShop.cs
      UICollection           collection root + UICollection.cs
      UIDailyLogin           nested UIDailyReward.prefab + UIDailyLogin.cs
      UIPiggyBank            popup root
      UIRemoveAds
      UISetting
      UIMasterPass
      UIGameRule
      NavigationBar          dual-guard: SetVisualRoute AND OnOpen/OnClose
      UIDialog               shared modal for leftover routes
  (scene override) gameplayCanvas -> Main scene gameplay Canvas

Main gameplay Canvas (scene-owned, not in reusable Home prefab)
  UiManager + UIGameplay + UIWin + UILose
  HUD, boosters, settings, result popups
```

Standalone prefab cannot hold another scene root. Scene instance overrides beat
prefab defaults. `homeScreenPopup` on the gameplay facade may still mean the
gameplay HUD — do not reassign it to Home.

Live nested prefab instance names stay stable (`UIDailyLogin` even if the asset
is `UIDailyReward.prefab`). Do not rename route objects to match a skill example.

## Route contract

```text
Navigate(destination)
  play            start saved current level
  home / close    SetVisualRoute(home), close popups, refresh map
  shop|collection SetVisualRoute, close popups, RefreshSurfaces
  dailyLogin|settings|profile|removeAds|spin|piggyBank|masterPass|starterPack
                  open that popup, keep Home under it unless mutually exclusive

SetVisualRoute(route)
  gameplayCanvas active only for "gameplay"
  UIHome / UIShop / UICollection mutually exclusive
  NavigationBar hidden for shop and collection (and again in those OnOpen)
```

Routes are idempotent: no duplicate listeners, tweens, or instantiated rows.
Back/close returns to the recorded owner route, not an assumed scene name.

Locked map nodes are not interactable; their callbacks no-op. Play of an
unlocked node starts immediately, including replay, without rewriting the
highest unlocked level. Win advances the frontier only.

## Data owners

```text
HomeProgress     local profile, streaks, daily claim, collection, VIP/ad-free flags
GameData         coins, inventory, current level, music/sfx/vibration/theme
LevelManager     board lifecycle, ActiveLevel for the current attempt
UI                snapshot bind + intent forward; no PlayerPrefs, no grants
```

Keep save-key prefixes stable. Home keys stay under their own prefix; do not
redirect economy keys through it.

## Evidence without Unity MCP

Read the coordinator, facade, focused handlers, `HomeProgress`/`GameData`, then
the prefab/scene YAML for serialized refs and overrides. Resolve `m_Script`
GUIDs through `.cs.meta`. Report File evidence. Play Mode / Device remain
unverified until actually run.
