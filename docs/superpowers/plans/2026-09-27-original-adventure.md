# Original Adventure Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. The user selected native execution with a final independent review. Steps use checkbox syntax for tracking.

**Goal:** Recreate the complete Crowther/Woods 350-point Adventure in PureBasic, with the approved desktop interface and documented desktop adaptations.

**Architecture:** Embed the original numbered data in the executable and translate the FORTRAN rules into a headless PureBasic session engine. Preserve ordered travel, object-list order, and input continuations. A native window submits input and displays results without owning gameplay rules.

**Tech Stack:** PureBasic 6.41, built-in window/gadget, string, file, and JSON libraries. No added dependency or runtime C/FORTRAN component.

**Spec:** [Approved recreation design](../../recreation/design.md). [Pinned source baseline](../../recreation/source-baseline.md). The festival design is superseded for this branch.

## Global constraints

- Recreate the original Adventure in PureBasic for Windows and macOS.
- Match its puzzles, treasures, scoring, lamp lifetime, carrying limits, random encounters, deaths, resurrection, cave closing, and endgame.
- Do not carry over the festival's fairness adjustments, unlimited oil, free hint policy, or simplified movement rules.
- Retain the scrolling transcript, keyboard command entry, 1100 by 780 initial window, and 18-point text.
- Original contextual hints retain their original eligibility and score consequences.
- Save/load menus store complete game state, including random generator state and pending yes/no prompts.
- Reject saves from the festival game without replacing the active session.
- Omit PDP-10 administrator features such as business-hour play restrictions and wizard access.
- Allow immediate local save/restore without time-sharing account restrictions.
- Implement game rules in PureBasic; do not wrap a C or FORTRAN executable.
- Local compiler: full PureBasic 6.41 macOS x64. Windows and native macOS arm64 verification require their own environments.

## Review focus

1. A false travel condition must fall through to the next different destination, not restart motion matching or reorder alternatives. Task 3.
2. An object/verb clarification must preserve the original continuation and command timing; yes/no replies must not tick ordinary turns. Tasks 2 and 6.
3. Save/load during a hint, dragon question, or resurrection must neither replay side effects nor charge twice. Task 8.
4. Two-sided objects, bird/cage coupling, bottle contents, and object-list ordering must remain valid after movement, death, and closing. Tasks 4, 6, and 7.
5. Malformed saves and canceled dialogs must preserve the active game, including random state and pending questions. Tasks 8 and 9.

## Reference and reuse

Work in `.worktrees/colossal-cave-original` on `feat/colossal-cave-original`. Preserve `feat/festival` at checkpoint `6c3e912`; do not merge or overwrite it. The new branch currently inherits the festival engine and its 89-check suite. Those checks establish the reuse baseline, not original-game correctness.

Use the exact `advent.for` and `advent.dat` hashes recorded in the source baseline. Local research copies are under `.superpowers/original-reference/`. At Task 1, add the unmodified reference, data, readme, and provenance to `reference/wood0350/`. Preserve upstream notices and attribution; do not invent a license or assert public-domain status. Record any distribution questions for release review.

Embed `advent.dat` with `IncludeBinary` and decode it at startup using PureBasic. Content remains compiled into the application, with no network or external file needed to play. Retaining original data avoids a hand-transcribed cave map. The FORTRAN reference is never linked or executed by the shipped game.

Reuse native controls and file-dialog patterns in `src/ui/window.pbi`. Replace its festival API calls once Task 3 provides a playable original opening. Keep legacy source/tests buildable until the original integration works, then move the old test entry to `tests/festival_tests.pb`; do not mix compatibility results.

## Files and interfaces

| Files | Responsibility |
| --- | --- |
| `reference/wood0350/{advent.for,advent.dat,advent.readme,PROVENANCE.md}` | Exact reference and provenance |
| `src/original/types.pbi`, `database.pbi` | Definitions, original IDs, embedded data decoder |
| `src/original/state.pbi`, `random.pbi`, `messages.pbi` | State, original RNG, ordered output events |
| `src/original/parser.pbi`, `engine.pbi` | Vocabulary, command phases, resumable session |
| `src/original/travel.pbi` | Conditional travel, BACK, forced movement, specials |
| `src/original/objects.pbi`, `actions.pbi` | Object bookkeeping and ordinary verbs |
| `src/original/puzzles.pbi` | Creature, liquid, treasure, and magic interactions |
| `src/original/encounters.pbi`, `hints.pbi`, `scoring.pbi` | Random actors, offers, and score |
| `src/original/closing.pbi`, `persistence.pbi` | Closing/endgame and validated saves |
| `src/original/original.pbi` | Single ordered include entry for app and tests |
| `src/main.pb`, `src/ui/window.pbi` | Original-game entry and native interface |
| `tests/original_tests.pb`, `tests/original/*.pbi` | Independent test runner and cases |
| `tests/original/fixtures/` | Source-derived state cases and complete command traces |
| `docs/recreation/{source-map.md,compatibility.md,verification.md}` | Label mapping, adaptations, evidence |
| `README.md` | Build and player instructions |

Use an `Original` module for the public session API; internal procedures may share its namespace. `Original::Database`, `Original::State`, and `Original::Output` are shared types. Declare interfaces before dependent includes.

- `Database`: immutable text groups, ordered travel records, vocabulary entries (including duplicate spellings), initial placements/fixed placements, action defaults, condition bits, score classes, and hint definitions. Preserve source capacities of 150 location slots, 100 object slots, 200 object-link slots, and 20 hint slots; allocate one extra slot for one-based indexing.
- `State`: original mutable arrays `place`, `fixed`, `prop`, `atloc`, `link`, `abb`, `hintlc`, `hinted`, `dloc`, `odloc`, `dseen`; scalars for locations, carried count, turn/lamp counts, discoveries, dwarf phase, kills, knife location, deaths, closing clocks and flags, bonus, quit/scoring state, abbreviation/detail counters, west counter, and magic-word sequence. Include `rng.q`, input words, retained verb/object, engine phase, and pending-question/resume fields. Inventory every variable live across an input call against the reference before finalising the type.
- `Output`: rendered text plus an ordered list of message events `(section.i, id.i, variant.i, args.s)`, `inputMode.i` (command/yes-no/continuation/ended), and `request.i` (none/save/open-help). Tests assert message identity and gameplay effects rather than typography.
- `LoadDatabase(*db.Database, *out.Output) -> .i`: success/failure, called once.
- `NewGame(*db.Database, *s.State, seed.q, *out.Output)`: initialises state and stops at the original instructions question.
- `Submit(*db.Database, *s.State, input.s, *out.Output)`: executes through the next input boundary; never blocks on desktop input.
- `Describe(*db.Database, *s.State, *out.Output, full.i)`: original in-game description behaviour; UI save restoration must display saved output without calling this and changing state.
- `RandomRange(*s.State, range.i) -> .i`: original generator step, returns 0 through range minus one.
- `MoveObject(*s.State, object.i, location.i)`, `CarryObject`, `DropObject`, `DestroyObject`, `JuggleObject`: preserve original chains, fixed-object aliases, and carried count.
- `Score(*db.Database, *s.State, scoringCommand.i) -> .i`: computes the original score without silently changing terminal status.
- `Save(*db.Database, *s.State, *out.Output, path.s) -> .i`, `Load(*db.Database, *s.State, *out.Output, path.s) -> .i`: persist complete session and visible pending prompt; failure preserves both live structures.

The names below are internal contracts, not separate frameworks: `ParseWords`, `ResolveTravel`, `ApplyAction`, `ApplyPuzzle`, `AdvanceEncounters`, `OfferHint`, `BeginDeath`, and `AdvanceClosing` consume the same database/state/output pointers. Each stores a phase or continuation before returning for input. Do not approximate FORTRAN control flow with a generic post-action turn increment.

## Commands and verification convention

Create `build/` if absent. Use these commands from the new worktree:

```sh
PUREBASIC_HOME=/Applications/PureBasic.app/Contents/Resources /Applications/PureBasic.app/Contents/Resources/compilers/pbcompiler tests/original_tests.pb --console --output build/original-tests
./build/original-tests all
PUREBASIC_HOME=/Applications/PureBasic.app/Contents/Resources /Applications/PureBasic.app/Contents/Resources/compilers/pbcompiler src/main.pb --output build/ColossalCave.app
open build/ColossalCave.app
```

The runner accepts the task groups below and exits nonzero for failures or an unknown group. Success prints `PASS <group>` with the check count. Compile after edits before running tests. Each behaviour task follows red, green, then the complete implemented suite. Reuse the small `Check` pattern; do not add a test framework.

Windows uses its configured full `pbcompiler.exe`, the same source/switches, and `.exe` output. Build the macOS x64 target with the installed compiler. Record unavailable platforms as unverified. Accessibility-based desktop automation was denied in the prior work; do not describe build/launch evidence as completed interactive testing.

## Task 1: Pinned data decoder and state foundations

**Files:** Reference files; `types.pbi`, `database.pbi`, `state.pbi`, `random.pbi`, `messages.pbi`, `original.pbi`; test runner and `tests/original/database.pbi`; source map.

**Interfaces:** Produce `LoadDatabase`, mutable state types, message lookup, and `RandomRange`.

- [ ] Pin reference bytes and attribution. Record data section meanings and code-label ranges in `source-map.md`; retain source order and state-dependent text grouping.
- [ ] Write failing decoder cases: 140 long-description locations, 65 short-description locations, 493 travel records before expansion by motion word, and 295 vocabulary records. Verify multiline messages, object property variants, duplicate vocabulary spellings, and the suppressed-message marker. A property block such as 100 must remain associated with its preceding object, not become a new ordinary object.
- [ ] Write independent travel-decoding assertions: encoded destination 110022 requires carrying object 10 and targets room 22; 303008 requires object 3's property to differ from zero and targets room 8. Check invalid section/ID input fails without partial publication.
- [ ] Implement the decoder from reference labels 1002 through 1083, then initial placements and object-chain setup at 1100 through 1800. Keep database immutable once validated.
- [ ] Implement the original `RAN`: `rng = (rng * 1021) mod 1048576`, then integer `range * rng / 1048576`. With state 1, successive `RandomRange(100)` results must be 0, 99, 2, 89. Preserve calls with range 1 because they advance state. Choose a nonzero odd starting state for new interactive sessions; fixture seeds are explicit.
- [ ] Run `database` and `all`; commit `feat: load original adventure data and state`.

## Task 2: Parser and resumable input

**Files:** `parser.pbi`, `engine.pbi`, message helpers; `tests/original/parser.pbi`.

**Interfaces:** Produce `NewGame`, `Submit`, and `ParseWords`; engine phase fields live in `State`.

- [ ] Add failing cases for the instructions question, yes/no reprompt, case folding, first-five-character lookup, duplicate word categories, noun-first and verb-first forms, retained verb/object, and `SAY` consuming a word without ordinary lookup. Derive expected IDs from the pinned vocabulary, not the implementation's own lookup.
- [ ] Make instructions acceptance set lamp limit 1000 and the five-point hint flag; refusal sets limit 330. Neither yes/no reply increments ordinary turns. Initial location is 1, closing clocks are 30 and 50, normal abbreviation period is 5.
- [ ] Port `GETIN`, `VOCAB`, labels 2600 through 5199, and the `YES` continuations. Trace the actual 20-character input handling and third-word behaviour before fixing input tests. Reject pasted multiple commands at the UI boundary; that desktop validation does not enter the game clock.
- [ ] Advance ordinary input timing at the source's label 2608, before action resolution. Test unknown vocabulary, ordinary clarification, LOOK, and INVENTORY against that timing. Do not inherit the festival's free-command policy.
- [ ] Run `parser` and `all`; commit `feat: port original command parsing and prompts`.

## Task 3: Ordered travel and playable opening window

**Files:** `travel.pbi`, basic object actions needed for cave entry, `engine.pbi`; app entry and existing window; `tests/original/travel.pbi`.

**Interfaces:** Produce `ResolveTravel`, `Describe`, and minimal `ApplyAction` for take, lamp, and grate; consume `Submit` in the UI.

- [ ] Add failing state fixtures for every travel condition class: unconditional, probability, dwarf exclusion, carried object, present/two-sided object, and property mismatch. Assert a failed condition skips repeated identical encoded destinations and chooses the next different destination even if its motion words differ.
- [ ] Port labels 8 through 50, the movement/description phases, forced movement, and BACK history. Special travel codes 301 through 303 are dispatched to a separate handler completed in Task 5. Until that milestone, report the incomplete development feature explicitly if encountered; never treat a special code as a room ID. The full compatibility suite includes their fixtures in Task 5.
- [ ] Add opening commands through the building, supplies, grate, and cave entry. Verify locked/unlocked travel and lamp requirements using source IDs. Preserve object-list output order and treasure discovery effects of descriptions.
- [ ] Wire the original session into the enlarged window. Replace title/startup copy, route questions through the same input field, and disable Save/Load until Task 8. Keep menu Help separate from original HELP vocabulary. Preserve keyboard focus and selected transcript text.
- [ ] Build the app and run `travel` plus `all`; verify visible opening and question flow where UI access permits. Commit `feat: make original cave entry playable`.

## Task 4: Objects, liquids, and ordinary actions

**Files:** `objects.pbi`, `actions.pbi`; `tests/original/objects.pbi`, `tests/original/actions.pbi`.

**Interfaces:** Complete object primitives and `ApplyAction` using the source's transitive/intransitive action tables.

- [ ] Add failing tests for two-sided fixed objects, the seven-item carrying boundary, dropping in source list order, automatic bird/cage coupling, and bottle water/oil transitions. Test the eighth take is refused, not merely that a constant equals seven.
- [ ] Port `CARRY`, `DROP`, `MOVE`, `PUT`, `DSTROY`, `JUGGLE`, the HERE/AT/TOTING/LIQ predicates, and handlers 8010 through 9290. List every action-table entry in the source map; delegate story-specific entries to Task 5 and closing-specific entries to Task 7 with explicit tests owned there.
- [ ] Verify TAKE/DROP, OPEN/LOCK, ON/OFF, READ, EAT/DRINK/FILL/POUR, FIND/INVENTORY, BRIEF, and action defaults. Reserve SCORE/QUIT and death terminal continuations for Task 6, with explicit development-only feedback until implemented. Distinguish absent objects, fixed objects, and inferred objects as the source does.
- [ ] Map SUSPEND to a save request without the historical waiting period. HOURS reports unrestricted local play. Neither launches an administrator flow.
- [ ] Run `objects`, `actions`, and `all`; commit `feat: port original inventory and object actions`.

## Task 5: Cave puzzles and treasure transitions

**Files:** `puzzles.pbi`, special travel integration; `tests/original/puzzles.pbi`; source-map rows for puzzle handlers.

**Interfaces:** Produce `ApplyPuzzle`, consumed by action and special-travel dispatch.

- [ ] Add source-derived failing cases for bird/rod/cage, bird/snake, fissure/rod, plant watering stages, door oiling, clam/trident/pearl, vase/pillow, dragon confirmation, bear feeding/chain, troll payment/bear crossing, vending batteries, plover/emerald, and FEE/FIE/FOE/FOO eggs.
- [ ] Assert inventory, fixed locations, properties, treasure tally/tally2, and emitted message IDs for each transition and its invalid alternative. Include irreversibility where the reference has it; do not insert safety routes from the festival game.
- [ ] Implement each case from its source labels, preserving question continuation and side-effect ordering. Cover the rod variants and special object substitutions in labels 5100 through 5140.
- [ ] Test dragon YES/NO/invalid responses, interrupted magic-word sequences, losing treasure to the troll, and bridge collapse with the bear. Fatal puzzle effects set the engine death phase; Task 6 adds resurrection and scoring. Test the fatal state transition here and the subsequent conversation in Task 6.
- [ ] Run `puzzles` and `all`; commit `feat: port original cave puzzles and treasures`.

## Task 6: Encounters, death, hints, and score

**Files:** `encounters.pbi`, `hints.pbi`, `scoring.pbi`, death phase in engine; `tests/original/encounters.pbi`, `hints.pbi`, `scoring.pbi`.

**Interfaces:** Produce `AdvanceEncounters`, `OfferHint`, `BeginDeath`, and `Score`.

- [ ] Write fixed-seed failures for dwarf activation and movement, first knife miss, later hits, blocking travel, pirate theft/chest placement, and darkness death. Account for all random draws, including parser failure text and range-one calls. Use the source's initial actor locations 19, 27, 33, 44, 64, and 114.
- [ ] Port encounter phases around 71 through 84 and 6000 through 6030. Preserve candidate travel order and restrictions. Test the pirate's treasure exceptions and chest/message placement.
- [ ] Port death labels 90 through 99: carried lamp goes to location 1 extinguished, other carried objects go to OLDLC2, resurrected player goes to location 3, and water/oil pseudo-objects reset. Preserve source list order, death count, refusal, final death, and closing-time refusal of resurrection.
- [ ] Port automatic hint counters, predicates 40400 through 40900, the two-stage offer, and score deductions. Accepted hints extend remaining lamp life by 30 times the cost only when the source permits it. Add `HINT` as a desktop convenience that invokes the same eligible offer without bypassing predicates/counters; the command itself adds no original turn. Declined offers never charge points, accepted offers never charge twice.
- [ ] Port scoring labels 20000 through 20220. Independently verify treasure values, discovery credit, intact deposits at location 3, survival, quit differences, dwarf activation, closing, magazine placement, and hint deductions. A complete success fixture totals 350; a five-point instructions hint reduces the same fixture to 345.
- [ ] Run encounter/hint/score groups and `all`; commit `feat: port original hazards hints and scoring`.

## Task 7: Lamp exhaustion, cave closing, and endgame

**Files:** `closing.pbi`, engine timing integration; `tests/original/closing.pbi`.

**Interfaces:** Produce `AdvanceClosing` at the original input phase; terminal output includes score and classification.

- [ ] Write failing cases for lamp warning, nearby fresh battery replacement adding 2500 to the remaining limit, exhaustion, and surface termination. Verify one decrement per original command and none per yes/no response.
- [ ] Port labels 10000 through 19999 and corresponding input-clock checks. Clock1 starts at 30 and only ticks when all treasures are discovered in eligible locations; clock2 starts at 50, with the first blocked escape applying the source's 15-turn panic setting.
- [ ] Test closing's grate/fissure changes, removal of actors, disabled resurrection, and transport to repository locations 115/116. Verify negative property encodings, held-object removal, and source object placement rather than building an approximate new room.
- [ ] Cover repository object interactions, oyster clue penalty, mirror/dwarf failures, and all BLAST outcomes. Score the correct endgame bonus as 45 and the other source outcomes distinctly.
- [ ] Run `closing` and `all`; commit `feat: reproduce cave closing and repository ending`.

## Task 8: Complete session persistence

**Files:** `persistence.pbi`, window menu integration; `tests/original/persistence.pbi`.

**Interfaces:** Produce `Save` and `Load` for database-compatible session state and output.

- [ ] Define a JSON envelope with `game = "crowther-woods-350"`, `formatVersion = 1`, the pinned data digest, state, and current output/prompt. Keep native pointers and desktop handles out of it.
- [ ] Add failing round trips at ordinary input, object clarification, hint cost confirmation, dragon confirmation, resurrection, closing, and game over. Apply identical subsequent input to original/restored sessions and compare all state, random state, ordered message events, and score. No load may describe a room by executing a gameplay phase again.
- [ ] Validate envelope/type/counts/ranges, known phases and question continuations, object chains without cycles/duplicates, carried count, actor locations, properties, and meaningful cross-field constraints before publishing candidate state. Reject festival saves, truncated JSON, wrong data digests, impossible pending prompts, and invalid RNG state while retaining the live session.
- [ ] Adapt the established sibling-temp/backup replacement pattern. Test first save, replacement, unwritable destination, and failure preserving an existing file. Clean only temporary files created by this operation.
- [ ] Enable Save/Load menus with cancel-as-no-op and confirmation before discarding progress. Re-render saved output on successful restore and restore input focus.
- [ ] Run `persistence` and `all`; commit `feat: save and restore complete original adventure sessions`.

## Task 9: Full fidelity and platform verification

**Files:** `tests/original/playthroughs.pbi`, fixture traces; README and recreation verification/compatibility documents; necessary fixes only.

**Interfaces:** Exercise `NewGame` and `Submit` from fresh state; no setting puzzle flags in end-to-end traces.

- [ ] Record a complete deterministic 350-point command trace with source-derived checkpoint assertions and no accepted hint penalties. Add a hint-accepting route, death/resurrection route, and wrong-endgame route. Branch-specific fixtures supplement these traces; a passing opening is not acceptance.
- [ ] Audit each source action handler, special travel, hint, and terminal path against the label-to-procedure map. Compare hand-audited source expectations for travel and object transitions; use another executable port only as secondary evidence and record known differences.
- [ ] Run all original groups and the retained festival suite as separate outputs. Confirm the new main program includes only the original engine. Record actual compiler architecture and build commands.
- [ ] Build and run the macOS app. Verify the 18-point text, resizing, scroll/copy, Enter behaviour, prompts, focus, save/load, cancel, Unicode filenames, and loading after death. Run the same checks on Windows and native arm64 when available; explicitly leave missing evidence open.
- [ ] Write player controls using original command forms, attribute Crowther/Woods and the reference archive, and list deliberate desktop differences. Do not claim unrestricted release licensing or cross-platform verification without evidence.
- [ ] Run the final independent whole-branch review using the user's chosen native workflow; resolve important findings with focused failing tests and a green suite. Commit `docs: record original adventure fidelity verification` after checks.

## Self-review and execution status

Tasks cover data, exact input timing, travel, all action families, encounters, score, hints, death, closing, saved continuations, and desktop adaptation. Source labels settle behavioural conflicts; document any necessary departure in `compatibility.md` and the execution ledger.

This plan is ready for user review. The user has already selected native execution and a final independent review, so do not ask them to choose an execution method again. No replacement engine code has been written in this planning step.
