Procedure World_NewGame(*world.WorldData, *state.GameState)
  ClearStructure(*state, GameState)
  InitializeStructure(*state, GameState)
  *state\formatVersion = 1 : *state\room = "village_square" : *state\fuel = 80
  ForEach *world\objects()
    *state\objectLocations(MapKey(*world\objects())) = *world\objects()\initialRoom
  Next
  *state\visited(*state\room) = 1
EndProcedure
Procedure World_Lit(*w.WorldData, *s.GameState)
  If *s\status = #Won Or Not *w\rooms(*s\room)\dark : ProcedureReturn #True : EndIf
  ProcedureReturn Bool(*s\lampLit And *s\fuel > 0 And (*s\objectLocations("lantern") = "inventory" Or *s\objectLocations("lantern") = *s\room))
EndProcedure
Procedure World_CanSee(*w.WorldData, *s.GameState, id.s)
  If Not FindMapElement(*w\objects(), id) : ProcedureReturn #False : EndIf
  Protected required.s = *w\objects()\requires
  If required <> "" And Not *s\flags(required) : ProcedureReturn #False : EndIf
  If *s\objectLocations(id) = "inventory" : ProcedureReturn #True : EndIf
  ProcedureReturn Bool(*s\objectLocations(id) = *s\room And (World_Lit(*w, *s) Or id = "lantern"))
EndProcedure
Procedure.s World_Describe(*w.WorldData, *s.GameState)
  Protected text.s, id.s, exits.s
  If Not World_Lit(*w, *s)
    ProcedureReturn "It is dark. You can feel the retreat route " + *w\rooms(*s\room)\retreatDirection + ". Recover or light your lantern, or retreat to safety."
  EndIf
  *s\visited(*s\room) = 2
  text = *w\rooms(*s\room)\title + #LF$ + *w\rooms(*s\room)\description
  ForEach *w\objects()
    id = MapKey(*w\objects())
    If *s\objectLocations(id) = *s\room And (*w\objects()\requires = "" Or *s\flags(*w\objects()\requires))
      text + #LF$ + "You see " + *w\objects()\name + "."
    EndIf
  Next
  ForEach *w\rooms(*s\room)\exits()
    exits + MapKey(*w\rooms(*s\room)\exits()) + " "
  Next
  ProcedureReturn text + #LF$ + "Exits: " + Trim(exits) + "."
EndProcedure
Procedure World_Treasures(*w.WorldData, *s.GameState)
  Protected count.i, id.s
  ForEach *w\objects()
    id = MapKey(*w\objects())
    If *w\objects()\treasure And (*s\objectLocations(id) = "inventory" Or *s\objectLocations(id) = "well_house") : count + 1 : EndIf
  Next
  ProcedureReturn count
EndProcedure
