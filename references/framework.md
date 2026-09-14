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

## Visual Feedback & Whole-Entity Tweening (DOTween)

When providing visual highlights or attention-drawing animations (e.g. Hint booster, objective pulse):
- **Whole-Entity Scaling:** Animate the complete visual unit rather than only sub-parts. For example, in an arrow composed of a `LineRenderer`, head `Transform`, and tail `Transform`:
  - Modulating only `headTransform.DOScale()` leaves the body static and looks disconnected.
  - Animate a single scalar variable via `DOTween.To()` and update `head.localScale`, `tail.localScale`, and `lineRenderer.widthMultiplier` synchronously.
- **Sorting Order Elevation:** During active attention tweening, temporarily boost the sorting order (e.g. `arrowSortingOrderMoving`) so the pulsing object renders cleanly above surrounding elements without clipping.
- **Clean Teardown:** In `StopHighlight()`, kill the tween and explicitly reset all modulated values (`Vector3.one`, `baseLineWidth`, original sorting orders).

## Progression Deduplication & Booster Pacing

- **Idempotent Win Events:** Event listeners from multiple surfaces (`UIManager`, `UIWin`) must not cause double-counting. Track `lastRecordedWinLevel` in `HomeProgress` to guarantee one progression increment per completed level.
- **Pacing & Unlock Thresholds:** Centralize booster unlock requirements as explicit constants. Both HUD display state (`UpdateBoosterUI`) and user click handlers (`OnHintClick`, etc.) must strictly check the same constant values.
- **Starter Booster Gifting:** On reaching an unlock milestone, award starter boosters once and record a permanent `PlayerPrefs` flag to avoid infinite grants on subsequent loads.

