import SeymourLean.Defs
import Mathlib.Algebra.Order.Ring.Int
import Mathlib.Algebra.BigOperators.Ring.Finset
import Mathlib.Data.Fintype.Fin
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith

/-!
# Blowing up by transitive tournaments

(`sec2-reduction.tex`, Lemma `lem:internal` and Lemma `lem:blowup`.)
-/

open Finset

namespace Seymour

/-- The blow-up `D[T_m]` on `V × Fin m`: `(v,a) → (w,b)` iff `v → w`, or `v = w` and `a < b`. -/
def blowAdj {V : Type*} (adj : V → V → Prop) (m : ℕ) : V × Fin m → V × Fin m → Prop :=
  fun x y => adj x.1 y.1 ∨ (x.1 = y.1 ∧ x.2 < y.2)

instance {V : Type*} [DecidableEq V] (adj : V → V → Prop) [DecidableRel adj] (m : ℕ) :
    DecidableRel (blowAdj adj m) := fun x y => by unfold blowAdj; infer_instance

section Internal

variable {m : ℕ}

/-- The forward image in the transitive tournament `T_m`. -/
abbrev tf (T : Finset (Fin m)) : Finset (Fin m) := img (fun a b : Fin m => a < b) T

lemma tf_tf_subset (T : Finset (Fin m)) : tf (tf T) ⊆ tf T := by
  intro c hc
  simp only [mem_img] at hc ⊢
  obtain ⟨b, ⟨a, ha, hab⟩, hbc⟩ := hc
  exact ⟨a, ha, hab.trans hbc⟩

lemma card_le_tf_add_one (T : Finset (Fin m)) (hT : T.Nonempty) :
    T.card ≤ (tf T).card + 1 := by
  set a := T.min' hT
  have : T ⊆ insert a (tf T) := by
    intro x hx
    rw [mem_insert]
    by_cases h : x = a
    · exact Or.inl h
    · right
      exact mem_img.mpr ⟨a, min'_mem T hT, lt_of_le_of_ne (min'_le T x hx) (Ne.symm h)⟩
  exact (card_le_card this).trans (card_insert_le _ _)

/-- **Internal estimate** (Lemma `lem:internal`). -/
lemma internal_estimate (T : Finset (Fin m)) (hT : T.Nonempty) :
    (T.card : ℤ) - 2 * (tf T).card + (tf (tf T)).card ≤ 1 := by
  have h1 := card_le_tf_add_one T hT
  have h2 := card_le_card (tf_tf_subset T)
  omega

end Internal

section Blow

variable {V : Type} [Fintype V] [DecidableEq V] {adj : V → V → Prop} [DecidableRel adj]

/-- Block of `w` in `W ⊆ V × Fin m`. -/
def blk {m : ℕ} (w : V) (W : Finset (V × Fin m)) : Finset (Fin m) :=
  univ.filter (fun a => (w, a) ∈ W)

lemma card_eq_sum_blk {m : ℕ} (W : Finset (V × Fin m)) :
    (W.card : ℤ) = ∑ w, ((blk w W).card : ℤ) := by
  have : W.card = ∑ w, (blk w W).card := by
    rw [card_eq_sum_card_fiberwise (f := Prod.fst) (t := univ) (by simp)]
    refine sum_congr rfl fun w _ => ?_
    refine card_nbij' Prod.snd (fun a => (w, a)) ?_ ?_ ?_ ?_
    · rintro ⟨a, b⟩ h
      simp only [coe_filter, Set.mem_ofPred_eq] at h
      simp [blk, ← h.2, h.1]
    · intro a ha
      simp only [blk, coe_filter, mem_univ, true_and, Set.mem_ofPred_eq] at ha
      simp [ha]
    · rintro ⟨a, b⟩ h
      simp only [coe_filter, Set.mem_ofPred_eq] at h
      simp [h.2]
    · intro a _; rfl
  rw [this]; push_cast; rfl

lemma sum_ind (A : Finset V) (c : ℤ) : ∑ w, (if w ∈ A then c else 0) = c * A.card := by
  rw [← sum_filter, sum_const, filter_mem_eq_inter, univ_inter, nsmul_eq_mul, mul_comm]

/-- **Blow-up lemma** (Lemma `lem:blowup`). -/
theorem blowup (hor : IsOriented adj) (hin : PosIndeg adj)
    (hdef : ∀ S : Finset V, S.Nonempty → S ≠ univ →
      ((img adj (img adj S)) \ img adj S).card < (img adj S \ S).card)
    (m : ℕ) (hm : Fintype.card V < m) :
    IsOriented (blowAdj adj m) ∧ PosIndeg (blowAdj adj m) ∧ StrictlyConcave (blowAdj adj m) := by
  have hm0 : 0 < m := lt_of_le_of_lt (Nat.zero_le _) hm
  set G := blowAdj adj m with hG
  have hGor : IsOriented G := by
    refine ⟨fun x h => ?_, fun x y h h' => ?_⟩
    · rcases h with h | h
      · exact hor.1 _ h
      · exact lt_irrefl _ h.2
    · rcases h with h | h <;> rcases h' with h' | h'
      · exact hor.2 _ _ h h'
      · rw [h'.1] at h; exact hor.1 _ h
      · rw [h.1] at h'; exact hor.1 _ h'
      · exact lt_asymm h.2 h'.2
  have hGin : PosIndeg G := by
    rintro ⟨w, b⟩
    obtain ⟨x, hx⟩ := hin w
    exact ⟨(x, ⟨0, hm0⟩), Or.inl hx⟩
  refine ⟨hGor, hGin, ?_⟩
  intro U hU hUne
  set S := U.image Prod.fst with hS
  set FS := img adj S with hFS
  set H0 := img adj FS ∪ FS with hH0
  have memS : ∀ w, w ∈ S ↔ (blk w U).Nonempty := by
    intro w
    simp only [hS, mem_image, blk, Finset.Nonempty, mem_filter, mem_univ, true_and]
    constructor
    · rintro ⟨⟨x, a⟩, hx, rfl⟩; exact ⟨a, hx⟩
    · rintro ⟨a, ha⟩; exact ⟨(w, a), ha, rfl⟩
  have memS' : ∀ x a, (x, a) ∈ U → x ∈ S := fun x a h => (memS x).mpr ⟨a, by simp [blk, h]⟩
  -- Fact D
  have factD : ∀ u c, (u, c) ∈ img G U → u ∈ S ∨ u ∈ FS := by
    intro u c h
    obtain ⟨⟨x, d⟩, hx, hxu⟩ := mem_img.mp h
    rcases hxu with h1 | h1
    · right; exact mem_img.mpr ⟨x, memS' x d hx, h1⟩
    · left; simp only at h1; rw [← h1.1]; exact memS' x d hx
  -- Fact A
  have factA : ∀ w, w ∈ FS → blk w (img G U) = univ := by
    intro w hw
    rw [eq_univ_iff_forall]; intro b
    obtain ⟨x, hxS, hxw⟩ := mem_img.mp hw
    obtain ⟨a, ha⟩ := (memS x).mp hxS
    simp only [blk, mem_filter, mem_univ, true_and] at ha ⊢
    exact mem_img.mpr ⟨(x, a), ha, Or.inl hxw⟩
  -- Fact B
  have factB : ∀ w, tf (blk w U) ⊆ blk w (img G U) := by
    intro w b hb
    obtain ⟨a, ha, hab⟩ := mem_img.mp hb
    simp only [blk, mem_filter, mem_univ, true_and] at ha ⊢
    exact mem_img.mpr ⟨(w, a), ha, Or.inr ⟨rfl, hab⟩⟩
  -- Fact C
  have factC : ∀ w, w ∉ H0 → blk w (img G (img G U)) ⊆ tf (tf (blk w U)) := by
    intro w hw b hb
    simp only [blk, mem_filter, mem_univ, true_and] at hb
    obtain ⟨⟨u, c⟩, hy, huw⟩ := mem_img.mp hb
    rcases huw with h1 | ⟨h1, h2⟩
    · exfalso; apply hw
      rcases factD u c hy with h | h
      · exact mem_union_right _ (mem_img.mpr ⟨u, h, h1⟩)
      · exact mem_union_left _ (mem_img.mpr ⟨u, h, h1⟩)
    · simp only at h1 h2
      subst h1
      obtain ⟨⟨x, d⟩, hx, hxu⟩ := mem_img.mp hy
      rcases hxu with h3 | ⟨h3, h4⟩
      · exfalso; apply hw
        exact mem_union_right _ (mem_img.mpr ⟨x, memS' x d hx, h3⟩)
      · simp only at h3 h4
        subst h3
        refine mem_img.mpr ⟨c, mem_img.mpr ⟨d, ?_, h4⟩, h2⟩
        simp [blk, hx]
  -- per-block inequality
  have hcardm : ∀ T : Finset (Fin m), T.card ≤ m := fun T => by
    simpa using card_le_univ T
  have key : ∀ w, ((blk w U).card : ℤ) - 2 * (blk w (img G U)).card
      + (blk w (img G (img G U))).card ≤
      (if w ∈ H0 then (m : ℤ) else 0) - 2 * (if w ∈ FS then (m : ℤ) else 0)
      + (if w ∈ FS ∩ S then (m : ℤ) else 0) + (if w ∈ S \ FS then (1 : ℤ) else 0) := by
    intro w
    have a1 := hcardm (blk w U)
    have a2 := hcardm (blk w (img G (img G U)))
    have a3 := card_le_card (factB w)
    by_cases hF : w ∈ FS
    · have hH : w ∈ H0 := mem_union_right _ hF
      have e1 := factA w hF
      rw [e1, card_univ, Fintype.card_fin]
      by_cases hSw : w ∈ S
      · simp [hF, hH, hSw]; omega
      · have : blk w U = ∅ := by
          rw [← not_nonempty_iff_eq_empty, ← memS]; exact hSw
        rw [this]; simp [hF, hH, hSw]; omega
    · by_cases hSw : w ∈ S
      · have hne := (memS w).mp hSw
        have b1 := card_le_tf_add_one _ hne
        have b2 := card_le_card (tf_tf_subset (blk w U))
        by_cases hH : w ∈ H0
        · simp [hF, hH, hSw]; omega
        · have b3 := card_le_card (factC w hH)
          simp [hF, hH, hSw]; omega
      · have : blk w U = ∅ := by
          rw [← not_nonempty_iff_eq_empty, ← memS]; exact hSw
        rw [this] at a3 ⊢
        by_cases hH : w ∈ H0
        · simp [hF, hH, hSw]; omega
        · have b3 := card_le_card (factC w hH)
          rw [this] at b3
          have : tf (tf (∅ : Finset (Fin m))) = ∅ := by simp [img]
          rw [this, card_empty] at b3
          simp [hF, hH, hSw]; omega
  have hsum := sum_le_sum (fun w (_ : w ∈ univ) => key w)
  have eL : ∑ w, (((blk w U).card : ℤ) - 2 * (blk w (img G U)).card
      + (blk w (img G (img G U))).card) =
      (U.card : ℤ) - 2 * (img G U).card + (img G (img G U)).card := by
    rw [card_eq_sum_blk U, card_eq_sum_blk (img G U), card_eq_sum_blk (img G (img G U)),
      mul_sum, ← sum_sub_distrib, ← sum_add_distrib]
  have eR : ∑ w, ((if w ∈ H0 then (m : ℤ) else 0) - 2 * (if w ∈ FS then (m : ℤ) else 0)
      + (if w ∈ FS ∩ S then (m : ℤ) else 0) + (if w ∈ S \ FS then (1 : ℤ) else 0)) =
      (m : ℤ) * H0.card - 2 * ((m : ℤ) * FS.card) + (m : ℤ) * (FS ∩ S).card
        + 1 * (S \ FS).card := by
    rw [sum_add_distrib, sum_add_distrib, sum_sub_distrib, ← mul_sum, sum_ind, sum_ind, sum_ind,
      sum_ind]
  rw [eL, eR] at hsum
  by_cases hSu : S = univ
  · have hF1 : img G U = univ := by
      rw [eq_univ_iff_forall]; rintro ⟨w, b⟩
      obtain ⟨x, hx⟩ := hin w
      have : x ∈ S := by rw [hSu]; exact mem_univ x
      obtain ⟨a, ha⟩ := (memS x).mp this
      simp only [blk, mem_filter, mem_univ, true_and] at ha
      exact mem_img.mpr ⟨(x, a), ha, Or.inl hx⟩
    have hF2 : img G (univ : Finset (V × Fin m)) = univ := by
      rw [eq_univ_iff_forall]; rintro ⟨w, b⟩
      obtain ⟨x, hx⟩ := hin w
      exact mem_img.mpr ⟨(x, ⟨0, hm0⟩), mem_univ _, Or.inl hx⟩
    rw [hF1, hF2]
    have := card_lt_card (ssubset_univ_iff.mpr hUne)
    omega
  · have hSne : S.Nonempty := hU.image Prod.fst
    have hd := hdef S hSne hSu
    have c1 := card_sdiff_add_card (img adj FS) FS
    have c2 := card_sdiff_add_card_inter FS S
    have c3 : (S \ FS).card ≤ Fintype.card V := card_le_univ _
    rw [← hFS] at hd
    have hb : (H0.card : ℤ) - 2 * FS.card + (FS ∩ S).card ≤ -1 := by
      rw [hH0]; omega
    have hm' : (0 : ℤ) ≤ m := by exact_mod_cast Nat.zero_le m
    have := mul_le_mul_of_nonneg_left hb hm'
    have e : (m : ℤ) * (H0.card - 2 * FS.card + (FS ∩ S).card) =
        (m : ℤ) * H0.card - 2 * ((m : ℤ) * FS.card) + (m : ℤ) * (FS ∩ S).card := by ring
    have hmV : (Fintype.card V : ℤ) < m := by exact_mod_cast hm
    have c3' : ((S \ FS).card : ℤ) ≤ Fintype.card V := by exact_mod_cast c3
    linarith

end Blow

end Seymour
