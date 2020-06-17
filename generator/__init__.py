generators = {}

def generator(func):
    generators[func.__name__] = func
    return func