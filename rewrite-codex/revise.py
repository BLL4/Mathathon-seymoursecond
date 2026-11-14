from pathlib import Path
p=Path('.')
f=p/'main.tex';s=f.read_text().replace('\\usepackage{enumitem}', '\\usepackage{enumitem}\n\\usepackage{needspace}')
f.write_text(s)
f=p/'reader-guide.tex';s=f.read_text().replace('\\paragraph{Notation dictionary.}', '\\Needspace{13\\baselineskip}\n\\paragraph{Notation dictionary.}');f.write_text(s)
f=p/'talk.tex';s=f.read_text()
s=s.replace('The deletion cost depends on the points uncovered', 'The deletion cost depends on the points uncovered')
s=s.replace('Here $H,Z$ collect the indicated corners over all conflicts.',r'''Here $H,Z$ collect these corners over all conflicts. A kept $(p,j)$ covers
$(i,j)$ if $p\to i$; a kept $(i,s)$ covers it if $s\to j$.''')
s=s.replace(r'''Choose coefficients simultaneously so that''',r'''\small
Here $J_p=\{j:(p,j)\in\mathcal R\}$ and $S_i=\{s:(i,s)\in\mathcal C\}$.
Choose coefficients simultaneously so that''')
s=s.replace(r'''For $P,Q\subseteq X^2$, require''',r'''\small
$F_1$ advances the first coordinate; $F_2$ advances the second.
For $P,Q\subseteq X^2$, require''')
s=s.replace('The companion article contains the full proofs and source bibliography.', 'Source: OpenAI, September 23, 2026 preprint, supplied with this project.\\\\\nThe companion article contains the full proofs and source bibliography.')
f.write_text(s)
