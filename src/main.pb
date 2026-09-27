XIncludeFile "game/types.pbi"
XIncludeFile "content/world.pbi"
XIncludeFile "game/world.pbi"
XIncludeFile "game/parser.pbi"
XIncludeFile "content/puzzles.pbi"
XIncludeFile "game/turns.pbi"
XIncludeFile "game/actions.pbi"
XIncludeFile "ui/window.pbi"
Define world.WorldData, state.GameState
Content_Load(@world)
World_NewGame(@world, @state)
UI_Run(@world, @state)
