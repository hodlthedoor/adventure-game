Procedure Hints_Reveal(*w.WorldData, *s.GameState, *r.ActionResult)
  Protected id.s, selected.s, room.s, solved.s, pass.i, level.i
  ResetStructure(*r, ActionResult)
  For pass = 1 To 2
    ForEach *w\hintOrder()
      id = *w\hintOrder() : room = *w\hints(id)\room : solved = *w\hints(id)\solvedFlag
      If *s\visited(room) < 2 : Continue : EndIf
      If pass = 1 And room <> *s\room : Continue : EndIf
      If solved <> ""
        If *s\flags(solved) : Continue : EndIf
      Else
        If *s\objectLocations(id) = "inventory" Or *s\objectLocations(id) = "well_house" : Continue : EndIf
      EndIf
      selected = id : Break
    Next
    If selected <> "" : Break : EndIf
  Next
  If selected = ""
    *r\text = "No hint is available here. Explore the exits or examine what you can see." : ProcedureReturn
  EndIf
  level = *s\hintLevels(selected) + 1
  If level > 3 : level = 3 : EndIf
  *s\hintLevels(selected) = level
  *r\text = "Hint " + Str(level) + "/3: " + *w\rooms(*w\hints(selected)\room)\title + #LF$
  Select level
    Case 1 : *r\text + *w\hints(selected)\clue1
    Case 2 : *r\text + *w\hints(selected)\clue2
    Case 3 : *r\text + *w\hints(selected)\clue3
  EndSelect
  If selected = "light" And Not *s\visited("storeroom") And level = 3
    *r\text = "The keeper wants a cup. Explore the royal stores east of the hall and look for a drinking vessel."
  EndIf
  If selected = "procession" And level = 3 And (Not *s\flags("light") Or Not *s\flags("cabinet"))
    *r\text = "The procession needs living light and a ceremonial bell. Explore the gardens and royal stores from the hall; ask their inhabitants and examine the objects there."
  EndIf
  If level < 3 : *r\text + #LF$ + "Type HINT again for a stronger clue." : EndIf
EndProcedure
