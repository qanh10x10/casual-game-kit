# Framework Contract

## Boundary map

```text
Authoring assets (CSV/ScriptableObject)
        -> definition loader/importer
        -> player state (progress, ownership, claims, currency)
        -> surface presenter/view model
        -> UGUI prefab views
        -> user action
        -> domain transaction
        -> persist once, emit refresh event
```

## Ownership

| Responsibility | Owner | Must not do |
|---|---|---|
| Definition | `ScriptableObject`/CSV importer | Store per-player claim or ownership. |
| Player state | Existing state model or the smallest new model | Reach into prefab hierarchy. |
| Domain action | Existing manager or one focused service | Change labels, sprites, or animation. |
| Presenter | Surface controller | Recalculate economy rules. |
| View | MonoBehaviour prefab component | Read `PlayerPrefs` directly or grant rewards. |
| Persistence | Existing save owner | Save on every visual frame. |
| Feedback | Shared event/toast/VFX pattern | Hide failed transaction reason. |

## Surface lifecycle

```csharp
Open(context)
Bind(snapshot)
HandleAction(action)
Refresh(snapshot)
Close()
```

`Open` resolves references and subscribes once. `Bind` renders all visible states. `HandleAction` validates through domain owner. `Refresh` is event-driven. `Close` unsubscribes and kills owned tweens/coroutines.

## Minimal seam names

Use names like these when the project has no equivalent; do not add an interface merely to match the list:

```csharp
DailyRewardSnapshot GetSnapshot();
bool TryClaimDailyReward(int day, out RewardClaimResult result);
void Bind(DailyRewardSnapshot snapshot);
void BindItem(DailyRewardItemViewData item);
```

The domain owner returns success/failure data. The presenter maps it to labels, sprites, button state, and feedback. The view owns no economy rule.

## State matrix minimum

Every surface declares relevant states: `Loading`, `Empty`, `Locked`, `Available`, `Selected`, `Owned`, `Claimable`, `Claimed`, `Disabled`, `Error`. Each action declares `canExecute`, `disabledReason`, and resulting event.

## Prefab contract

Use this shallow shape unless existing hierarchy proves otherwise:

```text
SurfaceRoot
  SafeArea
    Header
    Content
    Footer
  Overlay
```

Repeated children use one item prefab and a binder. Do not encode state by sibling names such as `Image (7)`. Preserve GUIDs and serialized references during moves.

## Puzzle-specific seam

The board owns rules. UI receives facts: objective progress, moves/energy, score, combo, selected cell/item, and result. UI never decides match validity, merge result, reward amount, or purchase price.
