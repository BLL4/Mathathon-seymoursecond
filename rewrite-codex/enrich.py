from pathlib import Path
p=Path('rewrite-codex')
def insert(name,needle,addition):
 f=p/name;s=f.read_text();assert s.count(needle)==1,(name,needle);f.write_text(s.replace(needle,addition+'\n'+needle))
insert('01-reduction.tex','\\begin{lemma}[Subset deficit]',r'''
\paragraph{Why delete arcs?}
Vertex minimality gives strong connectivity. Arc minimality supplies a good
vertex whenever at least one arc is removed. The useful deletion depends on
a set $T$ of already processed exterior neighbors. Its witness $v$ identifies
a nonempty batch $Q$ of new vertices. The potential $g(T)$ measures the
unprocessed image outside $I\cup T$, not all of $F(T)$. Its increment is
smaller than the batch size, so these local inequalities telescope.
\begin{figure}[ht]\centering\input{figures/deletion}
\caption{Schematic for a deletion step. The dashed arcs from $v$ to $Q$ are removed. Every surviving two-step endpoint lies in the top-right set. The set $C$ consists of old endpoints through $Q$ outside that set and outside $Q$, so all of $C$ is lost. Other arcs are unspecified.}
\end{figure}
''')
insert('01-reduction.tex','\\begin{lemma}[Transitive-tournament blowup]',r'''
\begin{figure}[ht]\centering\input{figures/blowup}
\caption{The blowup, illustrated with three vertices per block. The actual proof uses $m>n$. The thick arrow abbreviates a complete directed bipartite graph, not a single arc. Inside each block all arcs point in the label order.}
\end{figure}
\paragraph{What the amplification buys.}
Write $\delta(S)=|F^2(S)\setminus F(S)|-|F(S)\setminus S|$.
The previous lemma says $\delta(S)\le-1$ for proper nonempty $S$.
In the blowup we will show that the target expression is at most
$m\delta(S)+n$. Choosing $m>n$ makes this negative. This reasoning does not
apply to full support $S=V(D)$; that case has a separate, simpler proof.
For example, in a block of size five, $T=\{2,4\}$ gives
$f(T)=\{3,4,5\}$ and $f^2(T)=\{4,5\}$, so
$|T|-2|f(T)|+|f^2(T)|=-2$. The uniform upper bound is $1$, attained when
$T=\{5\}$. Thus sparse selections and terminal vertices are included.
''')
insert('02-pruning.tex','\\begin{lemma}[Pruning]',r'''
\paragraph{Read the conclusion before the proof.}
An ordinary conflict cover would only tell us how many members must go.
Here we need a cover whose cost improves whenever the kept families cover
more points of $Z$. Put $q=|Z\setminus(F_1\mathcal R'\cup F_2\mathcal C')|$.
The desired inequality is ``deletions $\le |H|+q$''. The term $q$ depends
on the output, so one cannot choose it in advance. The augmentation by two
copies of $Z$ converts output coverage into a discount on deletions.
''')
insert('02-pruning.tex','\\begin{lemma}[Kernels at maximum support rank]',r'''
\paragraph{The linear-algebra mechanism in one sentence.}
At maximum support rank, a right-kernel vector and a left-kernel vector
cannot both be nonzero across an allowed entry: perturbing that entry would
create a new image direction while keeping the entire old image.
\begin{figure}[ht]\centering\input{figures/kernel}
\caption{An image-space schematic for the rank lemma. The rectangle represents a subspace, not a numerical matrix. If both kernel coordinates were nonzero, one allowed perturbation would strictly increase the image dimension.}
\end{figure}
''')
insert('02-pruning.tex','\\begin{proof}[Proof of Lemma~\\ref{lem:pruning}]',r'''
\paragraph{Proof itinerary.}
There are five checkpoints: augment the conflict graph; choose a maximum
matching with as few original--original edges as possible; encode the two
coverage matchings by ranks; place independent vectors in a kernel using
a commuting square; turn the matching into a cover. The rank calculation
proves a bound for the whole augmented graph. Only the final cover step
turns that bound into a statement about deletions.
''')
insert('02-pruning.tex','We seek an assignment for which',r'''
\begin{figure}[ht]\centering\input{figures/conflict-square}
\caption{One conflict and its two intermediate corners. The vertical maps traverse the relation backward in the second coordinate; the horizontal maps traverse it forward in the first. The two products have the same coefficient $a_{pi}b_{sj}$, yielding $NL=AB$. These are linear maps, whereas $F_1,F_2$ are set-image operators.}
\end{figure}
''')
insert('02-pruning.tex','For every edge $(r,c)$ of $\\mathcal M$ between original members, the',r'''
\paragraph{Why shared coefficients cause no problem.}
We do not choose a different assignment for each matrix. For each desired
rank condition choose a minor that is a nonzero polynomial. Their finite
product is nonzero even if variables recur in different factors. Over the
infinite field $\mathbb R$, some assignment makes the product nonzero.
All the chosen conditions then hold at that one assignment. Later,
perturbing a single auxiliary matrix is only a contradiction argument for
its maximum rank; it does not change the fixed assignment of the square.
''')
insert('03-incompatibility.tex','\\begin{proposition}\\label{prop:no-concavity}',r'''
\paragraph{Why pairs, and why this objective?}
The strict inequality applies to one set at a time. Columns of $P$ and rows
of $Q$ provide many such sets while making their images share one ambient
square. Compatibility makes those images disjoint. Taking complements of
second images then produces a gain of more than $2d$. Pruning can cost
$d+d'$, so adding $d'$ to the new objective exactly pays for its output cost.
This explains the choice $|P|+|Q|+d$ before any algebra is performed.
\begin{figure}[ht]\centering\input{figures/objective}
\caption{The accounting of the contradiction. The second uncovered count $d'$ belongs to the retained families, so it must occur in both the deletion bound and the new objective.}
\end{figure}
''')
insert('03-incompatibility.tex','Both families contain $\\Delta$.',r'''
\paragraph{Two diagonal checks, with different purposes.}
First show membership: the diagonal belongs to the prospective families.
Then show isolation: these diagonal members have no conflicts there.
Membership alone would not make pruning preserve them. Isolation invokes
the preservation clause of the pruning lemma. This is what makes the new
pair admissible for the very same extremal problem.
''')
