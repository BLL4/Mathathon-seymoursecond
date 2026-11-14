import Mathlib.Algebra.MvPolynomial.Funext
import Mathlib.Algebra.MvPolynomial.NoZeroDivisors
import RankChecks

/-!
The finite simultaneous-nonvanishing step, allowing the same coefficient
variables to occur in every polynomial. The source's remaining obligation
is to establish that the specific matching and support-rank minors give
nonzero polynomials, not to choose separate assignments for them.
-/
namespace SecondNeighborhoodGenericAssignment

open scoped BigOperators

variable {K S I : Type*} [CommRing K] [IsDomain K] [Infinite K]

/-- A nonzero multivariate polynomial over an infinite integral domain
cannot vanish at every assignment. No finiteness assumption on S is needed. -/
theorem exists_nonzero_evaluation (p : MvPolynomial S K) (hp : p ≠ 0) :
    ∃ x : S → K, MvPolynomial.eval x p ≠ 0 := by
  classical
  by_contra hn
  apply hp
  apply MvPolynomial.funext
  intro x
  have hzero : MvPolynomial.eval x p = 0 := by
    by_contra h
    exact hn ⟨x, h⟩
  simpa using hzero

/-- A common assignment avoids finitely many nonzero polynomials, even
when their variables overlap. This is exactly the shared-coefficient step. -/
theorem simultaneous_nonvanishing (indices : Finset I)
    (p : I → MvPolynomial S K) (hp : ∀ i ∈ indices, p i ≠ 0) :
    ∃ x : S → K, ∀ i ∈ indices, MvPolynomial.eval x (p i) ≠ 0 := by
  classical
  have hprod : (∏ i ∈ indices, p i) ≠ 0 := Finset.prod_ne_zero_iff.mpr hp
  obtain ⟨x, hx⟩ := exists_nonzero_evaluation _ hprod
  refine ⟨x, ?_⟩
  have heval : (∏ i ∈ indices, MvPolynomial.eval x (p i)) ≠ 0 := by
    simpa only [map_prod] using hx
  exact Finset.prod_ne_zero_iff.mp heval

/-- Apply the common assignment directly to a finite list of polynomial
minor matrices of possibly different orders. Determinant commutes with
evaluation, so all evaluated minors are nonsingular simultaneously. -/
theorem simultaneous_nonsingular_minors (indices : Finset I) (n : I → ℕ)
    (M : (i : I) → Matrix (Fin (n i)) (Fin (n i)) (MvPolynomial S K))
    (hdet : ∀ i ∈ indices, (M i).det ≠ 0) :
    ∃ x : S → K, ∀ i ∈ indices,
      ((M i).map (MvPolynomial.eval x)).det ≠ 0 := by
  classical
  obtain ⟨x, hx⟩ := simultaneous_nonvanishing indices (fun i => (M i).det) hdet
  refine ⟨x, ?_⟩
  intro i hi
  have h := hx i hi
  rwa [RingHom.map_det] at h

/-- The same evaluated minors all have their full prescribed ranks. -/
theorem simultaneous_full_rank_minors (indices : Finset I) (n : I → ℕ)
    (M : (i : I) → Matrix (Fin (n i)) (Fin (n i)) (MvPolynomial S K))
    (hdet : ∀ i ∈ indices, (M i).det ≠ 0) :
    ∃ x : S → K, ∀ i ∈ indices,
      ((M i).map (MvPolynomial.eval x)).rank = n i := by
  classical
  obtain ⟨x, hx⟩ := simultaneous_nonsingular_minors indices n M hdet
  refine ⟨x, ?_⟩
  intro i hi
  simpa using Matrix.rank_of_det_ne_zero (hx i hi)

#print axioms exists_nonzero_evaluation
#print axioms simultaneous_nonvanishing
#print axioms simultaneous_nonsingular_minors
#print axioms simultaneous_full_rank_minors
end SecondNeighborhoodGenericAssignment
