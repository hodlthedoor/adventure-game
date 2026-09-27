XIncludeFile "../src/original/original.pbi"
Global failures.i, checks.i
Procedure Check(condition.i, label.s)
  checks + 1
  If Not condition : failures + 1 : PrintN("FAIL " + label) : EndIf
EndProcedure
XIncludeFile "original/database.pbi"
OpenConsole()
Define group.s = ProgramParameter()
If group = "" : group = "all" : EndIf
If group = "all" Or group = "database" : TestDatabase() : EndIf
If checks = 0 : PrintN("Unknown test group") : End 1 : EndIf
If failures : PrintN(Str(failures) + " failed / " + Str(checks)) : End 1 : EndIf
PrintN("PASS " + group + " (" + Str(checks) + " checks)")
End 0
