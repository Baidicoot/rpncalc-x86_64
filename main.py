import os
import parser
import modules
import generator
import generator.asm
from sys import argv

if __name__ == "__main__":
    if len(argv) != 4:
        print("INVALID ARGUMENTS SUPPLIED")
        exit(0)
    input = argv[1]
    output = argv[2]
    backend = argv[3]

    mods = {}

    for file in os.listdir():
        if file.endswith(".rpnm"):
            m = modules.parsemod(open(file).read())
            if m is None:
                print("COULD NOT PARSE MODULE FILE", file, "\nENSURE IT CONFORMS TO STANDARDS")
                exit(1)
            if m.name in mods:
                print("MODULE", m.name, "IS REDEFINED IN FILE", file)
                exit(2)
            mods[m.name] = m

    decls, ast = parser.parser.parse(open(input).read())

    external = {}
    for decl in decls:
        fns = mods[decl.name].include() if decl.__class__ == parser.Include else mods[decl.name].imprt()
        inter = fns.keys() & external.keys()
        if len(inter) > 0:
            print("NAME COLLISION ERROR:", inter, "ARE MULTIPLY USED")
            exit(3)
        external.update(fns)

    try:
        gen = generator.generators[backend]
    except:
        print("INVALID GENERATOR SUPPLIED. You can choose from:")
        for g in generator.generators.keys():
            print("   ", g)
    
    gen(ast, output, argv[3:], external)