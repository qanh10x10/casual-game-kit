# AI Surface Contract

Copy this block before implementing any puzzle-game UI.

```yaml
mode: Specify | Implement | Verify
surface: DailyReward
target_project: absolute Unity project path
unity_mcp: not-requested | requested
target_editor_pid: exact PID or unknown (only if Unity MCP was requested)
target_scene: Assets/_Game/Scenes/MainMenu.unity
target_prefab: Assets/_Game/Prefabs/UIMainMenu.prefab
user_job: "One sentence from player perspective"
primary_action: Claim reward
secondary_actions: [Close, Reset cycle]

evidence:
  source_files: []
  source_assets: []
  mcp_level: File | MCP | PlayMode | Device  # MCP/PlayMode only if requested and observed
  unknowns: []

states:
  - Loading
  - Empty
  - Locked
  - Available
  - Claimable
  - Claimed
  - Error

data:
  definition_owner: DailyRewardModel
  player_state_owner: UserDataModel
  view_model: DailyRewardViewData
  stable_ids: [cycleId, day, rewardId]
  persistence_owner: existing save owner
  clock_authority: LocalDevice | ServerUTC
  cycle_policy: Calendar | Consecutive
  missed_day_policy: Hold | AdvanceOne | CatchUp | Reset
  reset_time: "00:00 UTC"

actions:
  claim:
    preconditions: [definition exists, day available, key not claimed]
    transaction_owner: domain owner
    success_event: DailyRewardChanged
    failure_reasons: [AlreadyClaimed, Locked, InvalidReward, SaveFailed]

hierarchy:
  - SurfaceRoot
  - SafeArea/Header
  - SafeArea/Content/RewardItem
  - SafeArea/Footer
  - Overlay/Feedback

layout_contract:
  required: true | false
  reference_resolution: [1080, 1920]
  safe_area_owner: existing script/root or unknown
  anchors: []
  pivots: []
  layout_drivers: []
  scroll: { enabled: false, axis: None, viewport: none, content: none }
  device_checks: [narrow portrait, tall portrait, long text, empty state]

bindings:
  - path: Content/RewardItem/DayText
    source: view.dayLabel
  - path: Content/RewardItem/ClaimButton
    source: view.canClaim

ownership:
  controller: UIDailyReward
  item_view: ItemDailyReward
  domain_owner: GameManager or focused existing owner
  forbidden: [UI mutates PlayerPrefs, UI grants rewards, new framework]

ranges:
  minimum_items: 1
  typical_items: 7
  maximum_items: 31
  overflow_behavior: Scroll

validation:
  file: [binding paths exist, IDs stable, no missing references]
  mcp: [target hierarchy matches contract]
  play_mode: [claim once, relaunch, reset boundary]
  not_run: []
```

## Acceptance sentence

“When the player opens `<surface>`, state `<state>` renders from `<source>`; action `<action>` succeeds only under `<preconditions>`, persists through `<owner>`, emits `<event>`, and remains correct after `<reload>`.”
