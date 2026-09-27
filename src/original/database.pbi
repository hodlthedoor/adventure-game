DataSection
  OriginalData:
  IncludeBinary "../../reference/wood0350/advent.dat"
  OriginalDataEnd:
EndDataSection
Procedure.i LoadDatabase(*db.Database, *out.Output)
  Protected candidate.Database, source.s, line.s, text.s, fields.s, section.i, n.i, number.i, i.i, j.i, destination.i, motion.i, previousRoom.i, object.i, property.i, key.s
  source = PeekS(?OriginalData, ?OriginalDataEnd - ?OriginalData, #PB_Ascii)
  For n = 1 To CountString(source, #LF$) + 1
    line = RemoveString(StringField(source, n, #LF$), #CR$)
    If Trim(line) = "" : Continue : EndIf
    If section = 0
      section = Val(line)
      If section = 0 : Break : EndIf
      If section < 1 Or section > 12 : *out\text = "Invalid data section." : ProcedureReturn 0 : EndIf
      Continue
    EndIf
    fields = ReplaceString(Trim(line), #TAB$, " ")
    While FindString(fields, "  ") : fields = ReplaceString(fields, "  ", " ") : Wend
    number = Val(StringField(fields, 1, " "))
    If number = -1
      If section = 3 And candidate\travelCount : candidate\travel[candidate\travelCount] = -Abs(candidate\travel[candidate\travelCount]) : EndIf
      section = 0 : Continue
    EndIf
    i = FindString(line, #TAB$)
    If i : text = Mid(line, i + 1) : Else : text = "" : EndIf
    Select section
      Case 1, 2
        If number < 1 Or number > 150 : ProcedureReturn 0 : EndIf
        If section = 1
          If candidate\longText[number] <> "" : candidate\longText[number] + #LF$ : EndIf
          candidate\longText[number] + text
        Else
          If candidate\shortText[number] <> "" : candidate\shortText[number] + #LF$ : EndIf
          candidate\shortText[number] + text
        EndIf
      Case 3
        If number < 1 Or number > 150 : ProcedureReturn 0 : EndIf
        candidate\travelRecords + 1
        If number <> previousRoom
          If candidate\travelCount : candidate\travel[candidate\travelCount] = -Abs(candidate\travel[candidate\travelCount]) : EndIf
          candidate\key[number] = candidate\travelCount + 1 : previousRoom = number
        EndIf
        destination = Val(StringField(fields, 2, " "))
        For j = 3 To CountString(fields, " ") + 1
          motion = Val(StringField(fields, j, " "))
          If candidate\travelCount >= 1000 : ProcedureReturn 0 : EndIf
          candidate\travelCount + 1
          candidate\travel[candidate\travelCount] = destination * 1000 + motion
        Next
      Case 4
        AddElement(candidate\vocab())
        candidate\vocab()\value = number : candidate\vocab()\word = Left(StringField(ReplaceString(Trim(text), #TAB$, " "), 1, " "), 5)
      Case 5
        If number > 0 And number < 100
          object = number : property = -1
        Else
          property = number / 100
        EndIf
        If object < 1 Or object > 100 : ProcedureReturn 0 : EndIf
        If property = -1
          If candidate\inventory[object] <> "" : candidate\inventory[object] + #LF$ : EndIf
          candidate\inventory[object] + text
        Else
          key = Str(object) + ":" + Str(property)
          If candidate\objectText(key) <> "" : candidate\objectText(key) + #LF$ : EndIf
          candidate\objectText(key) + text
        EndIf
      Case 6
        If number < 1 Or number > 205 : ProcedureReturn 0 : EndIf
        If candidate\randomText[number] <> "" : candidate\randomText[number] + #LF$ : EndIf
        candidate\randomText[number] + text
      Case 7
        If number < 1 Or number > 100 : ProcedureReturn 0 : EndIf
        candidate\plac[number] = Val(StringField(fields, 2, " "))
        candidate\fixd[number] = Val(StringField(fields, 3, " "))
      Case 8
        If number < 1 Or number > 35 : ProcedureReturn 0 : EndIf
        candidate\actspk[number] = Val(StringField(fields, 2, " "))
      Case 9
        For j = 2 To CountString(fields, " ") + 1
          i = Val(StringField(fields, j, " "))
          If i < 1 Or i > 150 Or number < 0 Or number > 19 : ProcedureReturn 0 : EndIf
          candidate\cond[i] = candidate\cond[i] | (1 << number)
        Next
      Case 10
        i = candidate\classes
        If i = 0 Or candidate\cval[i] <> number
          candidate\classes + 1 : i = candidate\classes
          If i > 12 : ProcedureReturn 0 : EndIf
          candidate\cval[i] = number
        Else
          candidate\classText[i] + #LF$
        EndIf
        candidate\classText[i] + text
      Case 11
        If number < 1 Or number > 19 : ProcedureReturn 0 : EndIf
        If number > candidate\hntmax : candidate\hntmax = number : EndIf
        For j = 1 To 4 : candidate\hints[number*5+j] = Val(StringField(fields, j+1, " ")) : Next
      Case 12
        If number < 1 Or number > 35 : ProcedureReturn 0 : EndIf
        If candidate\magicText[number] <> "" : candidate\magicText[number] + #LF$ : EndIf
        candidate\magicText[number] + text
    EndSelect
  Next
  For i = 1 To 150
    If candidate\key[i] And Int(Abs(candidate\travel[candidate\key[i]])) % 1000 = 1 : candidate\cond[i] = 2 : EndIf
  Next
  If candidate\travelRecords <> 493 Or ListSize(candidate\vocab()) <> 295 : ProcedureReturn 0 : EndIf
  For i = 1 To 150
    If candidate\longText[i] <> "" : candidate\ltext[i] = 1000+i : EndIf
    If candidate\shortText[i] <> "" : candidate\stext[i] = 2000+i : EndIf
  Next
  For i = 1 To 100
    If candidate\inventory[i] <> "" : candidate\ptext[i] = 5000+i : EndIf
  Next
  For i = 1 To 205
    If candidate\randomText[i] <> "" : candidate\rtext[i] = 6000+i : EndIf
  Next
  For i = 1 To 35
    If candidate\magicText[i] <> "" : candidate\mtext[i] = 12000+i : EndIf
  Next
  For i = 1 To candidate\classes : candidate\ctext[i] = 10000+i : Next
  CopyStructure(@candidate, *db, Database)
  ProcedureReturn 1
EndProcedure
