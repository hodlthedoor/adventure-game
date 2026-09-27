Procedure Content_ApplyPuzzle(*w.WorldData, *s.GameState, *a.Action, *r.ActionResult)
  Protected tool.s, old.s
  If *a\verb = "go"
    If *s\room = "garden_gate" And *a\direction = "north" And Not *s\flags("irrigated")
      *r\text = "The thirsty root holds the gate shut. Restore water, then use the irrigation tap." : ProcedureReturn #True
    EndIf
    If *s\room = "arrival_hall" And *a\direction = "south" And Not *s\flags("procession")
      *r\text = "The procession door awaits living light and the ceremonial bell." : ProcedureReturn #True
    EndIf
    If *s\room = "celebration_chamber" And *a\direction = "east" And *s\status <> #Won
      *r\text = "The balcony shutters will open when the festival begins." : ProcedureReturn #True
    EndIf
    If *s\room = "cistern_rim" And *a\direction = "east" And Not *s\flags("garden_shortcut")
      *r\text = "The shortcut is barred from the garden side." : ProcedureReturn #True
    EndIf
    If *s\room = "storeroom" And *a\direction = "west" And Not *s\flags("store_shortcut")
      *r\text = "The latch is on the nursery side." : ProcedureReturn #True
    EndIf
    If *s\room = "mushroom_grove" And *a\direction = "west" : *s\flags("garden_shortcut") = 1 : EndIf
    If *s\room = "nursery" And *a\direction = "east" : *s\flags("store_shortcut") = 1 : EndIf
    ProcedureReturn #False
  EndIf
  If *a\verb = "talk"
    *r\spentTurn = 1
    Select *a\noun
      Case "steward"
        *r\text = "'The Festival of the First Rain is only a thousand years behind schedule,' says the steward. 'The delivery chute supplied water instead of tableware. Most irregular. Please mend the waterworks, fetch the royal bell, and persuade the keeper to lend her living light.'"
      Case "keeper"
        *r\text = "'Bring me a cup and the living light is yours,' says the keeper. 'The royal stores have one. A little crown might do, though I would exchange it back for a proper cup.'"
      Default
        *r\text = "It has nothing to say."
    EndSelect
    ProcedureReturn #True
  EndIf
  If *a\verb = "take" And *a\noun = "living_light" And *s\flags("light_installed") And *s\status <> #Won
    *r\text = "The light must stay in the pedestal until the festival. You can borrow it afterward." : ProcedureReturn #True
  EndIf
  If *a\verb = "take" And *s\status = #Won
    If *a\noun = "fork" Or *a\noun = "wedge"
      *s\flags(*a\noun + "_installed") = 0
      *s\flags("braced") = Bool(*s\flags("fork_installed") Or *s\flags("wedge_installed"))
    EndIf
    ProcedureReturn #False
  EndIf
  If *a\verb = "take" And ((*a\noun = "wedge" And *s\flags("wedge_installed")) Or (*a\noun = "fork" And *s\flags("fork_installed")))
    *r\text = "That is supporting the pump. Fit the other brace first to recover it safely." : ProcedureReturn #True
  EndIf
  If *a\verb <> "use" : ProcedureReturn #False : EndIf
  *r\spentTurn = 1
  If *s\status = #Won And (*a\noun = "pump" Or *a\noun = "valve" Or *a\noun = "rainwheel" Or *a\noun = "vent" Or *a\noun = "bell")
    *r\text = "The festival is underway. Best leave its machinery in peace." : ProcedureReturn #True
  EndIf
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
  If *a\noun = "irrigation" And *a\target = ""
    If *s\flags("water")
      *s\flags("irrigated") = 1 : *r\text = "Water wakes the root. It uncoils politely and opens the garden gate."
    Else
      *r\text = "The tap is dry. Restore pressure and divert the water in the waterworks first."
    EndIf
    ProcedureReturn #True
  EndIf
  If *a\noun = "manifest" And (*a\target = "cabinet" Or *a\target = "drawer")
    If *s\objectLocations("manifest") <> "inventory"
      *r\text = "Carry the manifest to the lock first." : ProcedureReturn #True
    EndIf
    If *a\target = "cabinet"
      *s\flags("cabinet") = 1 : *r\text = "ROOT, DROP, BELL. The cabinet opens, revealing a clay cup and the ceremonial bell."
    Else
      *s\flags("crown") = 1 : *r\text = "The drawer opens. A miniature crown gleams inside."
    EndIf
    ProcedureReturn #True
  EndIf
  If (*a\noun = "cup" Or *a\noun = "crown") And *a\target = "keeper"
    tool = *a\noun
    If *s\objectLocations(tool) <> "inventory"
      *r\text = "You must be carrying it to offer it." : ProcedureReturn #True
    EndIf
    If tool = "cup" : old = "crown" : Else : old = "cup" : EndIf
    If *s\flags("light") And *s\objectLocations(old) = "keepers_hut" : *s\objectLocations(old) = "inventory" : EndIf
    *s\objectLocations(tool) = "keepers_hut" : *s\flags("light") = 1
    *r\text = "'At last!' The keeper accepts it and offers you the living light. Any previous drinking vessel is returned to you." : ProcedureReturn #True
  EndIf
  If *a\noun = "living_light" And (*a\target = "pedestal" Or *a\target = "buds")
    If *s\objectLocations("living_light") <> "inventory"
      *r\text = "Pick up the living light first." : ProcedureReturn #True
    EndIf
    If *a\target = "buds"
      *s\flags("pearl") = 1 : *r\text = "A moon bud unfolds, revealing a pearl."
    Else
      *s\objectLocations("living_light") = "arrival_hall" : *s\flags("light_installed") = 1
      *r\text = "Living light fills the pedestal. Now ring the ceremonial bell."
    EndIf
    ProcedureReturn #True
  EndIf
  If *a\noun = "seedpod" And *a\target = ""
    *s\flags("seed") = 1 : *r\text = "The watered pod opens in your hands. A glass seed drops into its hollow." : ProcedureReturn #True
  EndIf
  If *a\noun = "vent" And *a\target = ""
    *s\flags("vented") = 1 : *s\hazardTimers("flood") = 0
    *r\text = "You open the overflow vent. Pressure has a safe way out." : ProcedureReturn #True
  EndIf
  If *a\noun = "rainwheel" And *a\target = ""
    *s\flags("rain") = 1
    If *s\flags("vented")
      *r\text = "The reservoirs fill safely. All that remains is the final bell."
    Else
      If *s\hazardTimers("flood") = 0 : *s\hazardTimers("flood") = 4 : EndIf
      *r\text = "DANGER: the ceiling reservoir is swelling! Open the vent or flee NORTH twice to the hall. Three actions remain."
    EndIf
    ProcedureReturn #True
  EndIf
  If *a\noun = "bell" And *a\target = ""
    If *s\objectLocations("bell") <> "inventory"
      *r\text = "Take the bell first." : ProcedureReturn #True
    EndIf
    Select *s\room
      Case "arrival_hall"
        If *s\flags("light_installed")
          *s\flags("procession") = 1 : *r\text = "The bell answers the living light. The southern procession door opens."
        Else
          *r\text = "A hollow note. The pedestal still needs living light."
        EndIf
      Case "celebration_chamber"
        If *s\flags("vented") And *s\flags("rain") And *s\flags("water")
          *s\status = #Won : *s\flags("festival") = 1
          *s\hazardTimers("flood") = 0 : *s\hazardTimers("pump") = 0
          *r\text = "The bell rings. Rain falls in silver threads; the clay guests raise their cups. Above you, the village well runs clear. 'Precisely on time,' says the steward. YOU HAVE WON! Treasures recovered: " + Str(World_Treasures(*w, *s)) + "/5. The balcony is open. You may explore safely and collect the remaining treasures."
        Else
          *r\text = "The ceremony is not ready. Restore village water, open the vent, then admit rain before the final bell."
        EndIf
      Default
        *r\text = "The bell gives a pleasant note. It belongs at the pedestal or the ceremony."
    EndSelect
    ProcedureReturn #True
  EndIf
  *r\spentTurn = 0
  ProcedureReturn #False
EndProcedure
