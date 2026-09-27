Procedure Turns_Advance(*w.WorldData, *s.GameState, *r.ActionResult)
  *s\turns + 1
  If *s\lampLit
    *s\fuel - 1
    Select *s\fuel
      Case 20 : *r\text + #LF$ + "Your lantern is running low: 20 turns of fuel remain."
      Case 5 : *r\text + #LF$ + "Your lantern sputters: only five turns remain. Retreat toward the well house to refill it."
      Case 0 : *s\lampLit = 0 : *r\text + #LF$ + "The lantern goes out. You can still retreat along the wall."
    EndSelect
  EndIf
  If *s\room <> "pump_room" : *s\hazardTimers("pump") = 0 : EndIf
  If *s\hazardTimers("pump") > 0
    *s\hazardTimers("pump") - 1
    If *s\hazardTimers("pump") = 0
      *s\status = #Dead : *r\text + #LF$ + "The pump tears free and crushes you. Your adventure ends here. Load a save or start a new game."
    Else
      *r\text + #LF$ + "The pump shakes violently. Actions remaining: " + Str(*s\hazardTimers("pump")) + "."
    EndIf
  EndIf
EndProcedure
