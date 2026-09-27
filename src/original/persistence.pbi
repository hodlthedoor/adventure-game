#DataDigest = "ab024845bb60f1ff753b25103de578120db307c672575e7435aeede4c9cc15ff"
; Check every member and fixed array before ExtractJSONStructure can coerce it.
Procedure.i SameShape(value.i, model.i)
  Protected i.i, member.i, number.d
  If Not value Or JSONType(value) <> JSONType(model) : ProcedureReturn 0 : EndIf
  Select JSONType(model)
    Case #PB_JSON_Object
      If JSONObjectSize(value) <> JSONObjectSize(model) : ProcedureReturn 0 : EndIf
      If ExamineJSONMembers(model)
        While NextJSONMember(model)
          member = GetJSONMember(value, JSONMemberKey(model))
          If Not SameShape(member, JSONMemberValue(model)) : ProcedureReturn 0 : EndIf
        Wend
      EndIf
    Case #PB_JSON_Array
      If JSONArraySize(value) <> JSONArraySize(model) : ProcedureReturn 0 : EndIf
      For i = 0 To JSONArraySize(model)-1
        If Not SameShape(GetJSONElement(value, i), GetJSONElement(model, i)) : ProcedureReturn 0 : EndIf
      Next
    Case #PB_JSON_Number
      number = GetJSONDouble(value)
      If number < -1000000000 Or number > 1000000000 Or number <> Round(number, #PB_Round_Down) : ProcedureReturn 0 : EndIf
    Case #PB_JSON_String
      If Len(GetJSONString(value)) > 65536 : ProcedureReturn 0 : EndIf
  EndSelect
  ProcedureReturn 1
EndProcedure
Procedure.i ValidState(*db.Database, *s.State)
  Protected i.i, room.i, obj.i, count.i, q.i, y.i, n.i, initial.State, output.Output
  Dim seen.i(200)
  If *s\rng < 1 Or *s\rng > 1048575 Or (*s\rng & 1) = 0 : ProcedureReturn 0 : EndIf
  If *s\loc < 0 Or *s\loc > 140 Or *s\oldloc < 0 Or *s\oldloc > 140 Or *s\oldlc2 < 0 Or *s\oldlc2 > 140 Or *s\newloc < 0 Or *s\newloc > 140 : ProcedureReturn 0 : EndIf
  If *s\numdie < 0 Or *s\numdie > 3 Or *s\holdng < 0 Or *s\holdng > 7 Or *s\turns < 0 Or *s\abbnum < 1 : ProcedureReturn 0 : EndIf
  If *s\hint < 0 Or *s\hint > *db\hntmax+1 Or *s\obj < 0 Or *s\obj > 100 : ProcedureReturn 0 : EndIf
  If *s\tally < 0 Or *s\tally > 15 Or *s\tally2 < 0 Or *s\tally2 > 15 Or *s\dflag < 0 Or *s\dflag > 1000000 : ProcedureReturn 0 : EndIf
  If *s\answerready Or *s\ended < 0 Or *s\ended > 1 : ProcedureReturn 0 : EndIf
  If *s\ended
    If *s\awaiting <> 0 Or *s\phase <> #PhaseCount+1 : ProcedureReturn 0 : EndIf
  ElseIf *s\awaiting = 1
    If *s\phase <> 310 And *s\phase <> 717 : ProcedureReturn 0 : EndIf
  ElseIf *s\awaiting = 2
    Select *s\phase
      Case 148 : q = 65 : y = 1 : n = 0
      Case 499 : q = 81+*s\numdie*2 : y = q+1 : n = 54
      Case 812 : q = 22 : y = 54 : n = 54
      Case 892 : q = 143 : y = 54 : n = 54
      Case 925 : q = 192 : y = 193 : n = 54
      Case 943 : q = 200 : y = 54 : n = 54
      Case 957, 959
        If *s\hint < 4 Or *s\hint > *db\hntmax : ProcedureReturn 0 : EndIf
        If *s\phase = 957
          q = *db\hints[*s\hint*5+3] : y = 0 : n = 54
        Else
          q = 175 : y = *db\hints[*s\hint*5+4] : n = 54
        EndIf
      Default : ProcedureReturn 0
    EndSelect
    If *s\questionmessage <> q Or *s\yesmessage <> y Or *s\nomessage <> n : ProcedureReturn 0 : EndIf
  Else
    ProcedureReturn 0
  EndIf
  ; Object IDs, vocabulary constants, and source dimensions are not mutable save data.
  NewGame(*db, @initial, 1, @output)
  XIncludeFile "save_constants.pbi"
  For i = 0 To 100
    If *s\place[i] < -1 Or *s\place[i] > 140 Or *s\fixed[i] < -1 Or *s\fixed[i] > 140 Or *s\prop[i] < -3 Or *s\prop[i] > 6 : ProcedureReturn 0 : EndIf
    If *s\place[i] = -1 And i <> *s\water And i <> *s\oil : count + 1 : EndIf
  Next
  If count <> *s\holdng : ProcedureReturn 0 : EndIf
  For room = 1 To 150
    obj = *s\atloc[room]
    While obj
      If obj < 1 Or obj > 200 : ProcedureReturn 0 : EndIf
      If seen(obj) : ProcedureReturn 0 : EndIf
      seen(obj) = 1
      If obj <= 100
        If *s\place[obj] <> room : ProcedureReturn 0 : EndIf
      Else
        If *s\fixed[obj-100] <> room : ProcedureReturn 0 : EndIf
      EndIf
      obj = *s\link[obj]
    Wend
  Next
  For i = 1 To 100
    If *s\place[i] > 0 And Not seen(i) : ProcedureReturn 0 : EndIf
    ; Original label 11000 assigns the repository mirror's far side directly,
    ; without adding its secondary node to ATLOC.
    If *s\fixed[i] > 0 And Not seen(i+100)
      If Not (*s\closed And i = *s\mirror And *s\fixed[i] = 116) : ProcedureReturn 0 : EndIf
    EndIf
  Next
  For i = 0 To 200
    If *s\link[i] < 0 Or *s\link[i] > 200 : ProcedureReturn 0 : EndIf
  Next
  For i = 0 To 6
    If *s\dloc[i] < 0 Or *s\dloc[i] > 140 Or *s\odloc[i] < 0 Or *s\odloc[i] > 140 Or *s\dseen[i] < 0 Or *s\dseen[i] > 1 : ProcedureReturn 0 : EndIf
  Next
  For i = 0 To 20
    If *s\hinted[i] < 0 Or *s\hinted[i] > 1 Or *s\hintlc[i] < -1 : ProcedureReturn 0 : EndIf
  Next
  ProcedureReturn 1
EndProcedure
Procedure.i Load(*db.Database, *s.State, path.s, *out.Output)
  Protected j.i, model.i, envelope.SaveEnvelope, template.SaveEnvelope, ok.i
  ResetStructure(*out, Output)
  Text(*out, "Could not load this save. It may be damaged, incompatible, or inaccessible. Your current game is unchanged.")
  If FileSize(path) < 1 Or FileSize(path) > 1048576 : ProcedureReturn 0 : EndIf
  j = LoadJSON(#PB_Any, path) : If Not j : ProcedureReturn 0 : EndIf
  model = CreateJSON(#PB_Any)
  If Not model : FreeJSON(j) : ProcedureReturn 0 : EndIf
  InsertJSONStructure(JSONValue(model), @template, SaveEnvelope)
  ok = SameShape(JSONValue(j), JSONValue(model)) : FreeJSON(model)
  If Not ok : FreeJSON(j) : ProcedureReturn 0 : EndIf
  ExtractJSONStructure(JSONValue(j), @envelope, SaveEnvelope) : FreeJSON(j)
  If envelope\game <> "crowther-woods-350" Or envelope\formatVersion <> 1 Or envelope\dataDigest <> #DataDigest : ProcedureReturn 0 : EndIf
  If Not ValidState(*db, @envelope\state) : ProcedureReturn 0 : EndIf
  CopyStructure(@envelope\state, *s, State)
  ResetStructure(*out, Output)
  *out\text = *s\lastPrompt
  If *s\ended : *out\inputMode = #Ended : Else : *out\inputMode = Bool(*s\awaiting = 2) : EndIf
  ProcedureReturn 1
EndProcedure
Procedure.i Save(*s.State, path.s, *out.Output)
  Protected j.i, temp.s, backup.s, hadOriginal.i, attempt.i, envelope.SaveEnvelope
  ResetStructure(*out, Output)
  Text(*out, "Could not save. Choose a writable folder and filename.")
  If path = "" Or FileSize(path) = -2 : ProcedureReturn 0 : EndIf
  Repeat
    temp = path + ".tmp-" + Str(Random(1000000000))
    backup = temp + ".backup" : attempt + 1
  Until (FileSize(temp) = -1 And FileSize(backup) = -1) Or attempt = 20
  If attempt = 20 : ProcedureReturn 0 : EndIf
  j = CreateJSON(#PB_Any) : If Not j : ProcedureReturn 0 : EndIf
  envelope\game = "crowther-woods-350" : envelope\formatVersion = 1 : envelope\dataDigest = #DataDigest
  CopyStructure(*s, @envelope\state, State)
  InsertJSONStructure(JSONValue(j), @envelope, SaveEnvelope)
  If Not SaveJSON(j, temp, #PB_JSON_PrettyPrint)
    FreeJSON(j) : DeleteFile(temp) : ProcedureReturn 0
  EndIf
  FreeJSON(j)
  hadOriginal = Bool(FileSize(path) >= 0)
  If hadOriginal
    If Not RenameFile(path, backup) : DeleteFile(temp) : ProcedureReturn 0 : EndIf
  EndIf
  If Not RenameFile(temp, path)
    If hadOriginal And Not RenameFile(backup, path)
      *out\text = "Save replacement failed. Your previous save is preserved at: " + backup
    EndIf
    DeleteFile(temp) : ProcedureReturn 0
  EndIf
  If hadOriginal : DeleteFile(backup) : EndIf
  *out\text = "Game saved." : ProcedureReturn 1
EndProcedure
