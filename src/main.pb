XIncludeFile "original/original.pbi"
XIncludeFile "ui/window.pbi"
Define world.Original::Database, state.Original::State, output.Original::Output
If Not Original::LoadDatabase(@world, @output)
  MessageRequester("Colossal Cave Adventure", "The embedded adventure database could not be loaded.")
  End 1
EndIf
Original::NewGame(@world, @state, Date(), @output)
UI_Run(@world, @state, @output)
