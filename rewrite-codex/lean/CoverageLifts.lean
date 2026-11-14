import RankChecks

/-!
Construct the normalized kernel lifts from spanning coverage columns.
Independence of the coverage columns is not needed for this construction:
spanning the relevant column images suffices. This is the linear-algebra
part of the matching-lift construction; the generic assignment producing
those spanning columns is not established here.
-/
namespace SecondNeighborhoodCoverageLifts

open Module LinearMap
open scoped BigOperators Classical

variable {K I V : Type*} [Field K] [DecidableEq I]
  [AddCommGroup V] [Module K V]

/-- Subtract a combination of coverage basis vectors to kill the image.
Outside the coverage set, the lift retains its original unit coordinates. -/
theorem exists_kernel_lift
    (L : (I → K) →ₗ[K] V) (A : Finset I) (r : I)
    (hspan : L (Pi.single r 1) ∈ Submodule.span K
      (Set.range (fun a : {a // a ∈ A} => L (Pi.single a.val 1)))) :
    ∃ u : I → K, L u = 0 ∧
      ∀ t, t ∉ A → u t = if r = t then 1 else 0 := by
  classical
  obtain ⟨c, hc⟩ := (Submodule.mem_span_range_iff_exists_fun K).mp hspan
  let w : I → K := ∑ a : {a // a ∈ A}, c a • Pi.single a.val 1
  have hw : L w = L (Pi.single r 1) := by
    simpa only [w, map_sum, map_smul] using hc
  have hwzero (t : I) (ht : t ∉ A) : w t = 0 := by
    simp only [w, Finset.sum_apply, Pi.smul_apply]
    apply Finset.sum_eq_zero
    intro a _
    have hne : a.val ≠ t := by
      intro h
      exact ht (h ▸ a.property)
    simp [Ne.symm hne]
  refine ⟨Pi.single r 1 - w, ?_, ?_⟩
  · simp only [map_sub, hw, sub_self]
  · intro t ht
    simp [Pi.single_apply, hwzero t ht, eq_comm]

/-- Distinct endpoints outside the coverage set have simultaneous lifts
whose restrictions to those endpoints form the identity matrix. -/
theorem exists_normalized_lifts
    {J : Type*} [DecidableEq J]
    (L : (I → K) →ₗ[K] V) (A : Finset I) (f : J → I)
    (hf : Function.Injective f) (houtside : ∀ j, f j ∉ A)
    (hspan : ∀ j, L (Pi.single (f j) 1) ∈ Submodule.span K
      (Set.range (fun a : {a // a ∈ A} => L (Pi.single a.val 1)))) :
    ∃ u : J → I → K, (∀ j, L (u j) = 0) ∧
      ∀ j k, u j (f k) = if j = k then 1 else 0 := by
  classical
  have hex j := exists_kernel_lift L A (f j) (hspan j)
  choose u hu hcoord using hex
  refine ⟨u, hu, ?_⟩
  intro j k
  simpa [hf.eq_iff] using hcoord j (f k) (houtside k)

/-- Combine the constructed lifts with the previous independence theorem.
The column-spanning and kernel-coordinate hypotheses are explicit; lifts
and their normalization no longer have to be supplied as assumptions. -/
theorem kernel_dimension_from_coverage_span
    {W T J : Type*} [AddCommGroup W] [Module K W]
    [AddCommGroup T] [Module K T] [FiniteDimensional K V]
    [Fintype J] [DecidableEq J]
    (Amap : V →ₗ[K] W) (B : (I → K) →ₗ[K] V)
    (L : (I → K) →ₗ[K] T) (N : T →ₗ[K] W)
    (hcommute : Amap.comp B = N.comp L)
    (coverage : Finset I) (f : J → I) (hf : Function.Injective f)
    (houtside : ∀ j, f j ∉ coverage)
    (hspan : ∀ j, L (Pi.single (f j) 1) ∈ Submodule.span K
      (Set.range (fun a : {a // a ∈ coverage} => L (Pi.single a.val 1))))
    (hzero : ∀ x, B x = 0 → ∀ j, x (f j) = 0) :
    Fintype.card J ≤ finrank K Amap.ker := by
  classical
  obtain ⟨u, hu, hcoord⟩ := exists_normalized_lifts L coverage f hf houtside hspan
  let coord : (I → K) →ₗ[K] (J → K) :=
    LinearMap.pi (fun j => LinearMap.proj (f j))
  apply SecondNeighborhoodRank.lifts_give_kernel_dimension Amap B L N hcommute u coord
  · exact hcoord
  · intro x hx
    funext j
    exact hzero x hx j
  · exact hu

#print axioms exists_kernel_lift
#print axioms exists_normalized_lifts
#print axioms kernel_dimension_from_coverage_span
end SecondNeighborhoodCoverageLifts
