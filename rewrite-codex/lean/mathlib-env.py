"""Run Lean using an existing compiled mathlib checkout, without writing there."""
import os, subprocess, sys
from pathlib import Path
if len(sys.argv)<4 or sys.argv[1]!='--mathlib-root':
    raise SystemExit('Usage: mathlib-env.py --mathlib-root /path/to/mathlib command [args...]')
base=Path(sys.argv[2]).resolve()
paths=[base/'.lake/build/lib/lean']
paths+=sorted((base/'.lake/packages').glob('*/.lake/build/lib/lean'))
paths+=sorted(base.parent.glob('*/.lake/build/lib/lean'))
env=dict(os.environ)
env['LEAN_PATH']=':'.join(map(str,paths))
raise SystemExit(subprocess.call(sys.argv[3:],env=env))
