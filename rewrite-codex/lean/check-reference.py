"""Rebuild the attributed source snapshot and our definition bridge locally."""
import argparse,hashlib,json,subprocess,sys
from pathlib import Path
parser=argparse.ArgumentParser()
parser.add_argument('--mathlib-root',required=True)
args=parser.parse_args()
mathlib=Path(args.mathlib_root).resolve()
here=Path(__file__).resolve().parent
ref=here/'reference'
manifest=json.loads((ref/'source-manifest.json').read_text())
for name,digest in manifest['files'].items():
    actual=hashlib.sha256((ref/'SeymourLean'/name).read_bytes()).hexdigest()
    if actual!=digest:raise SystemExit('Reference source changed: '+name)
order=['Defs','LinAlg','Konig','Reduction','BlowUp','Contradiction','Main',
       'Gamma','Generic','MatchingCore','MatchingBound','Final']
for module in ['SecondNeighborhood']+order+['ReferenceBridge']:
    source=(here/(module+'.lean')) if module in {'SecondNeighborhood','ReferenceBridge'} else (ref/'SeymourLean'/(module+'.lean'))
    command=[sys.executable,str(here/'mathlib-env.py'),'--mathlib-root',str(mathlib),
             'lean','+leanprover/lean4:v4.35.0','-o',str(source.with_suffix('.olean')),str(source)]
    run=subprocess.run(command,cwd=here.parent,text=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
    output=run.stdout.replace(str(here.parent)+'/', '')
    log=here/'reference-build.log' if module=='ReferenceBridge' else (here/'build.log' if module=='SecondNeighborhood' else ref/(module+'-build.log'))
    log.write_text(output)
    if run.returncode:
        print(output,end='');raise SystemExit(run.returncode)
    print(module+': checked',flush=True)
