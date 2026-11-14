import Seymour.Statements

/-!
Counterexamples to the exact mathematical definitions in the hash-recorded
review snapshot (only the broad import in Basic is narrowed). These definitions are not axioms. Refuting them does not refute
the correctly stated pruning lemma or the original paper.
-/
namespace SecondNeighborhoodStatementAudit

open Finset

variable {X : Type} [Fintype X] [DecidableEq X]

-- This body is copied directly from the reviewed PruningStatement.
def candidate (r : X → X → Prop) [DecidableRel r]
    (L R L' R' : Finset (X × X)) : Prop :=
      L' ⊆ L ∧ R' ⊆ R ∧
      -- no conflict between the retained families
      (∀ a ∈ L', ∀ b ∈ R', ¬ (r a.1 b.1 ∧ r b.2 a.2)) ∧
      -- every initially conflict-free member is retained
      (∀ a ∈ L, (∀ b ∈ R, ¬ (r a.1 b.1 ∧ r b.2 a.2)) → a ∈ L') ∧
      (∀ b ∈ R, (∀ a ∈ L, ¬ (r a.1 b.1 ∧ r b.2 a.2)) → b ∈ R') ∧
      -- the deletion bound
      (L.card - L'.card) + (R.card - R'.card) ≤
        (Finset.univ.filter (fun p : X × X =>
            ∃ a ∈ L, ∃ b ∈ R, a.2 = p.2 ∧ b.1 = p.1 ∧ r a.1 b.1 ∧ r b.2 a.2)).card +
        (Finset.univ.filter (fun z : X × X =>
            (∃ a ∈ L, ∃ b ∈ R, a.2 = z.2 ∧ b.1 = z.1 ∧ r a.1 b.1 ∧ r b.2 a.2) ∧
            ¬ ((∃ a ∈ L', a.2 = z.2 ∧ r a.1 z.1) ∨ (∃ b ∈ R', b.1 = z.1 ∧ r b.2 z.2)))).card


def emptyGraph : Seymour.OGraph (Fin 0) where
  Arc := fun _ _ => False
  irrefl := by simp
  asymm := by simp

instance : DecidableRel emptyGraph.Arc := fun _ _ => isFalse id

theorem empty_positive_indegree : ∀ v : Fin 0, ∃ u, emptyGraph.Arc u v := by
  intro v
  exact Fin.elim0 v

theorem empty_strict_concavity :
    ∀ U : Finset (Fin 0), U.Nonempty → U ≠ univ →
      U.card + (emptyGraph.F (emptyGraph.F U)).card < 2 * (emptyGraph.F U).card := by
  intro U hn _
  obtain ⟨v, _⟩ := hn
  exact Fin.elim0 v

theorem empty_subset_deficit :
    ∀ U : Finset (Fin 0), U.Nonempty → U ≠ univ →
      ((emptyGraph.F (emptyGraph.F U)) \ emptyGraph.F U).card <
        (emptyGraph.F U \ U).card := by
  intro U hn _
  obtain ⟨v, _⟩ := hn
  exact Fin.elim0 v

/-- Missing nonemptiness makes the claimed no-concavity proposition false. -/
theorem no_concavity_statement_false : ¬ Seymour.NoConcavityStatement := by
  intro h
  exact h (Fin 0) emptyGraph empty_positive_indegree empty_strict_concavity

/-- The stated reduction is trivial: always choose the empty output graph. -/
theorem reduction_statement_without_inputs : Seymour.ReductionStatement := by
  intro V _ _ G _ _
  exact ⟨Fin 0, inferInstance, inferInstance, emptyGraph, inferInstance,
    empty_positive_indegree, empty_strict_concavity⟩

/-- The pointwise counterexample definition is vacuously true on the empty graph. -/
theorem empty_is_counterexample : emptyGraph.IsCounterexample := by
  intro v
  exact Fin.elim0 v

/-- Minimizing over all vertex types lets the empty competitor rule out
any nonempty minimal counterexample, independently of the main theorem. -/
theorem no_nonempty_minimal_counterexample
    {V : Type} [Fintype V] [DecidableEq V] [Nonempty V]
    (D : Seymour.OGraph V) [DecidableRel D.Arc] :
    ¬ D.IsMinimalCounterexample := by
  intro hmin
  have hlex := hmin.2 (Fin 0) emptyGraph empty_is_counterexample
  have hcard : 0 < Fintype.card V := Fintype.card_pos_iff.mpr inferInstance
  simp only [Fintype.card_fin] at hlex
  omega

def triangleArc (a b : Fin 3) : Prop :=
  (a = 0 ∧ b = 1) ∨ (a = 1 ∧ b = 2) ∨ (a = 2 ∧ b = 0)

instance : DecidableRel triangleArc := by
  intro a b
  unfold triangleArc
  infer_instance

def triangle : Seymour.OGraph (Fin 3) where
  Arc := triangleArc
  irrefl := by unfold triangleArc; decide
  asymm := by unfold triangleArc; decide

instance : DecidableRel triangle.Arc := inferInstanceAs (DecidableRel triangleArc)

theorem triangle_positive_indegree : ∀ v : Fin 3, ∃ u, triangle.Arc u v := by
  change ∀ v : Fin 3, ∃ u, triangleArc u v
  unfold triangleArc
  decide

theorem triangle_not_strictly_concave :
    ¬ (∀ U : Finset (Fin 3), U.Nonempty → U ≠ univ →
      U.card + (triangle.F (triangle.F U)).card < 2 * (triangle.F U).card) := by
  intro h
  have hfail : ¬ (({0} : Finset (Fin 3)).card +
      (triangle.F (triangle.F {0})).card < 2 * (triangle.F {0}).card) := by decide
  exact hfail (h {0} (by simp) (by decide))

/-- The malformed blowup statement is false, not merely vacuous: its base
may be empty, while its universal target can be a directed triangle. -/
theorem blowup_statement_false : ¬ Seymour.BlowupStatement := by
  intro h
  have hbad := h (Fin 0) emptyGraph 1 (by decide) empty_positive_indegree empty_subset_deficit
    (Fin 3) triangle triangle_positive_indegree
  exact triangle_not_strictly_concave hbad

def forkArc (a b : Fin 3) : Prop := (a = 0 ∨ a = 1) ∧ b = 2

instance : DecidableRel forkArc := by
  intro a b
  unfold forkArc
  infer_instance

def forkLeft : Finset (Fin 3 × Fin 3) := {(0,2),(1,2)}
def forkRight : Finset (Fin 3 × Fin 3) := {(2,0),(2,1)}

theorem fork_is_asymmetric : ∀ a b, forkArc a b → ¬ forkArc b a := by
  unfold forkArc
  decide

/-- The oriented counterexample needs only four original members. We
check all sixteen pairs of retained subfamilies using kernel reduction. -/
theorem fork_has_no_wrong_pruning :
    ¬ ∃ L' R', candidate forkArc forkLeft forkRight L' R' := by
  have hl : forkLeft.powerset = {∅, {(0,2)}, {(1,2)}, forkLeft} := by decide
  have hr : forkRight.powerset = {∅, {(2,0)}, {(2,1)}, forkRight} := by decide
  rintro ⟨L', R', hc⟩
  have hL := mem_powerset.mpr hc.1
  have hR := mem_powerset.mpr hc.2.1
  rw [hl] at hL
  rw [hr] at hR
  simp only [mem_insert, mem_singleton] at hL hR
  rcases hL with rfl | rfl | rfl | rfl <;>
    rcases hR with rfl | rfl | rfl | rfl <;>
    revert hc <;>
    simp [candidate, forkArc, forkLeft, forkRight] <;>
    decide

/-- Refutes the exact imported definition, not just an informal variant. -/
theorem pruning_statement_false : ¬ Seymour.PruningStatement := by
  intro h
  have hc := h (Fin 3) forkArc forkLeft forkRight
  change ∃ L' R', candidate forkArc forkLeft forkRight L' R' at hc
  exact fork_has_no_wrong_pruning hc

#print axioms no_concavity_statement_false
#print axioms reduction_statement_without_inputs
#print axioms no_nonempty_minimal_counterexample
#print axioms blowup_statement_false
#print axioms pruning_statement_false
end SecondNeighborhoodStatementAudit
