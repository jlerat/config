import sys
from pathlib import Path
import re

folder = sys.argv[1]
lf = list(Path(folder).glob('*.out'))
jobs = list(set([re.sub('.*_JOB', '', f.stem) for f in lf]))
print(" ".join(jobs))
