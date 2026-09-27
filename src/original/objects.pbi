Procedure.i IDiv(a.i, b.i)
  ProcedureReturn a / b
EndProcedure
Procedure.i IMin(a.i, b.i)
  If a < b : ProcedureReturn a : EndIf
  ProcedureReturn b
EndProcedure
Procedure.i IMax(a.i, b.i)
  If a > b : ProcedureReturn a : EndIf
  ProcedureReturn b
EndProcedure
Procedure.i Vocab(*db.Database, word.s, category.i)
  ForEach *db\vocab()
    If *db\vocab()\word = word
      If category < 0 : ProcedureReturn *db\vocab()\value : EndIf
      If *db\vocab()\value / 1000 = category : ProcedureReturn *db\vocab()\value % 1000 : EndIf
    EndIf
  Next
  ProcedureReturn -1
EndProcedure
Procedure.i VocabIndex(*db.Database, index.i)
  If SelectElement(*db\vocab(), index-1) : ProcedureReturn *db\vocab()\value : EndIf
  ProcedureReturn -1
EndProcedure
Procedure.i Toting(*db.Database, *s.State, obj.i)
  ProcedureReturn Bool(*s\place[obj] = -1)
EndProcedure
Procedure.i Here(*db.Database, *s.State, obj.i)
  ProcedureReturn Bool(*s\place[obj] = *s\loc Or *s\place[obj] = -1)
EndProcedure
Procedure.i At(*db.Database, *s.State, obj.i)
  ProcedureReturn Bool(*s\place[obj] = *s\loc Or *s\fixed[obj] = *s\loc)
EndProcedure
Procedure.i Liq2(*s.State, property.i)
  ProcedureReturn (1-property)* *s\water + (property/2)*(*s\water+*s\oil)
EndProcedure
Procedure.i Liq(*db.Database, *s.State, unused.i)
  ProcedureReturn Liq2(*s, IMax(*s\prop[*s\bottle], -1-*s\prop[*s\bottle]))
EndProcedure
Procedure.i Liqloc(*db.Database, *s.State, loc.i)
  ProcedureReturn Liq2(*s, ((IDiv(*db\cond[loc], 2)*2) % 8 - 5) * (IDiv(*db\cond[loc], 4) % 2) + 1)
EndProcedure
Procedure.i Bitset(*db.Database, *s.State, loc.i, bit.i)
  ProcedureReturn Bool(*db\cond[loc] & (1 << bit))
EndProcedure
Procedure.i Forced(*db.Database, *s.State, loc.i)
  ProcedureReturn Bool(*db\cond[loc] = 2)
EndProcedure
Procedure.i Dark(*db.Database, *s.State, unused.i)
  ProcedureReturn Bool(*db\cond[*s\loc] % 2 = 0 And (*s\prop[*s\lamp] = 0 Or Not Here(*db, *s, *s\lamp)))
EndProcedure
Procedure Carry(*s.State, obj.i, loc.i)
  Protected current.i, attempts.i
  If obj <= 100
    If *s\place[obj] = -1 : ProcedureReturn : EndIf
    *s\place[obj] = -1 : *s\holdng + 1
  EndIf
  If loc <= 0 Or loc > 150 : ProcedureReturn : EndIf
  If *s\atloc[loc] = obj
    *s\atloc[loc] = *s\link[obj] : ProcedureReturn
  EndIf
  current = *s\atloc[loc]
  While current And attempts < 200
    If *s\link[current] = obj : *s\link[current] = *s\link[obj] : ProcedureReturn : EndIf
    current = *s\link[current] : attempts + 1
  Wend
EndProcedure
Procedure Drop(*s.State, obj.i, loc.i)
  If obj <= 100
    If *s\place[obj] = -1 : *s\holdng - 1 : EndIf
    *s\place[obj] = loc
  Else
    *s\fixed[obj-100] = loc
  EndIf
  If loc <= 0 : ProcedureReturn : EndIf
  *s\link[obj] = *s\atloc[loc] : *s\atloc[loc] = obj
EndProcedure
Procedure Move(*s.State, obj.i, loc.i)
  Protected from.i
  If obj <= 100 : from = *s\place[obj] : Else : from = *s\fixed[obj-100] : EndIf
  If from > 0 And from <= 150 : Carry(*s, obj, from) : EndIf
  Drop(*s, obj, loc)
EndProcedure
Procedure Dstroy(*s.State, obj.i)
  Move(*s, obj, 0)
EndProcedure
Procedure Juggle(*s.State, obj.i)
  Protected loc.i = *s\place[obj], fixed.i = *s\fixed[obj]
  Move(*s, obj, loc) : Move(*s, obj+100, fixed)
EndProcedure
Procedure.i Put(*db.Database, *s.State, obj.i, loc.i, property.i)
  Move(*s, obj, loc)
  ProcedureReturn -1-property
EndProcedure
