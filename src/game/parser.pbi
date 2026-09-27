Procedure.s Parser_Direction(word.s)
  Select word
    Case "n", "north" : ProcedureReturn "north"
    Case "s", "south" : ProcedureReturn "south"
    Case "e", "east" : ProcedureReturn "east"
    Case "w", "west" : ProcedureReturn "west"
    Case "u", "up" : ProcedureReturn "up"
    Case "d", "down" : ProcedureReturn "down"
  EndSelect
EndProcedure
Procedure.s Parser_Matches(*w.WorldData, *s.GameState, phrase.s, restrict.s = "")
  Protected matches.s, id.s
  ForEach *w\objects()
    id = MapKey(*w\objects())
    If FindString(*w\objects()\aliases, "|" + phrase + "|") And (restrict = "" Or FindString(restrict, "|" + id + "|"))
      If World_CanSee(*w, *s, id) : matches + "|" + id + "|" : EndIf
    EndIf
  Next
  ProcedureReturn matches
EndProcedure
Procedure Parser_Parse(*w.WorldData, *s.GameState, *c.ParseContext, input.s, *a.Action, *r.ActionResult)
  Protected verb.s, rest.s, matches.s, field.s, phrase.s, id.s, i.i, split.i, direction.s, resolved.s
  ResetStructure(*a, Action) : ResetStructure(*r, ActionResult)
  If Len(input) > 256 Or FindString(input, #LF$) Or FindString(input, #CR$)
    *r\text = "Enter one command, no more than 256 characters." : ProcedureReturn #Rejected
  EndIf
  input = LCase(Trim(ReplaceString(input, #TAB$, " ")))
  While FindString(input, "  ") : input = ReplaceString(input, "  ", " ") : Wend
  If input = "" : ProcedureReturn #Rejected : EndIf
  verb = StringField(input, 1, " ") : rest = Trim(Mid(input, Len(verb) + 1))
  direction = Parser_Direction(input)
  If direction <> ""
    *a\verb = "go" : *a\direction = direction
  Else
    Select verb
      Case "look", "l" : *a\verb = "look"
      Case "inventory", "i" : *a\verb = "inventory"
      Case "help", "hint", "wait" : *a\verb = verb
      Case "go" : *a\verb = verb : *a\direction = Parser_Direction(rest)
      Case "examine", "x", "inspect" : *a\verb = "examine" : *a\noun = rest
      Case "take", "get" : *a\verb = "take" : *a\noun = rest
      Case "drop", "light", "extinguish" : *a\verb = verb : *a\noun = rest
      Case "talk"
        *a\verb = "talk" : *a\noun = rest
        If Left(rest, 3) = "to " : *a\noun = Mid(rest, 4) : EndIf
      Case "use"
        *a\verb = "use" : split = FindString(rest, " on ")
        If split
          *a\noun = Left(rest, split - 1) : *a\target = Mid(rest, split + 4)
        Else
          *a\noun = rest
        EndIf
      Default
        If *c\field <> ""
          matches = Parser_Matches(*w, *s, input, *c\candidates)
          If CountString(matches, "|") = 2
            resolved = *c\field
            CopyStructure(@*c\pending, *a, Action)
            id = StringField(matches, 2, "|")
            If *c\field = "noun" : *a\noun = id : Else : *a\target = id : EndIf
          Else
            *r\text = "Please name one of those objects, or enter a new command." : ProcedureReturn #Clarify
          EndIf
        Else
          *r\text = "I do not understand that verb. Type HELP for command examples." : ProcedureReturn #Rejected
        EndIf
    EndSelect
  EndIf
  ResetStructure(*c, ParseContext)
  If *a\verb = "go"
    If *a\direction = "" : *r\text = "Go NORTH, SOUTH, EAST, WEST, UP, or DOWN." : ProcedureReturn #Rejected : EndIf
    ProcedureReturn #Ready
  EndIf
  If *a\verb = "look" Or *a\verb = "inventory" Or *a\verb = "help" Or *a\verb = "hint" Or *a\verb = "wait"
    If rest <> "" : *r\text = "Use " + UCase(*a\verb) + " by itself." : ProcedureReturn #Rejected : EndIf
    ProcedureReturn #Ready
  EndIf
  For i = 1 To 2
    If i = 1 : phrase = *a\noun : field = "noun" : Else : phrase = *a\target : field = "target" : EndIf
    If phrase = ""
      If i = 2 : Break : EndIf
      *r\text = "Name the object you mean." : ProcedureReturn #Rejected
    EndIf
    If field = resolved : Continue : EndIf
    matches = Parser_Matches(*w, *s, phrase)
    Select CountString(matches, "|")
      Case 0
        *r\text = "You cannot see '" + phrase + "' here." : ProcedureReturn #Rejected
      Case 2
        id = StringField(matches, 2, "|")
        If i = 1 : *a\noun = id : Else : *a\target = id : EndIf
      Default
        CopyStructure(*a, @*c\pending, Action) : *c\field = field : *c\candidates = matches
        *r\text = "Which do you mean?"
        ForEach *w\objects()
          If FindString(matches, "|" + MapKey(*w\objects()) + "|") : *r\text + " " + *w\objects()\name + ";" : EndIf
        Next
        ProcedureReturn #Clarify
    EndSelect
  Next
  ProcedureReturn #Ready
EndProcedure
