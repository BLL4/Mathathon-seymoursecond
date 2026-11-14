/-
  A regression check for the *statement* of the pruning lemma (Lemma 3.3).

  An earlier version of `Seymour/Statements.lean` counted the conflict points
  `Z = {(i,j)}` where the collision set `H = {(p,s)}` belongs.  That statement is
  false, and this file records a computer-checked counterexample to it.  It does
  not prove the pruning lemma; it only certifies that the statement we now state
  is not the refuted one.
-/
import Seymour.Statements

open Finset

namespace Seymour

/-- The relation `0 → 1`, `1 → 1` on `Fin 2`.  A loop is allowed here: the pruning
lemma is a statement about arbitrary finite relations, not about oriented graphs. -/
def rZ : Fin 2 → Fin 2 → Prop := fun x y => (x = 0 ∧ y = 1) ∨ (x = 1 ∧ y = 1)
instance : DecidableRel rZ := fun x y => by unfold rZ; infer_instance

/-- The left family of the counterexample. -/
def LZ : Finset (Fin 2 × Fin 2) := {(0,1),(1,1)}
/-- The right family of the counterexample. -/
def RZ : Finset (Fin 2 × Fin 2) := {(1,0),(1,1)}

/-- Every left member conflicts with every right member. -/
theorem LZ_conflicts_RZ : ∀ a ∈ LZ, ∀ b ∈ RZ, rZ a.1 b.1 ∧ rZ b.2 a.2 := by decide

/-- The conflict points `Z` form a single point. -/
theorem Z_of_example :
    (univ.filter (fun p : Fin 2 × Fin 2 => ∃ a ∈ LZ, ∃ b ∈ RZ,
      a.2 = p.2 ∧ b.1 = p.1 ∧ rZ a.1 b.1 ∧ rZ b.2 a.2)) = {(1,1)} := by decide

/-- The collisions `H` are `{(p,s)}` and there are four of them. -/
theorem H_of_example :
    (univ.filter (fun p : Fin 2 × Fin 2 => ∃ a ∈ LZ, ∃ b ∈ RZ,
      a.1 = p.1 ∧ b.2 = p.2 ∧ rZ a.1 b.1 ∧ rZ b.2 a.2)).card = 4 := by decide

/-- Since all four pairs conflict, a compatible pruning must delete a whole family:
two deletions, after which the survivors still cover the unique conflict point, so the
`q`-term is `0`.  The `Z`-version of the bound would claim `2 ≤ |Z| + 0 = 1`, so it
fails.  This is the statement of the earlier version of `Statements.lean`, refuted. -/
theorem z_version_fails :
    ¬ ∃ L' R' : Finset (Fin 2 × Fin 2), L' ⊆ LZ ∧ R' ⊆ RZ ∧
      (∀ a ∈ L', ∀ b ∈ R', ¬ (rZ a.1 b.1 ∧ rZ b.2 a.2)) ∧
      (LZ.card - L'.card) + (RZ.card - R'.card) ≤
        (univ.filter (fun p : Fin 2 × Fin 2 => ∃ a ∈ LZ, ∃ b ∈ RZ,
          a.2 = p.2 ∧ b.1 = p.1 ∧ rZ a.1 b.1 ∧ rZ b.2 a.2)).card := by decide

end Seymour
