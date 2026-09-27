XIncludeFile "../src/game/types.pbi"
XIncludeFile "../src/content/world.pbi"
XIncludeFile "../src/game/world.pbi"
XIncludeFile "../src/game/parser.pbi"
XIncludeFile "../src/game/actions.pbi"
Global failures.i, checks.i
Procedure Check(condition.i, label.s)
  checks + 1
  If Not condition
    failures + 1
    PrintN("FAIL " + label)
  EndIf
EndProcedure
XIncludeFile "cases/world.pbi"
XIncludeFile "cases/parser.pbi"
OpenConsole()
Define group.s = ProgramParameter()
If group = "" : group = "all" : EndIf
If group = "all" Or group = "world" : TestWorld() : EndIf
If group = "all" Or group = "parser" : TestParser() : EndIf
If checks = 0 : PrintN("FAIL unknown test group") : End 1 : EndIf
If failures : PrintN(Str(failures) + " failed / " + Str(checks)) : End 1 : EndIf
PrintN("PASS " + group + " (" + Str(checks) + " checks)")
End 0
