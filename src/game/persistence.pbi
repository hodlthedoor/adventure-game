Procedure Save_Number(value.i, minimum.i, maximum.i)
  If Not value : ProcedureReturn #False : EndIf
  If JSONType(value) <> #PB_JSON_Number : ProcedureReturn #False : EndIf
  Protected number.d = GetJSONDouble(value)
  ProcedureReturn Bool(number >= minimum And number <= maximum And number = Round(number, #PB_Round_Down))
EndProcedure
Procedure Save_Validate(*w.WorldData, root.i)
  Protected i.i, key.s, value.i, member.i, object.i, location.s, candidate.GameState
  If JSONType(root) <> #PB_JSON_Object : ProcedureReturn #False : EndIf
  For i = 1 To 5
    key = StringField("objectLocations|flags|visited|hintLevels|hazardTimers", i, "|")
    member = GetJSONMember(root, key)
    If Not member : ProcedureReturn #False : EndIf
    If JSONType(member) <> #PB_JSON_Object : ProcedureReturn #False : EndIf
  Next
  If Not Save_Number(GetJSONMember(root, "formatVersion"), 1, 1) : ProcedureReturn #False : EndIf
  If Not Save_Number(GetJSONMember(root, "turns"), 0, 1000000000) : ProcedureReturn #False : EndIf
  If Not Save_Number(GetJSONMember(root, "fuel"), 0, 80) : ProcedureReturn #False : EndIf
  If Not Save_Number(GetJSONMember(root, "lampLit"), 0, 1) : ProcedureReturn #False : EndIf
  If Not Save_Number(GetJSONMember(root, "status"), #Playing, #Won) : ProcedureReturn #False : EndIf
  value = GetJSONMember(root, "room")
  If Not value : ProcedureReturn #False : EndIf
  If JSONType(value) <> #PB_JSON_String : ProcedureReturn #False : EndIf
  If Not FindMapElement(*w\rooms(), GetJSONString(value)) : ProcedureReturn #False : EndIf
  object = GetJSONMember(root, "objectLocations")
  If JSONObjectSize(object) <> MapSize(*w\objects()) : ProcedureReturn #False : EndIf
  ForEach *w\objects()
    value = GetJSONMember(object, MapKey(*w\objects()))
    If Not value : ProcedureReturn #False : EndIf
    If JSONType(value) <> #PB_JSON_String : ProcedureReturn #False : EndIf
    location = GetJSONString(value)
    If location <> "inventory" And Not FindMapElement(*w\rooms(), location) : ProcedureReturn #False : EndIf
    If Not *w\objects()\portable And location <> *w\objects()\initialRoom : ProcedureReturn #False : EndIf
  Next
  For i = 1 To 4
    key = StringField("flags|visited|hintLevels|hazardTimers", i, "|")
    member = GetJSONMember(root, key)
    If ExamineJSONMembers(member)
      While NextJSONMember(member)
        key = JSONMemberKey(member) : value = JSONMemberValue(member)
        Select i
          Case 1
            If Not FindString("||braced|wedge_installed|fork_installed|pump|water|irrigated|cabinet|light|light_installed|procession|vented|rain|festival|seed|pearl|crown|garden_shortcut|store_shortcut|manifest|ritual|", "|" + key + "|") : ProcedureReturn #False : EndIf
            If Not Save_Number(value, 0, 1) : ProcedureReturn #False : EndIf
          Case 2
            If Not FindMapElement(*w\rooms(), key) : ProcedureReturn #False : EndIf
            If Not Save_Number(value, 0, 1) : ProcedureReturn #False : EndIf
          Case 3
            If Not FindMapElement(*w\hints(), key) : ProcedureReturn #False : EndIf
            If Not Save_Number(value, 0, 3) : ProcedureReturn #False : EndIf
          Case 4
            If key <> "pump" And key <> "flood" : ProcedureReturn #False : EndIf
            If Not Save_Number(value, 0, 3) : ProcedureReturn #False : EndIf
        EndSelect
      Wend
    EndIf
  Next
  ExtractJSONStructure(root, @candidate, GameState)
  If candidate\lampLit And candidate\fuel = 0 : ProcedureReturn #False : EndIf
  If Not candidate\visited(candidate\room) : ProcedureReturn #False : EndIf
  If candidate\flags("water") And Not candidate\flags("pump") : ProcedureReturn #False : EndIf
  If candidate\status <> #Won And candidate\flags("pump") And Not candidate\flags("braced") : ProcedureReturn #False : EndIf
  If candidate\flags("braced") <> Bool(candidate\flags("wedge_installed") Or candidate\flags("fork_installed")) : ProcedureReturn #False : EndIf
  If candidate\flags("wedge_installed") And candidate\flags("fork_installed") : ProcedureReturn #False : EndIf
  If candidate\flags("wedge_installed") And candidate\objectLocations("wedge") <> "pump_room" : ProcedureReturn #False : EndIf
  If candidate\flags("fork_installed") And candidate\objectLocations("fork") <> "pump_room" : ProcedureReturn #False : EndIf
  If candidate\hazardTimers("pump") And (candidate\room <> "pump_room" Or candidate\flags("braced")) : ProcedureReturn #False : EndIf
  If candidate\flags("irrigated") And Not candidate\flags("water") : ProcedureReturn #False : EndIf
  If candidate\flags("light") And Not candidate\flags("cabinet") : ProcedureReturn #False : EndIf
  If candidate\flags("light_installed") And Not candidate\flags("light") : ProcedureReturn #False : EndIf
  If candidate\flags("procession") And Not candidate\flags("light_installed") : ProcedureReturn #False : EndIf
  If candidate\flags("rain") And Not candidate\flags("procession") : ProcedureReturn #False : EndIf
  If candidate\status = #Won And Not (candidate\flags("festival") And candidate\flags("water") And candidate\flags("vented") And candidate\flags("rain") And candidate\flags("procession")) : ProcedureReturn #False : EndIf
  If candidate\flags("festival") And candidate\status <> #Won : ProcedureReturn #False : EndIf
  ProcedureReturn #True
EndProcedure
Procedure Save_Read(*w.WorldData, *s.GameState, path.s, *r.ActionResult)
  Protected j.i, candidate.GameState
  ResetStructure(*r, ActionResult)
  *r\text = "Could not load this save. It may be damaged, incompatible, or inaccessible. Your current game is unchanged."
  If FileSize(path) < 1 Or FileSize(path) > 1048576 : ProcedureReturn #False : EndIf
  j = LoadJSON(#PB_Any, path)
  If Not j : ProcedureReturn #False : EndIf
  If Not Save_Validate(*w, JSONValue(j)) : FreeJSON(j) : ProcedureReturn #False : EndIf
  ExtractJSONStructure(JSONValue(j), @candidate, GameState) : FreeJSON(j)
  CopyStructure(@candidate, *s, GameState)
  *r\text = "Game loaded." + #LF$ + World_Describe(*w, *s)
  ProcedureReturn #True
EndProcedure
Procedure Save_Write(*w.WorldData, *s.GameState, path.s, *r.ActionResult)
  Protected j.i, temp.s, backup.s, hadOriginal.i, attempt.i
  ResetStructure(*r, ActionResult)
  *r\text = "Could not save. Choose a writable folder and filename."
  If path = "" Or FileSize(path) = -2 : ProcedureReturn #False : EndIf
  Repeat
    temp = path + ".tmp-" + Str(Random(1000000000))
    backup = temp + ".backup" : attempt + 1
  Until (FileSize(temp) = -1 And FileSize(backup) = -1) Or attempt = 20
  If attempt = 20 : ProcedureReturn #False : EndIf
  j = CreateJSON(#PB_Any)
  If Not j : ProcedureReturn #False : EndIf
  InsertJSONStructure(JSONValue(j), *s, GameState)
  If Not SaveJSON(j, temp, #PB_JSON_PrettyPrint)
    FreeJSON(j) : DeleteFile(temp) : ProcedureReturn #False
  EndIf
  FreeJSON(j)
  hadOriginal = Bool(FileSize(path) >= 0)
  If hadOriginal
    If Not RenameFile(path, backup) : DeleteFile(temp) : ProcedureReturn #False : EndIf
  EndIf
  If Not RenameFile(temp, path)
    If hadOriginal And Not RenameFile(backup, path)
      *r\text = "Save replacement failed. Your previous save is preserved at: " + backup
    EndIf
    DeleteFile(temp) : ProcedureReturn #False
  EndIf
  If hadOriginal : DeleteFile(backup) : EndIf
  *r\text = "Game saved." : ProcedureReturn #True
EndProcedure
