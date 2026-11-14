import Mathlib.LinearAlgebra.FiniteDimensional.Basic
import Mathlib.LinearAlgebra.Matrix.Rank

/-!
The image-space mechanism of the maximum-support-rank kernel lemma,
and the rank inequality used to bound the augmented matching.
The generic simultaneous-minor construction is NOT formalized here.
-/
namespace SecondNeighborhoodRank

open Module LinearMap

section Perturbation
variable {K U V : Type*} [Field K] [AddCommGroup U] [Module K U]
  [AddCommGroup V] [Module K V] [FiniteDimensional K V]

/-- A permitted rank-one perturbation forces a right-kernel coordinate
and a left-kernel coordinate to have zero product at maximum rank. The
coordinate functionals and basis vector are abstracted as `phi`, `psi`, `e`.
The maximum-rank hypothesis is needed only for this one perturbation. -/
theorem kernel_perturbation
    (D : U →ₗ[K] V) (phi : U →ₗ[K] K) (psi : V →ₗ[K] K)
    (e : V) (x : U) (hx : D x = 0)
    (hleft : ∀ w, psi (D w) = 0)
    (hmax : finrank K (D + phi.smulRight e).range ≤ finrank K D.range) :
    phi x * psi e = 0 := by
  by_contra hprod
  have hphi : phi x ≠ 0 := by
    intro h
    exact hprod (by simp [h])
  have hpsi : psi e ≠ 0 := by
    intro h
    exact hprod (by simp [h])
  let D' : U →ₗ[K] V := D + phi.smulRight e
  have he : e ∈ D'.range := by
    have hx' : D' x = phi x • e := by simp [D', hx]
    have hmem : phi x • e ∈ D'.range := ⟨x, hx'⟩
    have hh := D'.range.smul_mem (phi x)⁻¹ hmem
    simpa [smul_smul, hphi] using hh
  have hle : D.range ≤ D'.range := by
    rintro z ⟨w, rfl⟩
    have hw : D' w ∈ D'.range := ⟨w, rfl⟩
    have hs := D'.range.smul_mem (phi w) he
    have hh := D'.range.sub_mem hw hs
    simpa [D'] using hh
  have heq : D.range = D'.range :=
    Submodule.eq_of_le_of_finrank_le hle hmax
  have heold : e ∈ D.range := by rw [heq]; exact he
  obtain ⟨w, hw⟩ := heold
  exact hpsi (hw ▸ hleft w)

end Perturbation

section SupportedMatrices
variable {K I J : Type*} [Field K] [Fintype I] [Fintype J]
  [DecidableEq I] [DecidableEq J]

/-- The exact maximum-support-rank kernel statement, for matrices over any
field. Maximum rank is a hypothesis about every matrix on the same support;
no generic-assignment theorem is used or assumed in this proof. -/
theorem maximum_support_kernel
    (S : I → J → Prop) (D : Matrix I J K)
    (hD : ∀ i j, ¬ S i j → D i j = 0)
    (hmax : ∀ C : Matrix I J K,
      (∀ i j, ¬ S i j → C i j = 0) → C.rank ≤ D.rank)
    (x : J → K) (y : I → K)
    (hx : D.mulVec x = 0) (hy : D.transpose.mulVec y = 0)
    (i : I) (j : J) (hij : S i j) : x j * y i = 0 := by
  classical
  let phi : (J → K) →ₗ[K] K := LinearMap.proj j
  let psi : (I → K) →ₗ[K] K := {
    toFun := fun v => dotProduct y v
    map_add' := fun v w => dotProduct_add y v w
    map_smul' := fun a v => dotProduct_smul a y v }
  let C : Matrix I J K := D + Matrix.single i j 1
  have hC : ∀ s t, ¬ S s t → C s t = 0 := by
    intro s t hnot
    have hne : ¬ (i = s ∧ j = t) := by
      rintro ⟨rfl, rfl⟩
      exact hnot hij
    simp [C, hD s t hnot, hne]
  have hmap : C.mulVecLin = D.mulVecLin + phi.smulRight (Pi.single i 1) := by
    apply LinearMap.ext
    intro v
    funext s
    by_cases h : s = i <;>
      simp [C, Matrix.single_mulVec, phi, LinearMap.smulRight_apply, h]
  have hleft (w : J → K) : psi (D.mulVecLin w) = 0 := by
    change dotProduct y (D.mulVec w) = 0
    rw [← Matrix.dotProduct_transpose_mulVec D w y, hy]
    simp
  have hrank : finrank K (D.mulVecLin + phi.smulRight (Pi.single i 1)).range ≤
      finrank K D.mulVecLin.range := by
    rw [← hmap]
    exact hmax C hC
  have h := kernel_perturbation D.mulVecLin phi psi (Pi.single i 1) x hx hleft hrank
  simpa [phi, psi, dotProduct_single_one] using h

end SupportedMatrices

section Lifts
variable {K U V W T I : Type*} [Field K]
  [AddCommGroup U] [Module K U] [AddCommGroup V] [Module K V]
  [AddCommGroup W] [Module K W] [AddCommGroup T] [Module K T]
  [FiniteDimensional K V] [Fintype I] [DecidableEq I]

/-- The source's lift argument: coordinates distinguish the lifts, every
ker B vector vanishes on these coordinates, and the commuting square
places the independent B-images in ker A. The construction of the lifts
and the coordinate-vanishing hypothesis are explicit inputs. -/
theorem lifts_give_kernel_dimension
    (A : V →ₗ[K] W) (B : U →ₗ[K] V)
    (L : U →ₗ[K] T) (N : T →ₗ[K] W)
    (hcommute : A.comp B = N.comp L)
    (u : I → U) (coord : U →ₗ[K] (I → K))
    (hcoord : ∀ i j, coord (u i) j = if i = j then 1 else 0)
    (hvanish : ∀ x, B x = 0 → coord x = 0)
    (hu : ∀ i, L (u i) = 0) :
    Fintype.card I ≤ finrank K A.ker := by
  classical
  have hind : LinearIndependent K (fun i => B (u i)) := by
    apply Fintype.linearIndependent_iff.mpr
    intro g hg i
    have hzero : B (∑ j, g j • u j) = 0 := by
      simpa only [map_sum, map_smul] using hg
    have hc := congrFun (hvanish _ hzero) i
    simpa [map_sum, map_smul, Finset.sum_apply, hcoord] using hc
  have hmem (i : I) : B (u i) ∈ A.ker := by
    change A (B (u i)) = 0
    have heq := congrArg (fun f : U →ₗ[K] W => f (u i)) hcommute
    simpa [hu] using heq
  let v : I → A.ker := fun i => ⟨B (u i), hmem i⟩
  have hv : LinearIndependent K v :=
    LinearIndependent.of_comp A.ker.subtype hind
  exact hv.fintype_card_le_finrank

end Lifts

section MatchingRank
variable {K : Type*} [Field K]
variable {R C H Z : Type*} [Fintype R] [Fintype H] [Fintype Z]

/-- Once the lifts supply k independent vectors in ker A, the remaining
matching bound follows from rank-nullity and the rank inequality for a
product. No matching, generic-rank, or lift construction is assumed proved
by this theorem: its exact inputs are exposed. -/
theorem matching_bound
    (L : Matrix Z R K) (N : Matrix C Z K)
    (B : Matrix H R K) (A : Matrix C H K)
    (k ell t : ℕ)
    (hcommute : N * L = A * B)
    (hL : L.rank = ell) (hN : N.rank = t)
    (hker : k ≤ finrank K A.mulVecLin.ker) :
    k + ell + t ≤ Fintype.card H + Fintype.card Z := by
  have hnull := A.mulVecLin.finrank_range_add_finrank_ker
  have hprod := Matrix.rank_mul_ge N L
  have hupper := Matrix.rank_mul_le_left A B
  rw [hcommute] at hprod
  rw [hL, hN] at hprod
  simp only [finrank_fintype_fun_eq_card] at hnull
  change A.rank + finrank K A.mulVecLin.ker = Fintype.card H at hnull
  omega

end MatchingRank

#print axioms kernel_perturbation
#print axioms maximum_support_kernel
#print axioms lifts_give_kernel_dimension
#print axioms matching_bound
end SecondNeighborhoodRank
