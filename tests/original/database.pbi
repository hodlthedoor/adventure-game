Procedure TestDatabase()
  Protected db.Original::Database, o.Original::Output, s.Original::State, i.i, longs.i, shorts.i, steps.i, rods.i
  Check(Original::LoadDatabase(@db, @o), "load pinned database")
  For i = 1 To 150
    If db\longText[i] <> "" : longs + 1 : EndIf
    If db\shortText[i] <> "" : shorts + 1 : EndIf
  Next
  Check(Bool(longs = 140 And shorts = 65), "original room descriptions")
  Check(Bool(db\travelRecords = 493), "all ordered travel records")
  Check(Bool(ListSize(db\vocab()) = 295), "all vocabulary records")
  ForEach db\vocab()
    If db\vocab()\word = "STEPS" : steps + 1 : EndIf
    If db\vocab()\word = "ROD" : rods + 1 : EndIf
  Next
  Check(Bool(rods = 2), "short duplicate vocabulary ignores comments")
  Check(Bool(steps = 2), "duplicate motion and object vocabulary retained")
  Check(Bool(CountString(db\longText[1], #LF$) = 2), "multiline description joined")
  Check(Bool(db\objectText("2:0") <> db\objectText("2:1") And db\objectText("2:1") <> ""), "lamp property descriptions distinct")
  Check(Bool(db\hints[4*5+2] = 2 And db\hints[3*5+2] = 5), "hint cost data")
  s\rng = 1
  Check(Bool(Original::RandomRange(@s, 100) = 0), "rng first")
  Check(Bool(Original::RandomRange(@s, 100) = 99), "rng second")
  Check(Bool(Original::RandomRange(@s, 100) = 2), "rng third")
  Check(Bool(Original::RandomRange(@s, 100) = 89), "rng fourth")
EndProcedure
