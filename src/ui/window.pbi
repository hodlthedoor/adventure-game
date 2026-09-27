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
Procedure UI_Run(*w.WorldData, *s.GameState)
  Protected event.i, command.s, r.ActionResult, c.ParseContext, a.Action, path.s
  If Not OpenWindow(#Window, 0, 0, 1100, 780, "Festival of the First Rain", #PB_Window_SystemMenu | #PB_Window_MinimizeGadget | #PB_Window_MaximizeGadget | #PB_Window_SizeGadget | #PB_Window_ScreenCentered)
    ProcedureReturn
  EndIf
  WindowBounds(#Window, 640, 480, #PB_Ignore, #PB_Ignore)
  CreateMenu(#Menu, WindowID(#Window))
  MenuTitle("Game") : MenuItem(#New, "New Game") : MenuItem(#Save, "Save...") : MenuItem(#Load, "Load...") : MenuBar() : MenuItem(#Help, "Help")
  EditorGadget(#Transcript, 16, 16, WindowWidth(#Window) - 32, WindowHeight(#Window) - 86, #PB_Editor_ReadOnly | #PB_Editor_WordWrap)
  StringGadget(#Input, 16, WindowHeight(#Window) - 56, WindowWidth(#Window) - 32, 32, "")
  If LoadFont(#ReadingFont, "Arial", 18)
    SetGadgetFont(#Transcript, FontID(#ReadingFont))
    SetGadgetFont(#Input, FontID(#ReadingFont))
  EndIf
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
          Case #Save
            path = SaveFileRequester("Save adventure", GetUserDirectory(#PB_Directory_Documents) + "festival.adventure-save", "Adventure save|*.adventure-save", 0)
            If path <> ""
              If FileSize(path) < 0 Or MessageRequester("Replace save", "Replace this existing save?", #PB_MessageRequester_YesNo) = #PB_MessageRequester_Yes
                Save_Write(*w, *s, path, @r) : UI_Append(r\text)
              EndIf
            EndIf
            SetActiveGadget(#Input)
          Case #Load
            path = OpenFileRequester("Load adventure", GetUserDirectory(#PB_Directory_Documents), "Adventure save|*.adventure-save|All files|*.*", 0)
            If path <> ""
              If MessageRequester("Load game", "Discard current progress and load this save?", #PB_MessageRequester_YesNo) = #PB_MessageRequester_Yes
                If Save_Read(*w, *s, path, @r)
                  ResetStructure(@c, ParseContext) : SetGadgetText(#Transcript, "")
                EndIf
                UI_Append(r\text)
              EndIf
            EndIf
            SetActiveGadget(#Input)
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
