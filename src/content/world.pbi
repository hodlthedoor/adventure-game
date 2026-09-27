XIncludeFile "hints.pbi"

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
  Content_LoadHints(*w)
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
  Content_Room(*w, "garden_gate", "The Thirsty Gate", "A garden gate is held shut by a thirsty root. Beside it stands an irrigation tap. A sign says: WATER FIRST, VISITORS SECOND.", 1, "south")
  Content_Room(*w, "mushroom_grove", "The Listening Grove", "Mushrooms turn toward the sound of your footsteps. A glassy seedpod hangs low. A bolt on this side opens the western shortcut to the cistern. East, a tiny kettle whistles.", 1, "south")
  Content_Room(*w, "keepers_hut", "The Keeper's Hut", "A mushroom keeper sits beneath an enormous teapot. 'A thousand years,' she says, 'and still nobody brings a cup.' A living light pulses inside a jar. The nursery lies north.", 1, "west")
  Content_Room(*w, "nursery", "The Nursery of Small Moons", "Pale buds cradle things that might be pearls. A plaque asks for living light, not lantern flame. A latch opens east into the royal stores.", 1, "south")
  Content_Room(*w, "cloakroom", "Royal Cloakroom", "Coats hang in order of their owners' importance. The smallest coat occupies the largest hook. The inventory office is east.", 1, "west")
  Content_Room(*w, "inventory_office", "Office of Very Careful Counting", "A manifest lies under a paperweight shaped like a suspicious accountant. Its symbols match the cabinet and drawer locks to the north.", 1, "west")
  Content_Room(*w, "storeroom", "The Ceremonial Stores", "A cabinet and a narrow drawer are locked by three symbol wheels. The manifest should show their order. The bell loft rises east. A nursery door to the west is latched from the far side.", 1, "south")
  Content_Room(*w, "bell_loft", "Bell Loft", "An inscription records the festival ritual. A painted crowd holds umbrellas, except for one very optimistic mole.", 1, "west")
  Content_Room(*w, "processional_passage", "Processional Passage", "The walls are lined with clay guests pretending not to stare. The ceremony chamber lies south; north leads back to the safe hall.", 1, "north")
  Content_Room(*w, "celebration_chamber", "The First Rain", "A rainwheel feeds the ceiling reservoirs. An overflow vent can relieve their pressure. A bell-shaped socket marks the final step. WARNING: vent before admitting water. If pressure rises, return NORTH twice to the hall or open the vent immediately.", 1, "north")
  Content_Room(*w, "overflow_balcony", "The Rainbow Balcony", "Fresh rain shimmers above the restored channels. On the parapet rests a crystal holding one perfectly still raindrop.", 0, "west")
  Content_Link(*w, "arrival_hall", "north", "garden_gate", "south")
  Content_Link(*w, "garden_gate", "north", "mushroom_grove", "south")
  Content_Link(*w, "mushroom_grove", "east", "keepers_hut", "west")
  Content_Link(*w, "keepers_hut", "north", "nursery", "south")
  Content_Link(*w, "arrival_hall", "east", "cloakroom", "west")
  Content_Link(*w, "cloakroom", "east", "inventory_office", "west")
  Content_Link(*w, "inventory_office", "north", "storeroom", "south")
  Content_Link(*w, "storeroom", "east", "bell_loft", "west")
  Content_Link(*w, "arrival_hall", "south", "processional_passage", "north")
  Content_Link(*w, "processional_passage", "south", "celebration_chamber", "north")
  Content_Link(*w, "celebration_chamber", "east", "overflow_balcony", "west")
  Content_Link(*w, "mushroom_grove", "west", "cistern_rim", "east")
  Content_Link(*w, "nursery", "east", "storeroom", "west")
  Content_Object(*w, "steward", "clay steward", "steward", "His invitation says EVERYONE, EVENTUALLY. TALK TO STEWARD for an explanation.", "arrival_hall")
  Content_Object(*w, "pedestal", "festival pedestal", "pedestal", "A hollow awaits living light. Install it here, then USE BELL to open the procession.", "arrival_hall")
  Content_Object(*w, "irrigation", "irrigation tap", "irrigation|tap|gate", "The gate's root needs water. Restore the supply, then USE IRRIGATION.", "garden_gate")
  Content_Object(*w, "seedpod", "glassy seedpod", "seedpod|pod", "Once the garden is watered, USE SEEDPOD to open it gently.", "mushroom_grove")
  Content_Object(*w, "keeper", "mushroom keeper", "keeper", "She wants something to drink tea from. A clay cup would do; so might a tiny crown.", "keepers_hut")
  Content_Object(*w, "living_light", "living light", "living light|light|jar", "A quiet pulse of life. It can wake nursery buds or light the festival pedestal, but cannot illuminate your route through the caves.", "keepers_hut", 1, 0, "light")
  Content_Object(*w, "buds", "moon buds", "buds|moons", "These buds open only to living light. USE LIVING LIGHT ON BUDS.", "nursery")
  Content_Object(*w, "manifest", "royal manifest", "manifest|paper", "The royal inventory marks the sequence: ROOT, DROP, BELL. USE MANIFEST ON CABINET or ON DRAWER to align their symbols.", "inventory_office", 1)
  Content_Object(*w, "cabinet", "ceremonial cabinet", "cabinet", "Its wheels show roots, drops, and bells. The office manifest gives their order.", "storeroom")
  Content_Object(*w, "drawer", "narrow drawer", "drawer", "Three symbol wheels lock the drawer, just like the cabinet.", "storeroom")
  Content_Object(*w, "cup", "clay cup", "cup", "A perfectly ordinary cup, ideal for someone who has waited centuries for tea.", "storeroom", 1, 0, "cabinet")
  Content_Object(*w, "bell", "ceremonial bell", "bell", "Ring it at the lit pedestal to start the procession. Ring it in the ceremony chamber only after venting overflow and admitting rain. USE BELL.", "storeroom", 1, 0, "cabinet")
  Content_Object(*w, "inscription", "festival inscription", "inscription|ritual", "FIRST open the overflow vent. SECOND turn the rainwheel. LAST ring the ceremonial bell. The old kingdom stopped its machinery when the pump foot broke; the steward never cancelled the invitations.", "bell_loft")
  Content_Object(*w, "vent", "overflow vent", "vent|overflow", "USE VENT before admitting rain. It also stops rising pressure in an emergency.", "celebration_chamber")
  Content_Object(*w, "rainwheel", "rainwheel", "rainwheel|wheel", "USE RAINWHEEL to admit water. The vent must be open first or pressure will become fatal.", "celebration_chamber")
  Content_Object(*w, "seed", "glass seed", "seed", "A seed containing an entire tiny greenhouse.", "mushroom_grove", 1, 1, "seed")
  Content_Object(*w, "pearl", "moon pearl", "pearl", "A little moon that has politely agreed to fit in your pocket.", "nursery", 1, 1, "pearl")
  Content_Object(*w, "crown", "miniature crown", "crown", "A silver crown small enough to use as a cup. The keeper might accept it and later exchange it for a real cup.", "storeroom", 1, 1, "crown")
  Content_Object(*w, "crystal", "rain crystal", "crystal", "One drop of the First Rain, held forever in crystal.", "overflow_balcony", 1, 1, "festival")
EndProcedure
