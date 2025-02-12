import sys
import subprocess
from pathlib import Path
import re

# -------------------------------------------------------------
# Config
# -------------------------------------------------------------
# Print line size
ITEMS_PER_LINES = 15
INDENT_SIZE = 3

# -------------------------------------------------------------
# Folders
# -------------------------------------------------------------
FOLDER = Path(sys.argv[1]).resolve()

# -------------------------------------------------------------
# Utils
# -------------------------------------------------------------
def indent(n):
    return "".join([" "]*INDENT_SIZE*n)

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
    return [int(re.search('(?<=TASK)(-|)[0-9]+', str(f)).group()) for f in files]

def printlist(objs, message, ind):
    if len(objs)>0:
        print(f"{indent(ind)}{message}:")
        for i in range(0, len(objs), ITEMS_PER_LINES):
            o = [f"{str(n):>4}" for n in objs[i:i+ITEMS_PER_LINES]]
            print(f"{indent(ind+1)}"+" ".join(o))


# -------------------------------------------------------------
# Process
# -------------------------------------------------------------
print(f"\n----------- ERROR FILES --------------")
lf = list(FOLDER.glob('*.out'))
if len(lf)>0:
    jobs = list(set([re.sub('.*JOB', '', f.stem) for f in lf]))
    for jobid in jobs:
        ndigits = 3
        txt = " ".join([jobid[i:i+ndigits] for i in range(0, len(jobid), ndigits)])
        print(f"{indent(1)}JOB ID [{txt}]")

        # Count error files
        l = ls(f"*JOB{jobid}.err")
        print(f"{indent(2)}Nb err files            : {len(l)}")

        # Finds error ignoring cases and reporting file names only
        g = grep(f"*{jobid}.err", "error", "il")
        print(f"{indent(2)}Nb err files with error : {len(g)}")

        # Print error file numbers
        if len(g)>0:
            errn = [int(re.sub(".*_TASK|_JOB.*", "", f)) for f in g]
            errn.sort()
            errn = [f"{t:3d}" for t in errn]
            printlist(errn, "Task IDs of files with error", 2)
        print("\n")
else:
    print("No err files found")

print(f"----------- LOG FILES --------------")
# Count log files
flogs = ls("*.log")
if len(flogs)>0:
    # List of tasks
    tasks = get_task(flogs)
    expected = [i for i in range(0, max(tasks)+1)]
    print(f"{indent(1)}Files expected/found :"+\
                f" {len(expected)} / {len(tasks)}")

    gs = grep("*.log", "process started", "il")
    print(f"{indent(1)}Files started        : {len(gs)}")
    started = get_task(gs)

    gc = grep("*.log", "process completed", "il")
    print(f"{indent(1)}Files completed      : {len(gc)}")
    completed = get_task(gc)

    gw = grep("*.log", "warn", "il")
    print(f"{indent(1)}Files with warnings  : {len(gw)}")

    ge = grep("*.log", "error", "il")
    print(f"{indent(1)}Files with errors    : {len(ge)}")

    d = list(set(expected)-set(tasks))
    d.sort()
    printlist(d, "IDs of missing logs files", 1)

    d = list(set(started)-set(completed))
    d.sort()
    printlist(d, "IDs of processes started but not completed", 1)

    d = list(set(expected)-set(started))
    d.sort()
    printlist(d, "IDs of processes not started", 1)

    e = get_task(ge)
    e.sort()
    printlist(e, "IDs of process with errors", 1)
else:
    print("No log files found")

print("------------------------------------\n")
