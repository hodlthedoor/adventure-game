# Reference mapping

The pinned `reference/wood0350/advent.for` is the authority. `tools/port_reference.py` translates its main program into 1,085 compiled PureBasic phases. The development script is not used by the game. Re-run it with `python3 tools/port_reference.py`; each generated case includes the original line and label. `phase-map.json` preserves the corresponding original statement.

| Source region | PureBasic implementation |
|---|---|
| Database sections 1–12 | `database.pbi`, embedded `advent.dat` |
| 1100 through initial instructions | `phases_initialise.pbi` |
| 2, 71–84 encounters | `phases_encounters.pbi` |
| 2000, 2600, 5000 input/description | `phases_parser.pbi` |
| 8 and conditional/special movement | `phases_travel.pbi` |
| 90–99 resurrection | `phases_death.pbi` |
| 8000/9000 action dispatch | `phases_actions.pbi` |
| 40000–40900 hints | `phases_hints.pbi` |
| 10000–19000 closing/lamp/repository | `phases_closing.pbi` |
| 20000–25000 score and termination | `phases_scoring.pbi` |
| SPEAK/PSPEAK/RSPEAK | `messages.pbi` |
| GETIN/YES desktop boundaries | `engine.pbi` |
| VOCAB, object chains, liquids, predicates | `objects.pbi` |
| RAN | `random.pbi` |
| Desktop session persistence | `persistence.pbi`, `save_constants.pbi` |

All implementation paths above are under `src/original/`. Logical regions share one phase switch because original handlers jump between regions. DO-loop variables live in State, so yielding for a question cannot lose a loop continuation. Known save boundaries are the two GETIN returns, eight YES sites, and terminal STOP. Validation permits the original repository mirror’s directly assigned far-side location without inventing an object-chain node.

The database preserves original numeric IDs, duplicate vocabulary, ordered travel alternatives, and property-specific messages. The game-owned random generator uses modulus 1048576 and multiplier 1021; even a range-one call advances it. It is independent of PureBasic randomness used to choose save temporary filenames.

Changes in generated code belong in the translator. Handwritten API, object helpers, persistence, and tests remain ordinary PureBasic. The map supports source audits; it does not by itself prove executable parity with a PDP-10 build.
