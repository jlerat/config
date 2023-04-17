import sys
import subprocess
from pathlib import Path
import re

# Print line size
line_size = 5
indent_size = 2
def indent(n):
    return "".join([" "]*indent_size*n)

# Finds the list of jobs
FOLDER = Path(sys.argv[1]).resolve()
lf = list(FOLDER.glob('*.out'))
jobs = list(set([re.sub('.*_JOB', '', f.stem) for f in lf]))

# Utils
def ls(files):
    #f = f"{FOLDER}/{files}"
    #l = subprocess.run(["ls", f], capture_output=True)
    #if l.returncode>0:
    #    raise ValueError(f"{l.stderr}")
    #return l.stdout
    return list(FOLDER.glob(files))

def grep(files, pattern, commands=''):
    gc = ["grep", f"'{pattern}'", f"{FOLDER}/{files}"]
    if commands != "":
        gc.append("-"+commands)

    gc = " ".join(gc)
    try:
        g = subprocess.check_output(gc, shell=True)
    except:
        return []
    return [f for f in g.decode().split("\n") if len(f)>0]

def get_task(files):
    return [int(re.search('(?<=TASK)[0-9]+', str(f)).group()) for f in files]


print(f"\n----------- ERROR FILES --------------")
for jobid in jobs:
    print(f"{indent(1)}JOB ID {jobid}")

    # Count error files
    l = ls(f"*JOB{jobid}.err")
    print(f"{indent(2)}Nb err files            : {len(l)}")

    # Finds error ignoring cases and reporting file names only
    g = grep(f"*{jobid}.err", "error", "il")
    print(f"{indent(2)}Nb err files with error : {len(g)}")

    # Print error file numbers
    if len(g)>0:
        errn = [re.sub(".*_TASK|_JOB.*", "", f) for f in g]
        print(f"{indent(2)}Files with error : ")
        for i in range(0, len(errn), line_size):
            print(f"{indent(2)}"+" ".join(errn[i:i+line_size]))

    print("\n")

print(f"----------- LOG FILES --------------")
# Count log files
flogs = ls("*.log")
# List of tasks
tasks = get_task(flogs)
expected = [i for i in range(0, max(tasks)+1)]
print(f"{indent(1)}Files expected/found :"+\
            f" {len(expected)} / {len(tasks)}")

if len(expected)>len(flogs):
    missings = set(expected)-set(tasks)
    print(f"{indent(1)}Missing files:")
    for i in range(0, len(missing), line_size):
        missn = [str(n) for n in missing[i:i+line_size]]
        print(f"{indent(1)}"+" ".join(missn))

gs = grep("*.log", "process started", "il")
print(f"{indent(1)}Files started        : {len(gs)}")

gc = grep("*.log", "process completed", "il")
print(f"{indent(1)}Files completed      : {len(gc)}")

gw = grep("*.log", "warn", "il")
print(f"{indent(1)}Files with warnings  : {len(gw)}")

ge = grep("*.log", "error", "il")
print(f"{indent(1)}Files with errors    : {len(ge)}")

print("\n")
completed = get_task(gc)
if len(expected)>len(gc):
    missings = list(set(expected)-set(completed))
    print(f"{indent(1)}Not started or not completed:")
    for i in range(0, len(missings), line_size):
        missn = [str(n) for n in missings[i:i+line_size]]
        print(f"{indent(1)}"+" ".join(missn))


print("\n")
