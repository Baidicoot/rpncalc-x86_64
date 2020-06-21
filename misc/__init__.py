class Path:
    pass

class Absolute(Path):
    def __init__(self, path: str):
        self.path = path

class Relative(Path):
    def __init__(self, path: str):
        self.path = path