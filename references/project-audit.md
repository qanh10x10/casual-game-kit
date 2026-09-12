# Project Audit: TowerDefense

## Verified facts

| Area | Evidence | Contract implication |
|---|---|---|
| Scenes | `Assets/_Game/Scenes/MainMenu.unity`, `MainGame.unity`, `Loading.unity`, `Tutorial.unity`, `Arena.unity` | Keep scene ownership explicit; surface route names remain stable. |
| Home prefab | `Assets/_Game/Prefabs/UIMainMenu.prefab` | Existing roots: `Bottom`, `UIBattle`, `BG`, `SafeArea/Top`, `PopUps`, `UIDeck`. |
| Gameplay prefab | `Assets/_Game/Prefabs/UIMainGame.prefab` | Existing roots: `HUDMainGame`, `HUDSelectBuff`, `HUDWin`, `HUDLose`, `HUDSetting`. |
| Home controller | `Assets/_Game/Scripts/UI/MainMenu/UIMainMenu.cs:12-71` | Singleton router binds buttons and popup references. Reuse before replacing. |
| Gameplay router | `Assets/_Game/Scripts/UI/UIMainGame.cs:6-51` | One controller toggles gameplay panels. New puzzle surfaces should follow same ownership. |
| Daily reward | `Assets/_Game/Scripts/UI/MainMenu/PopUps/UIDailyReward/UIDailyReward.cs:5-48` | List item binding currently indexes `UserDataModel.dailyRewardInfo`. Contract must define list length and fallback. |
| Daily reward item | `Assets/_Game/Scripts/UI/MainMenu/PopUps/UIDailyReward/ItemDailyReward.cs:33-160` | Claim applies rewards and emits `Module.Action_Event_DailyRewardChanged()`. Preserve idempotency boundary. |
| Daily quest | `Assets/_Game/Scripts/UI/MainMenu/PopUps/UIDailyQuest/UIDailyQuest.cs:9-57` | Quest visual sorting depends on state priority; state must be explicit. |
| Shared state | `Assets/_Game/Scripts/ScriptableObjects/UserDataModel.cs:44-165` | Definition assets are copied into player state, then serialized. Do not bind UI to authoring asset mutation. |
| Currency/events | `Assets/_Game/Scripts/Managers/Module.cs:207-243`, `417-481` | Existing currency setters emit refresh events. Use IDs/events, not polling every frame. |
| Daily lifecycle | `Assets/_Game/Scripts/Managers/GameManager.cs:214-349` | Daily reset uses `PlayerPrefs` date keys and progress mutation. New surfaces need reset semantics in contract. |
| CSV import | `Assets/_Game/Scripts/Editors/CSVImportPostprocessor.cs:10-323` | CSV rows import into ScriptableObjects. Keep authoring schema separate from runtime state. |
| Puzzle runtime | `Assets/_Game/Scripts/GamePlay/GameplayCtrl.cs`, `GamePlay/Board/GridManager.cs`, `GamePlay/SlotGrid.cs` | Board interaction and UI should communicate through a small result/event contract, not inspect board internals. |

## Compatibility notes

- Current `GameManager.RefreshDayIfPastMidnight()` advances `CurrentDay` by one and clamps at `totalDays`; `ResetDay()` regenerates reward rows; `NextDay()` increments directly. These are existing behaviors, not the plugin's universal calendar policy.
- Current daily reward CSV uses delimiter cells such as `Gold|Gem` and `500|120`. Preserve only when compatibility requires it; new contracts should validate equal lengths or use explicit reward rows.
- Current `UIDailyReward` binds item views by list index. A generalized skill must bind by stable `day`/`rewardId` and report count mismatches before rendering.
- Current quest progress saves on each changed event. The plugin may retain this for tiny offline games, but should state the write frequency and upgrade path if throughput matters.

## Gaps to mark, not hide

- No shop controller/data model is present in audited `_Game` paths; specify it as a new surface, not as an existing feature.
- Unity MCP relay is configured in Codex, but TowerDefense lacks `com.unity.ai.assistant` in its manifest/cache and target discovery returned zero Unity tools. File evidence is valid; MCP hierarchy/Play Mode evidence remains unverified.
- Existing `DataManager` is empty; do not assume it is the persistence owner.
