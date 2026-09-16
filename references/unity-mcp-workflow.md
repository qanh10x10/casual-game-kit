# Unity MCP Workflow (opt-in)

**Default: do not use Unity MCP.** File reads of `.cs`, `.prefab`, `.unity`, `.asset`, and `.meta` are enough for audit, specify, and most implement work.

Call Unity MCP only when the **current user request** explicitly asks for it, for example: inspect live hierarchy, enter Play Mode, read Console, mutate a prefab/scene through the Editor, or “use Unity MCP”. A connected editor, installed MCP server, or prior session that used MCP is not permission. If MCP is not requested, skip this file.

When requested, identify exact project path and editor PID first. Multiple Unity editors may be open. Process presence alone is not target proof.

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

Never promote `File` to `PlayMode`. If the user asked for MCP and discovery returns zero Unity tools or `Unity not available`, report `MCP blocked` and continue with file evidence. Do not retry MCP on a different open project.

After a user-requested C# edit, file diff / source build is enough unless they also asked to reimport and check the Unity Console.

## Current project note

TowerDefense's manifest and package cache do not contain `com.unity.ai.assistant`. The project-bound relay attempt returned zero tools and repeated named-pipe disconnects. The MCP bridge evidence in the shared editor log belongs to another open project, ArrowRush-PetRescue. Treat TowerDefense hierarchy and runtime behavior as file-only evidence until the Unity AI MCP package/connector is explicitly installed and healthy in this target project.

## Advanced Unity MCP Patterns & Production Playbook

### 1. Hierarchy Inspection & Duplicate Detection

When visual elements appear unresponsive or frozen:
- Call `Unity_ManageGameObject` with `action: "find"`, `find_all: true`, `search_inactive: true`.
- If multiple instances exist with identical names under the same parent (e.g., 3 `PetRescueGauge` instances under `ScreenContent`), examine their child hierarchy and components.
- Often the topmost sibling in hierarchy is a broken or unlinked clone that obscures the working one underneath.

### 2. Batch Prefab & Scene Repairs via Editor Scripts (`[MenuItem]`)

When direct scene manipulation via MCP is constrained or requires atomic prefab modifications:
1. Create a focused utility script in `Assets/Editor/` (or extend an existing menu utility):
   ```csharp
   [MenuItem("ArrowEscape/Clean Duplicates")]
   public static void CleanDuplicates()
   {
       string path = "Assets/Prefabs/TargetPrefab.prefab";
       GameObject root = PrefabUtility.LoadPrefabContents(path);
       try
       {
           // Inspect children, destroy duplicates with Object.DestroyImmediate
           PrefabUtility.SaveAsPrefabAsset(root, path);
       }
       finally
       {
           PrefabUtility.UnloadPrefabContents(root);
       }
       // Also sanitize active scene instance and call EditorSceneManager.SaveScene
   }
   ```
2. Reimport via `Unity_ManageAsset(Action: "Import", Path: "Assets/Editor/...")`.
3. Execute via `Unity_ManageMenuItem(Action: "Execute", MenuPath: "ArrowEscape/Clean Duplicates")`.
4. Check console logs via `Unity_GetConsoleLogs` to verify execution output.
5. Clean up temporary utility code after verifying changes.

### 3. Script Compilation & Console Verification Loop

Always follow this loop after editing any C# code:
1. `Unity_ManageAsset(Action: "Import", Path: "...")` for every edited script.
2. Poll `Unity_ManageEditor(Action: "GetState")` until `IsCompiling == false`.
3. Call `Unity_GetConsoleLogs(maxEntries: 5)` immediately.
4. Catch compile errors (e.g. CS1061 missing field name, CS0246 type not found) on the fly rather than leaving the editor in a broken state.

### 4. Platform Build Manifest Guard (Android AAPT)

- Unity's `Application Entry Point` setting determines the manifest activity.
- If using standard `UnityPlayerActivity`, ensure `AndroidManifest.xml` does NOT declare `UnityPlayerGameActivity` with `@style/BaseUnityGameActivityTheme`.
- Redundant GameActivity entries without GameActivity dependencies break Gradle AAPT linking (`AAPT: error: resource style/BaseUnityGameActivityTheme not found`).

