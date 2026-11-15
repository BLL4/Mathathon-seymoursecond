import SeymourLean.LinAlg

/-!
# The three-term complex

(`sec4-pruning.tex`, Section `sec:rank`: Claim `cl:rank-inequality` and the counting in
Claim `cl:kerA`.)

If `Nᵀ L = A B`, then `(N, -A) · (L; B) = NL - AB = 0`, so
`R^R → R^Z ⊕ R^H → R^C` is a complex and the ranks of its two maps add up to at most
`|Z| + |H|` (`rank_add_rank_le_of_mul_eq_zero`, which is Sylvester's inequality for a zero
product). A matching certifies lower bounds for the two ranks (`complex_count`):
`ℓ + k` for the stacked map, from the independent columns `sα` of `L` and the vectors
`u^r ∈ ker L` (`r ∈ s1`) whose images `B u^r` are independent, and `t` for the second map, from
the independent columns `sβ` of `Nᵀ`.
-/

open Finset
open scoped Matrix

set_option linter.unusedSectionVars false

namespace Seymour

variable {K : Type*} [Field K]

/-- Sylvester's inequality for a zero product: if `G * F = 0` then
`rank F + rank G ≤ dim (middle space)`. -/
lemma rank_add_rank_le_of_mul_eq_zero {ι μ ν : Type*} [Fintype ι] [DecidableEq ι] [Fintype μ]
    [DecidableEq μ] [Fintype ν] (G : Matrix ν μ K) (F : Matrix μ ι K) (h : G * F = 0) :
    F.rank + G.rank ≤ Fintype.card μ := by
  have := rank_mul_ge G F
  rw [h, Matrix.rank_zero] at this
  simpa using this

/-- The stacked matrix `(L; B) : R^R → R^Z ⊕ R^H`. -/
def stackRows {Z H R : Type*} (L : Matrix Z R K) (B : Matrix H R K) : Matrix (Z ⊕ H) R K :=
  Matrix.of fun zh r => Sum.elim (fun z => L z r) (fun h => B h r) zh

/-- The matrix `(N, -A) : R^Z ⊕ R^H → R^C`, given `Nᵀ`. -/
def sideCols {Z H C : Type*} (Nt : Matrix Z C K) (A : Matrix C H K) : Matrix C (Z ⊕ H) K :=
  Matrix.of fun c zh => Sum.elim (fun z => Nt z c) (fun h => -A c h) zh

/-- `NL = AB` says that the composite `(N, -A) · (L; B)` vanishes. -/
lemma sideCols_mul_stackRows {Z H R C : Type*} [Fintype Z] [Fintype H]
    (L : Matrix Z R K) (B : Matrix H R K) (Nt : Matrix Z C K) (A : Matrix C H K)
    (hNL : Ntᵀ * L = A * B) : sideCols Nt A * stackRows L B = 0 := by
  ext c r
  have h1 := congrFun (congrFun hNL c) r
  simp only [Matrix.mul_apply, Matrix.transpose_apply] at h1
  simp only [Matrix.mul_apply, sideCols, stackRows, Matrix.of_apply, Fintype.sum_sum_type,
    Sum.elim_inl, Sum.elim_inr, Matrix.zero_apply, neg_mul, sum_neg_distrib]
  rw [h1]
  ring

/-- **The dimension count** (Claims `cl:rank-inequality`, `cl:kerA`). Given `Nᵀ L = A B`,
a set `sα` of independent columns of `L`, a set `sβ` of independent columns of `Nᵀ`, and vectors
`u^r ∈ ker L` (`r ∈ s1`, `s1` disjoint from `sα`) whose images `B u^r` are independent,
`|s1| + |sα| + |sβ| ≤ |Z| + |H|`. -/
theorem complex_count {Z H R C : Type*} [Fintype Z] [Fintype H] [Fintype R] [Fintype C]
    [DecidableEq R] [DecidableEq C] [DecidableEq Z] [DecidableEq H]
    (L : Matrix Z R K) (B : Matrix H R K) (Nt : Matrix Z C K) (A : Matrix C H K)
    (hNL : Ntᵀ * L = A * B) (s1 sα : Finset R) (sβ : Finset C) (U : R → R → K)
    (hLu : ∀ r0 ∈ s1, L *ᵥ U r0 = 0) (indL : ColIndep L sα) (indN : ColIndep Nt sβ)
    (indW : ColIndep (Matrix.of fun h r => (B *ᵥ U r) h) s1) (hdisj : Disjoint s1 sα) :
    s1.card + sα.card + sβ.card ≤ Fintype.card Z + Fintype.card H := by
  classical
  -- `V`: column `a ∈ sα` is `e_a`, column `r ∉ sα` is `u^r`
  let V : Matrix R R K :=
    Matrix.of fun r r' => if r' ∈ sα then (if r = r' then 1 else 0) else U r' r
  set S := stackRows L B with hS
  set T := sideCols Nt A with hT
  have hcomplex := rank_add_rank_le_of_mul_eq_zero T S (sideCols_mul_stackRows L B Nt A hNL)
  rw [Fintype.card_sum] at hcomplex
  -- the columns of `S * V`
  have colα : ∀ r' ∈ sα, ∀ z, (S * V) (Sum.inl z) r' = L z r' := by
    intro r' hr' z
    simp only [Matrix.mul_apply, hS, stackRows, Matrix.of_apply, Sum.elim_inl, V, if_pos hr',
      mul_ite, mul_one, mul_zero, sum_ite_eq', mem_univ, if_true]
  have colα' : ∀ r' ∈ sα, ∀ h, (S * V) (Sum.inr h) r' = B h r' := by
    intro r' hr' h
    simp only [Matrix.mul_apply, hS, stackRows, Matrix.of_apply, Sum.elim_inr, V, if_pos hr',
      mul_ite, mul_one, mul_zero, sum_ite_eq', mem_univ, if_true]
  have col1 : ∀ r' ∈ s1, ∀ z, (S * V) (Sum.inl z) r' = 0 := by
    intro r' hr' z
    have hnot : r' ∉ sα := fun h => Finset.disjoint_left.mp hdisj hr' h
    have := congrFun (hLu r' hr') z
    simp only [Matrix.mulVec, dotProduct, Pi.zero_apply] at this
    simp only [Matrix.mul_apply, hS, stackRows, Matrix.of_apply, Sum.elim_inl, V, if_neg hnot]
    exact this
  have col1' : ∀ r' ∈ s1, ∀ h, (S * V) (Sum.inr h) r' = (B *ᵥ U r') h := by
    intro r' hr' h
    have hnot : r' ∉ sα := fun h => Finset.disjoint_left.mp hdisj hr' h
    simp only [Matrix.mul_apply, hS, stackRows, Matrix.of_apply, Sum.elim_inr, V, if_neg hnot,
      Matrix.mulVec, dotProduct]
  -- the `ℓ + k` columns of `S * V` indexed by `s1 ∪ sα` are independent
  have indSV : ColIndep (S * V) (s1 ∪ sα) := by
    intro w hw
    have hα : ∀ c ∈ sα, w c = 0 := by
      apply indL
      intro z
      have := hw (Sum.inl z)
      rw [sum_union hdisj] at this
      have hz : ∑ c ∈ s1, w c * (S * V) (Sum.inl z) c = 0 :=
        sum_eq_zero fun c hc => by rw [col1 c hc z, mul_zero]
      rw [hz, zero_add] at this
      rw [← this]
      exact sum_congr rfl fun c hc => by rw [colα c hc z]
    have h1 : ∀ c ∈ s1, w c = 0 := by
      apply indW
      intro h
      have := hw (Sum.inr h)
      rw [sum_union hdisj] at this
      have hz : ∑ c ∈ sα, w c * (S * V) (Sum.inr h) c = 0 :=
        sum_eq_zero fun c hc => by rw [hα c hc, zero_mul]
      rw [hz, add_zero] at this
      rw [← this]
      exact sum_congr rfl fun c hc => by rw [col1' c hc h, Matrix.of_apply]
    intro c hc
    rcases mem_union.mp hc with hc | hc
    · exact h1 c hc
    · exact hα c hc
  have hSV : (s1 ∪ sα).card ≤ S.rank :=
    indSV.card_le_rank.trans (Matrix.rank_mul_le_left S V)
  rw [card_union_of_disjoint hdisj] at hSV
  -- the `t` rows of `T` indexed by `sβ` are independent
  have indT : ColIndep Tᵀ sβ := by
    intro w hw
    apply indN
    intro z
    have := hw (Sum.inl z)
    simpa [hT, sideCols, Matrix.transpose_apply] using this
  have hTr : sβ.card ≤ T.rank := by
    have := indT.card_le_rank
    rwa [Matrix.rank_transpose] at this
  omega

end Seymour
