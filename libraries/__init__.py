from libraries.library import *
from libraries.parser import parser

def parselib(str: str) -> Library:
    decls = parser.parse(str)
    try:
        return Library(decls)
    except:
        return None