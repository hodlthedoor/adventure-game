Procedure.i RandomRange(*s.State, range.i)
  *s\rng = (*s\rng * 1021) % 1048576
  ProcedureReturn (range * *s\rng) / 1048576
EndProcedure
