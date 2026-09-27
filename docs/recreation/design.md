# Colossal Cave recreation design

Recreate the original Adventure in PureBasic for Windows and macOS, preserving its actual map and behaviour while presenting it in the larger desktop text window already requested. This replaces the festival design. The classic 350-point Crowther/Woods baseline and this design were approved by the user on 2026-09-27.

## Fidelity

Port the selected reference's numbered locations, ordered conditional travel, vocabulary, objects and object properties. Match its puzzles, treasures, scoring, lamp lifetime, carrying limits, random encounters, deaths, resurrection, cave closing, and endgame. Do not carry over the festival's fairness adjustments, unlimited oil, free hint policy, or simplified movement rules.

Use original vocabulary and command processing as the authority, including motion words and the original treatment of abbreviated words. Interface Help should explain those commands. Keep any convenience aliases explicitly documented and separate from the compatibility tests.

Original contextual hints retain their original eligibility and score consequences. If `HINT` is retained as a desktop convenience, it offers an eligible original hint and displays its cost before acceptance; it does not invent free solutions.

## Desktop adaptation

Retain the scrolling transcript, keyboard command entry, 1100 by 780 initial window, and 18-point text. Save/load menus store complete game state, including random generator state and pending yes/no prompts. Reject saves from the festival game without replacing the active session.

Omit PDP-10 administrator features such as business-hour play restrictions and wizard access. Allow immediate local save/restore without time-sharing account restrictions. Document these as desktop adaptations rather than original gameplay.

## Structure

Add a dedicated original-game engine under `src/original/`. Keep source data and numeric tables separate from procedures implementing travel, actions, encounters, scoring, hints, and closing. Implement game rules in PureBasic; do not wrap a C or FORTRAN executable.

Reuse the UI through a small command/session boundary. Replace its festival-specific title, startup message, state type, and persistence calls only when the original opening sequence is playable. Preserve the festival implementation in its branch history.

Maintain a traceable mapping from source labels and data sections to PureBasic procedures. Keep original travel rules in source order. Model input continuations explicitly so questions such as accepting a hint or resurrection can return to the desktop event loop.

## Implementation sequence

1. Pin the selected reference and record provenance. Build PureBasic data loading and validate section counts, IDs, and references.
2. Port vocabulary, state initialisation, descriptions, and ordered travel. Make the opening surface and cave-entry sequence playable in the existing desktop window.
3. Port object actions and puzzles against source-labelled tests, including liquids, creatures, bridges, magic words, and treasure handling.
4. Port turn accounting, random encounters, hints, death, and scoring. Use a seedable game-owned random generator so tests and saves reproduce outcomes.
5. Port closing and endgame; implement a distinct original-game save format with validated loads.
6. Verify complete scoring walkthroughs and hazardous alternatives, then compile and exercise the desktop game on each target platform.

## Acceptance

A recognisable opening is an intermediate milestone, not a completed recreation. Completion requires the original full-score path, original failure/death cases, hint score deductions, closing and endgame, deterministic save/restore, and reference comparisons for travel and object transitions. Record deliberate desktop differences explicitly.

Local compiler: full PureBasic 6.41 macOS x64. Windows and native macOS arm64 verification remain unavailable until those environments are supplied. Do not infer platform success from shared source.

## Next review

The reference version and fidelity/adaptation boundary are approved. Review the detailed implementation plan before writing the replacement rules. Native execution and a final independent review remain the user's chosen method.
