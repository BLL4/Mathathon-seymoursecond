import SeymourLean.Contradiction
import Mathlib.LinearAlgebra.Matrix.Kronecker

/-!
# Formal versions of the remarks added in the insights pass

(`sec3-pairs.tex`, `sec4-pruning.tex`, `sec5-contradiction.tex`.)

* `F1_F2_comm` : the two coordinate images commute, `F₁ (F₂ S) = F₂ (F₁ S)`.
* `kronecker_comm` : the linear versions `aᵀ ⊗ I` and `I ⊗ b` commute (Remark `rem:kronecker`).
* `diag_compatible_iff_oriented`, `exists_admissible_iff_oriented` : `(Δ,Δ)` is compatible iff
  the relation is oriented, and an admissible pair exists iff the relation is oriented
  (Lemma `lem:admissible-iff-oriented`).
* `conflict_swap`, `Zset_swap`, `Hset_swap` : reversing the relation turns the conflict `(r,c)`
  into the conflict `(c,r)` and exchanges `Z` and `H` (Remark `rem:reversal`).
* `gain_identity` : `|R| + |C| + Σκ = μ + 2d` (Remarks `rem:error-term`, `rem:algorithm`).
* `moved_identity` : `|R| + |C| - d` is the formal value of the moved pair `(F₁P, F₂Q)`
  (Remark `rem:move-repair`).
* `step_ledger`, `step_value` : for an arbitrary relation and an admissible pair, pruning the
  complements gives an admissible pair of value at least `|R| + |C| - d = val - Σκ`
  (Remarks `rem:move-repair`, `rem:algorithm`). Strict concavity is not assumed.
-/

open Finset
open scoped Matrix
open scoped Kronecker

namespace Seymour

/-- The linear versions of the two moves commute: `(aᵀ ⊗ I)(I ⊗ b) = (I ⊗ b)(aᵀ ⊗ I)`. -/
theorem kronecker_comm {α : Type*} [CommSemiring α] {X : Type*} [Fintype X] [DecidableEq X]
    (a b : Matrix X X α) :
    (aᵀ ⊗ₖ (1 : Matrix X X α)) * ((1 : Matrix X X α) ⊗ₖ b) =
      ((1 : Matrix X X α) ⊗ₖ b) * (aᵀ ⊗ₖ (1 : Matrix X X α)) := by
  rw [← Matrix.mul_kronecker_mul, ← Matrix.mul_kronecker_mul]
  simp only [Matrix.mul_one, Matrix.one_mul]

section Grid

variable {X : Type*} [Fintype X] [DecidableEq X] (adj : X → X → Prop) [DecidableRel adj]

lemma mem_F1 {S : Finset (X × X)} {z : X × X} :
    z ∈ F1 adj S ↔ ∃ p, (p, z.2) ∈ S ∧ adj p z.1 := by
  simp [F1]

lemma mem_F2 {S : Finset (X × X)} {z : X × X} :
    z ∈ F2 adj S ↔ ∃ s, (z.1, s) ∈ S ∧ adj s z.2 := by
  simp [F2]

/-- The two coordinate images commute. -/
theorem F1_F2_comm (S : Finset (X × X)) : F1 adj (F2 adj S) = F2 adj (F1 adj S) := by
  ext ⟨i, j⟩
  simp only [mem_F1, mem_F2]
  constructor
  · rintro ⟨p, ⟨s, hps, hsj⟩, hpi⟩
    exact ⟨s, ⟨p, hps, hpi⟩, hsj⟩
  · rintro ⟨s, ⟨p, hps, hpi⟩, hsj⟩
    exact ⟨p, ⟨s, hps, hsj⟩, hpi⟩

lemma F1_mono {S T : Finset (X × X)} (h : S ⊆ T) : F1 adj S ⊆ F1 adj T := by
  intro z hz
  rw [mem_F1] at hz ⊢
  obtain ⟨p, hp, hpi⟩ := hz
  exact ⟨p, h hp, hpi⟩

lemma F2_mono {S T : Finset (X × X)} (h : S ⊆ T) : F2 adj S ⊆ F2 adj T := by
  intro z hz
  rw [mem_F2] at hz ⊢
  obtain ⟨s, hs, hsj⟩ := hz
  exact ⟨s, h hs, hsj⟩

/-- `(Δ,Δ)` is compatible exactly when the relation is irreflexive and asymmetric. -/
theorem diag_compatible_iff_oriented :
    Disjoint (F1 adj (diag X)) (F2 adj (diag X)) ↔ IsOriented adj := by
  constructor
  · intro h
    have key : ∀ i j, adj j i → adj i j → False := by
      intro i j hji hij
      have h1 : (i, j) ∈ F1 adj (diag X) := (mem_F1 adj).mpr ⟨j, by simp [mem_diag], hji⟩
      have h2 : (i, j) ∈ F2 adj (diag X) := (mem_F2 adj).mpr ⟨i, by simp [mem_diag], hij⟩
      exact Finset.disjoint_left.mp h h1 h2
    exact ⟨fun x hx => key x x hx hx, fun x y hxy hyx => key y x hxy hyx⟩
  · intro hor
    rw [Finset.disjoint_left]
    rintro ⟨i, j⟩ h1 h2
    obtain ⟨p, hp, hpi⟩ := (mem_F1 adj).mp h1
    obtain ⟨s, hs, hsj⟩ := (mem_F2 adj).mp h2
    simp only [mem_diag] at hp hs
    subst hp
    subst hs
    exact hor.2 _ _ hsj hpi

/-- An admissible pair (compatible, both containing the diagonal) exists if and only if the
relation is oriented. This is the only place where Stage 3 uses orientation. -/
theorem exists_admissible_iff_oriented :
    (∃ P Q : Finset (X × X), diag X ⊆ P ∧ diag X ⊆ Q ∧ Disjoint (F1 adj P) (F2 adj Q)) ↔
      IsOriented adj := by
  constructor
  · rintro ⟨P, Q, hP, hQ, h⟩
    rw [← diag_compatible_iff_oriented]
    exact h.mono (F1_mono adj hP) (F2_mono adj hQ)
  · intro hor
    exact ⟨diag X, diag X, subset_rfl, subset_rfl,
      (diag_compatible_iff_oriented adj).mpr hor⟩

/-! ### Reversing the relation -/

instance swapDecidable : DecidableRel (Function.swap adj) :=
  fun x y => inferInstanceAs (Decidable (adj y x))

/-- For the reversed relation, `c` (as a left member) and `r` (as a right member) conflict
exactly when `r` and `c` conflict for the original relation. -/
theorem conflict_swap (r c : X × X) : Conflict (Function.swap adj) c r ↔ Conflict adj r c :=
  Iff.rfl

/-- Reversing the relation turns the opposite corners into the conflict points. -/
theorem Zset_swap (R C : Finset (X × X)) : Zset (Function.swap adj) C R = Hset adj R C := by
  ext z
  simp only [Zset, Hset, mem_filter, mem_univ, true_and]
  constructor
  · rintro ⟨c, hc, r, hr, hcr, rfl⟩
    exact ⟨r, hr, c, hc, (conflict_swap adj r c).mp hcr, rfl⟩
  · rintro ⟨r, hr, c, hc, hrc, rfl⟩
    exact ⟨c, hc, r, hr, (conflict_swap adj r c).mpr hrc, rfl⟩

/-- Reversing the relation turns the conflict points into the opposite corners. -/
theorem Hset_swap (R C : Finset (X × X)) : Hset (Function.swap adj) C R = Zset adj R C := by
  ext h
  simp only [Zset, Hset, mem_filter, mem_univ, true_and]
  constructor
  · rintro ⟨c, hc, r, hr, hcr, rfl⟩
    exact ⟨r, hr, c, hc, (conflict_swap adj r c).mp hcr, rfl⟩
  · rintro ⟨r, hr, c, hc, hrc, rfl⟩
    exact ⟨c, hc, r, hr, (conflict_swap adj r c).mpr hrc, rfl⟩

/-! ### The gain, exactly -/

/-- `κ(U) = |U| - 2|FU| + |F²U|`. -/
def kappa (U : Finset X) : ℤ :=
  (U.card : ℤ) - 2 * (img adj U).card + (img adj (img adj U)).card

lemma sum_kappa_col (P : Finset (X × X)) :
    ∑ j, kappa adj (col j P) =
      (P.card : ℤ) - 2 * (F1 adj P).card + (F1 adj (F1 adj P)).card := by
  rw [card_eq_sum_col P, card_eq_sum_col (F1 adj P), card_eq_sum_col (F1 adj (F1 adj P))]
  simp only [kappa, col_F1, sum_add_distrib, sum_sub_distrib, mul_sum]

lemma sum_kappa_row (Q : Finset (X × X)) :
    ∑ i, kappa adj (row i Q) =
      (Q.card : ℤ) - 2 * (F2 adj Q).card + (F2 adj (F2 adj Q)).card := by
  rw [card_eq_sum_row Q, card_eq_sum_row (F2 adj Q), card_eq_sum_row (F2 adj (F2 adj Q))]
  simp only [kappa, row_F2, sum_add_distrib, sum_sub_distrib, mul_sum]

/-- `|R| + |C| + Σκ = μ + 2d` for `R = (F₂²Q)ᶜ`, `C = (F₁²P)ᶜ`: the exact form of the gain
(Claim `cl:gain`, Remark `rem:error-term`). -/
theorem gain_identity (P Q : Finset (X × X)) :
    (((F2 adj (F2 adj Q))ᶜ.card : ℤ) + ((F1 adj (F1 adj P))ᶜ.card : ℤ)) +
        (∑ j, kappa adj (col j P) + ∑ i, kappa adj (row i Q)) =
      ((P.card : ℤ) + Q.card) +
        2 * ((Fintype.card (X × X) : ℤ) - (F1 adj P).card - (F2 adj Q).card) := by
  have cR := card_compl_add_card (F2 adj (F2 adj Q))
  have cC := card_compl_add_card (F1 adj (F1 adj P))
  rw [sum_kappa_col, sum_kappa_row]
  omega

/-- `|R| + |C| - d` equals the formal value `|X|² - ε₁(F₁P) - ε₂(F₂Q)` of the moved pair
(Remark `rem:move-repair`). -/
theorem moved_identity (P Q : Finset (X × X)) :
    (((F2 adj (F2 adj Q))ᶜ.card : ℤ) + ((F1 adj (F1 adj P))ᶜ.card : ℤ)) -
        ((Fintype.card (X × X) : ℤ) - (F1 adj P).card - (F2 adj Q).card) =
      (Fintype.card (X × X) : ℤ) - (((F1 adj (F1 adj P)).card : ℤ) - (F1 adj P).card) -
        (((F2 adj (F2 adj Q)).card : ℤ) - (F2 adj Q).card) := by
  have cR := card_compl_add_card (F2 adj (F2 adj Q))
  have cC := card_compl_add_card (F1 adj (F1 adj P))
  omega

end Grid

/-! ### The ledger without strict concavity -/

/-- **The ledger** (Steps 3–4 of `sec:ledger`, Remark `rem:algorithm`): for an arbitrary relation
and an admissible pair `(P,Q)`, pruning the complements `R = (F₂²Q)ᶜ`, `C = (F₁²P)ᶜ` gives an
admissible pair `(P',Q')` with `val(P',Q') ≥ |R| + |C| - d`. -/
theorem step_ledger (hP : PruningLemma) (X : Type) [Fintype X] [DecidableEq X]
    (adj : X → X → Prop) [DecidableRel adj] (P Q : Finset (X × X))
    (hdisj : Disjoint (F1 adj P) (F2 adj Q)) (hdP : diag X ⊆ P) (hdQ : diag X ⊆ Q) :
    ∃ P' Q' : Finset (X × X), Disjoint (F1 adj P') (F2 adj Q') ∧ diag X ⊆ P' ∧ diag X ⊆ Q' ∧
      (((F2 adj (F2 adj Q))ᶜ.card : ℤ) + ((F1 adj (F1 adj P))ᶜ.card : ℤ)) -
          ((Fintype.card (X × X) : ℤ) - (F1 adj P).card - (F2 adj Q).card) ≤
        (P'.card : ℤ) + Q'.card +
          ((Fintype.card (X × X) : ℤ) - (F1 adj P').card - (F2 adj Q').card) := by
  classical
  have hPd : ∀ v, (v, v) ∈ P := fun v => hdP (by simp [mem_diag])
  have hQd : ∀ v, (v, v) ∈ Q := fun v => hdQ (by simp [mem_diag])
  have hnot : ∀ z, z ∈ F1 adj P → z ∈ F2 adj Q → False := fun z h1 h2 =>
    Finset.disjoint_left.mp hdisj h1 h2
  have mF1 : ∀ {S : Finset (X × X)} {i j p : X}, (p, j) ∈ S → adj p i → (i, j) ∈ F1 adj S :=
    fun {S i j p} h1 h2 => by simp only [F1, mem_filter, mem_univ, true_and]; exact ⟨p, h1, h2⟩
  have mF2 : ∀ {S : Finset (X × X)} {i j s : X}, (i, s) ∈ S → adj s j → (i, j) ∈ F2 adj S :=
    fun {S i j s} h1 h2 => by simp only [F2, mem_filter, mem_univ, true_and]; exact ⟨s, h1, h2⟩
  have eF1 : ∀ {S : Finset (X × X)} {i j : X}, (i, j) ∈ F1 adj S → ∃ p, (p, j) ∈ S ∧ adj p i :=
    fun {S i j} h => by simpa [F1] using h
  have eF2 : ∀ {S : Finset (X × X)} {i j : X}, (i, j) ∈ F2 adj S → ∃ s, (i, s) ∈ S ∧ adj s j :=
    fun {S i j} h => by simpa [F2] using h
  set R := (F2 adj (F2 adj Q))ᶜ with hR
  set C := (F1 adj (F1 adj P))ᶜ with hC
  obtain ⟨R', hR'R, C', hC'C, hP1', hP2L, hP2R, hP3⟩ := hP X adj R C
  -- the diagonal lies in `R` and `C` and is conflict free
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
  -- `H` is contained in the old uncovered points
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
  have sR := card_sdiff_add_card_eq_card hR'R
  have sC := card_sdiff_add_card_eq_card hC'C
  refine ⟨R', C', hdisj', hdR', hdC', ?_⟩
  push_cast at *
  omega

/-- **One step of the algorithm** (Remark `rem:algorithm`): the pruned pair has value at least
`val(P,Q) - Σκ`, for an arbitrary relation. Under strict concavity every `κ` is negative and
the value strictly increases; this is `no_strictlyConcave`. -/
theorem step_value (hP : PruningLemma) (X : Type) [Fintype X] [DecidableEq X]
    (adj : X → X → Prop) [DecidableRel adj] (P Q : Finset (X × X))
    (hdisj : Disjoint (F1 adj P) (F2 adj Q)) (hdP : diag X ⊆ P) (hdQ : diag X ⊆ Q) :
    ∃ P' Q' : Finset (X × X), Disjoint (F1 adj P') (F2 adj Q') ∧ diag X ⊆ P' ∧ diag X ⊆ Q' ∧
      ((P.card : ℤ) + Q.card +
          ((Fintype.card (X × X) : ℤ) - (F1 adj P).card - (F2 adj Q).card)) -
          (∑ j, kappa adj (col j P) + ∑ i, kappa adj (row i Q)) ≤
        (P'.card : ℤ) + Q'.card +
          ((Fintype.card (X × X) : ℤ) - (F1 adj P').card - (F2 adj Q').card) := by
  obtain ⟨P', Q', h1, h2, h3, h4⟩ := step_ledger hP X adj P Q hdisj hdP hdQ
  refine ⟨P', Q', h1, h2, h3, ?_⟩
  have := gain_identity adj P Q
  linarith

end Seymour
