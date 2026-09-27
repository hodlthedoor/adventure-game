XIncludeFile "../src/game/types.pbi"
XIncludeFile "../src/content/world.pbi"
XIncludeFile "../src/game/world.pbi"
XIncludeFile "../src/game/parser.pbi"
XIncludeFile "../src/content/puzzles.pbi"
XIncludeFile "../src/game/turns.pbi"
XIncludeFile "../src/game/hints.pbi"
XIncludeFile "../src/game/actions.pbi"
XIncludeFile "../src/game/persistence.pbi"
Global failures.i, checks.i
Procedure Check(condition.i, label.s)
  checks + 1
  If Not condition
    failures + 1
    PrintN("FAIL " + label)
  EndIf
EndProcedure
Procedure RunCommands(*w.WorldData, *s.GameState, *c.ParseContext, commands.s, *r.ActionResult)
  Protected i.i
  For i = 1 To CountString(commands, "|") + 1
    Game_Submit(*w, *s, *c, StringField(commands, i, "|"), *r)
  Next
EndProcedure
XIncludeFile "cases/world.pbi"
XIncludeFile "cases/parser.pbi"
XIncludeFile "cases/waterworks.pbi"
XIncludeFile "cases/persistence.pbi"
XIncludeFile "cases/adventure.pbi"
XIncludeFile "cases/hints.pbi"
OpenConsole()
Define group.s = ProgramParameter()
If group = "" : group = "all" : EndIf
If group = "all" Or group = "world" : TestWorld() : EndIf
If group = "all" Or group = "parser" : TestParser() : EndIf
If group = "all" Or group = "waterworks" : TestWaterworks() : EndIf
If group = "all" Or group = "persistence" : TestPersistence() : EndIf
If group = "all" Or group = "adventure" : TestAdventure() : EndIf
If group = "all" Or group = "hints" : TestHints() : EndIf
If checks = 0 : PrintN("FAIL unknown test group") : End 1 : EndIf
If failures : PrintN(Str(failures) + " failed / " + Str(checks)) : End 1 : EndIf
PrintN("PASS " + group + " (" + Str(checks) + " checks)")
End 0
