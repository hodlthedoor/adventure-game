# Verification — 2026-09-27

## Executed checks

- Full PureBasic 6.41 C-backend **macOS x64** compilation of `src/main.pb`.
- Original suite: **100 checks passed**. Pinned data counts, vocabulary ambiguity, object text variants, original RNG sequence, parser continuation, original turn/lamp timing, grate access, paid hints, and punctuation are checked.
- Deterministic seed-13 trace reaches **350/350 in 293 turns**, without injecting puzzle state. Every command checks location, clock, unseen treasure tally, and deaths. It traverses the main puzzles, dwarf combat, pirate/chest recovery, cave closing, and correct repository blast.
- Every boundary of that trace is saved and loaded; the next command produces identical complete State and text. Dedicated round trips cover instructions, clarification, dragon confirmation, hint offer/cost, oyster hint, resurrection, and game over.
- Branch checks reach 345 after accepting instructions, 330/335 for wrong blasts, mirror failure, resurrection with dropped equipment, lamp exhaustion, and automatic/declined hints. Focused lamp/hint tests adjust clock eligibility; the full-score and alternate-ending routes use real commands.
- Malformed saves with invalid mnemonic IDs, phase, RNG, location, carrying count, sentinel, linked-list cycle, digest, array length, or number type are rejected without replacing the live game. Unicode filenames and replacement saves passed.
- Retained festival suite: **89 checks passed**, independently of the new original engine.
- A native EditorGadget smoke check appending 80 responses scrolled to visible Y=1842, visible height=398, document height=2240: the bottom is visible. The production path calls this append/scroll operation for each submitted command and response. Windows uses its native scroll message.

## Independent review

A read-only whole-branch review covered the translator, continuations, object helpers, ordered data, persistence, and UI wiring. It found two important malformed-save crash paths: missing immutable IDs and an unchecked room-zero sentinel. Both were fixed with rejection tests; the reviewer independently rebuilt and confirmed all 100 checks pass. No unresolved findings remained in its focused recheck.

## Limits of this evidence

No Windows or native macOS arm64 build was available. No running PDP-10 reference was available for independent transcript/RNG comparison. The source-labelled translation and source-derived branch assertions support fidelity; the recorded full-score fixture establishes playability and repeatability, not independent executable parity or exhaustive coverage of every possible command.

The app opens on macOS with the enlarged window and 18-point font. The native scrolling operation was checked directly. A later automated UI attempt could not acquire an active input gadget, so it did not establish physical Enter/focus behaviour. Interactive resize, copy, menu-dialog cancellation, and save/load focus still need a manual platform pass. No claim is made that those interactions passed automated UI testing.

## Commands

Run from the worktree root, with `build/` present:

```sh
export PUREBASIC_HOME=/Applications/PureBasic.app/Contents/Resources
"$PUREBASIC_HOME/compilers/pbcompiler" tests/original_tests.pb --console --output build/original-tests
./build/original-tests all
"$PUREBASIC_HOME/compilers/pbcompiler" tests/run_tests.pb --console --output build/festival-tests
./build/festival-tests all
"$PUREBASIC_HOME/compilers/pbcompiler" src/main.pb --output build/ColossalCave.app
```

The full game is compiled PureBasic. Python is used only to regenerate source during development. The earlier festival checkpoint remains on its own branch; no merge or push was performed.
