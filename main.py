import mkIR
from sys import argv

if (len(argv) != 3):
    print("INCORRECT ARGUMENTS SUPPLIED")
else:
    i = open(argv[1]).read()
    ir = mkIR.mkIR(i)
    gen = mkIR.emit(ir)
    open(argv[2], "w+").write(gen)