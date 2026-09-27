XIncludeFile "../src/original/original.pbi"
Global failures.i, checks.i
Procedure Check(condition.i, label.s)
  checks + 1
  If Not condition : failures + 1 : PrintN("FAIL " + label) : EndIf
EndProcedure
XIncludeFile "original/database.pbi"
XIncludeFile "original/session.pbi"
XIncludeFile "original/persistence.pbi"
XIncludeFile "original/playthroughs.pbi"
XIncludeFile "original/branches.pbi"
OpenConsole()
Define group.s = ProgramParameter()
If group = "" : group = "all" : EndIf
If group = "all" Or group = "database" : TestDatabase() : EndIf
If group = "all" Or group = "session" : TestSession() : EndIf
If group = "all" Or group = "persistence" : TestPersistence() : TestMalformedSaves() : EndIf
If group = "all" Or group = "playthroughs" : TestPlaythroughs() : EndIf
If group = "all" Or group = "branches" : TestBranches() : EndIf
If checks = 0 : PrintN("Unknown test group") : End 1 : EndIf
If failures : PrintN(Str(failures) + " failed / " + Str(checks)) : End 1 : EndIf
PrintN("PASS " + group + " (" + Str(checks) + " checks)")
End 0
