generators = {}

def generator(name):
    def internal(func):
        generators[name] = func
        return func
    return internal

libgenerators = {}

def libgenerator(name):
    def internal(func):
        libgenerators[name] = func
        return func
    return internal