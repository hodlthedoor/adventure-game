XIncludeFile "phase_entry.pbi"
Procedure Run(*db.Database, *s.State, *out.Output)
  Protected iterations.i
  Repeat
    iterations + 1
    If iterations > 50000
      Text(*out, "Internal error: the game did not reach an input boundary.")
      *s\ended = 1 : *out\inputMode = #Ended : ProcedureReturn
    EndIf
    Select *s\phase
      XIncludeFile "phases_initialise.pbi"
      XIncludeFile "phases_encounters.pbi"
      XIncludeFile "phases_parser.pbi"
      XIncludeFile "phases_travel.pbi"
      XIncludeFile "phases_death.pbi"
      XIncludeFile "phases_actions.pbi"
      XIncludeFile "phases_hints.pbi"
      XIncludeFile "phases_closing.pbi"
      XIncludeFile "phases_scoring.pbi"
      Default
        Text(*out, "Internal error: invalid game phase.")
        *s\ended = 1 : *out\inputMode = #Ended : ProcedureReturn
    EndSelect
  ForEver
EndProcedure
Procedure ParseWords(*s.State, input.s)
  Protected first.s, second.s
  input = UCase(Left(input, 20))
  input = Trim(ReplaceString(input, #TAB$, " "))
  While FindString(input, "  ") : input = ReplaceString(input, "  ", " ") : Wend
  first = StringField(input, 1, " ") : second = StringField(input, 2, " ")
  *s\wd1 = Left(first, 5) : *s\wd1x = Mid(first, 6, 5)
  *s\wd2 = Left(second, 5) : *s\wd2x = Mid(second, 6, 5)
EndProcedure
Procedure NewGame(*db.Database, *s.State, seed.q, *out.Output)
  ResetStructure(*s, State) : ResetStructure(*out, Output)
  *s\rng = (seed & 1048575) | 1
  *s\spices = 63
  *s\phase = #InitialPhase
  Run(*db, *s, *out)
  *s\lastPrompt = *out\text
EndProcedure
Procedure.i RequestHint(*db.Database, *s.State, *out.Output)
  Protected h.i, eligible.i
  For h = 4 To *db\hntmax
    If *s\hinted[h] Or Not Bitset(*db, *s, *s\loc, h) Or *s\hintlc[h] < *db\hints[h*5+1] : Continue : EndIf
    eligible = 0
    Select h
      Case 4 : eligible = Bool(*s\prop[*s\grate] = 0 And Not Here(*db, *s, *s\keys))
      Case 5 : eligible = Bool(Here(*db, *s, *s\bird) And Toting(*db, *s, *s\rod) And *s\obj = *s\bird)
      Case 6 : eligible = Bool(Here(*db, *s, *s\snake) And Not Here(*db, *s, *s\bird))
      Case 7 : eligible = Bool(*s\atloc[*s\loc] = 0 And *s\atloc[*s\oldloc] = 0 And *s\atloc[*s\oldlc2] = 0 And *s\holdng > 1)
      Case 8 : eligible = Bool(*s\prop[*s\emrald] <> -1 And *s\prop[*s\pyram] = -1)
      Case 9 : eligible = 1
    EndSelect
    If eligible
      *s\hint = h : *s\phase = 956 : *s\awaiting = 0
      Run(*db, *s, *out) : *s\lastPrompt = *out\text : ProcedureReturn 1
    EndIf
  Next
  Text(*out, "No original hint is available yet. Hints become eligible after enough time at a particular puzzle.")
  ProcedureReturn 0
EndProcedure
Procedure Submit(*db.Database, *s.State, input.s, *out.Output)
  ResetStructure(*out, Output)
  If *s\ended
    *out\inputMode = #Ended : Text(*out, "This adventure has ended. Load a save or start a new game.") : ProcedureReturn
  EndIf
  If Trim(input) = "" Or FindString(input, #LF$) Or FindString(input, #CR$)
    *out\inputMode = Bool(*s\awaiting = 2)
    Text(*out, "Enter one command at a time.") : ProcedureReturn
  EndIf
  If *s\awaiting = 1 And *s\phase = 310 And UCase(Trim(input)) = "HINT"
    RequestHint(*db, *s, *out) : ProcedureReturn
  EndIf
  If *s\awaiting = 2
    Select UCase(StringField(Trim(input), 1, " "))
      Case "Y", "YES" : *s\answer = 1
      Case "N", "NO" : *s\answer = 0
      Default
        *out\inputMode = #Question
        Text(*out, "Please answer the question with YES or NO.") : ProcedureReturn
    EndSelect
    *s\answerReady = 1
    If *s\answer : Emit(*db, *out, 6, *s\yesMessage) : Else : Emit(*db, *out, 6, *s\noMessage) : EndIf
  Else
    ParseWords(*s, input)
  EndIf
  *s\awaiting = 0
  Run(*db, *s, *out)
  *s\lastPrompt = *out\text
EndProcedure
