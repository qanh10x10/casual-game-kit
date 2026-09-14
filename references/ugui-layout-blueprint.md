# Unity UGUI Layout Blueprint

Use this reference for Canvas, anchors, safe area, `ScrollRect`,
`ContentSizeFitter`, `VerticalLayoutGroup`, `HorizontalLayoutGroup`,
`GridLayoutGroup`, `LayoutElement`, and mobile puzzle UI composition.

The numeric recipes assume a portrait reference canvas of **1080 x 1920**.
Preserve the target project's existing CanvasScaler and safe-area behavior when
they differ. Reference units are not guaranteed physical pixels on every device;
verify on representative portrait aspect ratios.

## Layout decision gate

Before adding a layout component:

```text
1. Identify the content axis: vertical, horizontal, grid, or fixed overlay.
2. Decide which object owns size on each axis: parent, layout group, or content.
3. Give each axis one size driver.
4. Choose anchors from the object's relationship to its parent, not its current
   screenshot position.
5. Add a ScrollRect only when content can exceed the visible viewport.
```

Do not combine manual `anchoredPosition` updates, a layout group, and a
`ContentSizeFitter` to control the same axis. That creates competing layout
drivers and unstable sizes.

## 1080 x 1920 Canvas setup

### Canvas

```text
Canvas
  Render Mode: Screen Space - Overlay (unless project evidence requires Camera)
  CanvasScaler
    UI Scale Mode: Scale With Screen Size
    Reference Resolution: 1080 x 1920
    Screen Match Mode: Match Width Or Height
    Match: preserve target project value; choose 0.5 when no existing policy
  GraphicRaycaster
```

For a portrait-first puzzle game, width priority (`Match = 0`) keeps horizontal
gutter/card width stable but can make tall content tighter. A middle match
(`0.5`) balances width and height. Do not change an existing value merely to
follow this default; record the reason in the surface contract.

### Full-screen roots

For `UIManager`, `ScreenLayer`, `PopupLayer`, `FeedbackLayer`, and blockers:

```text
RectTransform
  Anchor Min: (0, 0)
  Anchor Max: (1, 1)
  Left/Right/Top/Bottom: 0
  Pivot: (0.5, 0.5)
  Scale: (1, 1, 1)
```

Never use a fixed `1080 x 1920` size on a full-screen child whose parent already
stretches to the Canvas. Fixed reference dimensions belong on the CanvasScaler,
not on every descendant.

### Safe area

```text
Canvas
  SafeArea (full-screen RectTransform, runtime inset owner)
    ScreenLayer
    PopupLayer
    FeedbackLayer
```

The safe-area script owns inset calculation. Children anchor to `SafeArea` and
use normal layout; they must not each subtract notch/status-bar offsets.

If no safe-area component exists, document that as an unverified device risk.
Do not invent device-specific top padding from a screenshot.

## Anchor and pivot recipes

| UI role | Anchor Min | Anchor Max | Pivot | Size control |
|---|---:|---:|---:|---|
| Full-screen layer | `(0,0)` | `(1,1)` | `(0.5,0.5)` | offsets 0 |
| Top bar | `(0,1)` | `(1,1)` | `(0.5,1)` | height via `sizeDelta.y` |
| Bottom navigation | `(0,0)` | `(1,0)` | `(0.5,0)` | height via `sizeDelta.y` |
| Left rail/button | `(0,0.5)` | `(0,0.5)` | `(0,0.5)` | fixed width/height |
| Right rail/button | `(1,0.5)` | `(1,0.5)` | `(1,0.5)` | fixed width/height |
| Center modal | `(0.5,0.5)` | `(0.5,0.5)` | `(0.5,0.5)` | fixed or constrained size |
| Full-width section | `(0,0)` | `(1,0)` | `(0.5,0)` | height via layout/size |
| Vertical content | `(0,1)` | `(1,1)` | `(0.5,1)` | height grows downward |
| Horizontal content | `(0,0)` | `(0,1)` | `(0,0.5)` | width grows rightward |

Rules:

```text
Stretch when the object follows parent edges.
Fixed center when the object stays a stable size around the center.
Edge anchor when the object stays attached to one edge.
Layout-group child: let the group position it; do not hand-place children.
```

Pivot indicates the growth origin. Vertical lists use a top pivot so added rows
grow down. Horizontal lists use a left pivot so added cards grow right.

## Spacing and sizing tokens

Start with an 8-unit rhythm in reference units:

```text
4   optical correction only
8   tight icon/label gap
16  row gap / compact padding
24  card gap / section gap
32  standard inner padding
48  screen gutter / major section gap
64  large separation
88  default mobile primary hit-area starting point
```

For a 1080-wide screen:

```text
Page gutter: 48 left + 48 right = 984 usable width
Three-column grid, 24 gaps: (984 - 48) / 3 = 312 cell width
Two-column grid, 24 gap:    (984 - 24) / 2 = 480 cell width
```

Treat these as starting tokens. Preserve existing art-safe margins and validate
long localization, banners, and device safe areas before locking values.

## 1080 x 1920 reference zones

Apply these inside `SafeArea`, so device insets remain the safe-area owner's
responsibility:

```text
Home
  Header: top stretch, height 160, left/right 48
  Main: stretch, left/right 48, top 184, bottom 208
  Footer: bottom stretch, height 176, left/right 48

Gameplay
  HUDTop: top stretch, height 168, left/right 48
  BoardRegion: stretch, left/right 32, top 184, bottom 208
  BoosterBar: bottom stretch, height 176, left/right 48

Popup
  Blocker: full stretch, offsets 0
  Panel: full stretch, left/right 84, top/bottom 220
```

These are composition defaults, not absolute coordinates. Header/footer own
their edge; the middle region stretches between them. Increase a zone only when
real content, localization, or art requires it. Do not move every child to
compensate for one oversized section.

## Standard screen composition

Use anchors and layout relationships first. Example Home:

```text
UIHome
  SafeArea (stretch)
    Header (top stretch, fixed height)
      CurrencyBar (horizontal layout)
      SettingsButton (right edge anchor)
    Main (stretch between header/footer)
      Campaign/level summary (center or vertical layout)
      PrimaryPlayButton (centered, one dominant action)
      ActivityEntryRow (horizontal layout: DailyReward, DailyQuest, Shop)
    Footer (bottom stretch, fixed height)
      BottomNavigation (horizontal layout)
```

Example Gameplay:

```text
UIGameplay
  SafeArea (stretch)
    HUDTop (top stretch)
      Objective (left)
      Moves/Energy (center or left group)
      Pause (right)
    BoardRegion (stretch; board remains unobstructed)
    BoosterBar (bottom stretch or bottom edge anchor)
    ResultOverlay (full-screen overlay, inactive until result)
```

Example popup:

```text
PopupRoot (center or safe-area constrained)
  Header (fixed height)
  Body (stretch)
    ScrollViewport
      ScrollContent
  Footer (fixed height)
    PrimaryAction / Close
```

Reading order: title/context -> primary content -> primary action -> secondary
close/help. Keep currency and status visible only when they support the current
decision; do not stack unrelated panels inside a popup.

## ScrollRect anatomy

Use the native UGUI hierarchy:

```text
ScrollRegion (RectTransform + ScrollRect)
  Viewport (RectTransform + RectMask2D)
    Content (RectTransform + LayoutGroup + ContentSizeFitter on growth axis)
      ItemPrefab instances
```

Configure `ScrollRegion`:

```text
Viewport: Viewport
Content: Content
Horizontal: only for a horizontal list
Vertical: only for a vertical list
Movement Type: preserve project convention; Elastic is normal for casual lists
Scroll Sensitivity: tune on device, not from one editor mouse wheel
```

Do not put `ContentSizeFitter` on `ScrollRegion` or `Viewport` to make content
scroll. The content object owns the overflowing dimension.

### Create a Scroll View in the Unity Editor

```text
1. Under the intended Body/Main region, create UI > Scroll View.
2. Rename the root, Viewport, and Content by role when multiple lists exist.
3. Stretch the root to the available region; keep Viewport stretched to root.
4. Keep RectMask2D on Viewport. Remove only unused visual scrollbars, not the
   Viewport or mask.
5. On ScrollRect, assign Viewport and Content, then enable one scroll axis.
6. Set Content anchors/pivot for the growth axis.
7. Add one matching layout group and one-axis ContentSizeFitter to Content.
8. Add LayoutElement to item roots only when the layout needs an explicit item
   size.
9. Bind or instantiate items under Content. Never under Viewport beside Content.
10. Verify empty, one-item, overflow, long-text, and reopen states.
```

Scrollbar objects are optional on touch-first puzzle screens. If retained,
assign them to `ScrollRect`, anchor them to the matching viewport edge, and do
not let them reduce the content area accidentally. Hidden scrollbars do not fix
missing scroll affordance; clipped cards or a partial next item should still
signal that more content exists.

### Vertical ScrollRect recipe

```text
ScrollRegion
  Anchor Min: (0,0), Anchor Max: (1,1)
  offsets: match the available body region

Viewport
  Anchor Min: (0,0), Anchor Max: (1,1)
  offsets: 0
  RectMask2D: enabled

Content
  Anchor Min: (0,1), Anchor Max: (1,1)
  Pivot: (0.5,1)
  Anchored Position: (0,0)
  Size Delta: (0,0)
  VerticalLayoutGroup
    Child Alignment: Upper Center
    Padding: 0 or explicit 16/24/32/48 tokens
    Spacing: 16 or 24 starting token
    Control Child Size: Width ON, Height ON
    Force Expand: Width OFF, Height OFF
  ContentSizeFitter
    Horizontal Fit: Unconstrained
    Vertical Fit: Preferred Size
```

Use `LayoutElement.preferredHeight` on fixed-height rows. For variable-height
rows, let the row's internal layout calculate its preferred height, then let the
content fitter sum the rows.

### Horizontal ScrollRect recipe

```text
ScrollRegion and Viewport: stretch to body region

Content
  Anchor Min: (0,0), Anchor Max: (0,1)
  Pivot: (0,0.5)
  Anchored Position: (0,0)
  Size Delta: (0,0)
  HorizontalLayoutGroup
    Child Alignment: Middle Left
    Padding: 0 or 16/24/32/48 tokens
    Spacing: 16 or 24 starting token
    Control Child Size: Width ON, Height ON
    Force Expand: Width OFF, Height OFF
  ContentSizeFitter
    Horizontal Fit: Preferred Size
    Vertical Fit: Unconstrained
```

Use horizontal scrolling for cards, tabs, or compact choices. Do not use it for
a primary action row that fits on the screen; hidden actions hurt discoverability.

### Grid ScrollRect recipe

```text
Content
  Anchor Min: (0,1), Anchor Max: (1,1)
  Pivot: (0.5,1)
  GridLayoutGroup
    Constraint: Fixed Column Count
    Constraint Count: 2 or 3 from available width
    Cell Size: calculated from usable width
    Spacing: 24 starting token
    Padding: 0 or explicit page tokens
  ContentSizeFitter
    Horizontal Fit: Unconstrained
    Vertical Fit: Preferred Size
```

Set item width from the grid, not from each item's manual `RectTransform` width.
Use `LayoutElement` for variable row height only when the grid pattern supports
it; otherwise keep grid cells uniform.

## ContentSizeFitter rules

`ContentSizeFitter` asks a `RectTransform` to size itself from its layout
preferred/minimum size.

```text
Vertical list content: Vertical = Preferred Size
Horizontal list content: Horizontal = Preferred Size
Fixed overlay/panel: usually Unconstrained; size from anchors or LayoutElement
```

Avoid these combinations:

```text
ContentSizeFitter + manual size writes every frame
ContentSizeFitter + parent layout group controlling the same axis
ContentSizeFitter on both viewport and content for one scroll axis
AspectRatioFitter + ContentSizeFitter controlling the same axis
```

After dynamic binding, allow Unity's layout pass to settle before reading
`rect.height`/`rect.width`. If a script must force one rebuild, call
`LayoutRebuilder.ForceRebuildLayoutImmediate` on the smallest affected content
root after all children are bound; never call it every frame.

## VerticalLayoutGroup settings

Use it when siblings form a vertical reading sequence:

```text
Content/Section
  VerticalLayoutGroup
    Child Alignment: Upper Center or Upper Left
    Spacing: 16/24/32
    Padding: 16/24/32/48
    Control Child Size: Width ON, Height ON
    Child Force Expand: Width OFF, Height OFF
```

Set `Child Force Expand Height = ON` only when rows intentionally fill equal
available space, such as a two-button footer. For content lists, it usually
must be OFF or empty rows stretch unexpectedly.

## HorizontalLayoutGroup settings

Use it for sibling actions, currency chips, tabs, or card rails:

```text
Row
  HorizontalLayoutGroup
    Child Alignment: Middle Center / Middle Left
    Spacing: 16/24
    Padding: 16/24/32
    Control Child Size: Width ON, Height ON
    Child Force Expand: Width OFF, Height OFF
```

For equal-width buttons, use `Child Force Expand Width = ON` only when every
button is allowed to share the row. For icon + label rows, keep it OFF and give
the label a `LayoutElement.flexibleWidth = 1` when it should absorb remaining
space.

## LayoutElement

Use `LayoutElement` to declare a child's preferred size to its parent layout:

```text
Minimum: hard lower bound only when content must not collapse
Preferred: intended size for the normal state
Flexible: absorbs remaining space; use 1 sparingly
Ignore Layout: only for decorative/overlay children
```

Common recipes:

```text
Fixed reward row: preferredHeight = 112
Primary footer button: flexibleWidth = 1
Icon: preferredWidth = preferredHeight = 72 or 88
Spacer: flexibleHeight = 1 (only when deliberate)
```

Do not set every min/preferred/flexible field "just in case". One clear size
contract per child is easier to debug.

## Item prefab internals

```text
DailyRewardItem (LayoutElement preferredHeight = 112)
  Icon (fixed 72/88)
  Body (Horizontal or Vertical layout)
    Title
    RewardRows (VerticalLayoutGroup)
  StateMarkers (overlay, Ignore Layout)
  ClaimButton (fixed hit area, owner callback)
```

For a variable text item:

```text
ItemRoot
  VerticalLayoutGroup (control child width/height)
  ContentSizeFitter (vertical preferred only)
    Title (TMP, wrapping enabled)
    Description (TMP, wrapping enabled)
```

The item root reports a preferred height to the list. Do not hard-code a single
height if localization or multi-reward rows can increase it.

## Popup sizing recipe at 1080 x 1920

Use a safe-area-constrained panel, not a full-screen opaque panel by default:

```text
PopupPanel
  Anchor Min: (0,0)
  Anchor Max: (1,1)
  Left: 84, Right: -84
  Bottom: 220, Top: -220
  Pivot: (0.5,0.5)
  VerticalLayoutGroup
    Padding: 32/48
    Child Control Width: ON
    Child Control Height: ON
    Child Force Expand Height: OFF
```

Inside:

```text
Header: LayoutElement preferredHeight = 144-176
Body: flexibleHeight = 1
Footer: LayoutElement preferredHeight = 128-160
```

If body content can exceed the panel, make only `Body/ScrollRegion` scroll. Do
not make the title/footer part of the list. Keep one primary footer action and a
secondary close/cancel action.

## UI script and layout timing

```text
Open popup
  -> activate root
  -> bind snapshot
  -> create/reuse item views
  -> set layout data
  -> rebuild content once if measurement is needed
  -> set ScrollRect normalized position
```

The script owns data binding and item lifecycle. Layout components own geometry.
Do not calculate each child `anchoredPosition` in the controller when a layout
group expresses the relationship.

When reopening a list:

```text
clear or reuse old item views
remove stale button listeners
bind current IDs
reset scroll position only when UX requires it
```

## UX placement rules

```text
Top: status, context, currency, pause/settings.
Center: current puzzle/decision, not decorative noise.
Bottom: frequent navigation, boosters, or primary continuation action.
Modal footer: primary action first in reading/focus order; close/cancel secondary.
```

For gameplay, keep the board's interaction area free from popup cards and
nonessential badges. For Home, one play CTA must outrank Daily Reward, Quest,
Collection, and Shop. Notification dots indicate actionable state, not merely
available content.

## Common failure diagnosis

```text
Content does not scroll
  -> content preferred size is not larger than viewport
  -> wrong growth-axis fitter
  -> items have zero preferred/minimum size

Rows overlap or jump
  -> two components control the same axis
  -> manual anchoredPosition fights a layout group
  -> stale listeners/items survive refresh

Content width is too wide
  -> vertical content is not stretched to viewport width
  -> child force-expand/control width mismatch
  -> horizontal fitter enabled accidentally

Footer disappears on tall/short phones
  -> fixed screen coordinates used instead of edge anchors
  -> safe-area root not applied
  -> CanvasScaler policy changed without evidence

Text clips
  -> fixed height used for localized/variable text
  -> TMP wrapping/overflow not configured
  -> parent layout never receives preferred height
```

## Popup Card Composition Architecture (`ScreenContent`)

### Overlay Backdrop vs Interactive Card

Standardize popup hierarchy to separate background dimming from animated dialog cards:

```text
PopupRoot (Full-screen stretch: 0,0 to 1,1)
  Image (Black tint with alpha 0.7 - 0.85, Raycast Target ON)
  ScreenContent (Interactive Card, Centered: Anchor 0.5, 0.5, Pivot 0.5, 0.5)
    Header / Title (TMP)
    Body / ContentArea
    ActionButtons (Continue / AdReward)
    CloseButton (top-right or footer)
```

Animation rule:
- Open/Close tweens (scale 0 $\to$ 1, bounce) MUST target only `ScreenContent`.
- The `PopupRoot` backdrop remains static to avoid screen flicker or jarring background jumps.

### Duplicate GameObject Anti-Pattern

A common failure in prefab merging and UI editing:
- Multiple identical GameObjects (e.g. 3 `PetRescueGauge` instances) accidentally created under `ScreenContent`.
- In UGUI, later siblings render **on top** of earlier siblings.
- Scripts using `transform.Find("PetRescueGauge")` locate the *first* child (sibling index 2). The script animates sibling 2 correctly, but siblings 3 and 4 render over it with empty/static values, making features appear completely broken.
- **Rule:** Before finalizing prefab edits, inspect sibling counts and verify child uniqueness under `ScreenContent`.

## Level Progression Tree (Vertical ScrollView with Node Overlays)

### Hierarchy Shape

```text
UIHome/Scroll View/Viewport/Content
  Level1 (RectTransform, Button, Image)
    LevelLabel (TextMeshProUGUI)
    LevelPath (Image connector to Level2)
    Chain (Image, pet_chain lock overlay)
  Level2 ...
  LevelN
```

### Dynamic Node State Contract

When refreshing the level tree from `GameData.CurrentLevel`:

```csharp
int level = index + 1;
bool current = level == GameData.CurrentLevel;
bool passed = level < GameData.CurrentLevel;
bool future = level > GameData.CurrentLevel;

// 1. Button interactability
ui.levelButtons[index].interactable = !future;

// 2. Badge visuals & scale
ui.levelImages[index].sprite = current ? ui.currentLevelSprite
    : (passed ? ui.hardLevelSprite : ui.normalLevelSprite);
ui.levelImages[index].rectTransform.sizeDelta = current
    ? new Vector2(274f, 260f) : new Vector2(220f, 184f);

// 3. Status Overlays (Chain)
Transform chain = item.Find("Chain");
if (chain != null)
{
    chain.gameObject.SetActive(future);
}

// 4. Progress connectors
if (ui.levelPaths != null && index < ui.levelPaths.Length && ui.levelPaths[index] != null)
{
    bool isTop = (index == totalLevels - 1);
    ui.levelPaths[index].gameObject.SetActive(!isTop);
    if (!isTop) ui.levelPaths[index].sprite = passed ? ui.reachedPathSprite : ui.lockedPathSprite;
}
```


## Required AI output for layout work

```yaml
layout_contract:
  reference_resolution: [1080, 1920]
  canvas_scaler:
    ui_scale_mode: ScaleWithScreenSize
    match_policy: <existing value or reasoned default>
  safe_area:
    owner: <real script/root>
    verified: true | false
  surface: <Home | Gameplay | popup>
  hierarchy: []
  anchors: []
  layout_drivers:
    - object: <path>
      axis: Vertical
      owner: VerticalLayoutGroup + ContentSizeFitter
  scroll:
    enabled: true | false
    axis: Vertical | Horizontal | Both
    viewport: <path or none>
    content: <path or none>
  component_settings: []
  spacing_tokens: [16, 24, 32, 48]
  overflow_behavior: Scroll | Wrap | Collapse | Reject
  device_checks: [narrow portrait, tall portrait, long text, empty state]
  forbidden: [competing axis drivers, per-frame rebuild, manual child positioning]
```

Acceptance: every dynamic dimension has one owner, every scroll axis has a
viewport/content pair, every edge-attached element uses edge anchors, and the
layout remains usable at narrow/tall portrait sizes and with long content.
