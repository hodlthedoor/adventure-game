# Underground festival adventure

Build an original, whimsical text adventure inspired by Colossal Cave Adventure, using PureBasic for Windows and macOS. Exploration, connected puzzles, optional treasure hunting, and fair but dangerous situations should reward careful observation. Players interact through typed commands in a desktop window.

Status: agreed concept collected for written review. Detailed hint and turn rules below are proposed defaults for that review. The project currently has no implementation.

## Story and scope

The village well has begun returning strange objects instead of water. Beneath it lies a forgotten kingdom preparing for the Festival of the First Rain. Its royal steward, a meticulous clay figure, has mistaken the well for a delivery chute. Water is being diverted into the preparations; rejected decorations and party supplies travel back to the surface.

The player must restore the village water supply and help the celebration proceed safely. Incorrect operation of the ceremony machinery can flood the lower chambers.

The first release targets 15 to 20 locations, 6 to 8 main puzzles, and 5 optional treasures. Main-story completion must be possible without collecting every treasure. Some treasures also serve as tools; alternative solutions must allow players to recover those treasures without blocking the story.

## World structure

- The village and well introduce movement, examining objects, and inventory use.
- The underground arrival hall is a safe central hub, with access to three interconnected branches.
- The abandoned waterworks hold the diversion mechanism and clues explaining why the festival machinery stopped.
- The fungal gardens provide a living light needed for the ceremony, guarded by a possessive keeper.
- The royal storerooms contain ceremonial equipment and information needed to reconstruct the ritual.
- The celebration chamber hosts the finale, unlocked through discoveries across the branches.

Players can move between branches when stuck. Each branch contributes to the central mystery and offers optional discoveries. Before content implementation, define the exact room map and puzzle dependency graph, including resource access and routes back to safety.

## Challenge and fairness

Lantern fuel and machinery create turn-based pressure. Death and restoration from an earlier save are part of play. Time does not advance while the player reads or thinks.

Serious dangers must have discoverable clues before commitment. Warnings need to communicate the nature of a risk without giving away its solution. The arrival hall must remain safe when the player is waiting there; fuel use still depends on whether the lantern is lit.

Prevent silent unwinnable states through puzzle design: essential objects remain recoverable, permanent consumption has a replacement or alternative solution, and resource depletion offers a viable recovery route or an explicit failure outcome. Do not allow hours of apparently valid play after victory has become impossible.

## Desktop interface and commands

Use a scrolling story transcript, a command entry field, and New Game, Save, Load, and Help menus. Support keyboard-first play, readable text, and resizing on both platforms. After a command, show the result and return focus to the entry field.

The parser supports directions and abbreviations such as `GO NORTH`, `NORTH`, and `N`; inspection through `LOOK` and `EXAMINE`; object actions such as `TAKE`, `DROP`, and `USE KEY ON DOOR`; conversation through `TALK TO`; and `INVENTORY`, `HELP`, and `HINT`.

Normalise case and whitespace, recognise authored synonyms, and resolve objects visible or accessible to the player. Ask for clarification when a reference matches multiple objects. Unknown commands should explain the supported form without changing the world.

Proposed turn policy: valid movement, object manipulation, conversation, and deliberate attempts against puzzle mechanisms consume one turn. `LOOK`, `EXAMINE`, `INVENTORY`, `HELP`, `HINT`, saving, loading, parser errors, and clarification exchanges consume none. Unavailable movement and references to absent objects also consume none. Resolve an action first, then apply one turn of resource and hazard updates if the player is still alive and the game has not ended.

## Hints

Provide hints through `HINT`. Proposed behaviour:

- Select an encountered, unresolved puzzle relevant to the current location and game state.
- Reveal one level at a time: a gentle nudge, a more specific clue, then an explicit solution.
- State that another `HINT` will provide a stronger clue. Never reveal all levels at once.
- Avoid spoilers for places or puzzles the player has not encountered.
- If no local hint applies, suggest an already known unfinished lead, or say that no hint is available here.
- Keep hints free of turn, fuel, and treasure penalties. Preserve revealed levels when saving.

## PureBasic structure

Keep the engine and content in separate PureBasic source files. Use a main `.pb` entry point and focused `.pbi` includes. Exact file boundaries can follow the implementation plan.

- Window code handles input, transcript rendering, menus, and file dialogs.
- The parser converts text into an action or a clarification request.
- The world model stores room connections, object definitions, characters, and mutable game state using stable identifiers.
- Action handlers check conditions, update the state, and return text plus whether a turn was spent.
- Turn rules update active light sources, machinery, and hazards.
- Save/load code serialises mutable state and validates it before replacing the current session.
- Adventure content defines descriptions, vocabulary, puzzles, dialogue, and hint sequences.

The command flow is window input, parsing, action resolution, turn updates, then output rendering. Game rules should be callable without the window so scripted playthroughs can verify behaviour. Content can refer to game rules; game rules must not depend on desktop controls.

Use PureBasic facilities where suitable and keep OS-specific assumptions out of the game rules. Each platform needs its own build and runtime verification. Compiler version, available build machines, and concrete GUI and persistence APIs must be checked during implementation planning.

## Persistence and errors

Save the current room, inventory and object locations, puzzle and character state, remaining resources, hazard progress, visited locations, revealed hints, turn count, and ending status. Store a format version so unsupported saves can be rejected clearly.

A failed or invalid load must preserve the current session. A failed save must display an actionable message and preserve an existing valid save where possible. Use player-selected writable paths. Confirm before discarding an active game through New Game or loading another session.

Death should explain what happened and offer loading a save or starting again. Winning ends active hazards and presents the story outcome and recovered treasures.

## Delivery stages

1. First descent: desktop interface, parser, village, well, and arrival hall; movement, inspection, taking objects, and inventory.
2. Complete waterworks chain: prove a full puzzle sequence, fuel pressure, a signalled hazard, death, and save/load before expanding content.
3. Full adventure: gardens, storerooms, characters, progressive hints, optional treasures, and the festival finale.
4. Release preparation: balance resources, review clue fairness, improve command responses, and verify Windows and macOS builds.

## Acceptance and verification

- Complete the main story from a fresh session without optional treasures or hints.
- Complete a treasure-focused route, including alternate uses of treasure tools.
- Restore saves during puzzle and hazard sequences with equivalent subsequent behaviour.
- Verify fuel exhaustion, death, and irreversible actions against the fairness rules.
- Exercise command synonyms, ambiguous nouns, absent objects, and unsupported input without unintended state changes.
- Confirm hint progression respects discovery, survives save/load, and consumes no turns.
- Reject corrupt and unsupported saves while retaining the current game.
- On Windows and macOS, verify launching, resizing, keyboard entry, transcript scrolling, menus, file dialogs, and save restoration.

Automate meaningful rule and playthrough checks; use manual playtesting for prose, clue quality, and desktop behaviour. Cross-platform release readiness requires evidence from both operating systems.

## Scope boundaries

The initial release is one authored adventure. External content formats, a general scripting language, graphical exploration, multiplayer, and an AI-driven parser are outside this design.
