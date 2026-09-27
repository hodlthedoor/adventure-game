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
EndProcedure
