/-
  Regression checks for the *specifications* in `Seymour/Statements.lean`.

  A review found that three of the early specifications were satisfied only because
  the empty graph was allowed: `IsCounterexample` and "strictly concave" are both
  vacuous on the empty vertex set, so

  * `NoConcavityStatement` was *false* (it denied a true statement about the empty graph);
  * `ReductionStatement` was trivially true (the empty graph is always an output);
  * `IsMinimalCounterexample` was satisfied by no graph at all (the empty graph is its
    own smaller competitor).

  All three are fixed (nonemptiness is now required where the paper requires it).  This
  file records the refutations of the earlier versions, so that the fix cannot be undone
  silently.  Nothing here is used by the paper; it is a specification test.
-/
import Seymour.Statements

set_option linter.unusedSectionVars false

namespace Seymour

/-- The (unique) oriented graph on the empty type. -/
def emptyGraph : OGraph Empty where
  Arc := fun a => nomatch a
  irrefl := fun a => nomatch a
  asymm := fun h => nomatch h

instance : DecidableRel emptyGraph.Arc := fun a => nomatch a

/-- Every finset of the empty type is empty. -/
theorem finset_empty_type_eq_empty (U : Finset Empty) : U = ∅ := by
  rw [← Finset.card_eq_zero]
  have : U.card ≤ Fintype.card Empty := Finset.card_le_univ U
  simpa using this

/-- **The earlier `NoConcavityStatement` was false.** Without the nonemptiness
hypothesis, the empty graph satisfies the positive-indegree hypothesis and the strict
inequality vacuously, so the statement denies something true. -/
theorem old_noConcavity_is_false :
    ¬ (∀ (W : Type) [Fintype W] [DecidableEq W] (H : OGraph W) [DecidableRel H.Arc],
        (∀ v : W, ∃ u : W, H.Arc u v) →
          ¬ (∀ U : Finset W, U.Nonempty → U ≠ Finset.univ →
                U.card + (H.F (H.F U)).card < 2 * (H.F U).card)) := by
  intro h
  have hpos : ∀ v : Empty, ∃ u : Empty, emptyGraph.Arc u v := fun v => v.elim
  have hineq : ∀ U : Finset Empty, U.Nonempty → U ≠ Finset.univ →
      U.card + (emptyGraph.F (emptyGraph.F U)).card < 2 * (emptyGraph.F U).card := by
    intro U h1 _
    have hempty : U = ∅ := finset_empty_type_eq_empty U
    rw [hempty] at h1
    exact absurd h1 (by simp)
  exact (h Empty emptyGraph hpos) hineq

/-- **The earlier `ReductionStatement` was trivially true**: with an empty output the
conclusion holds for every input, counterexample or not.  This proves the earlier shape
(without the nonemptiness requirement on the output) outright, from no hypothesis. -/
theorem old_reduction_is_trivial :
    ∀ (V : Type) [Fintype V] [DecidableEq V] (G : OGraph V) [DecidableRel G.Arc],
      G.IsCounterexample →
        ∃ (W : Type) (_ : Fintype W) (_ : DecidableEq W) (H : OGraph W) (_ : DecidableRel H.Arc),
          (∀ v : W, ∃ u : W, H.Arc u v) ∧
            ∀ U : Finset W, U.Nonempty → U ≠ Finset.univ →
              U.card + (H.F (H.F U)).card < 2 * (H.F U).card := by
  intro V _ _ G _ _
  exact ⟨Empty, inferInstance, inferInstance, emptyGraph, inferInstance,
    (fun v => v.elim), (fun U h1 => absurd h1 (by
      have hempty : U = ∅ := finset_empty_type_eq_empty U
      rw [hempty]; simp))⟩

/-- **The earlier minimality was satisfied by no nonempty graph**: the empty graph is a
counterexample vacuously, has smaller order, and was allowed as a competitor. -/
theorem old_minimality_is_empty (V : Type) [Fintype V] [DecidableEq V] [Nonempty V]
    (G : OGraph V) [DecidableRel G.Arc] :
    ¬ (G.IsCounterexample ∧
      ∀ (W : Type) [Fintype W] [DecidableEq W] (E : OGraph W) [DecidableRel E.Arc],
        E.IsCounterexample →
          Fintype.card V < Fintype.card W ∨
            (Fintype.card V = Fintype.card W ∧ G.arcCount ≤ E.arcCount)) := by
  rintro ⟨-, hmin⟩
  have hemptyCE : emptyGraph.IsCounterexample := fun v => Empty.elim v
  have := hmin Empty emptyGraph hemptyCE
  have hpos : 0 < Fintype.card V := Fintype.card_pos_iff.mpr ‹Nonempty V›
  rcases this with h | ⟨h, -⟩
  · rw [Fintype.card_empty] at h
    omega
  · rw [Fintype.card_empty] at h
    omega

end Seymour
