import sys
from pathlib import Path
import re
import numpy as np

folder = sys.argv[1]
lf = list(Path(folder).glob('*.log'))
tasks = np.array([int(re.search('(?<=TASK)[0-9]+', f.stem).group()) for f in lf])

tasks = np.sort(tasks)
expected = np.arange(0, tasks.max()+1)
print(f"{len(expected)} log files expected, {len(tasks)} found.")

if len(expected)>len(tasks):
    missings = set(expected.tolist())-set(tasks.tolist())
    print("Missing log file for tasks")
    for miss in missings:
        print(f"{miss},")
else:
    print("All good.")
