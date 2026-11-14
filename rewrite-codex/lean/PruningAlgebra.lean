import KernelRestrictions
import CoverageLifts

/-!
Connect the actual corner kernel equations to coverage spanning and the
kernel-dimension bound. The square identity and both coverage-spanning
conditions are explicit inputs. This file does not claim to construct the
normalized maximum matching or the simultaneous generic assignment.
-/
namespace SecondNeighborhoodPruningAlgebra

open SecondNeighborhood SecondNeighborhoodRestrictions SecondNeighborhoodCoverageLifts
open Module LinearMap
open scoped BigOperators Classical

variable {X K : Type} [Fintype X] [Field K]

abbrev HIndex (E R C : Family X) := {q : X × X // cornerH E R C q.1 q.2}
abbrev ZIndex (E R C : Family X) := {q : X × X // cornerZ E R C q.1 q.2}

noncomputable def cornerB (E R C : Family X) (b : X → X → K) :
    ((X × X) → K) →ₗ[K] (HIndex E R C → K) where
  toFun u h := backwardRows R b (fun p j => u (p,j)) h.val.1 h.val.2
  map_add' u v := by
    funext h
    simp [backwardRows, mul_add, Finset.sum_add_distrib]
  map_smul' a u := by
    funext h
    change (∑ j : {j // R h.val.1 j}, b h.val.2 j.val * (a * u (h.val.1,j.val))) =
      a * ∑ j : {j // R h.val.1 j}, b h.val.2 j.val * u (h.val.1,j.val)
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro j _
    exact mul_left_comm _ _ _

noncomputable def cornerNT (E R C : Family X) (b : X → X → K) :
    ((X × X) → K) →ₗ[K] (ZIndex E R C → K) where
  toFun v z := backwardColumns C b (fun i s => v (i,s)) z.val.1 z.val.2
  map_add' u v := by
    funext z
    simp [backwardColumns, mul_add, Finset.sum_add_distrib]
  map_smul' a v := by
    funext z
    change (∑ s : {s // C z.val.1 s}, b s.val z.val.2 * (a * v (z.val.1,s.val))) =
      a * ∑ s : {s // C z.val.1 s}, b s.val z.val.2 * v (z.val.1,s.val)
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro s _
    exact mul_left_comm _ _ _

/-- Conditional algebraic core of the pruning proof. The normalized right
lifts are constructed from coverage span; their kernel products force the
matched left coordinates to vanish; left coverage span then constructs the
independent vectors in ker A. Thus neither the lifts nor the dimension bound
is assumed by this theorem. -/
theorem kernel_dimension_from_pruning_data
    {W T J : Type} [AddCommGroup W] [Module K W]
    [AddCommGroup T] [Module K T] [Fintype J] [DecidableEq J]
    (E R C : Family X) (b : X → X → K)
    (hb : ∀ s j, ¬ E s j → b s j = 0)
    (hmax : ∀ p i, E p i → ∀ D : Matrix {s // C i s} {j // R p j} K,
      (∀ s j, ¬ E s.val j.val → D s j = 0) →
      D.rank ≤ (auxiliary R C b p i).rank)
    (A : (HIndex E R C → K) →ₗ[K] W)
    (L : ((X × X) → K) →ₗ[K] T) (N : T →ₗ[K] W)
    (hcommute : A.comp (cornerB E R C b) = N.comp L)
    (left right : J → X × X) (hleftinj : Function.Injective left)
    (hconflict : ∀ j, R (left j).1 (left j).2 ∧ C (right j).1 (right j).2 ∧
      E (left j).1 (right j).1 ∧ E (right j).2 (left j).2)
    (coverageLeft coverageRight : Finset (X × X))
    (houtsideLeft : ∀ j, left j ∉ coverageLeft)
    (houtsideRight : ∀ j, right j ∉ coverageRight)
    (hspanLeft : ∀ j, L (Pi.single (left j) 1) ∈ Submodule.span K
      (Set.range (fun a : {a // a ∈ coverageLeft} => L (Pi.single a.val 1))))
    (hspanRight : ∀ j, (cornerNT E R C b) (Pi.single (right j) 1) ∈ Submodule.span K
      (Set.range (fun a : {a // a ∈ coverageRight} =>
        (cornerNT E R C b) (Pi.single a.val 1)))) :
    Fintype.card J ≤ finrank K A.ker := by
  classical
  have hex j := exists_kernel_lift (cornerNT E R C b) coverageRight (right j) (hspanRight j)
  choose v hv hcoord using hex
  have hnormal j : v j (right j) = 1 := by
    simpa using hcoord j (right j) (houtsideRight j)
  have hzero (u : (X × X) → K) (hu : cornerB E R C b u = 0) (j : J) : u (left j) = 0 := by
    have hrows p s (hps : cornerH E R C p s) :
        backwardRows R b (fun p j => u (p,j)) p s = 0 :=
      congrFun hu ⟨(p,s), hps⟩
    have hcols i s (his : cornerZ E R C i s) :
        backwardColumns C b (fun i s => v j (i,s)) i s = 0 :=
      congrFun (hv j) ⟨(i,s), his⟩
    obtain ⟨hr, hc, hpi, hsj⟩ := hconflict j
    exact matched_left_coordinate_zero E R C b
      (fun p j => u (p,j)) (fun i s => v j (i,s)) hb hmax hrows hcols
      (left j).1 (left j).2 (right j).1 (right j).2 hr hc hpi hsj (hnormal j)
  exact kernel_dimension_from_coverage_span A (cornerB E R C b) L N hcommute
    coverageLeft left hleftinj houtsideLeft hspanLeft hzero

#print axioms kernel_dimension_from_pruning_data
end SecondNeighborhoodPruningAlgebra
