import Mathlib.LinearAlgebra.Matrix.Rank
import Mathlib.LinearAlgebra.FiniteDimensional.Lemmas
import Mathlib.Combinatorics.Hall.Basic
import Mathlib.Tactic.FieldSimp
import Mathlib.Algebra.BigOperators.Field
import Mathlib.Tactic.LinearCombination

/-!
# Elementary linear algebra on column families

For a matrix `M : Matrix κ ι K` over a field and a finset `s` of column indices:
* `ColIndep M s` : the columns indexed by `s` are linearly independent (finset form);
* `InSpan M s c` : column `c` is a combination of the columns indexed by `s`.

Main facts: `ColIndep.card_le_rank`, `exists_colIndep_spanning` (extraction of a column basis),
`rank_le_of_inSpan`, `ColIndep.card_le_of_support` (independent columns supported on few rows),
`ColIndep.exists_matching` (independent columns can be matched injectively to rows carrying a
nonzero entry, by Hall's theorem), and `rank_mul_ge` (Sylvester's rank inequality).
-/

open Finset Module

set_option linter.unusedSectionVars false

namespace Seymour

variable {K : Type*} [Field K] {κ ι : Type*} [Fintype κ] [Fintype ι] [DecidableEq ι]

/-- The columns of `M` indexed by `s` are linearly independent. -/
def ColIndep (M : Matrix κ ι K) (s : Finset ι) : Prop :=
  ∀ w : ι → K, (∀ x, ∑ c ∈ s, w c * M x c = 0) → ∀ c ∈ s, w c = 0

/-- Column `c0` is a linear combination of the columns indexed by `s`. -/
def InSpan (M : Matrix κ ι K) (s : Finset ι) (c0 : ι) : Prop :=
  ∃ μ : ι → K, ∀ x, M x c0 = ∑ c ∈ s, μ c * M x c

lemma ColIndep.mono {M : Matrix κ ι K} {s t : Finset ι} (h : ColIndep M s) (ht : t ⊆ s) :
    ColIndep M t := by
  intro w hw c hc
  have := h (fun c => if c ∈ t then w c else 0) (by
    intro x
    simp_rw [ite_mul, zero_mul]
    rw [sum_ite_mem, inter_eq_right.mpr ht]
    exact hw x) c (ht hc)
  simpa [hc] using this

lemma ColIndep.insert {M : Matrix κ ι K} {s : Finset ι} {c0 : ι} (h : ColIndep M s)
    (hn : ¬ InSpan M s c0) (hc0 : c0 ∉ s) : ColIndep M (insert c0 s) := by
  intro w hw
  have h0 : w c0 = 0 := by
    by_contra hne
    apply hn
    refine ⟨fun c => - w c / w c0, fun x => ?_⟩
    have hx := hw x
    rw [sum_insert hc0] at hx
    have e : ∑ c ∈ s, -w c / w c0 * M x c = -(∑ c ∈ s, w c * M x c) / w c0 := by
      rw [neg_div, Finset.sum_div, ← sum_neg_distrib]
      refine sum_congr rfl fun c _ => ?_
      ring
    rw [e]
    field_simp
    linear_combination hx
  have hrest := h w (by
    intro x
    have hx := hw x
    rwa [sum_insert hc0, h0, zero_mul, zero_add] at hx)
  intro c hc
  rcases mem_insert.mp hc with rfl | hc
  · exact h0
  · exact hrest c hc

lemma ColIndep.card_le_rank {M : Matrix κ ι K} {s : Finset ι} (h : ColIndep M s) :
    s.card ≤ M.rank := by
  rw [Matrix.rank_eq_finrank_span_cols]
  let v : s → (κ → K) := fun c => M.col c
  have hv : LinearIndependent K v := by
    rw [Fintype.linearIndependent_iff]
    intro g hg c
    have := h (fun c => if hc : c ∈ s then g ⟨c, hc⟩ else 0) (by
      intro x
      have hx := congrFun hg x
      simp only [Finset.sum_apply, Pi.smul_apply, smul_eq_mul, Pi.zero_apply, v,
        Matrix.col_apply] at hx
      rw [← sum_coe_sort s]
      simpa using hx) c.1 c.2
    simpa using this
  have h1 := finrank_span_eq_card hv
  rw [Fintype.card_coe] at h1
  rw [← h1]
  apply Submodule.finrank_mono
  apply Submodule.span_mono
  rintro _ ⟨c, rfl⟩
  exact ⟨c.1, rfl⟩

lemma rank_le_of_inSpan {M : Matrix κ ι K} {s : Finset ι} (h : ∀ c, InSpan M s c) :
    M.rank ≤ s.card := by
  classical
  rw [Matrix.rank_eq_finrank_span_cols]
  have hle : Submodule.span K (Set.range M.col) ≤
      Submodule.span K ((s.image M.col : Finset (κ → K)) : Set (κ → K)) := by
    rw [Submodule.span_le]
    rintro _ ⟨c, rfl⟩
    obtain ⟨μ, hμ⟩ := h c
    have : M.col c = ∑ c' ∈ s, μ c' • M.col c' := by
      ext x; simp [hμ x]
    rw [this]
    refine Submodule.sum_mem _ fun c' hc' => Submodule.smul_mem _ _ ?_
    exact Submodule.subset_span (by simp only [coe_image]; exact ⟨c', hc', rfl⟩)
  calc finrank K (Submodule.span K (Set.range M.col))
      ≤ finrank K (Submodule.span K ((s.image M.col : Finset (κ → K)) : Set (κ → K))) :=
        Submodule.finrank_mono hle
    _ ≤ (s.image M.col).card := finrank_span_finset_le_card _
    _ ≤ s.card := card_image_le

/-- Extraction of a set of independent columns spanning all columns. -/
lemma exists_colIndep_spanning (M : Matrix κ ι K) :
    ∃ s : Finset ι, ColIndep M s ∧ ∀ c, InSpan M s c := by
  classical
  obtain ⟨s, hs, hmax⟩ := exists_max_image ((univ : Finset (Finset ι)).filter (ColIndep M))
    Finset.card ⟨∅, by simp [ColIndep]⟩
  simp only [mem_filter, mem_univ, true_and] at hs hmax
  refine ⟨s, hs, fun c => ?_⟩
  by_contra hn
  have hcs : c ∉ s := by
    intro hc; apply hn
    refine ⟨fun c' => if c' = c then 1 else 0, fun x => ?_⟩
    simp [hc]
  have := hmax _ (hs.insert hn hcs)
  rw [card_insert_of_notMem hcs] at this
  omega

lemma rank_eq_of_colIndep_spanning {M : Matrix κ ι K} {s : Finset ι} (h1 : ColIndep M s)
    (h2 : ∀ c, InSpan M s c) : M.rank = s.card :=
  le_antisymm (rank_le_of_inSpan h2) h1.card_le_rank

/-- Independent columns all supported in the rows `Y` number at most `|Y|`. -/
lemma ColIndep.card_le_of_support [DecidableEq κ] {M : Matrix κ ι K} {s : Finset ι}
    (h : ColIndep M s) (Y : Finset κ) (hY : ∀ x ∉ Y, ∀ c ∈ s, M x c = 0) : s.card ≤ Y.card := by
  -- the matrix restricted to rows in `Y`
  let M' : Matrix Y ι K := fun x c => M x.1 c
  have h' : ColIndep M' s := by
    intro w hw
    apply h w
    intro x
    by_cases hx : x ∈ Y
    · exact hw ⟨x, hx⟩
    · exact sum_eq_zero fun c hc => by rw [hY x hx c hc, mul_zero]
  calc s.card ≤ M'.rank := h'.card_le_rank
    _ ≤ Fintype.card Y := M'.rank_le_card_height
    _ = Y.card := Fintype.card_coe Y

/-- **Hall**: independent columns can be matched injectively to rows with nonzero entries. -/
lemma ColIndep.exists_matching [DecidableEq κ] {M : Matrix κ ι K} {s : Finset ι}
    (h : ColIndep M s) : ∃ g : s → κ, Function.Injective g ∧ ∀ c, M (g c) c ≠ 0 := by
  classical
  let t : s → Finset κ := fun c => univ.filter (fun x => M x c ≠ 0)
  have hall : ∀ u : Finset s, u.card ≤ (u.biUnion t).card := by
    intro u
    have hsub : u.map (Function.Embedding.subtype _) ⊆ s := by
      intro c hc
      obtain ⟨c', _, rfl⟩ := mem_map.mp hc
      exact c'.2
    have := (h.mono hsub).card_le_of_support (u.biUnion t) (by
      intro x hx c hc
      obtain ⟨c', hc', rfl⟩ := mem_map.mp hc
      by_contra hne
      apply hx
      exact mem_biUnion.mpr ⟨c', hc', by simpa [t] using hne⟩)
    simpa using this
  obtain ⟨g, hg, hgt⟩ := (all_card_le_biUnion_card_iff_exists_injective t).mp hall
  exact ⟨g, hg, fun c => by simpa [t] using hgt c⟩

/-- **Sylvester's rank inequality**: `rank(N L) ≥ rank L + rank N - (inner dimension)`. -/
lemma rank_mul_ge {μ : Type*} [Fintype μ] [DecidableEq μ] {ν : Type*} [Fintype ν]
    (N : Matrix ν μ K) (L : Matrix μ ι K) :
    L.rank + N.rank ≤ (N * L).rank + Fintype.card μ := by
  classical
  set f := L.mulVecLin
  set g := N.mulVecLin
  have hNL : (N * L).mulVecLin = g ∘ₗ f := Matrix.mulVecLin_mul N L
  have e1 : (N * L).rank = finrank K (LinearMap.range (g.domRestrict (LinearMap.range f))) := by
    unfold Matrix.rank
    rw [hNL, LinearMap.range_comp, LinearMap.range_domRestrict]
  have e2 := LinearMap.finrank_range_add_finrank_ker (g.domRestrict (LinearMap.range f))
  have e3 := LinearMap.finrank_range_add_finrank_ker g
  have e4 : finrank K (LinearMap.ker (g.domRestrict (LinearMap.range f))) ≤
      finrank K (LinearMap.ker g) := by
    apply LinearMap.finrank_le_finrank_of_injective
      (f := ((LinearMap.range f).subtype.restrict (p := LinearMap.ker (g.domRestrict _))
        (q := LinearMap.ker g) (by
          intro x hx
          simpa using hx)))
    intro x y hxy
    apply Subtype.ext; apply Subtype.ext
    have := congrArg Subtype.val hxy
    simpa using this
  have e5 : Matrix.rank L = finrank K (LinearMap.range f) := rfl
  have e6 : Matrix.rank N = finrank K (LinearMap.range g) := rfl
  rw [Module.finrank_fintype_fun_eq_card] at e3
  omega

end Seymour
