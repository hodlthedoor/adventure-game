Procedure Text(*out.Output, text.s, id.i = 0)
  If text = "" Or Left(text, 3) = ">$<" : ProcedureReturn : EndIf
  If *out\text <> "" : *out\text + #LF$ + #LF$ : EndIf
  *out\text + text
  AddElement(*out\events()) : *out\events()\section = 0 : *out\events()\id = id
EndProcedure
Procedure Emit(*db.Database, *out.Output, section.i, id.i, variant.i = 0)
  Protected text.s
  If id <= 0 : ProcedureReturn : EndIf
  Select section
    Case 1 : If id <= 150 : text = *db\longText[id] : EndIf
    Case 2 : If id <= 150 : text = *db\shortText[id] : EndIf
    Case 5
      If id <= 100
        If variant = -1
          text = *db\inventory[id]
        ElseIf FindMapElement(*db\objectText(), Str(id)+":"+Str(variant))
          text = *db\objectText()
        EndIf
      EndIf
    Case 6 : If id <= 205 : text = *db\randomText[id] : EndIf
    Case 10 : If id <= 12 : text = *db\classText[id] : EndIf
    Case 12 : If id <= 35 : text = *db\magicText[id] : EndIf
  EndSelect
  If text = "" Or Left(text, 3) = ">$<" : ProcedureReturn : EndIf
  Text(*out, text, id)
  *out\events()\section = section : *out\events()\variant = variant
EndProcedure
Procedure Speak(*db.Database, *out.Output, pointer.i)
  Emit(*db, *out, pointer / 1000, pointer % 1000)
EndProcedure
