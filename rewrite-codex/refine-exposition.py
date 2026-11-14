from pathlib import Path
import re
p=Path('02-pruning.tex');s=p.read_text()
a=s.index('There are five checkpoints:');b=s.index('\\begin{proof}[Proof of Lemma',a)
s=s[:a]+r'''The proof has seven explicit goals, in the order used below:
\begin{enumerate}[label=\arabic*.]
\item A small cover of an augmented graph gives the required pruning.
\item A normalized maximum matching splits into $k+\ell+t$ edges, with both coverage parts maximum.
\item Four linear maps satisfy $NL=AB$.
\item Three rank conditions imply $k+\ell+t\le |Z|+|H|$.
\item One coefficient assignment supplies all the needed ranks and coverage bases.
\item Kernel restrictions and normalized lifts supply $k$ independent vectors in $\ker A$.
\item Alternating paths turn the matching bound into the cover from Goal~1.
\end{enumerate}
Goals 4--6 are the algebraic heart. Goal~1 explains the budget we need,
and Goal~7 converts the algebra back into a deletion rule.

'''+s[b:]
s=s.replace('\\medskip\\noindent\n\\emph{The augmented graph and the required matching bound.}', '\\paragraph{Claim 1: a cover of size $|Z|+|H|$ suffices.}')
s=s.replace('We will obtain this cover by proving', '\\paragraph{Claim 2: the coverage matchings can both be made maximum.}\nWe will obtain this cover by proving')
s=s.replace('\\medskip\\noindent\n\\emph{Four maps and a simultaneous choice of coefficients.}', '\\paragraph{Claim 3: the four maps commute, $NL=AB$.}')
s=s.replace('We seek an assignment for which', '\\paragraph{Claim 4: three rank conditions imply the matching bound.}\nWe seek an assignment for which')
s=s.replace('The last inequality follows by restricting', "The last step is Sylvester's rank inequality. Here is its short proof, obtained by restricting")
s=s.replace('Our choice of coefficients uses', '\\paragraph{Claim 5: one assignment supplies all ranks and coverage bases.}\nOur choice of coefficients uses')
s=s.replace('For every edge $(r,c)$ of $\\mathcal M$ between original members, the', '\\paragraph{Claim 6: normalized lifts give $\\dim\\ker A\\ge k$.}\nFor every edge $(r,c)$ of $\\mathcal M$ between original members, the')
s=s.replace('\\medskip\\noindent\n\\emph{The kernel restriction and the matching bound.}\nIt remains to show that the $k$ lifts just constructed give independent\nvectors $Bu^r$. The key assertion, at our fixed coefficient assignment, is', r'''\paragraph{6a: restrict the full equations to the auxiliary matrices.}
We need one independent vector in $\ker A$ for each of the $k$ remaining
matched edges. The left lifts already give candidates: $u^r\in\ker L$
implies $ABu^r=NLu^r=0$. Only independence of the $Bu^r$ is missing.
It will follow if every vector in $\ker B$ vanishes at the distinguished
left endpoints. The right lifts will act as probes: $v^c_c=1$ turns a
zero product $u_rv^c_c=0$ into $u_r=0$.
First we prove the product statement for arbitrary kernel vectors at the
fixed coefficient assignment:''')
s=s.replace('For each original--original matched edge $(r,c)$, substitute', '\\paragraph{6b: use the right lifts to distinguish the left images.}\nFor each original--original matched edge $(r,c)$, substitute')
s=s.replace('\\medskip\\noindent\n\\emph{From the matching bound to a pruning.}', '\\paragraph{Claim 7: the matching bound gives the cover.}')
s=s.replace('The vertical maps traverse the relation backward in the second coordinate; the horizontal maps traverse it forward in the first.', 'The rows are $p,i$ and the columns are $s,j$, as in the coordinate grid. The vertical maps follow $p\\to i$; the horizontal maps run backward along $s\\to j$.')
s=s.replace('This layout shows composition of linear maps, not positions in the coordinate grid. The operators $F_1,F_2$ instead act on sets.', 'The two paths from $r$ to $c$ are the two factorizations. In contrast, the set operator $F_2$ follows the second-coordinate relation forward.')
# All occurrences of standalone D in this section denote matrices, not graphs.
s=re.sub(r'(?<![A-Za-z\\])D(?=[^A-Za-z]|$)', lambda m:r'\Phi',s)
p.write_text(s)
p=Path('figures/kernel.tex');s=p.read_text();s=re.sub(r'(?<![A-Za-z\\])D(?=[^A-Za-z]|$)',lambda m:r'\Phi',s);p.write_text(s)
p=Path('04-weighted-consequences.tex');s=p.read_text().replace('A(D)',r'\operatorname{Arc}(D)');p.write_text(s)
p=Path('05-directed-cycle-consequences.tex');s=p.read_text().replace('Z(v)',r'\overline N(v)');p.write_text(s)
p=Path('03-incompatibility.tex');s=p.read_text();needle='\\begin{figure}[ht]\\centering\\input{figures/objective}'
a=r'''\paragraph{Why the coefficient of uncovered points is one.}
Suppose instead that the objective were $M+\lambda d$. The same gain and
pruning estimates would only give a new objective strictly greater than
$M+d+(\lambda-1)d'$. Relative to the old $M+\lambda d$, its guaranteed
improvement would be strictly greater than $(\lambda-1)(d'-d)$. We have no
comparison between $d$ and $d'$. Choosing $\lambda=1$ removes both unknown
terms and makes the strict improvement automatic.
'''
assert s.count(needle)==1;s=s.replace(needle,a+'\n'+needle);p.write_text(s)
p=Path('reader-guide.tex');s=p.read_text().replace('$L,N,B,A$ &', '$\\Phi$, $\\Phi^{p,i}$ & Matrices in the pruning proof; $D$ remains a graph.\\\\\n$L,N,B,A$ &');p.write_text(s)
