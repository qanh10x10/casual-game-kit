# Data Contracts

## Three layers

1. **Definition:** stable content authored by designers.
2. **State:** player-owned progress and claim/ownership flags.
3. **View model:** derived display state with no persistence responsibility.

## Daily Reward

```csharp
[Serializable]
public sealed class DailyRewardDefinition
{
    public int day;
    public List<RewardEntry> rewards;
}

[Serializable]
public sealed class RewardEntry
{
    public string rewardId; // gold, gem, energy, item id
    public int amount;
}

[Serializable]
public sealed class DailyRewardState
{
    public string cycleId;
    public int currentDay;
    public string lastClaimDateUtc;
    public List<string> claimedKeys; // JsonUtility-compatible storage
}
```

Claim key = `cycleId + ":" + day`. Transaction order:

1. Resolve current date/cycle.
2. Reject if key already claimed, day locked, definition missing, or reward invalid.
3. Apply every `RewardEntry` atomically through currency/inventory owner.
4. Mark key claimed.
5. Persist state once.
6. Emit `DailyRewardChanged` and reward feedback.

No UI button may set `isClaimed` before the domain transaction succeeds.

The contract must choose `clockAuthority` (`LocalDevice` or trusted server), `cyclePolicy` (`Calendar` or `Consecutive`), `missedDayPolicy` (`Hold`, `AdvanceOne`, `CatchUp`, or `Reset`), and reset time. AI must not infer these from a seven-card layout.

## Daily Quest

Definition fields: `questId`, localization key, target event, target amount, reward entries, cycle. State fields: `current`, `claimed`, `lastResetDateUtc`. Progress is monotonic and clamps at target. Unknown quest IDs are logged and ignored, not silently mapped to another quest.

## Collection

Definition: `itemId`, display/localization keys, icon, rarity, stats, unlock rule. State: owned count, level, equipped slot, discovered flag. View derives `Locked`, `Available`, `Owned`, `Equipped`, `Upgradeable`.

## Shop

Definition: `offerId`, item/reward entries, price entries, purchase kind (`SoftCurrency`, `PremiumCurrency`, `IAP`, or `Ad`), schedule, limit, localization keys. State: purchase count, reset key, owned items, balances. Purchase validates offer schedule, limit, price, inventory capacity, then applies price and grants item in one transaction. IAP UI delegates receipt validation and entitlement to the installed purchasing layer. UI shows exact failure reason.

## Authoring format

CSV is acceptable for flat rows. Multi-reward cells need a documented delimiter and equal-length validation. Prefer explicit `RewardEntry` rows when delimiter parsing becomes ambiguous. Importers create/update ScriptableObjects; runtime never parses CSV.

## IDs and localization

IDs are stable, ASCII, and never generated from display text. UI stores localization keys, not translated sentences. Currency IDs, quest IDs, offer IDs, and reward IDs are contracts across code, CSV, analytics, and save data.
