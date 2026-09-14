# Popup And UI Script Contracts

Use this reference when specifying how popup scripts, screen scripts, and item
views cooperate. Names are examples. Reuse the project's real classes and
events when they exist.

## One popup flow

```text
UIManager.OpenPopup(id, context)
  -> select popup root
  -> close current popup
  -> activate target root
  -> target.Open(context)
  -> target requests snapshot/view data
  -> target.Bind(snapshot)

Player taps button
  -> popup script receives intent
  -> popup delegates domain action
  -> domain validates and mutates state
  -> save owner persists once
  -> domain emits changed event
  -> popup refreshes from a new snapshot
  -> popup shows success/error feedback
```

The popup script is a presenter/controller. It is not the data owner. A popup
must not read `PlayerPrefs`, edit a definition asset, grant currency, or decide
whether a purchase/claim is valid.

## Shared popup responsibilities

Each popup root script owns only:

```text
Open(context)       resolve direct references, subscribe once, request snapshot
Bind(snapshot)      render every visible state, including empty/error
HandleAction(...)   forward intent to domain owner, disable duplicate taps
Refresh(snapshot)   rebind after a changed event
Close()             unsubscribe, stop owned animation, clear transient rows
```

Recommended direct fields:

```text
CanvasGroup panel
Button closeButton
Transform contentRoot
GameObject loadingView
GameObject emptyView
GameObject errorView
```

Do not make a universal base class only to share these fields. Extract one only
when the project already has a popup base or multiple popups demonstrably share
real behavior.

## UIManager versus popup script

```text
UIManager.cs
  route, popup stack/owner route, shared blocker, global feedback, lifetime

UIHome.cs / UIGameplay.cs
  one screen's direct hierarchy and screen actions

UIDailyReward.cs / UIDailyQuest.cs / UICollection.cs / UIShop.cs
  one popup's snapshot binding, item creation, local actions, close behavior

DailyRewardItem.cs / QuestItem.cs / CollectionItem.cs / ShopOfferItem.cs
  one row/card's visuals and button intent forwarding

GameManager / EconomyManager / Inventory / QuestService / existing owner
  validation, state mutation, reward/purchase/equip rules, events

Save owner
  serialization, write timing, load/reload behavior
```

The top-level manager may call popup methods. It must not reach into popup child
labels, item internals, or economy fields.

## Daily Reward popup

### Hierarchy

```text
UIDailyReward (UIDailyReward.cs)
  Header/Title
  Header/DayProgress
  Content/Loading
  Content/Empty
  Content/Error
  Content/RewardList
    DailyRewardItem (DailyRewardItem.cs)
      DayText
      RewardRows
        RewardRow (icon, quantity, label)
      LockedState
      ClaimableState
      ClaimedState
      ClaimButton
  Footer/CloseButton
  Overlay/Feedback
```

### Script boundary

```text
UIDailyReward.cs
  GetSnapshot()
  Bind(days)
  OnClaimClicked(day)
  OnDailyRewardChanged()

DailyRewardItem.cs
  Bind(itemViewData)
  SetState(Locked|Claimable|Claimed|Error)
  RaiseClaimIntent(day)

domain owner
  TryClaimDailyReward(day, out result)
```

`DailyRewardItem` only raises `day`. `UIDailyReward` or the existing domain
owner performs the claim. Multi-reward days use a child `RewardRow` binder; do
not put one hard-coded `coinText`, `gemText`, and `boosterText` field on the item
unless the data contract guarantees exactly those three entries.

## Daily Quest popup

```text
UIDailyQuest.cs
  requests quest snapshot
  sorts claimable -> active -> completed/claimed
  binds progress and button state
  forwards Claim and Go intents
  refreshes after quest/currency/level events

QuestItem.cs
  renders description, progress text/bar, reward, state
  raises Claim or Go intent with questId

quest owner
  validates completion, grants reward, persists progress, emits QuestChanged
```

`Go` is enabled only when the target route is known. A missing target renders a
disabled reason; it must not guess a scene or silently close the popup.

## Collection / Deck popup

```text
UICollection.cs
  requests roster snapshot
  applies current filter/sort locally to view data
  keeps selected item ID across refresh
  binds detail panel from selected item
  forwards Equip, Upgrade, and Preview intents

CollectionItem.cs
  renders locked/owned/equipped/upgradeable state
  raises Select(itemId)

inventory/deck owner
  validates ownership, slot rules, cost, and upgrade requirements
  persists result and emits InventoryChanged/DeckChanged
```

Filter and selection are view state. Ownership, equipped status, level, and
upgrade cost are player/domain state. Never mutate the roster definition asset
when equipping or upgrading.

## Shop popup

```text
UIShop.cs
  requests catalog and wallet snapshot
  binds offers and current currency
  opens confirmation for premium/multi-grant offers
  disables duplicate purchase taps while transaction is pending
  maps domain result to feedback, then refreshes from changed event

ShopOfferItem.cs
  renders offer, quantity, price, limit, schedule, sold-out state
  raises Purchase(offerId)

shop/economy owner
  validates schedule, limit, price, wallet, inventory capacity
  charges and grants atomically
  persists once and emits ShopChanged/WalletChanged/InventoryChanged
```

The popup displays the failure reason returned by the domain owner. It does not
recalculate price from UI text or trust a client-side disabled button as proof.

## Settings popup

```text
UISettings.cs
  binds current sound/music/vibration/language values
  forwards toggle/select actions
  closes without changing unrelated screens

settings owner
  validates and persists setting
  emits SettingsChanged when other UI must refresh
```

Use the existing settings model and localization/audio managers. A toggle's
visual value is not persistence proof until the owner accepts the change.

## Result / confirmation overlays

```text
UIResult.cs
  binds immutable result snapshot (win/lose, score, rewards, next route)
  owns Continue, Retry, Home, and optional Revive intents
  locks gameplay input while overlay is active

UIConfirmPurchase.cs
  binds offer preview and exact price
  forwards Confirm/Cancel
  never performs the purchase itself
```

Result overlays consume facts produced by gameplay/domain owners. They do not
inspect board internals or award a second time when reopened.

## Resilient Reference Resolution & Dynamic Fallbacks

In casual game production, prefabs and scenes evolve frequently. Serialized
fields (`[SerializeField]`) often get detached or unassigned (`null`) when
reorganizing hierarchies or swapping prefab variants.

### Resilient Lazy Getters

Never rely solely on serialized Inspector fields for critical UI components.
Provide resilient property getters with dynamic `transform.Find` fallbacks:

```csharp
[SerializeField] private TextMeshProUGUI levelText;

public TextMeshProUGUI LevelText
{
    get
    {
        if (levelText != null) return levelText;
        var panel = PopupPanel;
        if (panel != null)
        {
            Transform t = panel.transform.Find("ScreenContent/CurrentLv")
                ?? panel.transform.Find("CurrentLv");
            if (t != null) levelText = t.GetComponent<TextMeshProUGUI>();
            if (levelText == null)
            {
                foreach (var tmp in panel.GetComponentsInChildren<TextMeshProUGUI>(true))
                {
                    if (tmp.name == "CurrentLv" || tmp.name == "LevelText")
                    {
                        levelText = tmp;
                        break;
                    }
                }
            }
        }
        return levelText;
    }
}
```

### Facade & Owner Auto-Binding

Sub-controllers (`UIWin`, `UILose`, `UIGameplay`) attached to popups or sub-panels
must safely resolve their parent facade (`UiManager` or `UIManager`):

```csharp
private void EnsureOwner()
{
    if (owner == null)
    {
        owner = GetComponentInParent<UiManager>()
            ?? UnityEngine.Object.FindFirstObjectByType<UiManager>(FindObjectsInactive.Include);
        if (owner != null) Bind(owner);
    }
}
```

### Exact Type & Property Verification

Never guess field names on external managers. Inspect source definitions or MCP
metadata before calling:
- Example: check `arrowManager.spawnedArrows` vs `arrowManager.arrows`.
- Accessing non-existent members yields CS1061 compile errors.

## Win / Result Popup & Progression Sequence

### Dynamic Level Resolution

Never hardcode completed level text (e.g. static "LEVEL 20"):

```csharp
int completedLevel = 1;
if (owner?.levelManager != null && owner.levelManager.ActiveLevel > 0)
    completedLevel = owner.levelManager.ActiveLevel;
else if (LevelManager.Instance != null && LevelManager.Instance.ActiveLevel > 0)
    completedLevel = LevelManager.Instance.ActiveLevel;
else
    completedLevel = Mathf.Max(1, GameData.CurrentLevel - 1);

if (LevelText != null)
    LevelText.text = $"LEVEL {completedLevel}";
```

### Deduplicated Event Handlers

When both `UIManager` and `UIWin` listen to `OnLevelCompleted`, guard `RecordWin`
against duplicate calls in the same frame/level:

```csharp
public static void RecordWin(int currentLevel = -1)
{
    if (mutating) return;
    if (currentLevel <= 0) currentLevel = GameData.CurrentLevel;
    if (currentLevel > 0 && lastRecordedWinLevel == currentLevel) return;
    if (currentLevel > 0) lastRecordedWinLevel = currentLevel;
    // ... increment win metrics ...
}
```

### Milestone Rescue / Unlock Chaining

1. Each win increments rescue progress by 1 ($0.2$ fill amount).
2. Upon reaching 5 ($1.0$), keep progress at 5 and flag `EarnedPetCount = UnlockedPetCount + 1` (`PendingPetIndex >= 0`).
3. Animate gauge fill to $1.0$ and trigger a milestone punch effect.
4. When the player clicks Continue or finishes rewarded ad, trigger the chained unlock dialog (`UIPopupWinPet`).
5. Only upon claiming the pet from `UIPopupWinPet` reset the progress counter to 0 for the next cycle.

## Booster Unlocking, Pacing & Onboarding Gifts

1. **Centralized Level Constants:** Define explicit unlock milestones:
   ```csharp
   public const int UnlockLevelRuler = 3;
   public const int UnlockLevelHint = 4;
   public const int UnlockLevelEraser = 5;
   public const int UnlockLevelMagicWand = 6;
   ```
2. **Onboarding Gifts Idempotency:** When a player reaches or exceeds a booster unlock level for the first time, grant starter quantity (e.g. 2 boosters) and record a persistent flag:
   ```csharp
   if (level >= UnlockLevelRuler && PlayerPrefs.GetInt("ArrowGame_BoosterGift_GridLines", 0) == 0)
   {
       PlayerPrefs.SetInt("ArrowGame_BoosterGift_GridLines", 1);
       GameData.GridLines.Value += 2;
       PlayerPrefs.Save();
   }
   ```
3. **Synchronized Guard Conditions:** Both UI visibility (`UpdateBoosterUnlockStates`) and click actions (`OnHintClick`, `OnEraserClick`, etc.) must check the exact same unlock constants (`level >= UnlockLevelHint`), preventing unclickable or unresponsive booster buttons.

## Item list rules

```text
Popup script owns list lifetime and ordering.
Item view owns one item's rendering.
Domain owner owns action validity.
```

For each item:

```text
Bind(viewData)
  set ID, labels, icons, progress, and all state markers
  set button interactability and disabled reason
  clear stale listeners before adding the current intent listener
```

Reuse existing pooling/list helpers when present. Otherwise instantiate the
smallest existing item prefab pattern. Do not create a generic list framework
for one popup.

## Event and listener rules

```text
Open/OnEnable: subscribe once
Close/OnDisable: unsubscribe symmetrically
Bind: render complete snapshot, not only changed fields
Action: disable while pending, re-enable from result
Changed event: request fresh snapshot, then bind
```

Avoid per-frame polling. Avoid duplicate subscriptions after reopening. Avoid
capturing a loop variable that no longer matches the bound item ID.

## Required AI output for popup scripts

```yaml
popup_contract:
  id: DailyReward
  root: <real hierarchy path>
  controller_script: <real script path>
  item_script: <real script path or none>
  direct_references: []
  view_state: [selectedId, filter, pendingAction]
  snapshot_source: <existing owner/method>
  actions:
    - intent: Claim(day)
      domain_owner: <real owner/method>
      success_event: <real event>
      failure_reasons: []
  lifecycle: [Open, Bind, HandleAction, Refresh, Close]
  forbidden: [PlayerPrefs in view, definition mutation, direct child reach-through]
```

Acceptance: popup behavior can be traced from button to intent, domain
validation, persistence, changed event, and refreshed visual state without
crossing ownership boundaries.
