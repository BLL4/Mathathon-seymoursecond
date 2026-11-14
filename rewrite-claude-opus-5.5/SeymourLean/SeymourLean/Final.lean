import SeymourLean.Main
import SeymourLean.MatchingBound

/-!
# The unconditional main theorem

Seymour's second neighbourhood conjecture: every nonempty finite oriented graph has a vertex `v`
with `|N⁺₁(v)| ≤ |N⁺₂(v)|`.
-/

namespace Seymour

/-- **Main theorem** (Seymour's second neighbourhood conjecture). -/
theorem seymour_second_neighbourhood (V : Type) [Fintype V] [DecidableEq V] [Nonempty V]
    (adj : V → V → Prop) [DecidableRel adj] (hor : IsOriented adj) :
    ∃ v, (N1 adj v).card ≤ (N2 adj v).card :=
  seymour_of_pruningLemma pruningLemma V adj hor

/-- The same, stated via `SeymourStatement`. -/
theorem seymourStatement : SeymourStatement := seymour_of_pruningLemma pruningLemma

end Seymour

#print axioms Seymour.seymour_second_neighbourhood
