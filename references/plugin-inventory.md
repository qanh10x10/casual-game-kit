# Unity Plugin Inventory

Use this reference before adding UI infrastructure or declaring a project
non-compliant because its hierarchy differs from the examples.

## Inventory contract

For each relevant concern, record:

```yaml
plugins:
  - concern: SafeArea | PopupTween | Localization | Pooling | MaskingParticles | AdsIAP | SaveState
    package_or_source: <manifest entry or source root>
    component_type: <namespace.type or none>
    script_guid: <guid or none>
    live_owner: <scene/prefab hierarchy path>
    serialized_settings: {}
    status: Active | InstalledNotWired | Legacy | Unknown
    evidence: []
```

Inspect package manifests, vendor source, `.meta` GUIDs, prefab/scene YAML, scene
instance overrides, and first-party callers. A folder, package, or DLL proves only
installation; `Active` requires a live serialized component or runtime caller.

## Reuse rules

- Keep one owner per concern. Extend or configure it before adding another system.
- Preserve vendor component GUIDs and serialized settings during hierarchy changes.
- Do not hand-edit vendor/package source for a project-specific UI requirement.
- Do not replace a working plugin merely to match an example class or object name.
- Wrap a plugin only when first-party code needs a stable project boundary; keep the
  wrapper thin and do not duplicate the plugin algorithm.
- Record unsupported states and platform symbols. Ads/IAP packages require runtime
  provider, receipt, cancel, unavailable, and error evidence; package presence is
  not release proof.

## Concern checks

### Safe area / notch

Resolve the live component and axis policy. If `Crystal.SafeArea` or an equivalent
component is serialized on the gameplay/inset root, it owns `Screen.safeArea`.
A null legacy field elsewhere does not justify adding custom safe-area code.

### Popup / tween

Reuse the current popup lifecycle and tween library. Verify input blockers,
CanvasGroup/raycast behavior, teardown, and repeated-open idempotency before adding
another modal/router abstraction.

### Localization

Reuse the installed localization provider and stable keys. If no provider is wired,
report the gap; do not introduce a package for one label.

### Pooling

Reuse existing pooling for repeated runtime objects. UI lists may use bounded
instantiate/destroy or local reuse when the list is small; do not add a global pool
without measured need.

### Masking / particles

Preserve existing masking and particle plugins when they satisfy the visual need.
Verify material/stencil behavior in the live Canvas and avoid duplicate components
that fight the same mesh or render state.

### Ads / IAP

Separate SDK installation from an active production provider. Verify compilation
symbols, platform configuration, callbacks, receipts, cancellation, failure, and
idempotent domain transactions. UI never grants products directly from a button.

### Save / state

Reuse the existing save/state owner. UI sends intents and renders snapshots; it does
not introduce its own PlayerPrefs keys or a second persistence abstraction.

## Verification

A plugin decision is complete when every named concern is `Active`,
`InstalledNotWired`, `Legacy`, `Unknown`, or explicitly `NotNeeded`, with file or
serialized evidence and no duplicate owner introduced.
