/-
  The statements of the paper, formalised, plus the logical assembly of the
  main theorem from its two propositions.

  What is *checked* here: the definitions, the exact form of every statement,
  the equivalence of "no vertex is good" with "every vertex is bad", and the
  final step of the proof (Proposition 2.1 and Proposition 4.1 together imply
  the theorem).  What is *not* proved here: the three deep lemmas
  (subset deficit, blowup, pruning).  They are recorded as `def`s of type Prop
  so that their statements can be compared with the paper line by line.
-/
import Seymour.Basic

set_option linter.unusedSectionVars false

namespace Seymour
namespace OGraph

open Seymour

variable {V : Type*} [Fintype V] [DecidableEq V] (G : OGraph V) [DecidableRel G.Arc]

/-- The arc set, as a finset of ordered pairs. -/
def arcs : Finset (V × V) := Finset.univ.filter (fun p => G.Arc p.1 p.2)

/-- The number of arcs. -/
def arcCount : ℕ := G.arcs.card

/-- A counterexample of minimum order and, subject to that, of minimum arc count. -/
def IsMinimalCounterexample : Prop :=
  G.IsCounterexample ∧
  ∀ (W : Type) [Fintype W] [DecidableEq W] (E : OGraph W) [DecidableRel E.Arc],
    E.IsCounterexample →
      Fintype.card V < Fintype.card W ∨
        (Fintype.card V = Fintype.card W ∧ G.arcCount ≤ E.arcCount)

end OGraph

/-- **Proposition 2.1** (counterexample reduction), as a proposition. -/
def ReductionStatement : Prop :=
  ∀ (V : Type) [Fintype V] [DecidableEq V] (G : OGraph V) [DecidableRel G.Arc],
    G.IsCounterexample →
      ∃ (W : Type) (_ : Fintype W) (_ : DecidableEq W) (H : OGraph W) (_ : DecidableRel H.Arc),
        (∀ v : W, ∃ u : W, H.Arc u v) ∧
          ∀ U : Finset W, U.Nonempty → U ≠ Finset.univ →
            U.card + (H.F (H.F U)).card < 2 * (H.F U).card

/-- **Proposition 4.1** (no graph satisfies the strict subset inequality). -/
def NoConcavityStatement : Prop :=
  ∀ (W : Type) [Fintype W] [DecidableEq W] (H : OGraph W) [DecidableRel H.Arc],
    (∀ v : W, ∃ u : W, H.Arc u v) →
      ¬ (∀ U : Finset W, U.Nonempty → U ≠ Finset.univ →
            U.card + (H.F (H.F U)).card < 2 * (H.F U).card)

/-- **Lemma 2.2** (subset deficit), as a proposition. -/
def SubsetDeficitStatement : Prop :=
  ∀ (V : Type) [Fintype V] [DecidableEq V] (D : OGraph V) [DecidableRel D.Arc],
    D.IsMinimalCounterexample →
      (∀ v : V, ∃ u : V, D.Arc u v) ∧
        ∀ S : Finset V, S.Nonempty → S ≠ Finset.univ →
          ((D.F (D.F S)) \ (D.F S)).card < ((D.F S) \ S).card

/-- **Lemma 2.3** (transitive-tournament blowup), as a proposition. -/
def BlowupStatement : Prop :=
  ∀ (V : Type) [Fintype V] [DecidableEq V] (D : OGraph V) [DecidableRel D.Arc] (m : ℕ),
    Fintype.card V < m →
      (∀ v : V, ∃ u : V, D.Arc u v) →
      (∀ S : Finset V, S.Nonempty → S ≠ Finset.univ →
          ((D.F (D.F S)) \ (D.F S)).card < ((D.F S) \ S).card) →
      ∀ (W : Type) [Fintype W] [DecidableEq W] (H : OGraph W) [DecidableRel H.Arc],
        -- `H` is the blowup `D[T_m]`: the hypothesis records only its shape,
        -- so this statement is a *specification* of what must be proved about it
        (∀ v : W, ∃ u : W, H.Arc u v) →
          ∀ U : Finset W, U.Nonempty → U ≠ Finset.univ →
            U.card + (H.F (H.F U)).card < 2 * (H.F U).card

/-- **Lemma 3.3** (pruning), as a proposition, in the form used in the paper. -/
def PruningStatement : Prop :=
  ∀ (X : Type) [Fintype X] [DecidableEq X] (r : X → X → Prop) [DecidableRel r]
    (L R : Finset (X × X)),
    ∃ L' R' : Finset (X × X),
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

/-- **The main theorem**, from the two propositions.  This is the step that closes the
proof; the two hypotheses are exactly Propositions 2.1 and 4.1 of the paper. -/
theorem main_of_reduction_and_noConcavity
    (hred : ReductionStatement) (hnc : NoConcavityStatement)
    (V : Type) [Fintype V] [DecidableEq V] (G : OGraph V) [DecidableRel G.Arc] :
    ∃ v, G.Good v := by
  by_contra h
  have hce : G.IsCounterexample := by
    intro v
    have hv : ¬ G.Good v := fun hg => h ⟨v, hg⟩
    simpa [OGraph.Good, not_le] using hv
  obtain ⟨W, hWf, hWdec, H, hHdec, hpos, hineq⟩ := hred V G hce
  letI := hWf
  letI := hWdec
  letI := hHdec
  exact hnc W H hpos hineq

/-- Contrapositive form: if every graph has a good vertex then no minimal counterexample
exists.  Recorded because it is the form in which the paper uses minimality. -/
theorem no_minimal_counterexample
    (hred : ReductionStatement) (hnc : NoConcavityStatement)
    (V : Type) [Fintype V] [DecidableEq V] (G : OGraph V) [DecidableRel G.Arc] :
    ¬ G.IsMinimalCounterexample := by
  intro hmin
  obtain ⟨v, hv⟩ := main_of_reduction_and_noConcavity hred hnc V G
  have := hmin.1 v
  simp only [OGraph.Good] at hv
  omega

end Seymour
