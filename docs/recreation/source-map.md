# Reference mapping

Database sections are decoded in `src/original/database.pbi`, preserving ordered travel and duplicate vocabulary. Message groups retain their original IDs and property variants. `random.pbi` implements the original RAN step.

The remaining control flow is being translated into resumable PureBasic phases. Every phase will retain its source line and label in a generated map, including input boundaries inside loops. This avoids restarting a turn when a question is answered or a save is restored.
