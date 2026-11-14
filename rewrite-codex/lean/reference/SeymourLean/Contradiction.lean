import SeymourLean.Defs
import Mathlib.Algebra.BigOperators.Ring.Finset
import Mathlib.Algebra.Order.Ring.Int

/-!
# The extremal contradiction (Section 3 of the original preprint)

Assuming the pruning lemma, no nonempty finite oriented graph with positive indegrees is
strictly concave (`no_strictlyConcave`).
-/

open Finset

namespace Seymour

variable {X : Type*} [Fintype X] [DecidableEq X]

/-- Column `j` of `S ⊆ X × X`: `{p | (p,j) ∈ S}`. -/
def col (j : X) (S : Finset (X × X)) : Finset X := univ.filter (fun p => (p, j) ∈ S)

/-- Row `i` of `S ⊆ X × X`: `{s | (i,s) ∈ S}`. -/
def row (i : X) (S : Finset (X × X)) : Finset X := univ.filter (fun s => (i, s) ∈ S)

lemma card_eq_sum_col_nat (S : Finset (X × X)) : S.card = ∑ j, (col j S).card := by
  rw [card_eq_sum_card_fiberwise (f := Prod.snd) (t := univ) (by simp)]
  refine sum_congr rfl fun j _ => ?_
  refine card_nbij' Prod.fst (fun p => (p, j)) ?_ ?_ ?_ ?_
  · rintro ⟨a, b⟩ h
    simp only [coe_filter, Set.mem_ofPred_eq] at h
    simp [col, h.1, ← h.2]
  · intro p hp
    simp only [col, coe_filter, mem_univ, true_and, Set.mem_ofPred_eq] at hp
    simp [hp]
  · rintro ⟨a, b⟩ h
    simp only [coe_filter, Set.mem_ofPred_eq] at h
    simp [h.2]
  · intro p _; rfl

lemma card_eq_sum_row_nat (S : Finset (X × X)) : S.card = ∑ i, (row i S).card := by
  rw [card_eq_sum_card_fiberwise (f := Prod.fst) (t := univ) (by simp)]
  refine sum_congr rfl fun i _ => ?_
  refine card_nbij' Prod.snd (fun s => (i, s)) ?_ ?_ ?_ ?_
  · rintro ⟨a, b⟩ h
    simp only [coe_filter, Set.mem_ofPred_eq] at h
    simp [row, h.1, ← h.2]
  · intro s hs
    simp only [row, coe_filter, mem_univ, true_and, Set.mem_ofPred_eq] at hs
    simp [hs]
  · rintro ⟨a, b⟩ h
    simp only [coe_filter, Set.mem_ofPred_eq] at h
    simp [h.2]
  · intro s _; rfl

lemma card_eq_sum_col (S : Finset (X × X)) : (S.card : ℤ) = ∑ j, ((col j S).card : ℤ) := by
  rw [card_eq_sum_col_nat]; push_cast; rfl

lemma card_eq_sum_row (S : Finset (X × X)) : (S.card : ℤ) = ∑ i, ((row i S).card : ℤ) := by
  rw [card_eq_sum_row_nat]; push_cast; rfl

variable (adj : X → X → Prop) [DecidableRel adj]

lemma col_F1 (j : X) (P : Finset (X × X)) : col j (F1 adj P) = img adj (col j P) := by
  ext i; simp [col, F1, img]

lemma row_F2 (i : X) (Q : Finset (X × X)) : row i (F2 adj Q) = img adj (row i Q) := by
  ext j; simp [row, F2, img]

/-- Summing strict concavity over the columns. -/
lemma fiber_sum_F1 [Nonempty X] (hconc : StrictlyConcave adj) (P : Finset (X × X))
    (hne : ∀ j, (col j P).Nonempty) (hprop : ∀ j, col j P ≠ univ) :
    (P.card : ℤ) + (F1 adj (F1 adj P)).card < 2 * (F1 adj P).card := by
  rw [card_eq_sum_col P, card_eq_sum_col (F1 adj (F1 adj P)), card_eq_sum_col (F1 adj P),
    ← sum_add_distrib, mul_sum]
  refine sum_lt_sum_of_nonempty univ_nonempty fun j _ => ?_
  rw [col_F1, col_F1]
  exact_mod_cast hconc _ (hne j) (hprop j)

lemma fiber_sum_F2 [Nonempty X] (hconc : StrictlyConcave adj) (Q : Finset (X × X))
    (hne : ∀ i, (row i Q).Nonempty) (hprop : ∀ i, row i Q ≠ univ) :
    (Q.card : ℤ) + (F2 adj (F2 adj Q)).card < 2 * (F2 adj Q).card := by
  rw [card_eq_sum_row Q, card_eq_sum_row (F2 adj (F2 adj Q)), card_eq_sum_row (F2 adj Q),
    ← sum_add_distrib, mul_sum]
  refine sum_lt_sum_of_nonempty univ_nonempty fun i _ => ?_
  rw [row_F2, row_F2]
  exact_mod_cast hconc _ (hne i) (hprop i)

/-- The diagonal `Δ`. -/
def diag (X : Type*) [Fintype X] [DecidableEq X] : Finset (X × X) := univ.filter (fun z => z.1 = z.2)

lemma mem_diag {z : X × X} : z ∈ diag X ↔ z.1 = z.2 := by simp [diag]

/-- Compatible families have disjoint images (Lemma "conflict geometry" (b)). -/
lemma disjoint_of_noConflict {P Q : Finset (X × X)}
    (h : ∀ r ∈ P, ∀ c ∈ Q, ¬ Conflict adj r c) : Disjoint (F1 adj P) (F2 adj Q) := by
  rw [Finset.disjoint_left]
  rintro ⟨i, j⟩ h1 h2
  simp only [F1, F2, mem_filter, mem_univ, true_and] at h1 h2
  obtain ⟨p, hp, hpi⟩ := h1
  obtain ⟨s, hs, hsj⟩ := h2
  exact h _ hp _ hs ⟨hpi, hsj⟩

/-- Number of uncovered points of a compatible pair. -/
lemma card_uncovered {A B : Finset (X × X)} (h : Disjoint A B) :
    (((A ∪ B)ᶜ).card : ℤ) = Fintype.card (X × X) - A.card - B.card := by
  have h1 := card_compl_add_card (A ∪ B)
  have h2 := card_union_add_card_inter A B
  rw [Finset.disjoint_iff_inter_eq_empty.mp h, card_empty] at h2
  omega

/-- **Proposition (no strict concavity)**, assuming the pruning lemma: there is no nonempty finite
oriented graph with positive indegrees which is strictly concave. -/
theorem no_strictlyConcave (hP : PruningLemma) (X : Type) [Fintype X] [DecidableEq X]
    [Nonempty X] (adj : X → X → Prop) [DecidableRel adj] (hor : IsOriented adj)
    (hin : PosIndeg adj) (hconc : StrictlyConcave adj) : False := by
  classical
  set N : ℤ := (Fintype.card (X × X) : ℤ) with hN
  let adm : Finset (X × X) × Finset (X × X) → Prop := fun pq =>
    Disjoint (F1 adj pq.1) (F2 adj pq.2) ∧ diag X ⊆ pq.1 ∧ diag X ⊆ pq.2
  let val : Finset (X × X) × Finset (X × X) → ℤ := fun pq =>
    (pq.1.card : ℤ) + pq.2.card + (N - (F1 adj pq.1).card - (F2 adj pq.2).card)
  -- the diagonal pair is admissible
  have hdiag : adm (diag X, diag X) := by
    refine ⟨?_, subset_rfl, subset_rfl⟩
    apply disjoint_of_noConflict
    rintro ⟨a, b⟩ ha ⟨c, d⟩ hc ⟨h1, h2⟩
    simp only [mem_diag] at ha hc
    subst ha; subst hc
    exact hor.2 _ _ h1 h2
  obtain ⟨⟨P, Q⟩, hPQmem, hmax⟩ :=
    exists_max_image (univ.filter adm) val ⟨_, mem_filter.mpr ⟨mem_univ _, hdiag⟩⟩
  simp only [mem_filter, mem_univ, true_and] at hPQmem
  obtain ⟨hdisj, hdP, hdQ⟩ := hPQmem
  have hPd : ∀ v, (v, v) ∈ P := fun v => hdP (by simp [mem_diag])
  have hQd : ∀ v, (v, v) ∈ Q := fun v => hdQ (by simp [mem_diag])
  have hnot : ∀ z, z ∈ F1 adj P → z ∈ F2 adj Q → False := fun z h1 h2 =>
    Finset.disjoint_left.mp hdisj h1 h2
  -- membership helpers
  have mF1 : ∀ {S : Finset (X × X)} {i j p : X}, (p, j) ∈ S → adj p i → (i, j) ∈ F1 adj S :=
    fun {S i j p} h1 h2 => by simp only [F1, mem_filter, mem_univ, true_and]; exact ⟨p, h1, h2⟩
  have mF2 : ∀ {S : Finset (X × X)} {i j s : X}, (i, s) ∈ S → adj s j → (i, j) ∈ F2 adj S :=
    fun {S i j s} h1 h2 => by simp only [F2, mem_filter, mem_univ, true_and]; exact ⟨s, h1, h2⟩
  have eF1 : ∀ {S : Finset (X × X)} {i j : X}, (i, j) ∈ F1 adj S → ∃ p, (p, j) ∈ S ∧ adj p i :=
    fun {S i j} h => by simpa [F1] using h
  have eF2 : ∀ {S : Finset (X × X)} {i j : X}, (i, j) ∈ F2 adj S → ∃ s, (i, s) ∈ S ∧ adj s j :=
    fun {S i j} h => by simpa [F2] using h
  -- columns of P and rows of Q are nonempty and proper
  have hP1 := fiber_sum_F1 adj hconc P (fun j => ⟨j, by simp [col, hPd]⟩) (by
    intro j hj
    obtain ⟨w, hw⟩ := hin j
    obtain ⟨p, hp⟩ := hin w
    have hpj : (p, j) ∈ P := by
      have : p ∈ col j P := by rw [hj]; exact mem_univ _
      simpa [col] using this
    exact hnot (w, j) (mF1 hpj hp) (mF2 (hQd w) hw))
  have hQ1 := fiber_sum_F2 adj hconc Q (fun i => ⟨i, by simp [row, hQd]⟩) (by
    intro i hi
    obtain ⟨w, hw⟩ := hin i
    obtain ⟨s, hs⟩ := hin w
    have his : (i, s) ∈ Q := by
      have : s ∈ row i Q := by rw [hi]; exact mem_univ _
      simpa [row] using this
    exact hnot (i, w) (mF1 (hPd w) hw) (mF2 his hs))
  -- complements
  set R := (F2 adj (F2 adj Q))ᶜ with hR
  set C := (F1 adj (F1 adj P))ᶜ with hC
  obtain ⟨R', hR'R, C', hC'C, hP1', hP2L, hP2R, hP3⟩ := hP X adj R C
  -- the diagonal lies in R and C and is conflict free
  have hdR : ∀ v, (v, v) ∈ R := by
    intro v; rw [hR, mem_compl]; intro h
    obtain ⟨s, hs, hsv⟩ := eF2 h
    exact hnot (v, s) (mF1 (hPd s) hsv) hs
  have hdC : ∀ v, (v, v) ∈ C := by
    intro v; rw [hC, mem_compl]; intro h
    obtain ⟨p, hp, hpv⟩ := eF1 h
    exact hnot (p, v) hp (mF2 (hQd p) hpv)
  have hdR' : diag X ⊆ R' := by
    rintro ⟨v, w⟩ hv
    simp only [mem_diag] at hv; subst hv
    refine hP2L _ (hdR v) ?_
    rintro ⟨i, s⟩ hc ⟨h1, h2⟩
    rw [hC, mem_compl] at hc
    exact hc (mF1 (mF1 (hPd s) h2) h1)
  have hdC' : diag X ⊆ C' := by
    rintro ⟨v, w⟩ hv
    simp only [mem_diag] at hv; subst hv
    refine hP2R _ (hdC v) ?_
    rintro ⟨p, j⟩ hr ⟨h1, h2⟩
    rw [hR, mem_compl] at hr
    exact hr (mF2 (mF2 (hQd p) h1) h2)
  have hdisj' : Disjoint (F1 adj R') (F2 adj C') := disjoint_of_noConflict adj hP1'
  -- H is contained in the old uncovered points
  have hH : Hset adj R C ⊆ (F1 adj P ∪ F2 adj Q)ᶜ := by
    intro h hh
    simp only [Hset, mem_filter, mem_univ, true_and] at hh
    obtain ⟨⟨p, j⟩, hr, ⟨i, s⟩, hc, ⟨h1, h2⟩, rfl⟩ := hh
    simp only [mem_compl, mem_union, not_or]
    rw [hC, mem_compl] at hc; rw [hR, mem_compl] at hr
    constructor
    · intro hps
      exact hc (mF1 hps h1)
    · intro hps
      exact hr (mF2 hps h2)
  have hZ : Zset adj R C \ (F1 adj R' ∪ F2 adj C') ⊆ (F1 adj R' ∪ F2 adj C')ᶜ := by
    intro z hz; simp only [mem_sdiff] at hz; simpa using hz.2
  have cH := card_le_card hH
  have cZ := card_le_card hZ
  have u1 := card_uncovered hdisj
  have u2 := card_uncovered hdisj'
  have cR := card_compl_add_card (F2 adj (F2 adj Q))
  have cC := card_compl_add_card (F1 adj (F1 adj P))
  have sR := card_sdiff_add_card_eq_card hR'R
  have sC := card_sdiff_add_card_eq_card hC'C
  have hle := hmax (R', C') (by
    simp only [mem_filter, mem_univ, true_and]
    exact ⟨hdisj', hdR', hdC'⟩)
  simp only [val] at hle
  rw [← hR] at cR; rw [← hC] at cC
  have : (N : ℤ) = Fintype.card (X × X) := rfl
  push_cast at *
  omega

end Seymour
