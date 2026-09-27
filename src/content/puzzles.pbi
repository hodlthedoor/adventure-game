Procedure Content_ApplyPuzzle(*w.WorldData, *s.GameState, *a.Action, *r.ActionResult)
  Protected tool.s, old.s
  If *a\verb = "take" And ((*a\noun = "wedge" And *s\flags("wedge_installed")) Or (*a\noun = "fork" And *s\flags("fork_installed")))
    *r\text = "That is supporting the pump. Fit the other brace first to recover it safely." : ProcedureReturn #True
  EndIf
  If *a\verb <> "use" : ProcedureReturn #False : EndIf
  *r\spentTurn = 1
  If *a\noun = "oil" And *a\target = "lantern"
    *s\fuel = 80 : *r\text = "You refill the lantern. Extinguish it first if you want to conserve every drop." : ProcedureReturn #True
  EndIf
  If *a\target = "pump" And (*a\noun = "wedge" Or *a\noun = "fork")
    tool = *a\noun
    If *s\objectLocations(tool) <> "inventory"
      *r\text = "Pick up the brace first." : ProcedureReturn #True
    EndIf
    If tool = "wedge" : old = "fork" : Else : old = "wedge" : EndIf
    If *s\flags(old + "_installed")
      *s\flags(old + "_installed") = 0 : *s\objectLocations(old) = "inventory"
    EndIf
    *s\flags(tool + "_installed") = 1 : *s\objectLocations(tool) = "pump_room"
    *s\flags("braced") = 1 : *s\hazardTimers("pump") = 0
    *r\text = "You fit the brace. The pump stands firm. Any previous brace is returned to you." : ProcedureReturn #True
  EndIf
  If *a\noun = "pump" And *a\target = ""
    If *s\flags("braced")
      *s\flags("pump") = 1 : *r\text = "The pump settles into a steady, reassuring rhythm."
    Else
      If *s\hazardTimers("pump") = 0 : *s\hazardTimers("pump") = 4 : EndIf
      *r\text = "DANGER: the unbraced pump is tearing loose! Brace it or escape EAST. Three actions before it breaks free."
    EndIf
    ProcedureReturn #True
  EndIf
  If *a\noun = "valve" And *a\target = ""
    If *s\flags("pump")
      *s\flags("water") = 1 : *r\text = "You divert water back to the village. The festival's garden feed also begins to flow."
    Else
      *r\text = "The valve will not shift without steady pump pressure."
    EndIf
    ProcedureReturn #True
  EndIf
  *r\spentTurn = 0
  ProcedureReturn #False
EndProcedure
