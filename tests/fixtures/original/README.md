# Full-score command fixture

`350.txt` starts from NewGame seed 13 and includes the initial NO. Each row records command, resulting location, original turn count, undiscovered-treasure tally, and deaths. It completes at 350 points in 293 turns with no state injection. Dwarf combat and random passage retries are explicit commands.

Route adapted from Sean L. Palmer’s public-domain 350-point walkthrough, retrieved 2026-09-27 from https://raw.githubusercontent.com/wh0am1-dev/adventure/master/walkthroughs/walkthrough2.txt. The source walkthrough requires manual responses to random events. This fixture records an actual deterministic run of this port, not an independently captured PDP-10 transcript.

The playthrough test checks every row, saves/restores each input boundary, and compares subsequent state and output. Separate branch tests cover a 345-point instructions route, resurrection, hint decisions, dragon confirmation, and alternate endgame bonuses.
