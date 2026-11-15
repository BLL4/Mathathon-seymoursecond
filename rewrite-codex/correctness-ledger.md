# Mathematical and artifact review

The initial review below describes the November 13 checkpoint. The dated
update at the end and `formalization-status.md` give the current status.

This is a review of the supplied proof, not a claim that the complete theorem has been formally certified. The original files were read without modification. The exposition retains the full main proof and its cited consequences. No gap was found in the main proof during this review; that statement describes the review's outcome, not an independent published verification.

## Reduction

- A sink works. A minimal counterexample has more than one vertex. A terminal strong component inherits both exact neighborhoods, so vertex minimality forces strong connectivity.
- Every proper nonempty S has E = F(S) minus S nonempty. Each deletion from S to E minus T therefore removes an arc. Arc minimality applies to the same vertex set, even if the deleted graph is disconnected or has a sink.
- A witness in the deleted graph must have lost a first neighbor: if its first neighborhood is unchanged, exact second neighborhoods can only shrink. Thus the witness lies in S and its lost set Q is nonempty.
- Surviving two-step endpoints lie in I union T union F(T). A new *exact* second neighbor was an old first neighbor and must be in Q intersection F(T). No new walk is created.
- C consists of old two-step endpoints through Q outside I, T, Q, and F(T). These are old exact second neighbors: no first neighbor is outside I union T union Q, and orientation excludes a return to v through Q.
- Independently checked the identity delta g = |C| - |Q intersection F(T)| in 10,000 seeded instances for arbitrary relations and disjointness Q intersection (I union T) empty. It does not rely on orientation. Strict negativity comes from the witness comparison and the old strict failure.
- Each new batch Q is nonempty and disjoint from all previous batches. Summing strict inequalities is legitimate because at least one batch occurs. All deletions restart from the original D.
- Since I is a subset of S, F(I) is contained in F(S). This identifies the final potential g(E) with the desired exterior second image.

## Blowup

- Inside a block with selected minimum a, f(T) is the tail after a and f²(T) is the tail after a+1 (empty when appropriate). The defect is at most one. At a=m the first and second images are both empty and |T|=1, giving the boundary case.
- A block of F(S) is completely filled by the first image; other first-image contributions are exactly internal images. For second images, the proof uses an upper bound, allowing full blocks for F(S) union F²(S). Counting internal contributions in an already full block later only increases that upper bound.
- The integer subset deficit is at most -1. With m>n, multiplying by m beats the at-most-n internal cost. The Lean arithmetic theorem checks the sign with explicit nonnegativity and multiplication hypotheses.
- Full support is checked separately. Positive base indegrees imply F(S)=V(D), even when the selection U is proper. Positive blowup indegrees imply the second image is full too. The defect equals |U|-|V(G)|<0.

## Pruning

- Families and the two copies of Z are tagged/disjoint, even when coordinates coincide. Conflicts are p→i and s→j, not j→s. Set coverage is forward in the appropriate coordinate; the vertical *linear* maps traverse the second coordinate backward.
- Initially isolated originals are isolated even after augmentation: any coverage of a conflict target would provide an opposing original with which to conflict.
- A maximum matching with fewest original-original edges makes each coverage matching maximum in its subgraph. Its augmenting path either increases total size or replaces one original-original edge while preserving size.
- For an original-original endpoint pair, both routes of the square have exactly one possible intermediate index. If it conflicts, both indices belong to their defined corner sets. If not, both products vanish. Thus NL=AB with no missing sum terms.
- Each matching minor factors into coordinate blocks. Variables are distinct inside each block, so the matching determinant monomial cannot cancel. Variables shared between blocks do not make a product of nonzero polynomials zero.
- All auxiliary support-rank minors and both matching minors are chosen simultaneously by a finite nonzero product over the infinite field R. There is no probabilistic claim or assertion that every assignment works.
- The maximum-support-rank kernel lemma keeps the old image and adds e_s under one allowed perturbation. Its application is at the fixed generic assignment; the hypothetical perturbation need not preserve other ranks.
- Restriction to D^(p,i) uses the complete B row and N-transpose column equations, not equations truncated to an arbitrary submatrix. A nonzero row/column forces its corner index into H/Z; all-zero rows/columns need no equation.
- Every ker B vector vanishes on the original matched left endpoints after substituting the normalized right lifts. The left lifts have unit restrictions at those endpoints, so their B-images are independent. Commutativity places those images in ker A.
- Rank-nullity and rank(NL)≥rank L+rank N-|Z| give the matching bound. The alternating-path cover contains exactly one endpoint of each matched edge, no unmatched vertices, and no isolated vertices.
- Every covered point of Z forces a distinct copy vertex into the cover. That proves deletions≤|H|+q with q counted *after* pruning. An ordinary minimum original conflict cover need not suffice; the star/K2,2 example in the article demonstrates this explicitly.
- Exhaustive pruning checks: all 4,096 two-point relation/family triples, including loops and opposite arcs. Further deterministic samples: 500 each at orders three and four. Every test retained initially isolated members. These are finite checks, not a proof for general relations.

## Extremal contradiction

- Orientation makes the initial diagonal pair compatible. Positive indegrees make every nonempty diagonal-containing fiber proper: a full fiber would fill its image fiber and meet the opposing diagonal image. The Lean file proves both proper-fiber statements.
- Strict fiber inequalities are summed over a nonempty vertex set. Compatibility is essential to interpret N-|F1P|-|F2Q| as an uncovered count.
- Complementing yields prospective total size strictly larger than M+2d.
- Checked diagonal membership and isolation separately; the latter is required for the preservation clause. Both are formalized in Lean.
- An H corner in either old image would extend to a forbidden second image. The corner containment is formalized for arbitrary relations; it needs neither orientation nor diagonal hypotheses once the prospective complements have been defined.
- After pruning, the uncovered points in Z are a subset of all d' uncovered points. The two charges are bounded by d and d'. No claim d'≤d is needed.
- All arithmetic uses ordinary integer subtraction. The Lean contradiction exposes the gain, deletion bound, survivor identity, and maximality as explicit inputs; none is smuggled in as an axiom.

## Consequences and scope

- Weighted external equivalences are retained as attributions to the source's references; those papers were not independently checked here. An additional direct argument for the vertex-weighted form explains why zero-weight blocks cause no problem: the clone's exact second neighborhood is contained in, and need not equal, the union of original second-neighbor blocks.
- In a triangle-free oriented graph, an exact second neighbor cannot be an in-neighbor, so it is a non-neighbor. The partition of n-1 vertices gives 2d+ + d- ≤ n-1. The semidegree corollary uses both minimum indegree and minimum outdegree and includes equality thresholds.
- Exhaustively tested the unweighted assertion on every labeled oriented graph of orders 1 through 5: 1, 3, 27, 729, and 59,049 cases respectively.

## Presentation revisions

1. Initial construction: fifteen frames, with notes allocating exactly twenty minutes. The talk includes reduction, the rank mechanism, cover charging, and the final contradiction. It is a proof overview; it does not attempt to speak every line of the article.
2. Mathematical consistency pass: defined coverage explicitly, added the index sets J_p and S_i, and added the coordinate conventions for F1/F2 at the extremal step. Notes distinguish forward set images from backward linear maps and separate generic assignment from hypothetical perturbation.
3. Flow and layout pass: kept one mathematical mechanism per frame, allocated two minutes to simultaneous minors, and preserved brief transitions back to the roadmap. Added explicit source attribution. All seven diagram-bearing frames were rendered and inspected, along with the remaining frames. The total is a planned speaking allocation, not an observed rehearsal time.

## Artifact review

Both LaTeX entry points compile with latexmk and pdfLaTeX. The bibliography resolves. Final logs are checked for undefined references, overfull boxes, and underfull boxes. All figures are inspected in rendered pages, and the notation table is kept with its heading. Build records and scope details are in README.md and the Lean logs.

## Lean declarations checked

The standard-library development compiles with Lean 4.35.0. Its finite star checks use kernel reduction (`decide`), and its named structural lemmas include `diagonal_compatible`, both `*_fiber_proper` lemmas, both `prospective_*_contains_diag` lemmas, both diagonal isolation lemmas, `conflict_corner_is_old_uncovered`, and `exact_second_convention`. The integer lemmas check amplification, cover charging, complement gain, and the final objective contradiction.

The additional mathlib development checks `kernel_perturbation`, `maximum_support_kernel`, `lifts_give_kernel_dimension`, and `matching_bound`. The maximum-support theorem is the exact matrix statement from the source, proved over any field by adding one allowed matrix unit; the abstract perturbation theorem supplies its image-space argument. In the lift theorem, a coordinate map distinguishes the chosen lifts and vanishes on ker B; the proof formally derives independence of their B-images and membership in ker A. Constructing this coordinate-vanishing property from the conflict kernels and constructing the lifts from the chosen matching remain separate obligations. The matching-bound theorem assumes the resulting kernel dimension bound and proves the rank-nullity accounting. The printed trusted axioms are Lean's standard `propext`, `Classical.choice`, and `Quot.sound`; completed checks contain no `sorryAx`.

The separate speaker-notes PDF was compiled as well as the slides. Rendering the notes exposed two plain-text subscript/superscript expressions that were hidden in slide-only mode; these were corrected and the notes rebuilt. Notes for the rank and lift slides were visually inspected.

## November 14 revision and complete reference rebuild

The first checkpoint was committed and pushed as `16f8281`. Work then
resumed with the review from Claude Opus 5.5. The pruning proof now has seven
numbered claims and an explicit independence roadmap. Matrices are Phi,
arc sets use Arc(D), and non-neighbors use an overlined N. The conflict
rectangle agrees with the coordinate grid. The potential discussion now
computes the leftover term for M+lambda d and explains why lambda=1 cancels
it. The talk puts the extremal setup before pruning, adds a coordinate-grid
frame, and has sixteen frames with contiguous notes covering exactly
0:00--20:00.

The new Codex component checks prove the actual auxiliary-kernel
restrictions, the conflict product and coordinate vanishing, normalized
lifts from coverage spans, and their connected kernel-dimension bound.
Additional polynomial checks prove simultaneous nonvanishing with shared
variables, preservation of nonsingular minors under evaluation, and a
matching specialization of a sparse determinant to the identity. Seven
component files now contain 39 theorem declarations. All compile without
warnings or unfinished proofs and print only standard Lean axioms.

After these independent checks, I inspected the other rewrite's completed
formalization, audited its exact-neighborhood and orientation definitions,
and copied an attributed source snapshot. The twelve reference files are
unchanged and hash-recorded; none of their compiled artifacts was copied.
Every reference module was rebuilt here, including reductions, blowup,
pruning, extremal optimization, and the full theorem. Our additional
`ReferenceBridge.lean` proves equality with the image convention in this
exposition and derives the complete unweighted conclusion without any
unproved pruning or reduction hypothesis. Both final theorems print only
`propext`, `Classical.choice`, and `Quot.sound`.

The full reference proof is by Claude Opus 5.5; it is not a second claim of
independent Codex authorship. Its generic coefficients lie in a rational
function field, while the exposition presents the real-assignment route.
Nonfatal deprecation and unused-parameter warnings are preserved with its
unchanged source. See `formalization-status.md` for the independent Codex
frontier and `lean/reference/source-manifest.json` for provenance.

All three revised PDFs compile with no layout or reference warnings. The
changed figures, grid frames, final slide, and formalization appendix were
rendered and visually inspected. The notes PDF was rebuilt with the
reordered frames and new timing plan.

## Later November 14 cross-review

Read the remaining DeepSeep4.1 companion and Claude's review of it. The
wrong Z charge was confirmed with a simpler four-member acyclic example;
all sixteen retained-subfamily pairs were checked independently in Python.
The Lean audit imports the actual statement bodies and proves the wrong
pruning proposition false. It also exposes additional empty-graph issues:
the no-concavity statement and blowup statement are false, the reduction is
trivial, and the minimality domain includes the empty competitor.
Consequently the blowup specification is not merely vacuous, contrary to
the earlier review's description. The original paper's statements remain
correct; these are specification errors in the companion.

Also recorded two repairable explanation errors: the cover contains the
forced copy of a covered point, not its surviving original member, and the
rank perturbation parameter must be nonzero. The correct cycle lemmas were
reused with attribution and definition bridges, replacing their assumed
main theorem by the rebuilt complete reference result. The resulting cycle
corollaries and all statement-audit results print only standard Lean axioms.

Adopted short reading routes and next-use annotations from DeepSeep, and a
local goal / explicit image definition from Claude's newer slides. Added a
reverse-fork H/Z figure and clarified that retained-neighbor classes in the
deletion schematic need not be nonempty. All writes remain in this folder.
See `updates-review.md`, `review-case-results.json`, and the review build logs.

Final update check at `99e1cbb`: the live companion repairs the H/Z charge
and specifies the actual blowup in `f6f6460`. Those two refutations concern
our recorded earlier snapshot. Its live empty-graph issues remain; see
`updates-review.md`. A numerical budget trace was added in response to the
new critique of our older snapshot.

## November 15 visual presentation revision

Replaced the main deck with a 17-frame visual account of the proof ideas.
Diagrams now carry every substantive main frame. The prior 16-frame source
and PDF are preserved as `talk-technical.tex` and `talk-technical.pdf`.
The new grid motivation and exchange-rate emphasis adopt useful ideas from
Claude's recent slides and animations, with attribution in the deck and
`slide-revision.md`. Independently checked the concrete examples using
`check_slide_examples.py`; its timing audit gives continuous 0:00–20:00.
All main frames were rendered and inspected. Main slides, notes and the
technical deck compile without layout or reference warnings. No Lean source
was changed; the mathematical scope of the formalization is unchanged.
The companion's empty-type and explanatory-text defects are now repaired,
and our older refutations remain explicitly identified as snapshot results.
