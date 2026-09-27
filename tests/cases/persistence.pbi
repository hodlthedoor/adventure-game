Procedure.s StateJSON(*s.GameState)
  Protected j.i = CreateJSON(#PB_Any), result.s
  InsertJSONStructure(JSONValue(j), *s, GameState)
  result = ComposeJSON(j)
  FreeJSON(j)
  ProcedureReturn result
EndProcedure
Procedure TestPersistence()
  Protected w.WorldData, s.GameState, restored.GameState, c.ParseContext, d.ParseContext, r.ActionResult, rr.ActionResult
  Protected path.s = GetTemporaryDirectory() + "festival-test-" + Str(Random(100000000)) + ".json", snapshot.s, j.i, root.i, f.i, n.i, malformed.s
  Content_Load(@w) : World_NewGame(@w, @s)
  RunCommands(@w, @s, @c, "n|take lantern|light lantern|d|d|w|w|use pump", @r)
  snapshot = StateJSON(@s)
  Check(Save_Write(@w, @s, path, @r), "write save")
  World_NewGame(@w, @restored)
  Check(Save_Read(@w, @restored, path, @r), "read save")
  Check(Bool(StateJSON(@restored) = snapshot), "complete mid-hazard state roundtrip")
  Game_Submit(@w, @s, @c, "wait", @r) : Game_Submit(@w, @restored, @d, "wait", @rr)
  Check(Bool(StateJSON(@s) = StateJSON(@restored) And r\text = rr\text), "restored hazard continues identically")
  For n = 1 To 9
    j = ParseJSON(#PB_Any, snapshot) : root = JSONValue(j)
    Select n
      Case 1 : RemoveJSONMember(root, "fuel")
      Case 2 : SetJSONString(GetJSONMember(root, "fuel"), "eighty")
      Case 3 : SetJSONInteger(GetJSONMember(root, "fuel"), -1)
      Case 4 : SetJSONString(GetJSONMember(root, "room"), "missing_room")
      Case 5 : SetJSONInteger(GetJSONMember(root, "status"), 99)
      Case 6 : SetJSONInteger(AddJSONMember(GetJSONMember(root, "flags"), "water"), 1)
      Case 7 : SetJSONInteger(GetJSONMember(root, "formatVersion"), 999)
      Case 8 : SetJSONInteger(AddJSONMember(GetJSONMember(root, "hazardTimers"), "pump"), -2)
      Case 9 : SetJSONString(AddJSONMember(GetJSONMember(root, "objectLocations"), "lantern"), "nowhere")
    EndSelect
    SaveJSON(j, path) : FreeJSON(j)
    malformed = StateJSON(@restored)
    Check(Bool(Not Save_Read(@w, @restored, path, @r)), "reject invalid save " + Str(n))
    Check(Bool(StateJSON(@restored) = malformed), "failed load retains state " + Str(n))
  Next
  f = CreateFile(#PB_Any, path) : WriteString(f, "{broken") : CloseFile(f)
  Check(Bool(Not Save_Read(@w, @restored, path, @r)), "reject truncated save")
  Check(Bool(Not Save_Write(@w, @s, path + "/missing/file", @r)), "unwritable path returns failure")
  DeleteFile(path)
  Check(Save_Write(@w, @s, path, @r), "create replacement baseline")
  Check(Save_Write(@w, @s, path, @r), "replace existing save")
  Check(Save_Read(@w, @restored, path, @r), "replacement remains readable")
  DeleteFile(path)
EndProcedure
