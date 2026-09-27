; Reach meaningful checkpoints through real commands, with no puzzle flag changes.
Procedure ReplayTo(*db.Original::Database, *s.Original::State, *o.Original::Output, stopCommand.s = "", instructions.i = 0)
  Protected f.i, line.s, cmd.s
  Original::NewGame(*db, *s, 13, *o)
  f = ReadFile(#PB_Any, "tests/fixtures/original/350.txt")
  If Not f : Check(0, "branch trace available") : ProcedureReturn : EndIf
  While Not Eof(f)
    line = ReadString(f)
    If line = "" Or Left(line,1) = "#" : Continue : EndIf
    cmd = StringField(line,1,"|")
    If *s\turns = 0 And *s\awaiting = 2 And instructions : cmd = "yes" : EndIf
    Original::Submit(*db, *s, cmd, *o)
    If cmd = stopCommand : Break : EndIf
  Wend
  CloseFile(f)
EndProcedure
Procedure TestBranches()
  Protected db.Original::Database, s.Original::State, copy.Original::State, o.Original::Output, n.i, t.i, old.i
  Original::LoadDatabase(@db,@o)
  ReplayTo(@db,@s,@o,"",1)
  Check(Bool(s\score=345 And s\ended), "instructions hint deducts five from complete win")
  ReplayTo(@db,@s,@o,"kill dragon")
  Check(Bool(s\phase=717 And s\prop[31]=0), "dragon asks for bare-hand confirmation")
  RoundTrip(@db,@s,"yes","dragon confirmation")
  Check(Bool(s\prop[31]=2 And s\fixed[62]=0), "dragon killed and rug released")
  ReplayTo(@db,@s,@o,"blast")
  ; Re-run only until the first repository arrival, preserving pre-blast state.
  Original::NewGame(@db,@s,13,@o)
  n=ReadFile(#PB_Any,"tests/fixtures/original/350.txt")
  Protected line.s
  While Not Eof(n)
    line=ReadString(n)
    If line="" Or Left(line,1)="#":Continue:EndIf
    Original::Submit(@db,@s,StringField(line,1,"|"),@o)
    If s\closed:Break:EndIf
  Wend
  CloseFile(n)
  Check(Bool(s\loc=115 And s\place[23]=115 And s\fixed[23]=116 And s\holdng=0), "repository setup and confiscated inventory")
  CopyStructure(@s,@copy,Original::State)
  Send(@db,@s,"sw|take rod|blast",@o)
  Check(Bool(s\ended And s\score=330 And s\bonus=135), "blast beside dynamite gives 25-point bonus")
  CopyStructure(@copy,@s,Original::State)
  Send(@db,@s,"sw|take rod|drop rod|ne|blast",@o)
  Check(Bool(s\ended And s\score=335 And s\bonus=134), "blast from wrong end gives 30-point bonus")
  CopyStructure(@copy,@s,Original::State)
  Send(@db,@s,"take oyster|read oyster",@o)
  Check(Bool(o\inputMode=Original::#Question And s\questionmessage=192), "oyster clue asks permission")
  RoundTrip(@db,@s,"yes","oyster hint")
  Check(s\hinted[2], "oyster clue penalty recorded")
  CopyStructure(@copy,@s,Original::State)
  Original::Submit(@db,@s,"break mirror",@o)
  Check(Bool(s\ended And s\bonus=0), "breaking repository mirror awakens dwarves")
  Original::NewGame(@db,@s,13,@o)
  Send(@db,@s,"no|e|take lamp|take keys|on|xyzzy|pit|down|west|jump",@o)
  Check(Bool(s\awaiting=2 And s\questionmessage=81), "fissure jump offers resurrection")
  old=s\oldlc2 : t=s\turns
  RoundTrip(@db,@s,"yes","resurrection")
  Check(Bool(s\loc=3 And s\numdie=1 And s\place[2]=1 And s\prop[2]=0 And s\place[1]=old And s\turns=t), "resurrection restores player and drops equipment without a turn")
  Original::NewGame(@db,@s,13,@o)
  Send(@db,@s,"no|e|take lamp|on",@o)
  s\limit=1
  Original::Submit(@db,@s,"look",@o)
  Check(Bool(s\prop[2]=0 And s\limit=-1), "lamp exhausts at zero")
  Original::Submit(@db,@s,"out",@o)
  Check(s\ended, "exhausted lamp ends surface session")
  Original::NewGame(@db,@s,13,@o)
  Send(@db,@s,"no|depression",@o)
  For n=1 To 5
    If s\awaiting=2:Break:EndIf
    Original::Submit(@db,@s,"wait",@o)
  Next
  Check(Bool(s\questionmessage=62 And s\awaiting=2), "automatic grate hint after original delay")
  RoundTrip(@db,@s,"yes","hint offer")
  t=s\limit
  RoundTrip(@db,@s,"no","hint cost confirmation")
  Check(Bool(Not s\hinted[4] And s\limit=t), "declining paid hint changes neither penalty nor lamp")
EndProcedure
