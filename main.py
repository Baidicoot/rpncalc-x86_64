import parser
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

    ast = parser.parser.parse(open(input).read())

    try:
        gen = generator.generators[backend]
    except:
        print("INVALID GENERATOR SUPPLIED. You can choose from:")
        for g in generator.generators.keys():
            print("   ", g)
    
    gen(ast, output, argv[3:])