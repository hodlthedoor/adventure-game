EnableExplicit
Enumeration
  #Playing
  #Dead
  #Won
EndEnumeration
Enumeration
  #Rejected
  #Ready
  #Clarify
EndEnumeration
Structure RoomDef
  title.s
  description.s
  dark.i
  retreatDirection.s
  Map exits.s()
EndStructure
Structure ObjectDef
  name.s
  aliases.s
  description.s
  initialRoom.s
  portable.i
  treasure.i
  requires.s
EndStructure
Structure HintDef
  room.s
  solvedFlag.s
  clue1.s
  clue2.s
  clue3.s
EndStructure
Structure WorldData
  Map rooms.RoomDef()
  Map objects.ObjectDef()
  Map hints.HintDef()
  List hintOrder.s()
EndStructure
Structure GameState
  formatVersion.i
  room.s
  turns.i
  fuel.i
  lampLit.i
  status.i
  Map objectLocations.s()
  Map flags.i()
  Map visited.i()
  Map hintLevels.i()
  Map hazardTimers.i()
EndStructure
Structure Action
  verb.s
  noun.s
  target.s
  direction.s
EndStructure
Structure ParseContext
  pending.Action
  field.s
  candidates.s
EndStructure
Structure ActionResult
  text.s
  spentTurn.i
EndStructure
