# Validation Gates

## Before editing

- `git status --short` captured; unrelated changes preserved.
- Exact target project, scene, prefab, script, and editor PID identified.
- Contract lists states, bindings, owner, persistence, and forbidden scope.

## File gate

- All serialized paths and IDs exist.
- No new package or framework without explicit approval.
- Definition/state/view separation is visible in code or documented as an existing exception.
- Reward/shop transactions validate before mutation and persist once after success.
- Event subscriptions are paired with unsubscriptions.

## Unity MCP gate

- MCP response identifies target project/editor, not merely any Unity process.
- Hierarchy read matches contract.
- Prefab asset and scene instance checked separately.
- Console read after observation shows whether diagnostics are clean, blocked, or unrelated.

## Play Mode gate

For Daily Reward: open, locked future day, claim current day once, repeat claim, reload, date rollover. For Quest: progress, cap, claim, reset. For Collection: locked/owned/equipped/upgradeable. For Shop: available, insufficient currency, limit, sold out, offline/failure. For Gameplay: input, objective update, pause, win, lose, return.

## Report format

```text
Validation: PASS | PARTIAL | BLOCKED
Commands/tools: <exact commands or MCP calls>
Evidence: File/MCP/PlayMode/Device
Failures: <exact short error>
Skipped: <not-run checks>
Remaining risks: <only evidence-backed items>
```
