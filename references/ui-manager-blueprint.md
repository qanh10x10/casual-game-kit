# UIManager Prefab Blueprint

Use this reference when the request creates or reorganizes a central Unity UI root.
It defines ownership and serialized wiring; it is not a reason to replace an
existing router or add a new framework.

## Decision gate

1. Search first for existing `UIManager`, `UiManager`, `UIMainMenu`, `UIMainGame`,
   popup manager, canvas root, scene router, and `DontDestroyOnLoad` owner.
2. If one owner already controls routes, extend it. Keep its class name, scene
   references, public methods, UnityEvents, and prefab GUIDs.
3. Create `UIManager` only when the project has no central UI owner and the
   requested surfaces need shared route/popup/input-lock ownership.
4. Do not create a manager for one screen, one popup, or a list binder.

## Ownership model

```text
UIManager
  owns UI lifetime, route, shared layers, input lock, global feedback
  does not own economy rules, reward grants, quest progress, or item layout

UIHome / UIGameplay / UICollection / UIShop
  owns one screen's hierarchy, state binding, local actions, screen animation
  delegates domain actions to the existing domain owner

UIDailyReward / UIDailyQuest / UISettings / UIResult
  owns one popup or overlay flow, close/back behavior, and local feedback

DailyRewardItem / QuestItem / CollectionItem / ShopOfferItem
  owns one repeated row/card's visual states and button forwarding
  does not read PlayerPrefs, grant rewards, or calculate prices
```

## Recommended prefab shape

Choose the smallest shape matching the current project.

### Single-scene UI root

```text
UIManager                         (UIManager.cs)
  Canvas                           (existing render mode/scaler)
    SafeArea
      ScreenLayer
        UIHome                     (UIHome.cs)
          Header
          Content
          Footer
        UIGameplay                 (UIGameplay.cs)
          HUD
          BoardSafeOverlay
          ResultOverlay
      PopupLayer
        UIDailyReward              (UIDailyReward.cs)
          Header
          RewardList
          Footer
        UIDailyQuest               (UIDailyQuest.cs)
        UICollection               (UICollection.cs)
        UIShop                     (UIShop.cs)
        UISettings                 (UISettings.cs)
      FeedbackLayer
        Toast
        RewardFeedback
      BlockerLayer                 (input lock/raycast blocker)
```

Use one `Canvas` and one safe-area owner. Screen roots and popup roots may be
inactive by default; `UIManager` activates exactly the requested route.

### Persistent manager plus scene UI

```text
UIManager                         (persistent only if existing project does this)
  SharedCanvas
    SafeArea
      PopupLayer
      FeedbackLayer
      BlockerLayer

Main scene
  SceneUI
    UIGameplay                    (scene-owned board HUD)
```

Do not put scene-only board references into a reusable manager prefab. Bind them
from the scene instance after scene load. Never create duplicate persistent
managers or duplicate canvases.

## Script-to-hierarchy mapping

Example only; replace paths with the project's real first-party roots.

```text
Assets/_Game/Scripts/UI/UIManager.cs
Assets/_Game/Scripts/UI/UIHome.cs
Assets/_Game/Scripts/UI/UIGameplay.cs
Assets/_Game/Scripts/UI/Popups/UIDailyReward.cs
Assets/_Game/Scripts/UI/Popups/UIDailyQuest.cs
Assets/_Game/Scripts/UI/Popups/UICollection.cs
Assets/_Game/Scripts/UI/Popups/UIShop.cs
Assets/_Game/Scripts/UI/Items/DailyRewardItem.cs
Assets/_Game/Scripts/UI/Items/QuestItem.cs
Assets/_Game/Scripts/UI/Items/CollectionItem.cs
Assets/_Game/Scripts/UI/Items/ShopOfferItem.cs
```

The component on each root owns only its direct serialized children:

```text
UIManager.cs       -> home, gameplay, popupLayer, feedbackLayer, blocker
UIHome.cs          -> header, playButton, dailyButton, questButton,
                      collectionButton, shopButton
UIGameplay.cs      -> objectiveText, moveText, pauseButton, resultOverlay
UIDailyReward.cs   -> titleText, rewardList, closeButton, feedback
DailyRewardItem.cs -> dayText, rewardRows, claimButton, locked/claimed markers
UIShop.cs          -> offerList, currencyBar, closeButton
ShopOfferItem.cs   -> icon, quantityText, priceText, buyButton, state markers
```

If a component needs a descendant owned by another component, route through a
method or event; do not serialize cross-screen internals as a shortcut.

## Route contract

Use explicit route methods when the project has no equivalent:

```csharp
OpenHome();
OpenGameplay(GameplayContext context);
OpenPopup(UIPopupId id);
ClosePopup();
SetInputLocked(bool locked);
```

Routes must be idempotent: opening the active route does not duplicate listeners,
animations, or instantiated list items. Back/close returns to the recorded owner
route, not an assumed scene name.

## Lifecycle contract

```text
UIManager.Awake/Initialize
  resolve existing references, validate required roots, subscribe shared events

UIManager.OpenRoute
  close current route, activate target, pass context, lock input during transition

Screen.Open(context)
  subscribe once, request snapshot/view data, bind all visible states

Screen.HandleAction(action)
  validate/delegate to domain owner, show result, wait for refresh event

Screen.Close
  unsubscribe, stop owned tweens/coroutines, clear transient item views
```

Never put `PlayerPrefs`, reward grants, purchase price checks, or quest mutation
inside `UIManager`, screen views, or item views.

## Serialized reference checklist

Before saving the prefab, output and verify:

```text
[ ] UIManager component is on the prefab root.
[ ] Every required root reference points to the correct child.
[ ] No scene-only object is serialized into a reusable prefab asset.
[ ] Canvas, scaler, safe area, sorting order, and raycast blocker match existing values.
[ ] Button callbacks target owner methods, not nested implementation details.
[ ] Repeated item prefab has one binder and explicit state markers.
[ ] Existing GUIDs and scene instance overrides remain intact.
```

## AI implementation output

For any `UIManager` request, return this mapping before mutation:

```yaml
ui_root:
  target_scene: <real scene path>
  target_prefab: <real prefab path or none>
  ownership_mode: ExistingManager | NewManager | SceneOwned
  manager_script: <real script path>
  screens:
    - id: Home
      root: <hierarchy path>
      script: <real script path>
      route: <method/event>
    - id: Gameplay
      root: <hierarchy path>
      script: <real script path>
      route: <method/event>
  popups:
    - id: DailyReward
      root: <hierarchy path>
      script: <real script path>
      primary_action: Claim
  shared_layers: [PopupLayer, FeedbackLayer, BlockerLayer]
  serialized_bindings: []
  scene_only_bindings: []
  forbidden_changes: [new UI framework, duplicate manager, save format]
```

Acceptance: every visible screen has one owner, every route has one entry point,
every action delegates to a domain owner, and every serialized field resolves to
the correct prefab or scene object.
