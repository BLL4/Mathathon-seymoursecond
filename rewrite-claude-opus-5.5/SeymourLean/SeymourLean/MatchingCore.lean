import SeymourLean.Generic
import SeymourLean.Gamma
import SeymourLean.ComplexCount

/-!
# The linear-algebra core of the matching bound

(`sec4-pruning.tex`, Sections `sec:matrices`–`sec:kernel`.)

We fix a finite set `X` with a relation `adj` and `R, C ⊆ X × X`, and build over
`K = Frac(ℚ[a_xy, b_xy])` the four matrices
* `Lm : Z × R`, `Lm_{(i,j),(p,j)} = a_pi`;
* `Ntm : Z × C`, the transpose of `N`, `N_{(i,s),(i,j)} = b_sj`;
* `Bm : H × R`, `Bm_{(p,s),(p,j)} = b_sj`;
* `Am : C × H`, `Am_{(i,s),(p,s)} = a_pi`,
prove `NL = AB` (Claim `cl:commute`), the kernel separation (Claim `cl:conflict-kernel`), and the
counting theorem `core_bound`: given the decomposition `M = M₁ ⊔ α ⊔ β` of a matching with the
two maximality properties, `k + ℓ + t ≤ |Z| + |H|` (Claims `cl:kerA`, `cl:rank-inequality`).
The final count goes through the three-term complex of `ComplexCount.lean`
(`dimension_count` is Claim `cl:rank-inequality` for the matrices of the paper).
-/

open Finset Module
open scoped Matrix

set_option linter.unusedSectionVars false

namespace Seymour

variable {X : Type} [Fintype X] [DecidableEq X] (adj : X → X → Prop) [DecidableRel adj]
variable (R C : Finset (X × X))

/-- The matrix `L`. -/
noncomputable def Lm : Matrix (Zset adj R C) R (KK X) :=
  blockMat adj false (fun z => z.1.2) (fun z => z.1.1) (fun r => r.1.2) (fun r => r.1.1)

/-- The transpose of the matrix `N`. -/
noncomputable def Ntm : Matrix (Zset adj R C) C (KK X) :=
  blockMat adj true (fun z => z.1.1) (fun z => z.1.2) (fun c => c.1.1) (fun c => c.1.2)

/-- The matrix `B`. -/
noncomputable def Bm : Matrix (Hset adj R C) R (KK X) :=
  Matrix.of fun h r => if h.1.1 = r.1.1 then gK adj true h.1.2 r.1.2 else 0

/-- The matrix `A`. -/
noncomputable def Am : Matrix C (Hset adj R C) (KK X) :=
  Matrix.of fun c h => if c.1.2 = h.1.2 then gK adj false h.1.1 c.1.1 else 0

variable {adj R C}

lemma mem_Hset {h : X × X} :
    h ∈ Hset adj R C ↔ ∃ r ∈ R, ∃ c ∈ C, Conflict adj r c ∧ h = (r.1, c.2) := by
  simp [Hset]

lemma blockMat_ne_zero {κ ι : Type*} {tag : Bool} {βκ πκ : κ → X} {βι πι : ι → X} {x : κ} {c : ι}
    (h : blockMat adj tag βκ πκ βι πι x c ≠ 0) : βκ x = βι c ∧ adj (πι c) (πκ x) := by
  simp only [blockMat, Matrix.of_apply] at h
  split_ifs at h with h1
  · exact ⟨h1, adj_of_gK_ne_zero h⟩
  · exact absurd rfl h

variable (adj R C)

/-- **Two factorizations** (Claim `cl:commute`): `N L = A B`. -/
lemma NL_eq_AB : (Ntm adj R C)ᵀ * Lm adj R C = Am adj R C * Bm adj R C := by
  ext c r
  simp only [Matrix.mul_apply, Matrix.transpose_apply, Lm, Ntm, Am, Bm, blockMat, Matrix.of_apply]
  by_cases hconf : Conflict adj r.1 c.1
  · have hz : (c.1.1, r.1.2) ∈ Zset adj R C := (mem_Zset adj).mpr ⟨r.1, r.2, c.1, c.2, hconf, rfl⟩
    have hh : (r.1.1, c.1.2) ∈ Hset adj R C := mem_Hset.mpr ⟨r.1, r.2, c.1, c.2, hconf, rfl⟩
    rw [Fintype.sum_eq_single ⟨_, hz⟩, Fintype.sum_eq_single ⟨_, hh⟩]
    · simp [mul_comm]
    · intro h hne
      split_ifs with h1 h2 <;> try simp only [mul_zero, zero_mul]
      apply absurd _ hne; apply Subtype.ext; ext <;> simp_all
    · intro z hne
      split_ifs with h1 h2 <;> try simp only [mul_zero, zero_mul]
      apply absurd _ hne; apply Subtype.ext; ext <;> simp_all
  · have h0 : gK adj true c.1.2 r.1.2 * gK adj false r.1.1 c.1.1 = 0 := by
      by_cases ha : adj r.1.1 c.1.1
      · have hb : ¬ adj c.1.2 r.1.2 := fun hb => hconf ⟨ha, hb⟩
        rw [gK_eq_zero_of_not hb, zero_mul]
      · rw [gK_eq_zero_of_not ha, mul_zero]
    rw [sum_eq_zero, sum_eq_zero]
    · intro h _
      split_ifs with h1 h2 <;> try simp only [mul_zero, zero_mul]
      rw [h2, ← h1, mul_comm]; exact h0
    · intro z _
      split_ifs with h1 h2 <;> try simp only [mul_zero, zero_mul]
      rw [h1, h2]; exact h0

/-- **Dimension count** (Claim `cl:rank-inequality`) for the matrices of the paper:
`rank (L; B) + rank (N, -A) ≤ |Z| + |H|`. -/
theorem dimension_count :
    (stackRows (Lm adj R C) (Bm adj R C)).rank + (sideCols (Ntm adj R C) (Am adj R C)).rank ≤
      (Zset adj R C).card + (Hset adj R C).card := by
  have := rank_add_rank_le_of_mul_eq_zero _ _
    (sideCols_mul_stackRows (Lm adj R C) (Bm adj R C) (Ntm adj R C) (Am adj R C)
      (NL_eq_AB adj R C))
  rwa [Fintype.card_sum, Fintype.card_coe, Fintype.card_coe] at this

omit [DecidableRel adj] in
/-- Reindexing a sum over a first-coordinate fiber. -/
lemma sum_fst_fiber {K : Type*} [AddCommMonoid K] (S : Finset (X × X)) (i : X) (F : S → K) :
    ∑ c : S, (if c.1.1 = i then F c else 0) = ∑ s : {s // (i, s) ∈ S}, F ⟨(i, s.1), s.2⟩ := by
  rw [← sum_filter]
  have e : (univ.filter (fun c : S => c.1.1 = i)) =
      (univ : Finset {s // (i, s) ∈ S}).map
        ⟨fun s => ⟨(i, s.1), s.2⟩, fun s s' h => by
          simp only [Subtype.mk.injEq, Prod.mk.injEq, true_and] at h
          exact Subtype.ext h⟩ := by
    ext c
    simp only [mem_filter, mem_univ, true_and, mem_map]
    constructor
    · intro h
      refine ⟨⟨c.1.2, ?_⟩, ?_⟩
      · rw [← h]; exact c.2
      · apply Subtype.ext; simp [← h]
    · rintro ⟨s, rfl⟩; rfl
  rw [e, sum_map]
  rfl

variable {adj R C}

/-- **Kernels separate conflicts** (Claim `cl:conflict-kernel`). -/
lemma kernel_claim (u : R → KK X) (v : C → KK X) (hu : Bm adj R C *ᵥ u = 0)
    (hv : Ntm adj R C *ᵥ v = 0) (r : R) (c : C) (hrc : Conflict adj r.1 c.1) :
    u r * v c = 0 := by
  classical
  set p := r.1.1
  set i := c.1.1
  let S := {s : X // (i, s) ∈ C}
  let J := {j : X // (p, j) ∈ R}
  let u' : S → KK X := fun s => v ⟨(i, s.1), s.2⟩
  let v' : J → KK X := fun j => u ⟨(p, j.1), j.2⟩
  have hu' : (Matrix.of fun (x : J) (s : S) => gK adj true s.1 x.1) *ᵥ u' = 0 := by
    ext j
    simp only [Matrix.mulVec, dotProduct, Matrix.of_apply, Pi.zero_apply]
    by_cases hz : (i, j.1) ∈ Zset adj R C
    · have := congrFun hv ⟨_, hz⟩
      simp only [Matrix.mulVec, dotProduct, Ntm, blockMat, Matrix.of_apply, Pi.zero_apply,
        ite_mul, zero_mul] at this
      simp only [eq_comm (a := i)] at this
      rw [sum_fst_fiber C i (fun c' => gK adj true c'.1.2 j.1 * v c')] at this
      · exact this
    · refine sum_eq_zero fun s _ => ?_
      by_cases hs : adj s.1 j.1
      · exact absurd ((mem_Zset adj).mpr ⟨(p, j.1), j.2, (i, s.1), s.2, ⟨hrc.1, hs⟩, rfl⟩) hz
      · rw [gK_eq_zero_of_not hs, zero_mul]
  have hv' : v' ᵥ* (Matrix.of fun (x : J) (s : S) => gK adj true s.1 x.1) = 0 := by
    ext s
    simp only [Matrix.vecMul, dotProduct, Matrix.of_apply, Pi.zero_apply]
    by_cases hh : (p, s.1) ∈ Hset adj R C
    · have := congrFun hu ⟨_, hh⟩
      simp only [Matrix.mulVec, dotProduct, Bm, Matrix.of_apply, Pi.zero_apply,
        ite_mul, zero_mul] at this
      have e := sum_fst_fiber R p (fun r' => gK adj true s.1 r'.1.2 * u r')
      simp only [eq_comm (a := p)] at this
      rw [e] at this
      rw [← this]
      exact sum_congr rfl fun j _ => mul_comm _ _
    · refine sum_eq_zero fun j _ => ?_
      by_cases hs : adj s.1 j.1
      · exact absurd (mem_Hset.mpr ⟨(p, j.1), j.2, (i, s.1), s.2, ⟨hrc.1, hs⟩, rfl⟩) hh
      · rw [gK_eq_zero_of_not hs, mul_zero]
  have := generic_kernel adj true (fun j : J => j.1) (fun s : S => s.1) Subtype.val_injective
    Subtype.val_injective u' v' hu' hv' ⟨c.1.2, c.2⟩ ⟨r.1.2, r.2⟩ hrc.2
  simp only [u', v'] at this
  rw [mul_comm]
  exact this

/-- **The core counting theorem** (Claims `cl:kerA`, `cl:rank-inequality`, `cl:simultaneous`). -/
theorem core_bound (s1 sα : Finset R) (sβ : Finset C) (π : R → X × X) (gα : R → X × X)
    (gβ : C → X × X)
    (hπ : ∀ r ∈ s1, π r ∈ C ∧ Conflict adj r.1 (π r))
    (hα : ∀ r ∈ sα, gα r ∈ Zset adj R C ∧ CovL adj r.1 (gα r)) (hαinj : Set.InjOn gα sα)
    (hβ : ∀ c ∈ sβ, gβ c ∈ Zset adj R C ∧ CovR adj c.1 (gβ c)) (hβinj : Set.InjOn gβ sβ)
    (hdisj : Disjoint s1 sα) (hπβ : ∀ r ∈ s1, ∀ c ∈ sβ, c.1 ≠ π r)
    (maxA : ∀ r0 ∈ s1, ∀ g' : R → X × X, Set.InjOn g' (insert r0 sα) →
      ¬ ∀ r ∈ insert r0 sα, g' r ∈ Zset adj R C ∧ CovL adj r.1 (g' r))
    (maxB : ∀ r0 ∈ s1, ∀ c0 : C, c0.1 = π r0 → ∀ g' : C → X × X,
      Set.InjOn g' (insert c0 sβ) →
      ¬ ∀ c ∈ insert c0 sβ, g' c ∈ Zset adj R C ∧ CovR adj c.1 (g' c)) :
    s1.card + sα.card + sβ.card ≤ (Zset adj R C).card + (Hset adj R C).card := by
  classical
  set L := Lm adj R C
  set Nt := Ntm adj R C
  set B := Bm adj R C
  set A := Am adj R C
  -- (1) the columns `sα` of `L` are independent
  have indL : ColIndep L sα := by
    refine block_indep adj false _ _ _ _ ?_ ?_ sα (fun c => ⟨gα c, (hα c c.2).1⟩) ?_ ?_
    · intro r r' h1 h2; exact Subtype.ext (Prod.ext h2 h1)
    · intro z z' h1 h2; exact Subtype.ext (Prod.ext h2 h1)
    · intro c c' h
      have := hαinj c.2 c'.2 (congrArg Subtype.val h)
      exact Subtype.ext this
    · intro c
      exact ⟨((hα c c.2).2.1).symm, (hα c c.2).2.2⟩
  -- (2) the rows `sβ` of `N` are independent
  have indN : ColIndep Nt sβ := by
    refine block_indep adj true _ _ _ _ ?_ ?_ sβ (fun c => ⟨gβ c, (hβ c c.2).1⟩) ?_ ?_
    · intro r r' h1 h2; exact Subtype.ext (Prod.ext h1 h2)
    · intro z z' h1 h2; exact Subtype.ext (Prod.ext h1 h2)
    · intro c c' h
      have := hβinj c.2 c'.2 (congrArg Subtype.val h)
      exact Subtype.ext this
    · intro c
      exact ⟨((hβ c c.2).2.1).symm, (hβ c c.2).2.2⟩
  -- (3) columns of `L` indexed by `s1` lie in the span of the columns `sα`
  have spanL : ∀ r0 ∈ s1, InSpan L sα r0 := by
    intro r0 hr0
    by_contra hn
    have hnot : r0 ∉ sα := fun h => Finset.disjoint_left.mp hdisj hr0 h
    obtain ⟨g, hg, hgne⟩ := (indL.insert hn hnot).exists_matching
    let g' : R → X × X := fun r => if h : r ∈ insert r0 sα then (g ⟨r, h⟩).1 else r.1
    apply maxA r0 hr0 g'
    · intro r hr r' hr' h
      have hr2 : r ∈ insert r0 sα := by simpa using hr
      have hr2' : r' ∈ insert r0 sα := by simpa using hr'
      simp only [g', dif_pos hr2, dif_pos hr2'] at h
      have := hg (Subtype.ext h)
      exact congrArg Subtype.val this
    · intro r hr
      simp only [g', dif_pos hr]
      refine ⟨(g ⟨r, hr⟩).2, ?_⟩
      have := blockMat_ne_zero (hgne ⟨r, hr⟩)
      exact ⟨this.1.symm, this.2⟩
  have spanN : ∀ r0 ∈ s1, ∀ c0 : C, c0.1 = π r0 → InSpan Nt sβ c0 := by
    intro r0 hr0 c0 hc0
    by_contra hn
    have hnot : c0 ∉ sβ := fun h => hπβ r0 hr0 c0 h hc0
    obtain ⟨g, hg, hgne⟩ := (indN.insert hn hnot).exists_matching
    let g' : C → X × X := fun c => if h : c ∈ insert c0 sβ then (g ⟨c, h⟩).1 else c.1
    apply maxB r0 hr0 c0 hc0 g'
    · intro c hc c' hc' h
      have hc2 : c ∈ insert c0 sβ := by simpa using hc
      have hc2' : c' ∈ insert c0 sβ := by simpa using hc'
      simp only [g', dif_pos hc2, dif_pos hc2'] at h
      have := hg (Subtype.ext h)
      exact congrArg Subtype.val this
    · intro c hc
      simp only [g', dif_pos hc]
      refine ⟨(g ⟨c, hc⟩).2, ?_⟩
      have := blockMat_ne_zero (hgne ⟨c, hc⟩)
      exact ⟨this.1.symm, this.2⟩
  -- (5) kernel vectors
  choose μ hμ using spanL
  let uvec : R → R → KK X := fun r0 r =>
    if h : r0 ∈ s1 then (if r = r0 then 1 else 0) - (if r ∈ sα then μ r0 h r else 0) else 0
  have hLu : ∀ r0 ∈ s1, L *ᵥ uvec r0 = 0 := by
    intro r0 hr0
    ext x
    simp only [Matrix.mulVec, dotProduct, uvec, dif_pos hr0, mul_sub, sum_sub_distrib,
      mul_ite, mul_one, mul_zero, sum_ite_eq', mem_univ, if_true, Pi.zero_apply]
    rw [sum_ite_mem, univ_inter, hμ r0 hr0 x]
    simp [mul_comm]
  have hu_at : ∀ r0 ∈ s1, ∀ r ∈ s1, uvec r0 r = if r = r0 then 1 else 0 := by
    intro r0 hr0 r hr
    have : r ∉ sα := fun h => Finset.disjoint_left.mp hdisj hr h
    simp [uvec, hr0, this]
  have hcC : ∀ r ∈ s1, π r ∈ C := fun r hr => (hπ r hr).1
  have hvex : ∀ r (hr : r ∈ s1), ∃ v : C → KK X, Nt *ᵥ v = 0 ∧ v ⟨π r, hcC r hr⟩ = 1 := by
    intro r hr
    obtain ⟨ν, hν⟩ := spanN r hr ⟨π r, hcC r hr⟩ rfl
    have hnot : (⟨π r, hcC r hr⟩ : C) ∉ sβ := fun h => hπβ r hr _ h rfl
    refine ⟨fun c => (if c = ⟨π r, hcC r hr⟩ then 1 else 0) - (if c ∈ sβ then ν c else 0),
      ?_, ?_⟩
    · ext x
      simp only [Matrix.mulVec, dotProduct, mul_sub, sum_sub_distrib,
        mul_ite, mul_one, mul_zero, sum_ite_eq', mem_univ, if_true, Pi.zero_apply]
      rw [sum_ite_mem, univ_inter, hν x]
      simp [mul_comm]
    · simp [hnot]
  choose vv hvv using hvex
  -- (6)+(7) the vectors `B u^r` are independent
  let W : Matrix (Hset adj R C) R (KK X) := Matrix.of fun h r => (B *ᵥ uvec r) h
  have indW : ColIndep W s1 := by
    intro θ hθ r hr
    set U : R → KK X := ∑ r' ∈ s1, θ r' • uvec r'
    have hBU : B *ᵥ U = 0 := by
      ext h
      have := hθ h
      simp only [U, Matrix.mulVec_sum, Matrix.mulVec_smul, Finset.sum_apply, Pi.smul_apply,
        smul_eq_mul, Pi.zero_apply]
      simpa [W] using this
    have hk := kernel_claim U (vv r hr) hBU (hvv r hr).1 r ⟨π r, hcC r hr⟩ (hπ r hr).2
    rw [(hvv r hr).2, mul_one] at hk
    have hUr : U r = θ r := by
      simp only [U, Finset.sum_apply, Pi.smul_apply, smul_eq_mul]
      rw [sum_eq_single r]
      · rw [hu_at r hr r hr]; simp
      · intro r' hr' hne
        rw [hu_at r' hr' r hr, if_neg (Ne.symm hne), mul_zero]
      · intro h; exact absurd hr h
    rw [← hUr]; exact hk
  -- (8) counting, through the three-term complex `R^R → R^Z ⊕ R^H → R^C` (`sec:rank`)
  have := complex_count L B Nt A (NL_eq_AB adj R C) s1 sα sβ uvec hLu indL indN indW hdisj
  rwa [Fintype.card_coe, Fintype.card_coe] at this

end Seymour
