import sys
from pathlib import Path
import re

folder = sys.argv[1]
lf = list(Path(folder).glob('*.log'))
tasks = [int(re.search('(?<=TASK)[0-9]+', f.stem).group()) for f in lf]

expected = [i for i in range(0, max(tasks)+1)]

print(f"{len(expected)} log files expected, {len(tasks)} found.")

if len(expected)>len(tasks):
    missings = set(expected)-set(tasks)
    print("Missing log file for tasks")
    for miss in missings:
        print(f"{miss},")
else:
    print("All good.")
