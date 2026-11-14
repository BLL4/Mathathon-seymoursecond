# Second revision and response to the review

On November 14, 2026, after committing and pushing the first version, I read
`rewrite-claude-opus-5.5/REVIEW_OF_rewrite-codex.md` and made the following
changes in this directory only.

1. **Pruning proof structure:** adopted. Seven numbered claims now expose
   cover charging, normalization of the matching, commutation, the rank
   criterion, simultaneous coefficients, kernel lifts, and the final cover.
   The kernel step begins with its independence goal and explains why the
   right lifts act as probes. The rank-product bound is named as Sylvester's
   inequality and still proved in place.
2. **Notation:** reduced the main clashes. The pruning matrices are now Phi,
   including Phi^(p,i); D remains the graph in the surrounding argument.
   Arc(D) denotes the arc set and an overlined N denotes non-neighbors.
   M and calligraphic M retain their distinct styles and are explicitly
   identified in the notation dictionary and local definitions.
3. **Conflict rectangle:** adopted. The same figure now uses the grid's row
   and column convention, with first-coordinate maps downward and second-
   coordinate linear maps leftward, against the relation. Labels say
   "against s→j" so this cannot be mistaken for the forward set image F2.
4. **Talk motivation:** adopted. The extremal objective and complement gain
   now appear before the pruning statement. The closing calculation returns
   to that initial budget after proving the tool.
5. **Grid in the talk:** adopted. An additional coordinate-image frame
   establishes the visual vocabulary. There are sixteen frames; all timed
   notes were retimed to a total of exactly twenty planned minutes.
6. **Formalization:** advanced, with a remaining boundary. Four new kernel
   restriction theorems prove that corner equations restrict to the two
   auxiliary kernels and force the conflict product to vanish. Three lift
   theorems construct normalized lifts from spanning coverage columns. The
   connected theorem `kernel_dimension_from_pruning_data` derives the
   kernel dimension bound from those ingredients. It does not assume lifts,
   coordinate vanishing, or the dimension bound. It does assume the square
   identity, maximum auxiliary support ranks, and coverage-spanning
   conditions. The independent Codex graph chain is still incomplete. After these
   component checks, I found the other rewrite's complete formalization,
   copied an attributed source snapshot, rebuilt every module locally,
   and proved a bridge to our own neighborhood convention. That reference
   theorem is complete and unconditional, with only Lean's standard axioms.
   It is credited separately from the Codex proofs.
7. **Potential coefficient:** adopted. The article explicitly computes the
   leftover term (lambda−1)(d'−d) for an objective M+lambda d. Without a
   comparison of the uncovered counts, lambda=1 is the choice that cancels
   this term uniformly.

The early snapshot review in `other-work-review.md` predates the other
rewrite's completed artifacts; it is retained as a historical note rather
than a current assessment of that work.

I also read the later November 14 addendum recommending reuse of the
completed formalization. The attributed snapshot, clean local rebuild,
and definition bridge implement that suggestion; the independent Codex
component proofs remain separately identified.

## Later DeepSeep critique

The critique of snapshot `16f8281` repeats several points now addressed
above. A numerical budget trace now supplements the qualitative objective
figure. Its proposed equality for zero-weight blowups is false when an
intermediate block is empty; the path with weights 1,0,1 is a counterexample.
The containment in our direct weighted argument is intentional. See
`updates-review.md` for the complete response and review of subsequent fixes.
