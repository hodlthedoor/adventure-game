Procedure.s StateJSON(*s.Original::State)
  Protected j.i = CreateJSON(#PB_Any), result.s
  InsertJSONStructure(JSONValue(j), *s, Original::State)
  result = ComposeJSON(j) : FreeJSON(j) : ProcedureReturn result
EndProcedure
Procedure RoundTrip(*db.Original::Database, *s.Original::State, nextInput.s, label.s)
  Protected restored.Original::State, a.Original::Output, b.Original::Output, path.s = "build/test-save-洞窟.json"
  Check(Original::Save(*s, path, @b), "save " + label)
  Check(Original::Load(*db, @restored, path, @b), "load " + label)
  Check(Bool(StateJSON(*s) = StateJSON(@restored)), "exact restore " + label)
  Original::Submit(*db, *s, nextInput, @a) : Original::Submit(*db, @restored, nextInput, @b)
  Check(Bool(StateJSON(*s) = StateJSON(@restored) And a\text = b\text And a\inputMode = b\inputMode), "continued " + label)
  DeleteFile(path)
EndProcedure
Procedure TestPersistence()
  Protected db.Original::Database, s.Original::State, o.Original::Output, before.s, f.i
  Original::LoadDatabase(@db, @o) : Original::NewGame(@db, @s, 5, @o)
  RoundTrip(@db, @s, "no", "instructions question")
  Send(@db, @s, "e|take", @o)
  RoundTrip(@db, @s, "lamp", "object clarification")
  Send(@db, @s, "on|xyzzy", @o)
  RoundTrip(@db, @s, "west", "ordinary command and RNG")
  before = StateJSON(@s)
  f = CreateFile(#PB_Any, "build/bad-save.json") : WriteString(f, "{}") : CloseFile(f)
  Check(Bool(Not Original::Load(@db, @s, "build/bad-save.json", @o) And StateJSON(@s) = before), "bad save leaves session unchanged")
  Check(Bool(Not Original::Save(@s, "build/no-such-directory/save.json", @o)), "unwritable save fails")
  DeleteFile("build/bad-save.json")
EndProcedure
