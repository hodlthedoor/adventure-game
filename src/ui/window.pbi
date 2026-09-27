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
  #ReadingFont
EndEnumeration
Procedure UI_Append(text.s)
  If text <> ""
    AddGadgetItem(#Transcript, -1, text + #LF$)
    SetGadgetState(#Transcript, CountGadgetItems(#Transcript) - 1)
  EndIf
EndProcedure
Procedure UI_Run(*w.Original::Database, *s.Original::State, *out.Original::Output)
  Protected event.i, command.s, r.Original::Output, path.s
  If Not OpenWindow(#Window, 0, 0, 1100, 780, "Colossal Cave Adventure", #PB_Window_SystemMenu | #PB_Window_MinimizeGadget | #PB_Window_MaximizeGadget | #PB_Window_SizeGadget | #PB_Window_ScreenCentered)
    ProcedureReturn
  EndIf
  WindowBounds(#Window, 640, 480, #PB_Ignore, #PB_Ignore)
  CreateMenu(#Menu, WindowID(#Window))
  MenuTitle("Game") : MenuItem(#New, "New Game") : MenuItem(#Save, "Save...") : MenuItem(#Load, "Load...") : MenuBar() : MenuItem(#Help, "Help")
  DisableMenuItem(#Menu, #Save, 1) : DisableMenuItem(#Menu, #Load, 1)
  EditorGadget(#Transcript, 16, 16, WindowWidth(#Window) - 32, WindowHeight(#Window) - 86, #PB_Editor_ReadOnly | #PB_Editor_WordWrap)
  StringGadget(#Input, 16, WindowHeight(#Window) - 56, WindowWidth(#Window) - 32, 32, "")
  If LoadFont(#ReadingFont, "Arial", 18)
    SetGadgetFont(#Transcript, FontID(#ReadingFont))
    SetGadgetFont(#Input, FontID(#ReadingFont))
  EndIf
  AddKeyboardShortcut(#Window, #PB_Shortcut_Return, #Submit)
  UI_Append(*out\text)
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
                Original::Submit(*w, *s, command, @r) : UI_Append(r\text)
              EndIf
              SetGadgetText(#Input, "") : SetActiveGadget(#Input)
            EndIf
          Case #Help
            UI_Append("Original commands include NORTH or N, ENTER, TAKE LAMP, ON, OPEN GRATE, INVENTORY, LOOK, SCORE, and QUIT. The original parser uses two words and the first five letters of each. Ordinary commands consume turns, including failed commands. Answer questions with YES or NO. Menu Help does not spend a turn.")
            SetActiveGadget(#Input)
          Case #Save, #Load
            UI_Append("Save and load are being ported; they are not available in this development build.")
          Case #New
            If MessageRequester("New game", "Discard this game and start again?", #PB_MessageRequester_YesNo) = #PB_MessageRequester_Yes
              Original::NewGame(*w, *s, Date(), @r)
              SetGadgetText(#Transcript, "") : UI_Append(r\text) : SetActiveGadget(#Input)
            EndIf
        EndSelect
    EndSelect
  Until event = #PB_Event_CloseWindow
  CloseWindow(#Window)
EndProcedure
