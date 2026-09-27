# Underground Festival Adventure Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or superpowers:executing-plans to implement this plan task-by-task, according to the user's selected execution method. Steps use checkbox syntax for tracking.

**Goal:** Deliver a complete original text adventure with a desktop interface, fair classic difficulty, optional treasures, and progressive hints on Windows and macOS.

**Architecture:** Keep adventure definitions in PureBasic includes and mutable state separate from those definitions. Run parsing, actions, and turn updates independently of the desktop window so the same rules support interactive play and scripted verification.

**Tech Stack:** PureBasic 6.41 baseline; native window/gadget, JSON, and file libraries; no added dependencies.

**Spec:** [Approved game design](../specs/2026-09-27-adventure-design.md).

## Global constraints

- Build an original, whimsical text adventure inspired by Colossal Cave Adventure, using PureBasic for Windows and macOS.
- The first release targets 15 to 20 locations, 6 to 8 main puzzles, and 5 optional treasures.
- Main-story completion must be possible without collecting every treasure.
- Time does not advance while the player reads or thinks.
- Prevent silent unwinnable states through puzzle design.
- Keep the engine and content in separate PureBasic source files.
- A failed or invalid load must preserve the current session.
- Cross-platform release readiness requires evidence from both operating systems.
- Use the approved spec's exact turn and hint policies. Add no dependency without user agreement.

## Environment and build prerequisites

Observed on 2026-09-27: `/Applications/PureBasic.app/Contents/Resources/compilers/pbcompiler --version` reports PureBasic 6.41, C backend, macOS arm64, Free. It prints the version with exit code 1. Apple command-line tools are selected at `/Library/Developer/CommandLineTools`; compilation has not yet been tested. No Windows build machine has been verified.

The [documented free-edition limit](https://www.purebasic.com/documentation/mainguide/order.html) is 800 source lines. The complete modular game and tests may exceed it. Use a full compiler for the complete build; do not compress code or change the agreed architecture to work around the limit. During execution, run the first build with the available compiler and report any actual licensing or toolchain blocker. Installing or buying software is not part of this plan.

Initial release build targets are macOS arm64 and Windows x64. Intel Mac support can use the same source but remains unverified until built and tested with the corresponding compiler. Record the Windows compiler location when a Windows environment is available.

Use native `EditorGadget` with read-only and word-wrap flags for the transcript and `StringGadget` for input. Preserve native system colours, since editor background customisation differs on macOS. See [EditorGadget](https://www.purebasic.com/documentation/gadget/editorgadget.html) and [StringGadget](https://www.purebasic.com/documentation/gadget/stringgadget.html).

Use built-in JSON structure serialisation for saves, with explicit validation before extraction. See [InsertJSONStructure](https://www.purebasic.com/documentation/json/insertjsonstructure.html). Game content remains compiled PureBasic; JSON is only the save format.

## Review focus

1. Blank input, pasted newlines, and long commands must not trigger unintended actions or turns. Task 2.
2. A command issued during clarification must either resolve it or replace it cleanly. Task 2.
3. Missing save fields, invalid IDs, and impossible combinations must not be accepted as valid progress. Task 4.
4. Cancelling dialogs or attempting to save to an unwritable location must preserve the current game and existing saves. Tasks 4 and 8.
5. Dropped tools, exhausted light, and treasure alternatives must retain a route to victory or an explicit ending. Tasks 3, 5, and 7.

## File ownership and shared interfaces

Create these files as their tasks need them, without empty scaffolding:

| File | Responsibility | Task |
| --- | --- | --- |
| `src/main.pb` | Includes, initialisation, desktop entry point | 2 |
| `src/game/types.pbi` | IDs and shared structures | 1 |
| `src/game/world.pbi` | Definition lookup, state reset, visibility | 1 |
| `src/game/parser.pbi` | Command parsing and clarification | 2 |
| `src/game/actions.pbi` | General actions and command dispatch | 1, 2 |
| `src/game/turns.pbi` | Fuel and hazard updates | 3 |
| `src/game/persistence.pbi` | Versioned save/load | 4 |
| `src/game/hints.pbi` | Hint selection and reveal levels | 6 |
| `src/content/world.pbi` | Rooms, objects, descriptions, aliases | 1, 3, 5 |
| `src/content/puzzles.pbi` | Authored puzzle conditions and consequences | 3, 5 |
| `src/content/hints.pbi` | Three clue levels per puzzle | 6 |
| `src/ui/window.pbi` | Native controls, menu events, transcript | 2, 4, 8 |
| `tests/run_tests.pb` | Console entry, assertions, case selection, exit status | 1 |
| `tests/cases/*.pbi` | Behaviour tests named in each task | 1 to 7 |
| `docs/game/world-and-puzzles.md` | Exact map, clues, dependencies, solutions | 1, 3, 5 |
| `docs/testing/release-checklist.md` | Platform evidence and manual playtest results | 8 |
| `README.md`, `.gitignore` | Build/play instructions; ignore build outputs and saves | 1, 2, 8 |

Use `EnableExplicit`. Central structures:

- `WorldData`: maps of room, object, and puzzle definitions keyed by stable strings. Definitions carry descriptions, aliases, exits, light requirements, and treasure flags. Each dark room defines a fixed `retreatDirection.s` leading along a guaranteed route toward the lit hall.
- `GameState`: `formatVersion.i = 1`, `room.s`, `turns.i`, `fuel.i`, `lampLit.i`, `status.i` (playing/dead/won), plus maps `objectLocations.s()`, `flags.i()`, `visited.i()`, `hintLevels.i()`, and `hazardTimers.i()`. Object locations are room IDs or `inventory`; puzzle consumption uses retained state flags instead of deleting essential objects.
- `Action`: `verb.s`, `noun.s`, `target.s`, `direction.s`.
- `ParseContext`: pending action and candidate object IDs; belongs to the session, not saved gameplay. Reset it on successful load/new game.
- `ActionResult`: `text.s`, `spentTurn.i`. State carries death and win status.

All procedures below take typed pointers and use `.i` returns for status unless `.s` is specified. Pass state explicitly. Definition maps are read-only after `Content_Load(*world.WorldData)`.

## Verification commands

Run from the repository root, with `build/` created first. The test executable accepts a case-group argument and returns nonzero on failure; no external testing library is needed. Use one small `Check(condition.i, label.s)` procedure reporting failures, plus direct assertions in cases. Do not build a testing framework.

```sh
/Applications/PureBasic.app/Contents/Resources/compilers/pbcompiler tests/run_tests.pb --console --output build/adventure-tests
./build/adventure-tests world
/Applications/PureBasic.app/Contents/Resources/compilers/pbcompiler src/main.pb --output build/Adventure.app
open build/Adventure.app
```

On Windows, use the configured `pbcompiler.exe` with the same switches, output `build/adventure-tests.exe` and `build/Adventure.exe`, then run those executables. These switches and `.app` output are documented in the [command-line compiler reference](https://www.purebasic.com/documentation/reference/cli_compiler.html). Test invocations below assume a fresh compilation after each edit. Expected successful output is `PASS <group>` and process exit 0; `all` runs every case group.

## Task 1: Playable world rules and first-descent content

**Files:** Create `types.pbi`, both `world.pbi` files, `actions.pbi`, `tests/run_tests.pb`, `tests/cases/world.pbi`, `docs/game/world-and-puzzles.md`, `README.md`, `.gitignore` at the paths above.

**Interfaces:** Produce `Content_Load(*world.WorldData)`, `World_NewGame(*world.WorldData, *state.GameState)`, `World_CanSee(*world.WorldData, *state.GameState, objectId.s)`, and `Game_Apply(*world.WorldData, *state.GameState, *action.Action, *result.ActionResult)`. The latter executes one already parsed action, initially movement, inspection, taking, dropping, and inventory.

- [ ] Record the 19-room map in `world-and-puzzles.md`. Use reciprocal links: village square north to well house; well house down to well shaft; shaft down to arrival hall. Hall west to sluice landing, west to pump room, north to valve gallery, east to cistern rim. Hall north to garden gate, north to mushroom grove, east to keeper's hut, north to nursery. Hall east to cloakroom, east to inventory office, north to storeroom, east to bell loft. Hall south to processional passage, south to celebration chamber, east to overflow balcony. Add grove west to cistern rim and nursery east to storeroom as shortcuts opened from their branch sides. Mark conditions and reverse directions explicitly.
- [ ] Implement only the first four rooms initially. Put a lantern in the well house; the established ladder provides safe descent without an additional puzzle. Load descriptions and exits from content includes.
- [ ] Add failing `world` assertions: starting room is `village_square`; applying north moves to `well_house`; taking the lantern puts it in inventory; taking it again leaves one copy; dropping it makes it recoverable; a nonexistent exit leaves room and turn count unchanged. Run and confirm these fail because game behaviour is absent.
- [ ] Implement the shared types, state reset, visibility, and actions. Keep the room graph and prose out of general action logic. Guard object access by location and visibility.
- [ ] Compile and run `world`, expecting `PASS world`. Document any actual compiler limitation before proceeding. Commit as `feat: add first descent world rules`.

## Task 2: Typed commands and desktop play

**Files:** Create `src/main.pb`, `src/game/parser.pbi`, `src/ui/window.pbi`, `tests/cases/parser.pbi`; modify actions, test runner, and README.

**Interfaces:** Consume Task 1. Produce `Parser_Parse(*world.WorldData, *state.GameState, *context.ParseContext, input.s, *action.Action, *result.ActionResult)` returning ready/clarify/rejected; `Game_Submit(*world.WorldData, *state.GameState, *context.ParseContext, input.s, *result.ActionResult)`; `UI_Run(*world.WorldData, *state.GameState)`.

- [ ] Add failing `parser` cases for mixed case and extra spaces; `N`, `NORTH`, and `GO NORTH` equivalence; `USE KEY ON DOOR`; two visible matching objects producing clarification; answering with one candidate; and a fresh full command replacing clarification. Verify rejected input and clarification do not spend turns.
- [ ] Add assertions that blank input and commands over 256 characters leave gameplay unchanged. Reject pasted CR/LF input as multiple commands rather than joining or executing it. Add absent-object and unsupported-verb cases with helpful feedback.
- [ ] Implement parser aliases, scoped resolution, and `Game_Submit`. `HELP` lists supported command forms. Support the spec's commands plus `LIGHT LANTERN`, `EXTINGUISH LANTERN`, and `WAIT` for resource and hazard play. Preserve pending input only until resolved or replaced.
- [ ] Implement a resizable 900 by 650 window, minimum 640 by 480, with transcript, input, and menus. Submit through Enter only while input has focus. Echo the command, append the response, clear input, and restore focus. Keep transcript readable and selectable. Save/Load menus are disabled until Task 4.
- [ ] Run `parser` and `world`, then build and manually play the first descent. Check keyboard focus, copying text, scrolling, resizing, and exactly one execution per Enter press. Commit as `feat: add desktop command interface`.

## Task 3: Waterworks, light, and dangerous turns

**Files:** Create `src/game/turns.pbi`, `src/content/puzzles.pbi`, `tests/cases/waterworks.pbi`; modify content, actions, and world/puzzle documentation.

**Interfaces:** Produce `Content_ApplyPuzzle(*world.WorldData, *state.GameState, *action.Action, *result.ActionResult)` returning handled/unhandled, and `Turns_Advance(*world.WorldData, *state.GameState, *result.ActionResult)`. `Game_Submit` invokes turns once only for a spent action while status remains playing.

- [ ] Define puzzles 1 and 2: brace the pump with the ordinary wooden wedge from the landing before operating it; then set the diversion valve after the pump is stable. The repaired route restores village water. Optional silver tuning fork can substitute for the wedge and can later be exchanged back safely.
- [ ] Write the machinery failure history into inspection text. Pump vibration and posted maintenance instructions signal danger. Unbraced operation starts a three-action local failure timer; leaving the pump room cancels it, bracing stops it, and expiry while present causes death. A newly started timer does not decrement on its activation action.
- [ ] Add failing `waterworks` cases for the safe sequence, fatal sequence, escape, tool recovery, and exactly one update per action. Assert inspection/help/hints do not advance timers. Implement content handlers and turn rules after observing failures.
- [ ] Start lantern fuel at 80 turns, consuming one per spent turn while lit, with warnings at 20 and 5. At zero, switch it off. The well-house oil can refills it to 80 without a global supply limit; travel still creates pressure. In darkness, permit the authored retreat direction, extinguishing, accessible lantern recovery and lighting, and free informational commands with descriptions limited by visibility. Refuse further blind exploration clearly. Every retreat chain must reach the naturally lit hall without a locked exit or required tool; the shaft and surface are also naturally lit. Darkness never prevents Save/Load menus.
- [ ] Test fuel exhaustion deep in a branch, dropping the lantern, retreat to refill, and re-entry. Ensure darkness cannot strand the player behind a one-way exit. Run `waterworks`, `world`, and `parser`; manually verify warnings appear before failure. Commit as `feat: add waterworks puzzles and turn hazards`.

## Task 4: Save, restore, and restart

**Files:** Create `src/game/persistence.pbi`, `tests/cases/persistence.pbi`; modify window, main, and test runner.

**Interfaces:** Produce `Save_Write(*world.WorldData, *state.GameState, path.s, *result.ActionResult)` and `Save_Read(*world.WorldData, *state.GameState, path.s, *result.ActionResult)`, returning success/failure. Load through a temporary `GameState` and replace the live state only after complete validation.

- [ ] Add failing `persistence` cases for exact state round-trip mid-hazard, equal outcomes after the same next action, missing fields, truncated JSON, wrong field types, unknown IDs, negative fuel/timers, invalid status, and inconsistent puzzle prerequisites. Assert failed loads leave all live fields unchanged.
- [ ] Implement format version 1 with built-in JSON. Validate required members and permitted ranges before extraction, then validate content invariants. Extend invariant checks when Task 5 adds puzzles. Save all maps and scalar state; reject unsupported versions explicitly.
- [ ] Write to a sibling temporary file, confirm successful output, then replace the destination while retaining a recoverable backup until replacement succeeds. Test unwritable destination and replacement failure with real temporary directories and files; an existing valid save must remain recoverable. Avoid a custom filesystem abstraction just for tests.
- [ ] Wire Save/Load menus to native file dialogs. Cancellation is a no-op. Confirm before discarding active progress; successful load/new game clears clarification and refreshes the displayed location. Death retains Load/New Game access; winning disables active turn progression. Save and restore terminal states consistently.
- [ ] Run `persistence` and prior groups. Manually save midway through the waterworks, restart, load, and finish it. Commit as `feat: add validated save and restore`.

## Task 5: Gardens, storerooms, treasures, and finale

**Files:** Modify adventure content, puzzle handlers, persistence invariants, and world/puzzle documentation; create `tests/cases/adventure.pbi`.

**Interfaces:** Extend the existing content and `Content_ApplyPuzzle` contracts. Keep new story-specific conditions out of the parser and window.

- [ ] Finish the room definitions and record these seven main puzzles in total: (1) brace pump, (2) restore diversion, (3) open the garden irrigation gate using restored water, (4) trade the storeroom's ordinary clay cup for the keeper's living light, (5) use the office manifest's symbols to open the ceremonial cabinet, (6) ring the stored ceremonial bell with the living light installed to open the procession route, (7) perform the festival sequence shown in the bell-loft inscription: vent overflow, admit rain, ring the final bell. The cabinet contains bell and cup; its clues are accessible without garden progress. Check dependencies for cycles before coding.
- [ ] Add five recoverable treasures: silver tuning fork at the cistern rim, glass seed in a grove seedpod opened by irrigation, moon pearl revealed in the nursery by living light, miniature crown in a manifest-opened storeroom drawer, and rain crystal on the overflow balcony after a successful festival. The tuning fork can brace the pump; the miniature crown can substitute as the keeper's cup, with a reversible exchange for the ordinary cup. Count recovered treasures carried or deposited at the well house.
- [ ] Add failing `adventure` cases for completing each puzzle, invalid-order feedback without irreversible item loss, character trade reversal, unlocking both shortcuts, and safe/fatal festival sequences. An explicit pressure warning precedes a three-action flood timer if water is admitted before venting; opening the vent stops it. Escape to the hall resets the attempt without destroying essential items.
- [ ] Implement authored descriptions, conversation clues, and consequences. Living light supports the ritual but does not replace the lantern for cave travel. After victory, stop hazards and permit safe exploration to collect remaining treasures; only inspection, movement, and treasure collection remain active, with no resource cost.
- [ ] Run `adventure` and previous groups. Play a route that visits branches in a different order from the authoring sequence. Confirm a waterworks-only success does not end the game and the finale requires the living light and ceremony equipment. Commit as `feat: complete festival adventure content`.

## Task 6: Progressive hints

**Files:** Create both hint includes and `tests/cases/hints.pbi`; modify command dispatch and content initialisation.

**Interfaces:** Produce `Hints_Reveal(*world.WorldData, *state.GameState, *result.ActionResult)` and `Content_LoadHints(*world.WorldData)`. Add authored hint levels and puzzle priorities to definition data.

- [ ] Add failing `hints` cases asserting one clue per call, three levels maximum, final clue repeated after exhaustion, no fuel/turn/timer change, and no clues for unseen puzzles. Assert local unresolved puzzles outrank known remote leads and completed puzzles are skipped.
- [ ] Author nudge, specific clue, and explicit solution for every main puzzle and optional treasure puzzle. Mark puzzle discovery when its relevant mechanism or clue is seen; use that state to select hints deterministically. Stronger clues must reflect the player's actual missing prerequisite.
- [ ] Implement selection and dispatch, preserving levels in the existing save state. If only a known remote lead applies, name its location; otherwise explain that no hint is available here. Add a save/load case after revealing level two.
- [ ] Run `hints`, `persistence`, and `adventure`. Manually read all hint sequences against the actual puzzle solutions and check they neither contradict state nor spoil undiscovered rooms. Commit as `feat: add progressive puzzle hints`.

## Task 7: Whole-game fairness verification

**Files:** Create `tests/cases/playthroughs.pbi`; update content only where evidence reveals problems, and record resource budgets in `docs/game/world-and-puzzles.md`.

**Interfaces:** Drive `Game_Submit` from a new state, without setting puzzle flags directly. Use save/read procedures at checkpoints.

- [ ] Add executable command sequences for a zero-treasure main-story win, all-five-treasure collection including return from the finale, and a different branch order. Assert status and treasure count, not exact prose. Main-story checks use the wedge and clay cup so no treasure is required.
- [ ] Add realistic detours, optional inspections, drop/recover operations, refilling, treasure substitutions, and save/restore before each hazardous sequence. Track fuel at branch entry and return; normal exploration must have ample time to react to warnings.
- [ ] Check every item consumption and permanent gate change against a route back to safety and a remaining main-story solution. Add a targeted test only for a real failure mode uncovered during this audit. Adjust fuel or warning thresholds only with recorded playthrough evidence.
- [ ] Run `all`, expecting every group to pass and exit 0. Commit as `test: verify complete adventure routes and fairness`.

## Task 8: Windows and macOS release checks

**Files:** Create `docs/testing/release-checklist.md`; update README, window code, and `.gitignore` as needed.

**Interfaces:** Existing desktop entry point and test runner; no new game API.

- [ ] Build and run `all` plus the desktop app on macOS arm64 and Windows x64 using full compilers where required. Record OS/compiler versions, commands, results, and any unavailable target explicitly.
- [ ] On each platform, check font readability, resizing and minimum size, multiline transcript scrolling/copying, keyboard focus, Enter submission, menus, save/load dialogs, and cancellation. Test filenames with spaces and Unicode, an unwritable save location, and loading after death.
- [ ] Give a fresh playtester the game and Help text. Record where they misread danger, guessed unsupported reasonable commands, or required the final hint. Fix demonstrated problems and rerun affected tests.
- [ ] Document controls, save location behaviour, build commands, and actual tested targets. Package the native `.app` and `.exe` from successful builds. Distribution signing and notarisation are separate publishing work if requested.
- [ ] Run the final relevant checks after fixes and record platform evidence. Do not mark a target released based only on source portability. Commit as `docs: record adventure release verification`.

## Execution handoff

The approved design is implemented by these tasks in dependency order. Review this plan's concrete map, puzzles, and initial tuning before execution. The recommended approach is native execution in the current session because the tasks share tightly coupled game-state and content interfaces; subagent-driven execution is available if the user prefers independent review per task.

No game source or test files have been created by the planning work. The local free compiler and unavailable Windows verification are recorded prerequisites, not reasons to change the agreed game scope.
