# Desktop adaptations

The reference is Crowther/Woods WOOD0350, pinned in `reference/wood0350/`.

- Native desktop window, enlarged text, selectable transcript, and local file dialogs replace terminal I/O.
- Business-hour restrictions, wizard administration, and suspension delays are omitted.
- A new session starts with an explicit nonzero random seed; subsequent draws use the original generator and call order.
- HINT may request an already eligible original hint. Accepting still requires confirmation and retains its original score cost.
- Menu Help and invalid multiline desktop input do not enter the original command clock.

Original commands, including unsuccessful commands, retain original timing. Do not interpret modern presentation as changes to puzzle fairness.

- `SAVE` and `LOAD` at ordinary command prompts are desktop commands with no game turn. `SUSPEND` retains its original command-clock cost before opening Save. Menus remain usable during questions and after termination.
- The saved display is the latest game response/prompt, not a full transcript. Restoring never re-executes description or random-event phases.
- Input is Unicode desktop text, case-normalised, with tabs treated as spaces. Empty/multiline submissions do not enter gameplay. Recognition retains the first 20 input characters and first five characters of each of two words.
- SPICES is explicitly initialised to vocabulary object 63. The pinned main program references that mnemonic without initialising it, making the original lost-spice tally undefined.
- Dynamic numeric sentences use ordinary decimal formatting rather than FORTRAN fixed-width padding; original database prose remains intact.
