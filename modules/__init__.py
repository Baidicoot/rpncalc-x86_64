from typing import List, Dict, Tuple, Optional
import toml

class Module:
    def __init__(self, name: str, files: List[str], fns: Dict[str, Tuple[str, int]]):
        self.name = name
        self.files = files
        self.fns = fns
    
    def include(self) -> Dict[str, Tuple[str, int]]:
        return self.fns
    
    def imprt(self) -> Dict[str, Tuple[str, int]]:
        return {self.name+'.'+k : v for k, v in self.fns.items()}

def parsemod(str: str) -> Optional[Module]:
    data = toml.loads(str)
    if type(data['files']) != list or len(data['files']) < 1:
        return None
    files = data['files']
    keys = set(data.keys())
    if len(keys) != 2:
        return None
    keys.discard('files')
    name = keys.pop()
    try:
        fns = {k : (v['name'], v['args']) for k, v in data[name].items()}
    except:
        return None
    return Module(name, files, fns)