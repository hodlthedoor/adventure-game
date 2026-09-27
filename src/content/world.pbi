Procedure Content_Room(*w.WorldData, id.s, title.s, description.s, dark.i = 0, retreat.s = "")
  *w\rooms(id)\title = title
  *w\rooms(id)\description = description
  *w\rooms(id)\dark = dark
  *w\rooms(id)\retreatDirection = retreat
EndProcedure
Procedure Content_Link(*w.WorldData, from.s, direction.s, destination.s, reverse.s)
  *w\rooms(from)\exits(direction) = destination
  *w\rooms(destination)\exits(reverse) = from
EndProcedure
Procedure Content_Object(*w.WorldData, id.s, name.s, aliases.s, description.s, room.s, portable.i = 0, treasure.i = 0, requires.s = "")
  *w\objects(id)\name = name
  *w\objects(id)\aliases = "|" + aliases + "|" + id + "|" + name + "|"
  *w\objects(id)\description = description
  *w\objects(id)\initialRoom = room
  *w\objects(id)\portable = portable
  *w\objects(id)\treasure = treasure
  *w\objects(id)\requires = requires
EndProcedure
Procedure Content_Load(*w.WorldData)
  ClearMap(*w\rooms()) : ClearMap(*w\objects())
  Content_Room(*w, "village_square", "The Empty Bucket", "The village well has returned a paper crown, three damp invitations, and absolutely no water. Someone below is having a party. The well house lies north.")
  Content_Room(*w, "well_house", "The Well House", "A bucket rests beside a sturdy ladder descending into the well. A brass lantern hangs on a peg. A notice reads: RETURN WHAT YOU BORROW. Treasure left here will be safe.")
  Content_Room(*w, "well_shaft", "The Well Shaft", "The ladder passes a chute full of rejected bunting. Far below, a voice counts teaspoons. Daylight and glowing tiles mark the way up and down.")
  Content_Room(*w, "arrival_hall", "The Hall of Expected Guests", "A clay steward straightens an invitation addressed to EVERYONE, EVENTUALLY. West: waterworks. North: gardens. East: royal stores. South: the closed procession passage. The ladder leads up. Glowing tiles make this a safe place to plan.")
  Content_Link(*w, "village_square", "north", "well_house", "south")
  Content_Link(*w, "well_house", "down", "well_shaft", "up")
  Content_Link(*w, "well_shaft", "down", "arrival_hall", "up")
  Content_Object(*w, "lantern", "brass lantern", "lamp|lantern", "An oil lantern. LIGHT LANTERN to light it, EXTINGUISH LANTERN to save fuel. The oil can in the well house can refill it.", "well_house", 1)
  Content_Room(*w, "sluice_landing", "Sluice Landing", "A loose wooden wedge props up a sign: PUMP CREW, BRACE BEFORE STARTING. The pump room lies west; the safe hall is east.", 1, "east")
  Content_Room(*w, "pump_room", "The Shivering Pump", "A vast pump leans on a cracked foot. Scratches mark where unbraced machinery once struck the walls. A service lever starts it. East is the escape to the landing; north is the valve gallery.", 1, "east")
  Content_Room(*w, "valve_gallery", "Valve Gallery", "A diversion valve is labelled VILLAGE / FESTIVAL. A plaque explains: the last festival stopped when its pump foot broke. The steward has mistaken your well for a supply chute.", 1, "south")
  Content_Room(*w, "cistern_rim", "Cistern Rim", "Water carries tiny paper boats around a still basin. A silver tuning fork rests on its broad stone rim. A barred garden shortcut lies east.", 1, "west")
  Content_Link(*w, "arrival_hall", "west", "sluice_landing", "east")
  Content_Link(*w, "sluice_landing", "west", "pump_room", "east")
  Content_Link(*w, "pump_room", "north", "valve_gallery", "south")
  Content_Link(*w, "valve_gallery", "east", "cistern_rim", "west")
  Content_Object(*w, "oil", "oil can", "oil|can", "A full oil can, connected to the village's supply barrel. USE OIL ON LANTERN here to refill it.", "well_house")
  Content_Object(*w, "wedge", "wooden wedge", "wedge", "A sturdy brace. It would fit the gap beneath the pump's cracked foot.", "sluice_landing", 1)
  Content_Object(*w, "pump", "pump", "pump|lever", "The foot is cracked. BRACE BEFORE STARTING, says the sign. USE a brace ON PUMP, then USE PUMP. Unbraced operation could kill you; east is the escape route.", "pump_room")
  Content_Object(*w, "valve", "diversion valve", "valve", "USE VALVE once the pump is running safely to restore the village supply.", "valve_gallery")
  Content_Object(*w, "fork", "silver tuning fork", "fork|tuning fork", "A silver tuning fork, stronger than it looks. It could brace the pump in place of wood.", "cistern_rim", 1, 1)
EndProcedure
