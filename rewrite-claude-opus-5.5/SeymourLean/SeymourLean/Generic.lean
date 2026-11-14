import SeymourLean.LinAlg
import Mathlib.Algebra.MvPolynomial.NoZeroDivisors
import Mathlib.RingTheory.Localization.FractionRing
import Mathlib.LinearAlgebra.Matrix.Nondegenerate

/-!
# Generic matrices

We work over the field `K = Frac(ℚ[x_v : v ∈ Bool × X × X])`. For an arrow `u → w` of a relation
`adj` on `X` the "variable" `gv adj tag u w` is the indeterminate `x_(tag,u,w)`, and it is `0` when
`u ↛ w`. (`tag = false` gives the `a`-variables, `tag = true` the `b`-variables of the paper.)

* `generic_indep` : a polynomial matrix whose square submatrix (columns `s`, rows `g(s)`)
  specialises to the identity has independent columns `s` over `K` (fact (iii) of
  `sec:generic`, proved by specialisation of the determinant).
* `block_indep` : the block-structured matrices `L`, `Nᵀ`, `Φᵀ` have independent columns along any
  matching of their support (Claim `cl:edmonds`(b)).
* `generic_kernel` : the kernel lemma (Lemma `lem:kernel`) for a generic matrix.
-/

open Finset Module

set_option linter.unusedSectionVars false

namespace Seymour

variable {X : Type*} [DecidableEq X]

/-- The coefficient field. -/
abbrev KK (X : Type*) := FractionRing (MvPolynomial (Bool × X × X) ℚ)

/-- The generic entry attached to a pair `(u, w)`. -/
noncomputable def gv (adj : X → X → Prop) [DecidableRel adj] (tag : Bool) (u w : X) :
    MvPolynomial (Bool × X × X) ℚ :=
  if adj u w then MvPolynomial.X (tag, u, w) else 0

/-- Its image in the field `K`. -/
noncomputable def gK (adj : X → X → Prop) [DecidableRel adj] (tag : Bool) (u w : X) : KK X :=
  algebraMap _ (KK X) (gv adj tag u w)

lemma gK_eq_zero_of_not {adj : X → X → Prop} [DecidableRel adj] {tag : Bool} {u w : X}
    (h : ¬ adj u w) : gK adj tag u w = 0 := by
  simp [gK, gv, h]

lemma adj_of_gK_ne_zero {adj : X → X → Prop} [DecidableRel adj] {tag : Bool} {u w : X}
    (h : gK adj tag u w ≠ 0) : adj u w := by
  by_contra h'; exact h (gK_eq_zero_of_not h')

section GenericIndep

variable {σ : Type*} {κ ι : Type*} [Fintype κ] [Fintype ι] [DecidableEq ι]

lemma generic_indep (Q : Matrix κ ι (MvPolynomial σ ℚ)) (s : Finset ι) (g : s → κ)
    (ev : σ → ℚ)
    (hev : ∀ c c' : s, MvPolynomial.eval ev (Q (g c') c) = if c' = c then 1 else 0) :
    ColIndep (Q.map (algebraMap _ (FractionRing (MvPolynomial σ ℚ)))) s := by
  classical
  set F := FractionRing (MvPolynomial σ ℚ)
  let Qs : Matrix s s (MvPolynomial σ ℚ) := Matrix.of fun c' c => Q (g c') c
  have h1 : (MvPolynomial.eval ev).mapMatrix Qs = 1 := by
    ext c' c
    simp [Qs, hev, Matrix.one_apply]
  have h2 : Qs.det ≠ 0 := by
    intro h
    have := congrArg (MvPolynomial.eval ev) h
    rw [RingHom.map_det, h1, Matrix.det_one, map_zero] at this
    exact one_ne_zero this
  have h3 : ((algebraMap _ F).mapMatrix Qs).det ≠ 0 := by
    rw [← RingHom.map_det]
    exact (map_ne_zero_iff _ (IsFractionRing.injective _ F)).mpr h2
  intro w hw c hc
  have hmv : ((algebraMap _ F).mapMatrix Qs) *ᵥ (fun c : s => w c) = 0 := by
    ext c'
    have := hw (g c')
    rw [← sum_coe_sort s] at this
    simpa [Matrix.mulVec, dotProduct, Qs, mul_comm] using this
  have := Matrix.eq_zero_of_mulVec_eq_zero h3 hmv
  exact congrFun this ⟨c, hc⟩

end GenericIndep

section Block

variable {κ ι : Type*} [Fintype κ] [Fintype ι] [DecidableEq ι] [DecidableEq κ]
variable (adj : X → X → Prop) [DecidableRel adj]

/-- Block-structured generic matrix: entry `(x,c)` is `gK tag (πι c) (πκ x)` if `x` and `c` lie in
the same block, and `0` otherwise. -/
noncomputable def blockMat (tag : Bool) (βκ πκ : κ → X) (βι πι : ι → X) : Matrix κ ι (KK X) :=
  Matrix.of fun x c => if βκ x = βι c then gK adj tag (πι c) (πκ x) else 0

lemma block_indep (tag : Bool) (βκ πκ : κ → X) (βι πι : ι → X)
    (hι : ∀ c c', βι c = βι c' → πι c = πι c' → c = c')
    (hκ : ∀ x x', βκ x = βκ x' → πκ x = πκ x' → x = x')
    (s : Finset ι) (g : s → κ) (hg : Function.Injective g)
    (hgP : ∀ c : s, βκ (g c) = βι c ∧ adj (πι c) (πκ (g c))) :
    ColIndep (blockMat adj tag βκ πκ βι πι) s := by
  classical
  intro w hw c0 hc0
  set b0 := βι c0
  set s0 := s.filter (fun c => βι c = b0) with hs0
  have hs0s : s0 ⊆ s := filter_subset _ _
  have hw0 : ∀ x, ∑ c ∈ s0, w c * blockMat adj tag βκ πκ βι πι x c = 0 := by
    intro x
    by_cases hx : βκ x = b0
    · have := hw x
      rw [← sum_filter_add_sum_filter_not s (fun c => βι c = b0)] at this
      rw [← hs0] at this
      have hz : ∑ c ∈ s.filter (fun c => ¬ βι c = b0),
          w c * blockMat adj tag βκ πκ βι πι x c = 0 := by
        refine sum_eq_zero fun c hc => ?_
        have hc' := (mem_filter.mp hc).2
        simp [blockMat, hx, Ne.symm hc']
      rw [hz, add_zero] at this
      exact this
    · refine sum_eq_zero fun c hc => ?_
      have hc' := (mem_filter.mp hc).2
      have : βκ x ≠ βι c := by rw [hc']; exact hx
      simp [blockMat, this]
  -- apply `generic_indep` on the block `b0`
  let g0 : s0 → κ := fun c => g ⟨c.1, hs0s c.2⟩
  let Q : Matrix κ ι (MvPolynomial (Bool × X × X) ℚ) :=
    Matrix.of fun x c => if βκ x = βι c then gv adj tag (πι c) (πκ x) else 0
  have hQ : Q.map (algebraMap _ (KK X)) = blockMat adj tag βκ πκ βι πι := by
    ext x c; simp only [Q, blockMat, Matrix.map_apply, Matrix.of_apply, gK]
    split_ifs <;> simp
  let ev : Bool × X × X → ℚ := fun v =>
    if v.1 = tag ∧ ∃ c : s0, πι c = v.2.1 ∧ πκ (g0 c) = v.2.2 then 1 else 0
  have hblk : ∀ c : s0, βι c = b0 := fun c => (mem_filter.mp c.2).2
  have hev : ∀ c c' : s0, MvPolynomial.eval ev (Q (g0 c') c) = if c' = c then 1 else 0 := by
    intro c c'
    have hb : βκ (g0 c') = βι c := by
      rw [(hgP ⟨c'.1, hs0s c'.2⟩).1, hblk c']; exact (hblk c).symm
    simp only [Q, Matrix.of_apply, hb, if_true, gv]
    by_cases hcc : c' = c
    · subst hcc
      have hadj := (hgP ⟨c'.1, hs0s c'.2⟩).2
      simp only [g0] at hadj ⊢
      rw [if_pos hadj, MvPolynomial.eval_X, if_pos rfl]
      simp only [ev]
      rw [if_pos ⟨rfl, c', rfl, rfl⟩]
    · rw [if_neg hcc]
      split_ifs with hadj
      · rw [MvPolynomial.eval_X]
        simp only [ev]
        rw [if_neg]
        rintro ⟨-, c'', h1, h2⟩
        have e1 : c''.1 = c.1 := hι _ _ (by rw [hblk c'', hblk c]) h1
        have e2 : g0 c'' = g0 c' := hκ _ _ (by
          rw [(hgP ⟨c''.1, hs0s c''.2⟩).1, (hgP ⟨c'.1, hs0s c'.2⟩).1, hblk c'', hblk c']) h2
        have e3 : c'' = c' := by
          have := hg e2
          exact Subtype.ext (congrArg Subtype.val this)
        exact hcc (e3 ▸ Subtype.ext e1)
      · simp
  have hind := generic_indep Q s0 g0 ev hev
  rw [hQ] at hind
  exact hind w hw0 c0 (mem_filter.mpr ⟨hc0, rfl⟩)

/-- **Kernel lemma** (Lemma `lem:kernel`) for a generic matrix
`Ψ x c = gK tag (πι c) (πκ x)` with injective `πι`, `πκ`: if `Ψ u = 0` and `vᵀ Ψ = 0` then
`u c * v x = 0` whenever `πι c → πκ x`. -/
lemma generic_kernel (tag : Bool) (πκ : κ → X) (πι : ι → X)
    (hι : Function.Injective πι) (hκ : Function.Injective πκ)
    (u : ι → KK X) (v : κ → KK X)
    (hu : (Matrix.of fun x c => gK adj tag (πι c) (πκ x)) *ᵥ u = 0)
    (hv : v ᵥ* (Matrix.of fun x c => gK adj tag (πι c) (πκ x)) = 0)
    (c0 : ι) (x0 : κ) (hadj : adj (πι c0) (πκ x0)) : u c0 * v x0 = 0 := by
  classical
  set Ψ : Matrix κ ι (KK X) := Matrix.of fun x c => gK adj tag (πι c) (πκ x) with hΨ
  by_contra hne
  have hu0 : u c0 ≠ 0 := left_ne_zero_of_mul hne
  have hv0 : v x0 ≠ 0 := right_ne_zero_of_mul hne
  set E : Matrix κ ι (KK X) := Matrix.of fun x c => if x = x0 ∧ c = c0 then 1 else 0
  set Ψ' := Ψ + E with hΨ'
  have hE : ∀ w : ι → KK X, E *ᵥ w = fun x => if x = x0 then w c0 else 0 := by
    intro w; ext x
    simp only [Matrix.mulVec, dotProduct, E, Matrix.of_apply]
    by_cases hx : x = x0
    · simp [hx]
    · simp [hx]
  -- (1) rank Ψ' ≤ rank Ψ
  have hbl : Ψ = blockMat adj tag (fun _ => πκ x0) πκ (fun _ => πκ x0) πι := by
    ext x c; simp [hΨ, blockMat]
  have r1 : Ψ'.rank ≤ Ψ.rank := by
    obtain ⟨sc, hind, hspan⟩ := exists_colIndep_spanning Ψ'
    rw [rank_eq_of_colIndep_spanning hind hspan]
    obtain ⟨g, hg, hgne⟩ := hind.exists_matching
    have hind' : ColIndep Ψ sc := by
      rw [hbl]
      refine block_indep adj tag _ πκ _ πι (fun c c' _ h => hι h) (fun x x' _ h => hκ h) sc g hg
        (fun c => ⟨rfl, ?_⟩)
      have := hgne c
      simp only [hΨ', hΨ, E, Matrix.add_apply, Matrix.of_apply] at this
      by_cases h : g c = x0 ∧ c.1 = c0
      · rw [h.1, h.2]; exact hadj
      · rw [if_neg h, add_zero] at this
        exact adj_of_gK_ne_zero this
    exact hind'.card_le_rank
  -- (2) rank Ψ < rank Ψ'
  have hle : LinearMap.range Ψ.mulVecLin ≤ LinearMap.range Ψ'.mulVecLin := by
    rintro _ ⟨w, rfl⟩
    refine ⟨w - (w c0 / u c0) • u, ?_⟩
    simp only [Matrix.mulVecLin_apply]
    rw [hΨ', Matrix.add_mulVec, Matrix.mulVec_sub, Matrix.mulVec_smul, hu, hE, hE]
    ext x
    simp only [Pi.add_apply, Pi.sub_apply, Pi.smul_apply, Pi.zero_apply, smul_eq_mul]
    split_ifs
    · field_simp; ring
    · ring
  have hin : (fun x => if x = x0 then (1 : KK X) else 0) ∈ LinearMap.range Ψ'.mulVecLin := by
    refine ⟨(u c0)⁻¹ • u, ?_⟩
    simp only [Matrix.mulVecLin_apply]
    rw [hΨ', Matrix.add_mulVec, Matrix.mulVec_smul, hu, hE]
    ext x
    simp only [Pi.add_apply, Pi.smul_apply, Pi.zero_apply, smul_eq_mul, mul_zero, zero_add]
    split_ifs
    · field_simp
    · rfl
  have hout : (fun x => if x = x0 then (1 : KK X) else 0) ∉ LinearMap.range Ψ.mulVecLin := by
    rintro ⟨w, hw⟩
    simp only [Matrix.mulVecLin_apply] at hw
    have h1 : v ⬝ᵥ (Ψ *ᵥ w) = 0 := by rw [Matrix.dotProduct_mulVec, hv, zero_dotProduct]
    rw [hw] at h1
    simp [dotProduct] at h1
    exact hv0 h1
  have hlt : LinearMap.range Ψ.mulVecLin < LinearMap.range Ψ'.mulVecLin :=
    lt_of_le_of_ne hle (fun h => hout (h ▸ hin))
  have r2 : Ψ.rank < Ψ'.rank := Submodule.finrank_lt_finrank_of_lt hlt
  omega

end Block

end Seymour
