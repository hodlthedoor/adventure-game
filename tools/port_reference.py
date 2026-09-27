"""Regenerate the literal PureBasic control-flow port from the pinned WOOD0350 source.

Development tool only. The game executes compiled PureBasic, not this translator.
Source line and statement label accompany every generated phase for audit.
"""
from pathlib import Path
import re,json
ROOT=Path(__file__).resolve().parent.parent
source=(ROOT/'reference/wood0350/advent.for').read_text()
records=[]
for line_no,line in enumerate(source.split('\n'),1):
    if not line or line[0] in 'Cc\f': continue
    m=re.match(r'^(?:\t| {5})[1-9]\s*(.*)',line)
    if m:
        records[-1]['code']+=m[1].strip(); continue
    m=re.match(r'^(\d*)\s+(.*)',line)
    if m: records.append(dict(line=line_no,label=m[1],code=m[2].strip()))
a=next(i for i,r in enumerate(records) if r['label']=='1100')
b=next(i for i,r in enumerate(records) if r['label']=='25000')
records=[r for r in records[a:b+1] if not r['code'].startswith(('FORMAT','INTEGER'))]
for i,r in enumerate(records): r['pc']=i+1
labels={r['label']:r['pc'] for r in records if r['label']}
state_arrays={'PLACE':101,'FIXED':101,'PROP':101,'ATLOC':151,'LINK':201,'ABB':151,'HINTLC':21,'HINTED':21,'DLOC':7,'ODLOC':7,'DSEEN':7,'TK':21}
db_arrays={'LTEXT','STEXT','KEY','COND','TRAVEL','PLAC','FIXD','PTEXT','RTEXT','ACTSPK','CTEXT','CVAL','MTEXT'}
consts={'LOCSIZ':'150','MAXTRS':'79','HNTMAX':'*db\\hntmax','CLSSES':'(*db\\classes+1)','LINSIZ':'9650','TRVSIZ':'750','TABSIZ':'300','VRBSIZ':'35','RTXSIZ':'205','CLSMAX':'12','HNTSIZ':'20','MAGSIZ':'35'}
strings={'WD1','WD1X','WD2','WD2X'}
scalars=set()
def scalar(name):
    if name in consts:return consts[name]
    scalars.add(name)
    return '*s\\'+name.lower()
def split_args(s):
    out=[];start=depth=0;quoted=False
    for i,c in enumerate(s):
        if c=="'":quoted=not quoted
        if quoted:continue
        if c=='(':depth+=1
        if c==')':depth-=1
        if c==',' and depth==0:out.append(s[start:i]);start=i+1
    out.append(s[start:]);return out
TOK=re.compile(r"\s*(('[^']*')|(\.[A-Z]+\.)|([A-Z][A-Z0-9]*)|(\d+)|(.))")
class Expr:
    def __init__(self,s):
        self.t=[m[0].strip() for m in TOK.findall(s)] if False else [m.group(1) or m.group(3) or m.group(4) or m.group(5) or m.group(6) for m in TOK.finditer(s)]
        self.i=0
    def pop(self):v=self.t[self.i];self.i+=1;return v
    def peek(self):return self.t[self.i] if self.i<len(self.t) else ''
    def parse(self,minimum=0):
        t=self.pop()
        if t in ('+','-','.NOT.'):
            x=self.parse(6 if t!='.NOT.' else 3)
            left=('Bool(Not '+x+')') if t=='.NOT.' else '('+t+x+')'
        elif t=='(':
            left='('+self.parse()+')';assert self.pop()==')'
        elif t.startswith("'"):
            left="~"+json.dumps(t[1:-1])
        elif t=='.TRUE.':left='1'
        elif t=='.FALSE.':left='0'
        elif t.isdigit():left=t
        elif self.peek()=='(':
            self.pop();args=[]
            while self.peek()!=')':
                args.append(self.parse())
                if self.peek()!=',':break
                self.pop()
            assert self.pop()==')',(t,self.t)
            if t in state_arrays:left='*s\\'+t.lower()+'['+args[0]+']'
            elif t in db_arrays:left='*db\\'+t.lower()+'['+args[0]+']'
            elif t=='HINTS':left='*db\\hints['+args[0]+'*5+'+args[1]+']'
            elif t=='MOD':left='('+args[0]+' % '+args[1]+')'
            elif t=='IABS':left='Int(Abs('+args[0]+'))'
            elif t in ('MIN0','MAX0'):left=('IMin' if t=='MIN0' else 'IMax')+'('+', '.join(args)+')'
            elif t=='RAN':left='RandomRange(*s, '+args[0]+')'
            elif t=='PCT':left='Bool(RandomRange(*s, 100) < '+args[0]+')'
            elif t=='KTAB':left='VocabIndex(*db, '+args[0]+')'
            elif t=='VOCAB':left='Vocab(*db, '+', '.join(args)+')'
            elif t in ('HERE','AT','TOTING','LIQ','LIQLOC','BITSET','DARK','FORCED','PUT'):
                left=t.title()+'(*db, *s, '+', '.join(args)+')'
            elif t=='START':left='0'
            else:raise ValueError(('unknown call',t,args))
        else:left=scalar(t)
        prec={'.OR.':1,'.AND.':2,'.EQ.':3,'.NE.':3,'.GT.':3,'.GE.':3,'.LT.':3,'.LE.':3,'+':4,'-':4,'*':5,'/':5}
        while self.peek() in prec and prec[self.peek()]>=minimum:
            op=self.pop();right=self.parse(prec[op]+1)
            if op=='+' and left=='0' and right.startswith('~"'):left=right;continue
            if op in ('.EQ.','.NE.'):
                if left in ('*s\\wd1','*s\\wd2','*s\\wd1x','*s\\wd2x') and right=='0':right='""'
            if op=='/':left='IDiv('+left+', '+right+')'
            elif op.startswith('.'):
                actual={'.OR.':'Or','.AND.':'And','.EQ.':'=','.NE.':'<>','.GT.':'>','.GE.':'>=','.LT.':'<','.LE.':'<='}[op]
                left='Bool('+left+' '+actual+' '+right+')'
            else:left='('+left+' '+op+' '+right+')'
        return left

def expr(s):
    e=Expr(s);v=e.parse();assert e.i==len(e.t),(s,e.t[e.i:]);return v

def jump(label):return '*s\\phase = '+str(labels[label])+' : Continue'
loops={}
for r in records:
    m=re.match(r'DO\s+(\d+)\s+(\w+)=(.*)',r['code'])
    if m:
        start,end,*step=split_args(m[3]);loops.setdefault(m[1],[]).append((m[2],end,step[0] if step else '1',r['pc']+1))

def statement(code,r):
    if code.startswith('IF('):
        depth=0;quoted=False
        for i,c in enumerate(code[2:],2):
            if c=="'":quoted=not quoted
            if quoted:continue
            if c=='(':depth+=1
            if c==')':
                depth-=1
                if depth==0:break
        return ['If '+expr(code[3:i])]+['  '+x for x in statement(code[i+1:].strip(),r)]+['EndIf']
    m=re.match(r'GOTO\s*(\d+)$',code)
    if m:return [jump(m[1])]
    m=re.match(r'GOTO\s*\(([^)]+)\)\s*(.*)',code)
    if m:
        out=['Select '+expr(m[2])]
        for i,label in enumerate(m[1].split(','),1):out+=['  Case '+str(i)+' : *s\\phase = '+str(labels[label.strip()])]
        return out+['EndSelect','Continue']
    m=re.match(r'DO\s+(\d+)\s+(\w+)=(.*)',code)
    if m:return [scalar(m[2])+' = '+expr(split_args(m[3])[0])]
    if code=='CONTINUE':return []
    if code=='STOP':return ['*s\\ended = 1 : *out\\inputMode = #Ended : ProcedureReturn']
    if code.startswith('PAUSE'):return []
    if code.startswith('CALL '):
        m=re.match(r'CALL (\w+)(?:\((.*)\))?',code);name=m[1];args=split_args(m[2]) if m[2] else []
        if name in ('POOF','MOTD','MAINT','CIAO','DATIME','HOURS'):return []
        if name=='GETIN':return ['*s\\awaiting = 1 : *out\\inputMode = #Command : ProcedureReturn']
        if name=='A5TOA1':
            separator=' + " "' if ord(args[2][1])>=64 else ''
            return ['*s\\render = RTrim('+expr(args[0])+' + '+expr(args[1])+')'+separator+' + '+expr(args[2]), '*s\\k = Len(*s\\render)']
        values=[expr(x) for x in args]
        if name=='SPEAK':return ['Speak(*db, *out, '+values[0]+')']
        if name=='RSPEAK':return ['Emit(*db, *out, 6, '+values[0]+')']
        if name=='PSPEAK':return ['Emit(*db, *out, 5, '+', '.join(values)+')']
        if name=='MSPEAK':return ['Emit(*db, *out, 12, '+values[0]+')']
        if name in ('DROP','CARRY','MOVE','DSTROY','JUGGLE'):
            return [name.title()+'(*s, '+', '.join(values)+')']
        if name=='BUG':return ['*out\\text + "Internal reference error " + Str('+values[0]+') : *out\\inputMode = #Ended : *s\\ended = 1 : ProcedureReturn']
        raise ValueError(('call',name))
    if code.startswith('TYPE '):
        num=code[5:].split(',')[0]
        messages={
            '67':'Str(*s\\dtotal) + " threatening little dwarves are in the room with you."',
            '78':'Str(*s\\attack) + " of them throw knives at you!"',
            '68':'Str(*s\\stick) + " of them get you!"',
            '5015':'"What do you want to do with the " + *s\\render',
            '5199':'"I see no " + *s\\render',
            '8002':'*s\\render',
            '9032':'"Okay, " + Chr(34) + *s\\render',
            '8243':'"If you were to quit now, you would score " + Str(*s\\score) + " out of a possible " + Str(*s\\mxscor) + "."',
            '40012':'"I am prepared to give you a hint, but it will cost you " + Str(*db\\hints[*s\\hint*5+2]) + " points."',
            '20100':'"You scored " + Str(*s\\score) + " out of a possible " + Str(*s\\mxscor) + ", using " + Str(*s\\turns) + " turns."',
            '20202':'"You just went off my scale!!"',
            '20212':'"To achieve the next higher rating, you need " + Str(*s\\k) + " more points."',
            '20222':'"To achieve the next higher rating would be a neat trick! Congratulations!!"',
        }
        if num in ('1999','8302'):return []
        return ['Text(*out, '+messages[num]+', '+num+')']
    m=re.match(r'(.+?)=(.*)',code)
    if m:
        left,right=m.groups()
        if left in consts:return []
        if left=='KK' and right.startswith("'"):return []
        if left=='COND(LOC)':return [] # already derived by the database loader
        if left=='OBJ' and right=='WD2':right="WD2.NE.0"
        value=expr(right)
        if left in strings and right=='0':value='""'
        out=[expr(left)+' = '+value]
        if left=='DEMO' and right=='START(0)':out+=['*s\\saved = -1']
        return out
    raise ValueError(('statement',code))

out=[];mapping=[]
for r in records:
    code=r['code'];pc=r['pc']
    lines=['Case '+str(pc)+' ; FORTRAN '+str(r['line'])+(' label '+r['label'] if r['label'] else ''), '  *s\\phase = '+str(pc+1)]
    if r['label']=='8300':
        lines+=['  *out\\request = 1', '  '+jump('2012')]
    elif r['label']=='8310':
        lines+=['  Text(*out, "This desktop cave is open at all hours.", 8310)', '  '+jump('2012')]
    else:
        m=re.search(r'YES\(',code)
        if m:
            start=m.start();depth=1;end=m.end()
            while depth:
                if code[end]=='(':depth+=1
                if code[end]==')':depth-=1
                end+=1
            args=split_args(code[m.end():end-1])
            lines += ['  If Not *s\\answerReady', '    *s\\phase = '+str(pc), '    *s\\yesMessage = '+expr(args[1]), '    *s\\noMessage = '+expr(args[2]), '    *s\\questionMessage = '+expr(args[0]), '    Emit(*db, *out, 6, *s\\questionMessage)', '    *s\\awaiting = 2 : *out\\inputMode = #Question : ProcedureReturn', '  EndIf', '  *s\\answerReady = 0']
            code=code[:start]+'ANSWER'+code[end:]
        lines+=['  '+x for x in statement(code,r)]
        for variable,end,step,target in reversed(loops.get(r['label'],[])):
            lines+=['  '+scalar(variable)+' + '+expr(step), '  If '+scalar(variable)+' <= '+expr(end)+' : *s\\phase = '+str(target)+' : EndIf']
    out.extend(lines)
    mapping.append(r)
# all scalars referred to only in hand-written formatting or continuations
scalars.update('SETUP SAVED ANSWER PHASE AWAITING ANSWERREADY YESMESSAGE NOMESSAGE QUESTIONMESSAGE ENDED DTOTAL ATTACK STICK SCORE MXSCOR HINT K RNG REQUEST'.split())
scalars-=set(consts)|set(state_arrays)|strings
fields=['Structure State','  rng.q','  render.s','  lastPrompt.s']
fields+=['  '+n.lower()+'.s' for n in sorted(strings)]
fields+=['  '+n.lower()+'.i' for n in sorted(scalars) if n!='RNG']
fields+=['  '+n.lower()+'.i['+str(size)+']' for n,size in state_arrays.items()]
fields+=['EndStructure']
p=ROOT/'src/original/types.pbi';s=p.read_text();tail=s[s.index('EndStructure',s.index('Structure State'))+len('EndStructure'):];s=s[:s.index('Structure State')]+ '\n'.join(fields)+tail;p.write_text(s)
# Preserve source regions as readable include fragments within the compiled phase switch.
regions=[('initialise',0,620),('encounters',620,790),('parser',790,1000),('travel',1000,1155),('death',1155,1210),('actions',1210,1815),('hints',1815,1855),('closing',1855,1989),('scoring',1989,9999)]
chunks={name:[] for name,_,_ in regions}
for r in records:
    name=next(name for name,start,end in regions if start<=r['line']<end)
    start=next(i for i,l in enumerate(out) if l.startswith('Case '+str(r['pc'])+' ;'))
    end=next((i for i in range(start+1,len(out)) if out[i].startswith('Case ')),len(out))
    chunks[name]+=out[start:end]
for name,lines in chunks.items():(ROOT/'src/original'/('phases_'+name+'.pbi')).write_text('; Generated by tools/port_reference.py; audit against reference labels.\n'+'\n'.join(lines)+'\n')
(ROOT/'docs/recreation/phase-map.json').write_text(json.dumps(mapping,indent=2)+'\n')
(ROOT/'src/original/phase_entry.pbi').write_text('#InitialPhase = '+str(labels['1100'])+'\n#CommandLoopPhase = '+str(labels['2600'])+'\n#DescribePhase = '+str(labels['2000'])+'\n#ScorePhase = '+str(labels['20000'])+'\n#FirstPhase = '+str(labels['1'])+'\n#PhaseCount = '+str(len(records))+'\n')
print('Generated',len(records),'phases and',len(scalars),'scalar fields')
