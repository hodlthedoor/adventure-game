Procedure TestHints()
  Protected w.WorldData, s.GameState, restored.GameState, c.ParseContext, r.ActionResult, first.s, third.s, turns.i, fuel.i, timer.i
  Protected path.s = GetTemporaryDirectory() + "festival-hints-" + Str(Random(10000000)) + ".json"
  Content_Load(@w) : World_NewGame(@w, @s)
  Game_Submit(@w, @s, @c, "hint", @r)
  Check(Bool(MapSize(s\hintLevels()) = 0), "no unseen puzzle hints")
  RunCommands(@w, @s, @c, "n|take lantern|light lantern|d|d|w|w|use pump", @r)
  turns = s\turns : fuel = s\fuel : timer = s\hazardTimers("pump")
  Game_Submit(@w, @s, @c, "hint", @r) : first = r\text
  Check(Bool(s\hintLevels("pump") = 1), "first clue only")
  Game_Submit(@w, @s, @c, "hint", @r)
  Check(Bool(s\hintLevels("pump") = 2 And r\text <> first), "second clue progresses")
  Save_Write(@w, @s, path, @r)
  Check(Save_Read(@w, @restored, path, @r), "hint save loads")
  Check(Bool(restored\hintLevels("pump") = 2), "revealed hint survives load")
  Game_Submit(@w, @s, @c, "hint", @r) : third = r\text
  Game_Submit(@w, @s, @c, "hint", @r)
  Check(Bool(s\hintLevels("pump") = 3 And r\text = third And third <> first), "final clue repeats without advancing")
  Check(Bool(s\turns = turns And s\fuel = fuel And s\hazardTimers("pump") = timer), "hints never spend resources")
  RunCommands(@w, @s, @c, "e|take wedge|w|use wedge on pump|use pump|n|hint", @r)
  Check(Bool(s\hintLevels("water") = 1 And s\hintLevels("pump") = 3), "local unsolved puzzle replaces solved puzzle")
  RunCommands(@w, @s, @c, "use valve|s|e|e|hint", @r)
  Check(Bool(s\hintLevels("water") = 1), "completed valve is not hinted again")
  DeleteFile(path)
EndProcedure
