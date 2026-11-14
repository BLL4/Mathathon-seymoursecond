from pathlib import Path
import re
p=Path('talk.tex');s=p.read_text()
s=s.replace('D^{p,i}',r'\Phi^{p,i}').replace('Auxiliary matrices D',r'Auxiliary matrices $\Phi^{p,i}$')
s=s.replace('If $D$ has maximum rank',r'If $\Phi$ has maximum rank').replace('Dx=0',r'\Phi x=0').replace('D^{\\mathsf T}y=0',r'\Phi^{\mathsf T}y=0')
s=s.replace('local to D;',r'local to $\Phi$;').replace('restrict to D and D transpose',r'restrict to $\Phi^{p,i}$ and its transpose')
frames=re.findall(r'\\begin\{frame\}.*?\\end\{frame\}',s,re.S)
assert len(frames)==15
newgrid=r'''\begin{frame}{Coordinates turn one inequality into many}
\begin{center}\input{figures/grid}\end{center}
\small
Columns $P_j$ of the left family use $F_1$; rows $Q_i$ of the right family
use $F_2$. The diagonal makes every such fiber nonempty.
\note{6:45--7:45. Fix first coordinate as the row and second as the column. A relation arrow moves F1 vertically inside a column and F2 horizontally inside a row. These are set images, so paths merge and points are counted once. With the diagonal included, each left column and each right row has its diagonal vertex. The next frame turns the sum of these fiber inequalities into a gain in family size.}
\end{frame}'''
frames[12]=frames[12].replace('$F_1$ advances the first coordinate; $F_2$ advances the second.\n','')
frames[12]=frames[12].replace('The diagonal is present and isolated in these prospective families.\nConflict corners $H$ are old uncovered points, hence $|H|\\le d$.',r'''We need a pruning that retains $\Delta$ and deletes at most $d+d'$, where
$d'$ is the new uncovered count. Then the new objective exceeds $M+d$.''')
frames[12]=frames[12].replace('For a diagonal conflict in the prospective families, a two-step path would put the opposing member in the second image whose complement defines it. Similarly an H corner in an old image extends one more step to contradict a complement definition. These checks make pruning admissible.', 'The desired gain is now visible before we introduce the pruning lemma. Its output-dependent term is exactly the new uncovered count in our objective. We return to diagonal preservation and the old uncovered bound after proving the tool.')
frames[13]=frames[13].replace('\\begin{center}\\input{figures/objective}\\end{center}',r'''\small
In the prospective families, $\Delta$ is isolated and $H$ consists of old
uncovered points. Thus $|H|\le d$; new uncovered targets number at most $d'$.
\begin{center}\input{figures/objective}\end{center}''')
frames[13]=frames[13].replace("At most d' conflict targets", "A conflict with a diagonal member gives a two-step path into a forbidden second image, so the diagonal survives. An H corner in either old image extends one more step into a forbidden second image, so H is old uncovered. At most d' conflict targets")
ordered=frames[:6]+[newgrid,frames[12]]+frames[6:12]+frames[13:]
assert len(ordered)==16
durations=[30,75,45,75,90,90,60,90,90,75,120,75,90,75,90,30]
assert sum(durations)==1200
clock=0
for idx,(f,secs) in enumerate(zip(ordered,durations)):
    if idx:
        f=re.sub(r'(\\begin\{frame\}\{)\d+\.\s*',lambda m:m[1]+str(idx)+'. ',f,count=1)
    start=f'{clock//60}:{clock%60:02}';clock+=secs;end=f'{clock//60}:{clock%60:02}'
    f=re.sub(r'(\\note\{)\d+:\d+--\d+:\d+\.',lambda m:m[1]+start+'--'+end+'.',f,count=1)
    ordered[idx]=f
p.write_text(s[:s.index('\\begin{frame}')]+ '\n\n'.join(ordered)+'\n\\end{document}\n')
for name in ['02-pruning.tex','figures/kernel.tex']:
    p=Path(name);p.write_text(p.read_text().replace('Dw=',r'\Phi w='))
