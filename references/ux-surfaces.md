# UX Surface Recipes

## Home

Job: choose the next activity quickly. Header shows currency and player progress. Main area presents one primary play action. Secondary entries expose Daily Reward, Daily Quest, Collection, and Shop with notification only when an actionable state exists. Bottom navigation changes route; it does not duplicate domain actions.

States: first run, normal, actionable notification, locked feature, offline, update required. Empty Shop/Collection uses a next action, not a blank panel.

## Gameplay UI

Job: understand board state and make the next move. Keep board unobstructed. HUD shows objective, remaining moves/energy, score/combo, pause. Feedback sequence: input accepted → board resolves → objective updates → reward/result. Win/lose overlay owns next action and return path. Do not place economy popups over a critical puzzle decision.

Puzzle variants map to same contract: match-3 uses selected cells and cascades; merge uses source/target and merge result; sort/packing uses slot validity and completion; word/logic uses attempt, hint, and solve result.

## Daily Reward

Job: recognize today’s reward and claim once. Show current day as focal item, past days as claimed, future days as locked. Multi-rewards render one row per reward entry. Reset/skip is secondary and must state its consequence. After success, show reward feedback and update the notification dot.

## Daily Quest

Job: know what to do next. Sort claimable first, active second, completed/claimed last. Progress uses text plus bar/icon; color alone is insufficient. “Go” action deep-links to the relevant surface only when target is known.

## Collection / Deck

Job: inspect, compare, equip, upgrade. Use filter/sort only when item count requires it. Card states: locked, owned, selected, equipped, upgradeable. Detail panel owns one primary action. Keep roster and detail selection stable after refresh.

## Shop

Job: compare offer value and complete a purchase safely. Card shows item, quantity, price currency, remaining limit, schedule, and owned result. One primary purchase action. Confirmation is required when price is premium currency or bundle contains multiple grants. Show sold out, insufficient funds, offline, and purchase failure explicitly.

## Motion and accessibility

Use existing DOTween/VFX conventions only for state feedback: claim burst, count-up, panel enter/exit, selected card. Stop or reduce motion when user setting requests it. Preserve large hit areas, readable TMP text, focus/keyboard path where platform requires it, contrast, and non-color state cues.
