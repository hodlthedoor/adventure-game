Procedure Content_Hint(*w.WorldData, id.s, room.s, solved.s, a.s, b.s, c.s)
  AddElement(*w\hintOrder()) : *w\hintOrder() = id
  *w\hints(id)\room = room : *w\hints(id)\solvedFlag = solved
  *w\hints(id)\clue1 = a : *w\hints(id)\clue2 = b : *w\hints(id)\clue3 = c
EndProcedure
Procedure Content_LoadHints(*w.WorldData)
  ClearMap(*w\hints()) : ClearList(*w\hintOrder())
  Content_Hint(*w, "pump", "pump_room", "pump", "The pump's footing looks unreliable.", "The gap beneath its broken foot needs a brace. You passed one on the landing.", "TAKE WEDGE on the landing, USE WEDGE ON PUMP, then USE PUMP. Escape EAST if it starts shaking.")
  Content_Hint(*w, "water", "valve_gallery", "water", "The village water is going somewhere else.", "The diversion valve needs steady pressure before you can turn it.", "Start the safely braced pump, then USE VALVE in this gallery.")
  Content_Hint(*w, "irrigated", "garden_gate", "irrigated", "This gate is alive, and thirsty.", "The tap needs a restored supply from the waterworks.", "After restoring the village supply, USE IRRIGATION to release the root.")
  Content_Hint(*w, "cabinet", "storeroom", "cabinet", "The cabinet symbols look like inventory marks.", "The manifest in the office gives the symbol order.", "TAKE MANIFEST in the office, then USE MANIFEST ON CABINET here. Take the cup and bell.")
  Content_Hint(*w, "light", "keepers_hut", "light", "Listen to what the keeper has been waiting for.", "She needs a drinking vessel. The royal stores may help.", "Offer a carried clay cup with USE CUP ON KEEPER, then TAKE LIVING LIGHT. A miniature crown also works.")
  Content_Hint(*w, "procession", "arrival_hall", "procession", "The pedestal and the sealed door are connected.", "The festival needs living light and a ceremonial sound.", "Bring living light from the keeper and the ceremonial bell from the royal stores. USE LIVING LIGHT ON PEDESTAL, then USE BELL.")
  Content_Hint(*w, "festival", "celebration_chamber", "festival", "A reservoir needs somewhere to release excess pressure.", "The safe order is overflow, water, then music. Venting also stops a dangerous attempt.", "USE VENT, USE RAINWHEEL, then USE BELL while carrying the ceremonial bell. Escape NORTH twice if pressure rises.")
  Content_Hint(*w, "fork", "cistern_rim", "", "Something valuable lies on the rim.", "The silver tuning fork is also a sturdy tool.", "TAKE FORK. If used as a pump brace, exchange it for the wooden wedge before taking it home.")
  Content_Hint(*w, "seed", "mushroom_grove", "seed", "The seedpod looks ready to open.", "Water has softened its seams.", "USE SEEDPOD, then TAKE SEED.")
  Content_Hint(*w, "pearl", "nursery", "pearl", "These buds need a particular kind of light.", "Lantern flame is not alive. The keeper has something better.", "Carry the living light here, USE LIVING LIGHT ON BUDS, then TAKE PEARL. If already installed, borrow it after the festival.")
  Content_Hint(*w, "crown", "storeroom", "crown", "The little drawer deserves attention too.", "Its symbols use the same system as the cabinet.", "USE MANIFEST ON DRAWER, then TAKE CROWN. Exchange a clay cup for it if you offered it to the keeper.")
  Content_Hint(*w, "crystal", "overflow_balcony", "", "Look along the parapet.", "One raindrop has become a lasting memento.", "TAKE CRYSTAL. Treasures count when carried or deposited at the well house.")
EndProcedure
