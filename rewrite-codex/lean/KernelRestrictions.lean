import RankChecks
import SecondNeighborhood

/-!
The restriction step in the pruning argument. This file defines the actual
row equations on H and column equations on Z, proves that they restrict to
the auxiliary matrices, and derives the conflict-kernel product identity.

The maximum-support-rank conditions are explicit inputs. Their simultaneous
realization by one coefficient array is still a separate obligation.
-/
namespace SecondNeighborhoodRestrictions

open SecondNeighborhood SecondNeighborhoodRank
open scoped BigOperators Classical

variable {X K : Type} [Fintype X] [Field K]

noncomputable def backwardRows (R : Family X) (b : X → X → K)
    (u : X → X → K) (p s : X) : K := by
  classical
  exact ∑ j : {j // R p j}, b s j.val * u p j.val

noncomputable def backwardColumns (C : Family X) (b : X → X → K)
    (v : X → X → K) (i j : X) : K := by
  classical
  exact ∑ s : {s // C i s}, b s.val j * v i s.val

def auxiliary (R C : Family X) (b : X → X → K) (p i : X) :
    Matrix {s // C i s} {j // R p j} K := fun s j => b s.val j.val

/-- A nonzero auxiliary row has an H corner, so the full B equation applies.
A row without an allowed entry is identically zero by support. -/
theorem restrict_left_kernel
    (E R C : Family X) (b u : X → X → K)
    (hb : ∀ s j, ¬ E s j → b s j = 0)
    (hu : ∀ p s, cornerH E R C p s → backwardRows R b u p s = 0)
    (p i : X) (hpi : E p i) :
    (auxiliary R C b p i).mulVec (fun j => u p j.val) = 0 := by
  classical
  funext s
  change (∑ j : {j // R p j}, b s.val j.val * u p j.val) = 0
  by_cases hrow : ∃ j : {j // R p j}, E s.val j.val
  · obtain ⟨j, hsj⟩ := hrow
    exact hu p s.val ⟨j.val, i, j.property, s.property, hpi, hsj⟩
  · apply Finset.sum_eq_zero
    intro j _
    have hnot : ¬ E s.val j.val := fun h => hrow ⟨j, h⟩
    rw [hb _ _ hnot, zero_mul]

/-- A nonzero auxiliary column has a Z corner, so the full N-transpose
equation applies. Zero columns are handled without assuming a Z corner. -/
theorem restrict_right_kernel
    (E R C : Family X) (b v : X → X → K)
    (hb : ∀ s j, ¬ E s j → b s j = 0)
    (hv : ∀ i j, cornerZ E R C i j → backwardColumns C b v i j = 0)
    (p i : X) (hpi : E p i) :
    (auxiliary R C b p i).transpose.mulVec (fun s => v i s.val) = 0 := by
  classical
  funext j
  change (∑ s : {s // C i s}, b s.val j.val * v i s.val) = 0
  by_cases hcol : ∃ s : {s // C i s}, E s.val j.val
  · obtain ⟨s, hsj⟩ := hcol
    exact hv i j.val ⟨p, s.val, j.property, s.property, hpi, hsj⟩
  · apply Finset.sum_eq_zero
    intro s _
    have hnot : ¬ E s.val j.val := fun h => hcol ⟨s, h⟩
    rw [hb _ _ hnot, zero_mul]

/-- This is the conflict-kernel identity in the source. Its kernel inputs
are equations only on the two corner sets, not on the entire square. -/
theorem conflict_kernel_product
    (E R C : Family X) (b u v : X → X → K)
    (hb : ∀ s j, ¬ E s j → b s j = 0)
    (hmax : ∀ p i, E p i → ∀ D : Matrix {s // C i s} {j // R p j} K,
      (∀ s j, ¬ E s.val j.val → D s j = 0) →
      D.rank ≤ (auxiliary R C b p i).rank)
    (hu : ∀ p s, cornerH E R C p s → backwardRows R b u p s = 0)
    (hv : ∀ i j, cornerZ E R C i j → backwardColumns C b v i j = 0)
    (p j i s : X) (hr : R p j) (hc : C i s)
    (hpi : E p i) (hsj : E s j) : u p j * v i s = 0 := by
  classical
  have hleft := restrict_left_kernel E R C b u hb hu p i hpi
  have hright := restrict_right_kernel E R C b v hb hv p i hpi
  exact maximum_support_kernel
    (fun s : {s // C i s} => fun j : {j // R p j} => E s.val j.val)
    (auxiliary R C b p i)
    (fun s j hn => hb s.val j.val hn)
    (hmax p i hpi)
    (fun j => u p j.val) (fun s => v i s.val)
    hleft hright ⟨s, hc⟩ ⟨j, hr⟩ hsj

/-- A normalized right-kernel witness forces the corresponding left
coordinate to vanish for every left-kernel vector. This supplies the
coordinate-vanishing input needed by the already checked lift theorem. -/
theorem matched_left_coordinate_zero
    (E R C : Family X) (b u v : X → X → K)
    (hb : ∀ s j, ¬ E s j → b s j = 0)
    (hmax : ∀ p i, E p i → ∀ D : Matrix {s // C i s} {j // R p j} K,
      (∀ s j, ¬ E s.val j.val → D s j = 0) →
      D.rank ≤ (auxiliary R C b p i).rank)
    (hu : ∀ p s, cornerH E R C p s → backwardRows R b u p s = 0)
    (hv : ∀ i j, cornerZ E R C i j → backwardColumns C b v i j = 0)
    (p j i s : X) (hr : R p j) (hc : C i s)
    (hpi : E p i) (hsj : E s j) (hnormal : v i s = 1) : u p j = 0 := by
  have h := conflict_kernel_product E R C b u v hb hmax hu hv p j i s hr hc hpi hsj
  simpa [hnormal] using h

#print axioms restrict_left_kernel
#print axioms restrict_right_kernel
#print axioms conflict_kernel_product
#print axioms matched_left_coordinate_zero
end SecondNeighborhoodRestrictions
