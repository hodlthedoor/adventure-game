Procedure TestPlaythroughs()
  Protected db.Original::Database, s.Original::State, restored.Original::State, o.Original::Output, r.Original::Output
  Protected f.i, line.s, cmd.s, commandIndex.i, exact.i = 1, saving.i = 1, before.s
  Original::LoadDatabase(@db, @o) : Original::NewGame(@db, @s, 13, @o)
  f = ReadFile(#PB_Any, "tests/fixtures/original/350.txt")
  Check(Bool(f), "350 trace available") : If Not f : ProcedureReturn : EndIf
  While Not Eof(f)
    line = ReadString(f)
    If line = "" Or Left(line,1) = "#" : Continue : EndIf
    commandIndex + 1 : cmd = StringField(line, 1, "|")
    If Not Original::Save(@s, "build/replay.json", @r) Or Not Original::Load(@db, @restored, "build/replay.json", @r)
      If saving : PrintN("SAVE boundary failed commandIndex " + Str(commandIndex) + " phase " + Str(s\phase)) : EndIf
      saving = 0
    Else
      Original::Submit(@db, @restored, cmd, @r)
    EndIf
    Original::Submit(@db, @s, cmd, @o)
    If s\loc <> Val(StringField(line,2,"|")) Or s\turns <> Val(StringField(line,3,"|")) Or s\tally <> Val(StringField(line,4,"|")) Or s\numdie <> Val(StringField(line,5,"|"))
      If exact : PrintN("TRACE mismatch commandIndex " + Str(commandIndex) + " command " + cmd) : EndIf
      exact = 0
    EndIf
    If saving And (StateJSON(@s) <> StateJSON(@restored) Or o\text <> r\text)
      PrintN("RESTORE mismatch commandIndex " + Str(commandIndex)) : saving = 0
    EndIf
  Wend
  CloseFile(f) : DeleteFile("build/replay.json")
  Check(exact, "350 trace location, clock, treasure and death checkpoints")
  Check(saving, "save/reload every 350 trace boundary preserves next command")
  Check(Bool(s\score = 350 And s\mxscor = 350 And s\ended And s\numdie = 0 And s\bonus = 133), "full original grandmaster ending")
  RoundTrip(@db, @s, "look", "game over")
EndProcedure
