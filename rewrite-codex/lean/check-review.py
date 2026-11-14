"""Validate the review snapshot and check its counterexamples and adopted lemmas."""
import argparse,hashlib,json,subprocess,sys
from pathlib import Path
parser=argparse.ArgumentParser()
parser.add_argument('--mathlib-root',required=True)
parser.add_argument('--lean-bin',help='Optional path to the pinned Lean binary, bypassing elan')
parser.add_argument('--cycles',action='store_true',help='Also check the adopted cycle consequences')
parser.add_argument('--force',action='store_true',help='Recompile even when local checked objects are current')
args=parser.parse_args()
mathlib=Path(args.mathlib_root).resolve()
here=Path(__file__).resolve().parent
review=here/'review-target'
manifest=json.loads((review/'source-manifest.json').read_text())
for name,digest in manifest['files'].items():
    if hashlib.sha256((review/'original/Seymour'/name).read_bytes()).hexdigest()!=digest:
        raise SystemExit('Review source changed: '+name)
for name,digest in manifest['compiled_files'].items():
    if hashlib.sha256((review/'Seymour'/name).read_bytes()).hexdigest()!=digest:
        raise SystemExit('Compiled review source changed: '+name)
imports='import Mathlib.Data.Fintype.Prod\nimport Mathlib.Data.Fintype.Powerset\nimport Mathlib.Data.Finset.Card\nimport Std\n'
for name in manifest['files']:
    original=(review/'original/Seymour'/name).read_text()
    expected=original.replace('import Mathlib\n',imports) if name=='Basic.lean' else original
    if (review/'Seymour'/name).read_text()!=expected:
        raise SystemExit('Unrecorded mathematical source adaptation: '+name)
if args.cycles:
    ref=here/'reference/SeymourLean/Final.olean'
    if not ref.exists():
        subprocess.run([sys.executable,str(here/'check-reference.py'),'--mathlib-root',str(mathlib)],check=True,cwd=here.parent)
order=['Basic','Statements','ReviewCounterexamples']+(['Cycles','AdoptedCycleConsequences'] if args.cycles else [])
for module in order:
    source=here/(module+'.lean') if module in {'ReviewCounterexamples','AdoptedCycleConsequences'} else review/'Seymour'/(module+'.lean')
    log=(here/'review-build.log' if module=='ReviewCounterexamples' else here/'cycles-build.log') if module in {'ReviewCounterexamples','AdoptedCycleConsequences'} else review/(module+'-build.log')
    deps=[]
    if module in {'Statements','Cycles'}:deps=[review/'Seymour/Basic.olean']
    if module=='ReviewCounterexamples':deps=[review/'Seymour/Statements.olean']
    if module=='AdoptedCycleConsequences':deps=[review/'Seymour/Cycles.olean',here/'reference/SeymourLean/Final.olean']
    obj=source.with_suffix('.olean')
    current=(not args.force and obj.exists() and log.exists() and all(p.exists() for p in deps)
             and obj.stat().st_mtime>=max(p.stat().st_mtime for p in [source]+deps)
             and 'error:' not in log.read_text() and 'sorryAx' not in log.read_text())
    if current:
        print(module+': checked (current local object)',flush=True)
        continue
    command=[sys.executable,str(here/'mathlib-env.py'),'--mathlib-root',str(mathlib),args.lean_bin or 'lean']
    if not args.lean_bin:command+=['+leanprover/lean4:v4.35.0']
    command+=['-o',str(obj),str(source)]
    with log.open('w') as stream:
        result=subprocess.run(command,cwd=here.parent,text=True,stdout=stream,stderr=subprocess.STDOUT)
    output=log.read_text().replace(str(here.parent)+'/', '')
    log.write_text('\n'.join(line.rstrip() for line in output.splitlines()) + ('\n' if output else ''))
    if result.returncode:
        print(output,end='');raise SystemExit(result.returncode)
    print(module+': checked',flush=True)
