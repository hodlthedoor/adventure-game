Procedure Game_Apply(*w.WorldData, *s.GameState, *a.Action, *r.ActionResult)
  Protected destination.s, text.s, id.s
  ClearStructure(*r, ActionResult)
  If *s\status = #Dead And *a\verb <> "help" And *a\verb <> "inventory"
    *r\text = "Your adventure has ended. Use the Game menu to load a save or start again." : ProcedureReturn
  EndIf
  If Not World_Lit(*w, *s)
    If *a\verb = "go" And *a\direction <> *w\rooms(*s\room)\retreatDirection
      *r\text = "It is too dark. Retreat " + *w\rooms(*s\room)\retreatDirection + "." : ProcedureReturn
    EndIf
    If *a\verb = "use" Or *a\verb = "talk" Or (*a\verb = "take" And *a\noun <> "lantern")
      *r\text = "You need your lantern for that. You can still retreat." : ProcedureReturn
    EndIf
  EndIf
  If Content_ApplyPuzzle(*w, *s, *a, *r) : ProcedureReturn : EndIf
  Select *a\verb
    Case "light", "extinguish"
      If *a\noun <> "lantern"
        *r\text = "Only the lantern can be lit or extinguished."
      ElseIf *a\verb = "light" And *s\fuel = 0
        *r\text = "The lantern needs oil from the well house."
      Else
        *s\lampLit = Bool(*a\verb = "light") : *r\spentTurn = 1
        If *s\lampLit : *r\text = "The lantern casts a warm circle of light." : Else : *r\text = "You extinguish the lantern." : EndIf
      EndIf
    Case "help"
      *r\text = "GO NORTH (or N), SOUTH, EAST, WEST, UP, DOWN; LOOK; EXAMINE object; TAKE object; DROP object; USE object ON target; TALK TO person; INVENTORY; LIGHT LANTERN; EXTINGUISH LANTERN; WAIT; HINT. Save often using the Game menu. Reading and hints cost no turns."
    Case "hint"
      Hints_Reveal(*w, *s, *r)
    Case "wait"
      *r\text = "A moment passes." : *r\spentTurn = 1
    Case "go"
      destination = *w\rooms(*s\room)\exits(*a\direction)
      If destination = ""
        *r\text = "There is no exit that way." : ProcedureReturn
      EndIf
      *s\room = destination
      If Not *s\visited(destination) : *s\visited(destination) = 1 : EndIf
      *r\text = World_Describe(*w, *s) : *r\spentTurn = 1
    Case "look"
      *r\text = World_Describe(*w, *s)
    Case "inventory"
      *r\text = "You are carrying:"
      ForEach *s\objectLocations()
        If *s\objectLocations() = "inventory"
          *r\text + #LF$ + *w\objects(MapKey(*s\objectLocations()))\name
        EndIf
      Next
      *r\text + #LF$ + "Lantern fuel: " + Str(*s\fuel) + ". Treasures recovered: " + Str(World_Treasures(*w, *s)) + "/5."
    Case "examine", "take", "drop"
      If Not World_CanSee(*w, *s, *a\noun)
        *r\text = "You cannot see that here." : ProcedureReturn
      EndIf
      Select *a\verb
        Case "examine"
          *r\text = *w\objects(*a\noun)\description
        Case "take"
          If *s\objectLocations(*a\noun) = "inventory"
            *r\text = "You already have it."
          ElseIf Not *w\objects(*a\noun)\portable
            *r\text = "That must stay where it is."
          Else
            *s\objectLocations(*a\noun) = "inventory" : *r\text = "Taken." : *r\spentTurn = 1
          EndIf
        Case "drop"
          If *s\objectLocations(*a\noun) <> "inventory"
            *r\text = "You are not carrying it."
          Else
            *s\objectLocations(*a\noun) = *s\room : *r\text = "Dropped." : *r\spentTurn = 1
          EndIf
      EndSelect
    Default
      *r\text = "That action is not available yet."
  EndSelect
EndProcedure
Procedure Game_Submit(*w.WorldData, *s.GameState, *c.ParseContext, input.s, *r.ActionResult)
  Protected a.Action
  If Parser_Parse(*w, *s, *c, input, @a, *r) <> #Ready : ProcedureReturn : EndIf
  Game_Apply(*w, *s, @a, *r)
  If *r\spentTurn And *s\status = #Playing : Turns_Advance(*w, *s, *r) : EndIf
EndProcedure
