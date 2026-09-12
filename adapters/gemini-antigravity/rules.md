# Antigravity Rules - Puzzle Game UI

Apply when modifying or reviewing Unity UI code (`Assets/**/*.cs`) or prefabs (`Assets/**/*.prefab`):
- Produce a Surface Contract first.
- Strict separation of authoring definitions vs player state.
- Idempotent reward transactions with explicit event emissions.
- Semantic hierarchy: Screen -> SafeArea -> Header/Content/Footer/Overlay.
- Full reference blueprints available in skill `puzzle-game-ui`.
