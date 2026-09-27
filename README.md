# Colossal Cave Adventure — PureBasic

A desktop recreation of the classic Crowther/Woods 350-point Adventure, using the WOOD0350 source and database. The game runs entirely in PureBasic, with a native 1100 × 780 window and 18-point text.

Development branch: `feat/colossal-cave-original`. The earlier **Festival of the First Rain** game is preserved on `feat/festival` at `6c3e912`.

## Playing

Type a command and press **Enter**. The transcript scrolls to the latest response. Try `NORTH` or `N`, `ENTER`, `TAKE LAMP`, `ON`, `OPEN GRATE`, `INVENTORY`, `LOOK`, `SCORE`, and `QUIT`. The original parser recognises two words and the first five letters of each. Answer questions with `YES` or `NO`.

Original commands spend turns, including failed commands, LOOK, and INVENTORY. The lamp runs down, hazards can kill you, and some mistakes cannot be undone. `HINT` requests an eligible original hint; hints retain their original waiting periods, confirmation, and point penalties. Automatic hint offers also remain.

Use **Game → Save / Load** for local JSON saves. Menus work at questions and after game over. `SAVE` and `LOAD` also open the dialogs at ordinary command prompts without spending a turn. Original `SUSPEND` opens Save after its normal command processing. Saves preserve the current prompt, random state, and unfinished questions. Loading restores the latest response, not the entire transcript. Festival saves are incompatible. Menu Help is free.

## Building

Open `src/main.pb` in the full PureBasic IDE and compile. Python and the historical FORTRAN compiler are not runtime dependencies. `advent.dat` is embedded, so the built application needs no separate data files.

On this Mac, using PureBasic 6.41 x64:

```sh
export PUREBASIC_HOME=/Applications/PureBasic.app/Contents/Resources
"$PUREBASIC_HOME/compilers/pbcompiler" src/main.pb --output build/ColossalCave.app
open build/ColossalCave.app
```

Create `build/` first on a fresh checkout. Windows uses the same entry point with its installed PureBasic compiler and an `.exe` output. Windows and native Mac arm64 builds have not been verified here.

## Verification and references

```sh
"$PUREBASIC_HOME/compilers/pbcompiler" tests/original_tests.pb --console --output build/original-tests
./build/original-tests all
```

Run from the repository root. Groups: `database`, `session`, `persistence`, `playthroughs`, `branches`. The retained festival suite is `tests/run_tests.pb` and tests a separate game.

See [verification](docs/recreation/verification.md), [desktop differences](docs/recreation/compatibility.md), [source mapping](docs/recreation/source-map.md), and [reference provenance](reference/wood0350/PROVENANCE.md). Original game by Will Crowther and Don Woods; historical files are from [Arthur O’Dwyer’s Adventure collection](https://github.com/Quuxplusone/Advent/tree/master/WOOD0350).
