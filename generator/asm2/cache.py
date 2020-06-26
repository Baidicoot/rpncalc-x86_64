# for caching the output of the assembler on the ast
import pickle
import os

def cached(lib) -> bool:
    if lib.name in os.listdir("build/"):
        ast = pickle.load(open("build/"+lib.name, "rb"))
        if ast == lib:
            return True
    return False

def cache(lib):
    pickle.dump(lib, open("build/"+lib.name, "wb"))