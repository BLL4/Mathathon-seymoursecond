import GenericAssignment

/-!
A matching gives a nonzero sparse generic determinant. Align the matching
with the diagonal. Assign 1 to its variables and 0 to all other variables;
the evaluated matrix is the identity. Distinctness is needed within this
one minor, not across the different minors used in the proof.
-/
namespace SecondNeighborhoodMatchingMinor

open scoped Classical
variable {K S : Type*} [CommRing K] [IsDomain K]

noncomputable def sparseGeneric {n : ℕ} (allowed : Fin n → Fin n → Prop)
    (entryVar : Fin n × Fin n → S) : Matrix (Fin n) (Fin n) (MvPolynomial S K) :=
  fun i j => if allowed i j then MvPolynomial.X (entryVar (i,j)) else 0

/-- A perfect matching, enumerated diagonally, certifies a nonzero minor
polynomial whenever the allowed entries have distinct entryVar names. -/
theorem matching_minor_det_ne_zero {n : ℕ}
    (allowed : Fin n → Fin n → Prop) (entryVar : Fin n × Fin n → S)
    (hvariable : Function.Injective entryVar) (hmatching : ∀ i, allowed i i) :
    (sparseGeneric (K := K) allowed entryVar).det ≠ 0 := by
  classical
  let x : S → K := fun s => if ∃ k : Fin n, entryVar (k,k) = s then 1 else 0
  have hentry (i j : Fin n) :
      MvPolynomial.eval x (MvPolynomial.X (entryVar (i,j))) =
        if i = j then 1 else 0 := by
    simp only [MvPolynomial.eval_X]
    change (if ∃ k : Fin n, entryVar (k,k) = entryVar (i,j) then (1 : K) else 0) = _
    by_cases h : i = j
    · subst j
      simp [show ∃ k : Fin n, entryVar (k,k) = entryVar (i,i) from ⟨i, rfl⟩]
    · have hnot : ¬ ∃ k : Fin n, entryVar (k,k) = entryVar (i,j) := by
        rintro ⟨k, hk⟩
        have heq := hvariable hk
        have hki := congrArg Prod.fst heq
        have hkj := congrArg Prod.snd heq
        exact h (hki.symm.trans hkj)
      simp [hnot, h]
  have hidentity :
      (sparseGeneric (K := K) allowed entryVar).map (MvPolynomial.eval x) = 1 := by
    ext i j
    by_cases h : i = j
    · subst j
      simp [sparseGeneric, hmatching, hentry]
    · by_cases hij : allowed i j <;> simp [sparseGeneric, hij, hentry, h]
  have hdet :
      MvPolynomial.eval x (sparseGeneric (K := K) allowed entryVar).det = 1 := by
    rw [RingHom.map_det]
    change ((sparseGeneric (K := K) allowed entryVar).map (MvPolynomial.eval x)).det = 1
    rw [hidentity]
    simp
  intro hzero
  rw [hzero, map_zero] at hdet
  exact zero_ne_one hdet

#print axioms matching_minor_det_ne_zero
end SecondNeighborhoodMatchingMinor
