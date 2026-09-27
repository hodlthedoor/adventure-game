DeclareModule Original
  EnableExplicit
  XIncludeFile "types.pbi"
  Declare.i LoadDatabase(*db.Database, *out.Output)
  Declare.i RandomRange(*s.State, range.i)
  Declare NewGame(*db.Database, *s.State, seed.q, *out.Output)
  Declare Submit(*db.Database, *s.State, input.s, *out.Output)
EndDeclareModule
Module Original
  EnableExplicit
  XIncludeFile "database.pbi"
  XIncludeFile "random.pbi"
  XIncludeFile "messages.pbi"
  XIncludeFile "objects.pbi"
  XIncludeFile "engine.pbi"
EndModule
