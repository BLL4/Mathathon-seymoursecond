# A guided rewrite of "A proof of Seymour's second-neighborhood conjecture"

This directory contains a rewritten, figure-rich presentation of the preprint
*A proof of Seymour's second-neighborhood conjecture* (OpenAI, 23 September 2026), together with a
20-minute beamer talk, a computational verification suite and a Lean 4 companion.

The mathematics is unchanged: no statement is weakened, no case is removed, no proof step is
dropped. What is added is structure, pictures, motivation and an explicit record of how each step was
checked. The source in `../original/` was read only; nothing was written there.

## Where things are

| path | what it is |
|---|---|
| `plan/00-charter-draft-v1.md` | first draft of "what does it mean to make the write-up more readable" |
| `plan/01-charter-revised-v2.md` | the revised charter: the rules the rewrite is held to, and the record of how it was reviewed |
| `paper/main.pdf` | the rewritten paper (35 pages, 15 figures) |
| `paper/` | its LaTeX sources; build with `latexmk -pdf main.tex` |
| `slides/main.pdf` | the 20-minute beamer deck (21 frames) |
| `slides/` | its sources (`latexmk -pdf main.tex`) |
| `checks/verify.py` | the computational checks; run `python3 verify.py` in `checks/` |
| `checks/run.log` | the last recorded run: all checks pass |
| `lean/` | the Lean 4 companion; see `lean/README.md` |

## How to read the paper

`paper/00-howtoread.tex` (printed right after the abstract) gives three reading routes — five
minutes, an hour, a day — the conventions, the meaning of the four kinds of box, and a notation table.
The paper opens every section with a contract ("what goes in, what comes out, why") and closes it
with a summary; every statement is followed by an "In words" line and a proof plan; Appendix B
translates the notation and the numbering back to the original preprint.
