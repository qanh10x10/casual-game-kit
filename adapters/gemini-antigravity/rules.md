# Antigravity Rules - Puzzle Game UI

Apply when modifying or reviewing Unity UI code (`Assets/**/*.cs`) or prefabs (`Assets/**/*.prefab`):
- Produce a Surface Contract first.
- Strict separation of authoring definitions vs player state.
- Idempotent reward transactions with explicit event emissions.
- Semantic hierarchy: Screen -> SafeArea -> Header/Content/Footer/Overlay.
- Follow `ui-code-layout.md` for Home `UIManager` vs gameplay `UiManager`.
- Do not call Unity MCP unless the current request explicitly asks for it.
- Full reference blueprints available in skill `casual-game-kit`.
