Enumeration
  #Window
  #Transcript
  #Input
  #Menu
  #New
  #Save
  #Load
  #Help
  #Submit
EndEnumeration
Procedure UI_Append(text.s)
  If text <> ""
    AddGadgetItem(#Transcript, -1, text + #LF$)
    SetGadgetState(#Transcript, CountGadgetItems(#Transcript) - 1)
  EndIf
EndProcedure
Procedure UI_Run(*w.WorldData, *s.GameState)
  Protected event.i, command.s, r.ActionResult, c.ParseContext, a.Action
  If Not OpenWindow(#Window, 0, 0, 900, 650, "Festival of the First Rain", #PB_Window_SystemMenu | #PB_Window_MinimizeGadget | #PB_Window_MaximizeGadget | #PB_Window_SizeGadget | #PB_Window_ScreenCentered)
    ProcedureReturn
  EndIf
  WindowBounds(#Window, 640, 480, #PB_Ignore, #PB_Ignore)
  CreateMenu(#Menu, WindowID(#Window))
  MenuTitle("Game") : MenuItem(#New, "New Game") : MenuItem(#Save, "Save...") : MenuItem(#Load, "Load...") : MenuBar() : MenuItem(#Help, "Help")
  DisableMenuItem(#Menu, #Save, 1) : DisableMenuItem(#Menu, #Load, 1)
  EditorGadget(#Transcript, 16, 16, WindowWidth(#Window) - 32, WindowHeight(#Window) - 86, #PB_Editor_ReadOnly | #PB_Editor_WordWrap)
  StringGadget(#Input, 16, WindowHeight(#Window) - 56, WindowWidth(#Window) - 32, 32, "")
  AddKeyboardShortcut(#Window, #PB_Shortcut_Return, #Submit)
  UI_Append("FESTIVAL OF THE FIRST RAIN" + #LF$ + "An underground adventure. Type HELP for commands. Save often; heed the warnings.")
  UI_Append(World_Describe(*w, *s))
  SetActiveGadget(#Input)
  Repeat
    event = WaitWindowEvent()
    Select event
      Case #PB_Event_SizeWindow
        ResizeGadget(#Transcript, 16, 16, WindowWidth(#Window) - 32, WindowHeight(#Window) - 86)
        ResizeGadget(#Input, 16, WindowHeight(#Window) - 56, WindowWidth(#Window) - 32, 32)
      Case #PB_Event_Menu
        Select EventMenu()
          Case #Submit
            If GetActiveGadget() = #Input
              command = GetGadgetText(#Input)
              If Trim(command) <> ""
                UI_Append("> " + command)
                Game_Submit(*w, *s, @c, command, @r) : UI_Append(r\text)
              EndIf
              SetGadgetText(#Input, "") : SetActiveGadget(#Input)
            EndIf
          Case #Help
            a\verb = "help" : Game_Apply(*w, *s, @a, @r) : UI_Append(r\text) : SetActiveGadget(#Input)
          Case #New
            If MessageRequester("New game", "Discard this game and start again?", #PB_MessageRequester_YesNo) = #PB_MessageRequester_Yes
              World_NewGame(*w, *s) : ResetStructure(@c, ParseContext)
              SetGadgetText(#Transcript, "") : UI_Append(World_Describe(*w, *s)) : SetActiveGadget(#Input)
            EndIf
        EndSelect
    EndSelect
  Until event = #PB_Event_CloseWindow
  CloseWindow(#Window)
EndProcedure
