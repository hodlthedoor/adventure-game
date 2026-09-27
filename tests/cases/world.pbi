Procedure TestWorld()
  Protected w.WorldData, s.GameState, a.Action, r.ActionResult
  Content_Load(@w) : World_NewGame(@w, @s)
  Check(Bool(s\room = "village_square"), "new game starts in village")
  a\verb = "go" : a\direction = "north"
  Game_Apply(@w, @s, @a, @r)
  Check(Bool(s\room = "well_house"), "north follows authored exit")
  a\verb = "take" : a\noun = "lantern"
  Game_Apply(@w, @s, @a, @r)
  Check(Bool(s\objectLocations("lantern") = "inventory"), "take transfers lantern")
  Game_Apply(@w, @s, @a, @r)
  Check(Bool(r\spentTurn = 0), "duplicate take is harmless")
  a\verb = "drop" : Game_Apply(@w, @s, @a, @r)
  Check(Bool(s\objectLocations("lantern") = "well_house"), "dropped lantern recoverable")
  a\verb = "take" : Game_Apply(@w, @s, @a, @r)
  Check(Bool(s\objectLocations("lantern") = "inventory"), "recover dropped lantern")
  a\verb = "go" : a\direction = "east"
  Game_Apply(@w, @s, @a, @r)
  Check(Bool(s\room = "well_house" And s\turns = 0 And r\spentTurn = 0), "invalid exit changes nothing")
EndProcedure
