output = []

def imm(opcode, r0, val):
    global output
    instr = val
    instr = (instr << 4) | r0
    instr = (instr << 12) | opcode
    assert(instr < 2 ** 32)
    output.append(instr)

def reg(opcode, r0 = 0, r1 = 0, r2 = 0, r3 = 0, r4 = 0):
    global output
    instr = r4
    instr = (instr << 4) | r3
    instr = (instr << 4) | r2
    instr = (instr << 4) | r1
    instr = (instr << 4) | r0
    instr = (instr << 12) | opcode
    assert(instr < 2 ** 32)
    output.append(instr)

def clr(r0): reg(0, r0)
def setll(r0, val): imm(1, r0, val)
def setlh(r0, val): imm(2, r0, val)
def sethl(r0, val): imm(3, r0, val)
def sethh(r0, val): imm(4, r0, val)
def hlt(): reg(5)
def mov(r0, r1): reg(6, r0, r1)
def br(r0): reg(7, r0)
def brl(r0, r1, r2): reg(8, r0, r1, r2)
def brg(r0, r1, r2): reg(9, r0, r1, r2)
def bre(r0, r1, r2): reg(10, r0, r1, r2)
def brne(r0, r1, r2): reg(11, r0, r1, r2)
def brle(r0, r1, r2): reg(12, r0, r1, r2)
def brge(r0, r1, r2): reg(13, r0, r1, r2)
def add(r0, r1, r2): reg(14, r0, r1, r2)
def sub(r0, r1, r2): reg(15, r0, r1, r2)
def mul(r0, r1, r2): reg(16, r0, r1, r2)
def div(r0, r1, r2): reg(17, r0, r1, r2)
def pushl(r0): reg(18, r0)
def pushh(r0): reg(19, r0)
def _ip(): return len(output)
def r(n): return n
sp = 15

# ---------------------
clr(sp)
setll(sp, 20);

clr(r(0))

clr(r(1))
setll(r(1), 123)

clr(r(2))
setll(r(2), 1)

clr(r(3))
loop = _ip()
setll(r(3), loop)
add(r(0), r(0), r(2))
brl(r(0), r(1), r(3))

pushl(r(0))
pushh(r(0))
hlt()
# ---------------------

def b(v):
    return bin(v)[2:].zfill(8)

binary = ''
for instr in output:
    binary += b(instr >> 24)
    binary += b((instr >> 16) & 0xff)
    binary += b((instr >> 8) & 0xff)
    binary += b(instr & 0xff)
    binary += '\n'
for i in range(32 - len(output)):
    binary += '1' * 32 
    binary += '\n'

with open('imgs/ram.bin', 'w') as f:
    f.write(binary)

