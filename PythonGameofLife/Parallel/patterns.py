from dataclasses import dataclass
import tomllib
from pathlib import Path

PATTERNS_FILE = Path('PythonGameofLife/Parallel/patterns.toml')

@dataclass
class Pattern:
    name: str
    alive_cells: set[tuple[int, int]]

    @classmethod
    def from_toml(cls, name, toml_data):
        alive_cells=set()
        for cell in toml_data["alive_cells"]:
            alive_cells.add(tuple(cell))
        return cls(name, alive_cells)

# Get a single pattern from the file
def get_pattern(name, filename=PATTERNS_FILE):
    data = tomllib.loads(filename.read_text(encoding="utf-8"))
    return Pattern.from_toml(name, toml_data=data[name])
    
# Get all patterns
def get_all_patterns(filename=PATTERNS_FILE):
    data = tomllib.loads(filename.read_text(encoding="utf-8"))
    result=[]
    for name, toml_data in data.items():
        result.append(Pattern.from_toml(name, toml_data))
    return result