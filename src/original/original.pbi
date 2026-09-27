DeclareModule Original
  EnableExplicit
  XIncludeFile "types.pbi"
  Declare.i LoadDatabase(*db.Database, *out.Output)
  Declare.i RandomRange(*s.State, range.i)
EndDeclareModule
Module Original
  EnableExplicit
  XIncludeFile "database.pbi"
  XIncludeFile "random.pbi"
EndModule
