# Original Adventure source baseline

New branch: `feat/colossal-cave-original`, based on the preserved festival checkpoint `6c3e912`.

Approved target: classic Crowther/Woods 350-point Adventure, confirmed by the user on 2026-09-27.

## Reference

The WOOD0350 directory in Arthur O'Dwyer's historical Adventure collection contains the PDP-10 FORTRAN source and data. Its accompanying readme identifies it as the original Crowther/Woods 350-point version, rescued from the LINK-10 regression test system.

- Repository: https://github.com/Quuxplusone/Advent/tree/master/WOOD0350
- Source: https://raw.githubusercontent.com/Quuxplusone/Advent/master/WOOD0350/advent.for
- Data: https://raw.githubusercontent.com/Quuxplusone/Advent/master/WOOD0350/advent.dat
- Readme: https://raw.githubusercontent.com/Quuxplusone/Advent/master/WOOD0350/advent.readme

Retrieved on 2026-09-27 into the ignored `.superpowers/original-reference/` research directory. No upstream source has been added to the shipped game.

SHA-256:

```text
advent.for a52830ca4bcc5d508290fe89b5507d26fa55441119869e9a6dd5a736ed677fa9
advent.dat ab024845bb60f1ff753b25103de578120db307c672575e7435aeede4c9cc15ff
```

Measured from the data: 140 location IDs with long descriptions, 65 with short descriptions, 493 travel records, and 295 vocabulary records. Preserve original numeric IDs and travel ordering during translation; these are game data, not estimates of reachable rooms or unique words.

## Reuse boundary

Reuse the native window, 1100 by 780 initial size, 18-point text, menus, and general separation between UI and headless rules. Review the old parser and save format before replacing them: they encode festival-specific assumptions and are not evidence of original-game fidelity. Festival saves must be identified and rejected by the new game.

The checkpoint's 89 passing checks apply to the festival game only. Original-game correctness needs its own tests and walkthrough evidence.
