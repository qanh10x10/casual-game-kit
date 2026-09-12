# Unity MCP Workflow

## Target gate

Before calling Unity MCP, identify exact project path and editor PID. Multiple Unity editors may be open. Process presence alone is not target proof.

Expected read-only sequence:

1. `Unity_ManageEditor`/state discovery for target project.
2. `Unity_ListResources` for scenes, prefabs, scripts, and assets.
3. `Unity_ReadResource` for target prefab/scene/script.
4. `Unity_ManageScene` only for explicit scene observation or opening requested by the contract.
5. `Unity_ManageGameObject` for hierarchy inspection.
6. `Unity_ReadConsole` for diagnostics after any observation.

## Safe mutation gate

Mutation requires an approved surface contract and exact asset paths. Before mutation capture prefab/scene identity, GUID-sensitive references, and current console state. After mutation run `Unity_ValidateScript` or the narrowest available validation, then inspect the target scene instance separately from the prefab asset.

## Evidence levels

- `File`: source file or serialized asset inspected.
- `MCP`: Unity target returned the requested resource/hierarchy.
- `PlayMode`: target scene entered Play Mode and behavior observed.
- `Device`: device/simulator behavior observed.

Never promote `File` to `PlayMode`. If MCP discovery returns zero Unity tools or `Unity not available`, report `MCP blocked`; continue only with file evidence for specification work.

## Current project note

TowerDefense's manifest and package cache do not contain `com.unity.ai.assistant`. The project-bound relay attempt returned zero tools and repeated named-pipe disconnects. The MCP bridge evidence in the shared editor log belongs to another open project, ArrowRush-PetRescue. Treat TowerDefense hierarchy and runtime behavior as file-only evidence until the Unity AI MCP package/connector is explicitly installed and healthy in this target project.
