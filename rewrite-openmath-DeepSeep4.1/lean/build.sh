#!/bin/sh
# build the Lean companion; run from this directory
set -e
for f in Basic Cycles Statements; do
  LEAN_PATH=.:$LEAN_PATH lean -o Seymour/$f.olean Seymour/$f.lean
  echo "built Seymour/$f.lean"
done
