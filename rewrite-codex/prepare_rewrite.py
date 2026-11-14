from pathlib import Path
import shutil
src=Path('original/build/source'); out=Path('rewrite-codex')
(out/'figures').mkdir(exist_ok=True)
for p in src.glob('*.tex'):
    shutil.copyfile(p,out/p.name)
shutil.copyfile(src/'references.bib',out/'references.bib')
shutil.copyfile(src/'figures/pruning.tex',out/'figures/pruning.tex')
p=out/'main.tex'; s=p.read_text()
s=s.replace('A proof of Seymour\'s second-neighborhood conjecture', 'Understanding the second-neighborhood proof')
s=s.replace('\\author{OpenAI}', '\\author{Codex exposition of the supplied OpenAI preprint}')
s=s.replace('\\date{September 23, 2026}', '\\date{November 13, 2026}')
a=s.index('We prove that'); b=s.index('\\end{abstract}',a)
s=s[:a]+'''This is an illustrated, expanded exposition of the supplied September 23,
2026 preprint by OpenAI. We explain its counterexample reduction, its
relation-theoretic pruning lemma, and the extremal argument joining them.
The mathematical proof text is retained with additional explanations,
worked examples, and diagrams. The main contribution of this version is
exposition; it is not an independent claim of priority. The accompanying
verification ledger distinguishes mathematical review, finite experiments,
and the scope of the Lean development.
'''+s[b:]
s=s.replace('\\input{00-introduction}', '\\tableofcontents\n\\input{reader-guide}\n\\input{00-introduction}')
s=s.replace('\\bibliographystyle', '\\input{verification-scope}\n\\bibliographystyle')
p.write_text(s)
p=out/'00-introduction.tex';s=p.read_text();a=s.index('The conjecture was recorded');b=s.index('Our proof builds',a)
history=s[a:b]
(out/'historical-context.tex').write_text('\\section{Historical context from the source}\nThe following literature summary is retained from the supplied preprint;\nit is not an independent survey of the current literature.\n\n'+history)
s=s[:a]+s[b:]
s=s.replace("Theorem~\\ref{thm:main} resolves the conjecture positively, without a", "The supplied preprint presents Theorem~\\ref{thm:main} as a resolution of the conjecture, without a")
s=s.replace('\\paragraph{Proof strategy.}', '\\paragraph{Proof strategy: the three bridges.}')
p.write_text(s)
p=out/'main.tex';s=p.read_text().replace('\\input{verification-scope}', '\\input{verification-scope}\n\\input{historical-context}');p.write_text(s)
