Procedure Send(*db.Original::Database, *s.Original::State, commands.s, *o.Original::Output)
  Protected i.i
  For i = 1 To CountString(commands, "|") + 1
    Original::Submit(*db, *s, StringField(commands, i, "|"), *o)
  Next
EndProcedure
Procedure TestSession()
  Protected db.Original::Database, s.Original::State, o.Original::Output, t.i
  Original::LoadDatabase(@db, @o) : Original::NewGame(@db, @s, 1, @o)
  Check(Bool(o\inputMode = Original::#Question), "instructions question")
  Original::Submit(@db, @s, "no", @o)
  Check(Bool(s\loc = 1 And s\limit = 330 And s\turns = 0), "original normal opening")
  Send(@db, @s, "enter|take keys|take lamp|on|xyzzy", @o)
  Check(Bool(s\loc = 11 And s\place[1] = -1 And s\place[2] = -1 And s\prop[2] = 1), "building supplies and magic travel")
  t = s\turns : Original::Submit(@db, @s, "gobbledygook", @o)
  Check(Bool(s\turns = t+1), "unknown command counts turn")
  t = s\limit : Send(@db, @s, "look|inventory", @o)
  Check(Bool(s\limit = t-2), "look and inventory consume original lamp time")
  Original::NewGame(@db, @s, 1, @o) : Original::Submit(@db, @s, "yes", @o)
  Check(Bool(s\hinted[3] And s\limit = 1000 And s\turns = 0), "instructions affect lamp and score without a turn")
  Send(@db, @s, "enter|take|lamp", @o)
  Check(Bool(s\place[2] = -1), "verb-only continuation")
  Original::NewGame(@db, @s, 1, @o) : Send(@db, @s, "no|enter|keys|take", @o)
  Check(Bool(s\place[1] = -1), "noun-first continuation")
  Original::NewGame(@db, @s, 1, @o) : Send(@db, @s, "no|enter|take keys|take lamp|on|out|depression|open grate|down", @o)
  Check(Bool(s\loc = 9 And s\prop[3] = 1), "open grate and descend")
  Original::NewGame(@db, @s, 1, @o)
  s\wd1 = "PRESERVED"
  Original::Submit(@db, @s, "no", @o)
  Check(Bool(s\wd1 = "PRESERVED"), "yes/no has separate input buffer")
  Original::NewGame(@db, @s, 1, @o) : Send(@db, @s, "no|depression", @o)
  t = s\turns : Original::Submit(@db, @s, "hint", @o)
  Check(Bool(s\turns = t And o\inputMode = Original::#Command), "HINT without eligibility is free and gives no clue")
  s\hintlc[4] = db\hints[4*5+1]
  Original::Submit(@db, @s, "hint", @o)
  Check(Bool(o\inputMode = Original::#Question And s\questionmessage = 62), "eligible HINT uses original offer")
  Original::Submit(@db, @s, "yes", @o)
  Check(Bool(s\questionmessage = 175 And Not s\hinted[4]), "hint cost requires separate consent")
  Original::Submit(@db, @s, "yes", @o)
  Check(Bool(s\hinted[4] And s\turns = t And s\limit = 390), "accepted grate hint costs original points and extends lamp")
EndProcedure
