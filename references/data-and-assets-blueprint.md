# Data, ScriptableObject, And Assets Blueprint

Use this reference when a puzzle project needs new data, ScriptableObjects,
CSV import, or an `Assets` folder layout. Audit the target project first and
reuse its real roots. The layout below is a default for a project with no
equivalent structure, not a migration mandate.

## Four data layers

```text
Definition asset
  designer-authored, stable IDs, balance/content, no player progress

Runtime state
  player-owned progress, claims, ownership, currencies, settings, save data

View model
  transient derived labels/icons/progress/button state for one screen

UI prefab/view
  serialized references and visual state only
```

Example flow:

```text
DailyRewardDefinitionSO
  -> DailyRewardState
  -> DailyRewardViewData
  -> UIDailyReward
  -> DailyRewardItem
```

Never mutate a definition asset when a player claims a reward, equips an item,
buys an offer, or upgrades a unit. Never bind a UI directly to a mutable
authoring asset when player state can differ.

## ScriptableObject rules

### Definition ScriptableObject

Use a `ScriptableObject` class for authored content shared by many scenes or
systems:

```csharp
[CreateAssetMenu(menuName = "PuzzleGame/Daily Reward Definition")]
public sealed class DailyRewardDefinitionSO : ScriptableObject
{
    public string cycleId;
    public List<DailyRewardDayDefinition> days;
}
```

Definition fields normally include:

```text
stable ID / cycle ID
localization keys
sprite/icon references
reward/item entries
amounts and balance values
unlock/purchase rules
analytics ID when already used by the project
```

Definition fields must not include:

```text
isClaimed
currentProgress
ownedCount
equippedSlot
wallet balance
lastClaimDate
```

Those belong to runtime state.

### Runtime state

Prefer the existing player state owner (`GameData`, `UserDataModel`, save
model, or equivalent). Add a small serializable state type only when the
existing owner has no suitable field:

```csharp
[Serializable]
public sealed class DailyRewardState
{
    public string cycleId;
    public int currentDay;
    public List<string> claimedKeys;
    public string lastClaimDateUtc;
}
```

Runtime state is loaded, mutated by a domain owner, persisted by the save owner,
then exposed to UI as a snapshot. Do not create a `DailyRewardState.asset` per
player and do not save player progress back into a definition `.asset`.

### View model

Use a plain class/struct for derived display data:

```csharp
public readonly struct DailyRewardItemViewData
{
    public readonly int day;
    public readonly string dayLabel;
    public readonly IReadOnlyList<RewardViewData> rewards;
    public readonly bool canClaim;
    public readonly string disabledReason;
    public readonly DailyRewardItemState state;
}
```

View models may combine definition + runtime state + localization, but have no
save method, domain mutation, or prefab reference.

## Asset instance versus script location

Keep the class and its asset instances separate:

```text
Scripts/.../DailyRewardDefinitionSO.cs   <- C# type
Data/.../DailyReward/default.asset       <- authored instance
```

A `.cs` file inside `Resources` is a misplaced script. A `.asset` file inside a
`Scripts` folder is an authored data instance in the wrong ownership area.

## Recommended default folder layout

Use this only when the project has no established equivalent:

```text
Assets/_Game/
  Art/UI/
  Prefabs/UI/
    Root/UIManager.prefab
    Screens/UIHome.prefab
    Screens/UIGameplay.prefab
    Popups/UIDailyReward.prefab
    Popups/UIDailyQuest.prefab
    Popups/UICollection.prefab
    Popups/UIShop.prefab
    Items/DailyRewardItem.prefab
    Items/QuestItem.prefab
    Items/CollectionItem.prefab
    Items/ShopOfferItem.prefab
  Scripts/
    UI/
      UIManager.cs
      Screens/UIHome.cs
      Screens/UIGameplay.cs
      Popups/UIDailyReward.cs
      Popups/UIDailyQuest.cs
      Popups/UICollection.cs
      Popups/UIShop.cs
      Items/DailyRewardItem.cs
      Items/QuestItem.cs
      Items/CollectionItem.cs
      Items/ShopOfferItem.cs
    Data/
      Definitions/DailyRewardDefinitionSO.cs
      Definitions/DailyQuestDefinitionSO.cs
      Definitions/ShopOfferDefinitionSO.cs
      Definitions/CollectionItemDefinitionSO.cs
      Runtime/DailyRewardState.cs
      Runtime/DailyQuestState.cs
      Runtime/InventoryState.cs
      ViewModels/DailyRewardViewData.cs
    Domain/
      Rewards/DailyRewardService.cs
      Quests/DailyQuestService.cs
      Shop/ShopService.cs
      Collection/CollectionService.cs
    Save/
      SaveOwner.cs
    Editors/
      CSVImportPostprocessor.cs
      DefinitionValidation.cs
  Data/
    DailyRewards/daily_reward.asset
    DailyQuests/daily_quest.asset
    Shop/offers.asset
    Collection/items/
  CSV/
    DailyRewards/daily_reward.csv
    DailyQuests/daily_quest.csv
    Shop/offers.csv
  Scenes/
```

Folder names are ownership signals, not cosmetic grouping. If the project
already uses `Assets/TheVayuputra/ArrowGame/Script/...`, `Assets/_Game/Resources`,
or another convention, preserve it and map the same responsibilities onto its
existing roots.

## Resources and loading

Use `Resources` only when the target project already loads definitions with
`Resources.Load` or serialized references cannot be used. If using it:

```text
Assets/_Game/Resources/Data/DailyRewards/daily_reward.asset
Resources.Load<DailyRewardDefinitionSO>("Data/DailyRewards/daily_reward")
```

Do not put runtime saves, generated JSON, or player-specific state under
`Assets/Resources`. Do not add Addressables or another loading framework for one
surface. If the project already uses Addressables, follow that owner instead.

## CSV importer contract

```text
CSV source
  -> editor-only parser/validator
  -> ScriptableObject asset
  -> runtime loader/state owner
  -> view model/UI
```

Importer rules:

```text
validate required headers and stable IDs
reject duplicate IDs
validate numeric ranges and equal-length multi-value cells
report row/column errors with the source path
write/update only authored definition assets
never run in player builds
```

Runtime must not parse CSV on every popup open. If an existing importer uses a
delimiter such as `Gold|Gem`, preserve compatibility and validate token counts;
new schemas should prefer explicit reward rows.

## Definition choices by feature

```text
Daily Reward: one cycle/catalog SO containing ordered day definitions;
              player claims live in DailyRewardState.
Daily Quest:  catalog SO for quest definitions;
              progress/claimed flags live in DailyQuestState.
Collection:   one SO per reusable item or one catalog SO when items are tiny;
              ownership/equipped/level live in InventoryState.
Shop:         catalog/offer SO for price, schedule, grants, limits;
              purchase count and wallet live in runtime state.
Level:        level definition SO/asset for board layout and objectives;
              current run/result lives in gameplay state.
```

Do not split one tiny immutable row into many nested assets unless designers
need independent reuse or the project already follows that pattern.

## UI binding ownership

```text
Definition SO -> domain/presenter reads authored values
Runtime state -> domain/save owner reads and mutates player values
View model -> popup/screen binds labels, icons, progress, states
Prefab -> serialized component references only
```

Example Daily Reward binding:

```text
DailyRewardDefinitionSO.days[i].rewards
  -> DailyRewardViewData.rewards
  -> UIDailyReward creates DailyRewardItem
  -> DailyRewardItem binds RewardRow views
```

The item receives `RewardViewData`; it does not look up the definition asset,
wallet, or save file by itself.

## Data request output

For any new data or folder request, AI must return this before editing:

```yaml
data_contract:
  feature: DailyReward
  existing_roots: []
  definition:
    type: ScriptableObject
    class_script: <real path>
    asset_instances: [<real paths>]
    mutable_fields_forbidden: [claimed, progress, balance]
  runtime_state:
    owner: <real save/state owner>
    type: <real class or fields>
    persistence: <real method/event>
  view_model:
    type: <real class or inline mapping>
    source: [definition, runtime_state]
  importer:
    source_csv: <real path or none>
    editor_script: <real path or none>
    validation: []
  folders:
    scripts: []
    prefabs: []
    data_assets: []
    resources: []
  bindings: []
  forbidden_changes: [runtime CSV parsing, player state in definition asset]
```

Acceptance: a reviewer can identify which file defines content, which owner
stores player state, which code mutates it, which asset is loaded, and which UI
field displays the resulting view data.
