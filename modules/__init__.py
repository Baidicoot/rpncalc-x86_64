from typing import List, Dict, Tuple, Optional
import toml

class Module:
    def __init__(self, name: str, files: Dict[str, List[str]], fns: Dict[str, Tuple[str, int]], path: str):
        self.name = name
        self.files = files
        self.fns = fns
        self.path = path
    
    def include(self) -> Dict[str, Tuple[str, int]]:
        return self.fns
    
    def imprt(self) -> Dict[str, Tuple[str, int]]:
        return {self.name+'.'+k : v for k, v in self.fns.items()}

def parsemod(str: str, path) -> Optional[List[Module]]:
    mods = toml.loads(str)
    parsed = []
    for name, data in mods.items():
        if type(data['files']) != dict:
            return None
        files = data['files']
        keys = set(data.keys())
        keys.discard('files')
        fns = {}
        for k in keys:
            defn = (data[k]['name'], data[k]['args'])
            if k in fns.keys():
                return None
            fns[k] = defn
            if 'alts' in data[k].keys():
                for alt in data[k]['alts']:
                    if alt in fns.keys():
                        return None
                    fns[alt] = defn
        parsed.append(Module(name, files, fns, path))
    return parsed