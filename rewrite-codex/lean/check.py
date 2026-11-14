"""Compile the development in dependency order, recording each check locally."""
import argparse
from pathlib import Path
import subprocess
import sys

parser=argparse.ArgumentParser()
parser.add_argument('--mathlib-root',required=True,help='Existing compiled mathlib v4.35.0 checkout')
args=parser.parse_args()
mathlib=Path(args.mathlib_root).resolve()
here=Path(__file__).resolve().parent
files=[('SecondNeighborhood','build.log'),('RankChecks','rank-build.log'),
       ('KernelRestrictions','restrictions-build.log'),('CoverageLifts','lifts-build.log'),
       ('PruningAlgebra','algebra-build.log'),('GenericAssignment','generic-build.log'),
       ('MatchingMinor','minor-build.log')]
for module,logname in files:
    command=[sys.executable,str(here/'mathlib-env.py'),'--mathlib-root',str(mathlib),
             'lean','+leanprover/lean4:v4.35.0','-o',str(here/(module+'.olean')),
             str(here/(module+'.lean'))]
    result=subprocess.run(command,cwd=here.parent,text=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
    # Relative paths keep the committed verification records portable.
    output=result.stdout.replace(str(here.parent)+'/', '')
    (here/logname).write_text(output)
    if result.returncode:
        print(output,end='')
        raise SystemExit(result.returncode)
    print(module+': checked',flush=True)
