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

Procedure TestMalformedSaves()
  Protected db.Original::Database, s.Original::State, o.Original::Output, before.s
  Protected j.i, root.i, state.i, i.i, field.s, rejected.i
  Original::LoadDatabase(@db,@o) : Original::NewGame(@db,@s,13,@o) : Original::Submit(@db,@s,"no",@o)
  before=StateJSON(@s)
  For i=1 To 12
    Original::Save(@s,"build/tampered.json",@o)
    j=LoadJSON(#PB_Any,"build/tampered.json") : root=JSONValue(j) : state=GetJSONMember(root,"state")
    field=StringField("plant2|rod2|troll2|phase|rng|loc|holdng|sentinel|chain|digest|array|number",i,"|")
    Select i
      Case 1 To 7 : SetJSONInteger(GetJSONMember(state,field),1000000000)
      Case 8
        SetJSONInteger(GetJSONMember(state,"loc"),0)
        SetJSONInteger(GetJSONElement(GetJSONMember(state,"atloc"),0),1000000000)
      Case 9 : SetJSONInteger(GetJSONElement(GetJSONMember(state,"link"),1),1)
      Case 10 : SetJSONString(GetJSONMember(root,"dataDigest"),"wrong")
      Case 11 : RemoveJSONElement(GetJSONMember(state,"place"),0)
      Case 12 : SetJSONString(GetJSONMember(state,"turns"),"twelve")
    EndSelect
    SaveJSON(j,"build/tampered.json") : FreeJSON(j)
    rejected=Bool(Not Original::Load(@db,@s,"build/tampered.json",@o))
    Check(Bool(rejected And StateJSON(@s)=before),"reject malformed save: "+field)
  Next
  ; Replacement follows the existing backup pattern and yields the newer session.
  Original::Save(@s,"build/tampered.json",@o)
  Original::Submit(@db,@s,"east",@o)
  Check(Original::Save(@s,"build/tampered.json",@o),"replace existing save")
  Original::Submit(@db,@s,"out",@o)
  Check(Bool(Original::Load(@db,@s,"build/tampered.json",@o) And s\loc=3),"replacement contains new session")
  DeleteFile("build/tampered.json")
EndProcedure
