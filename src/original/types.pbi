Enumeration
  #Command
  #Question
  #Ended
EndEnumeration
Structure VocabEntry
  word.s
  value.i
EndStructure
Structure TextGroup
  text.s
EndStructure
Structure MessageEvent
  section.i
  id.i
  variant.i
EndStructure
Structure Output
  text.s
  inputMode.i
  request.i
  List events.MessageEvent()
EndStructure
Structure Database
  longText.s[151]
  shortText.s[151]
  rtext.s[206]
  mtext.s[36]
  inventory.s[101]
  Map objectText.s()
  travel.i[1001]
  key.i[151]
  cond.i[151]
  plac.i[101]
  fixd.i[101]
  actspk.i[36]
  ctext.s[13]
  cval.i[13]
  hints.i[101]
  hntmax.i
  classes.i
  travelRecords.i
  travelCount.i
  List vocab.VocabEntry()
EndStructure
Structure State
  rng.q
EndStructure
