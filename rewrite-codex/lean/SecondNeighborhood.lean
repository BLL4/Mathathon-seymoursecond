import Std

/-!
Selected formal checks for the supplied second-neighborhood proof.

No mathlib dependency. Sets are predicates; all theorem assumptions are
explicit. This file does NOT formalize the full minimal-counterexample or
maximum-support-rank argument. It checks the set-theoretic interfaces of the
extremal construction and the integer accounting, without `sorry`.
-/
namespace SecondNeighborhood

abbrev Family (X : Type) := X → X → Prop
abbrev Subset {X : Type} (P Q : Family X) := ∀ x y, P x y → Q x y

variable {X : Type} (E : X → X → Prop)

def image (S : X → Prop) (y : X) : Prop := ∃ x, S x ∧ E x y
def first (P : Family X) (i j : X) : Prop := ∃ p, P p j ∧ E p i
def second (Q : Family X) (i j : X) : Prop := ∃ s, Q i s ∧ E s j
def diag : Family X := fun i j => i = j
def compatible (P Q : Family X) : Prop := ∀ i j, first E P i j → second E Q i j → False
def conflict (p j i s : X) : Prop := E p i ∧ E s j
def prospectiveLeft (Q : Family X) : Family X := fun p j => ¬ second E (second E Q) p j
def prospectiveRight (P : Family X) : Family X := fun i s => ¬ first E (first E P) i s
def uncovered (P Q : Family X) (p s : X) : Prop := ¬ first E P p s ∧ ¬ second E Q p s

def cornerH (R C : Family X) (p s : X) : Prop :=
  ∃ j i, R p j ∧ C i s ∧ conflict E p j i s

def cornerZ (R C : Family X) (i j : X) : Prop :=
  ∃ p s, R p j ∧ C i s ∧ conflict E p j i s

-- One-step images are monotone and their coordinate directions commute.
theorem first_mono {P Q : Family X} (h : Subset P Q) :
    Subset (first E P) (first E Q) := by
  intro i j hi
  obtain ⟨p, hp, ep⟩ := hi
  exact ⟨p, h p j hp, ep⟩

theorem second_mono {P Q : Family X} (h : Subset P Q) :
    Subset (second E P) (second E Q) := by
  intro i j hi
  obtain ⟨s, hs, es⟩ := hi
  exact ⟨s, h i s hs, es⟩

theorem coordinate_images_commute (P : Family X) (i j : X) :
    first E (second E P) i j ↔ second E (first E P) i j := by
  constructor
  · rintro ⟨p, ⟨s, hps, esj⟩, epi⟩
    exact ⟨s, ⟨p, hps, epi⟩, esj⟩
  · rintro ⟨s, ⟨p, hps, epi⟩, esj⟩
    exact ⟨p, ⟨s, hps, esj⟩, epi⟩

theorem compatible_iff_no_conflict (P Q : Family X) :
    compatible E P Q ↔
      ∀ p j i s, P p j → Q i s → ¬ conflict E p j i s := by
  constructor
  · intro h p j i s hp hq hc
    exact h i j ⟨p, hp, hc.1⟩ ⟨s, hq, hc.2⟩
  · intro h i j h1 h2
    obtain ⟨p, hp, epi⟩ := h1
    obtain ⟨s, hq, esj⟩ := h2
    exact h p j i s hp hq ⟨epi, esj⟩

-- Orientation is needed for the initial admissible pair.
theorem diagonal_compatible (asymm : ∀ x y, E x y → ¬ E y x) :
    compatible E diag diag := by
  intro i j h1 h2
  obtain ⟨p, hp, epi⟩ := h1
  obtain ⟨s, hs, esj⟩ := h2
  change p = j at hp
  change i = s at hs
  subst p
  subst s
  exact asymm j i epi esj

-- Diagonal membership plus positive indegrees make all fibers proper.
theorem left_fiber_proper {P Q : Family X}
    (hdiag : ∀ v, Q v v) (hin : ∀ v, ∃ w, E w v)
    (hcompat : compatible E P Q) (j : X) : ¬ (∀ p, P p j) := by
  intro full
  obtain ⟨w, ewj⟩ := hin j
  obtain ⟨u, euw⟩ := hin w
  exact hcompat w j ⟨u, full u, euw⟩ ⟨w, hdiag w, ewj⟩

theorem right_fiber_proper {P Q : Family X}
    (hdiag : ∀ v, P v v) (hin : ∀ v, ∃ w, E w v)
    (hcompat : compatible E P Q) (i : X) : ¬ (∀ s, Q i s) := by
  intro full
  obtain ⟨w, ewi⟩ := hin i
  obtain ⟨u, euw⟩ := hin w
  exact hcompat i w ⟨w, hdiag w, ewi⟩ ⟨u, full u, euw⟩

-- The new families contain the diagonal.
theorem prospective_left_contains_diag {P Q : Family X}
    (hdiag : ∀ v, P v v) (hcompat : compatible E P Q) (v : X) :
    prospectiveLeft E Q v v := by
  rintro ⟨s, hvs, esv⟩
  exact hcompat v s ⟨s, hdiag s, esv⟩ hvs

theorem prospective_right_contains_diag {P Q : Family X}
    (hdiag : ∀ v, Q v v) (hcompat : compatible E P Q) (v : X) :
    prospectiveRight E P v v := by
  rintro ⟨p, hpv, epv⟩
  exact hcompat p v hpv ⟨p, hdiag p, epv⟩

-- Membership alone is insufficient: diagonal members must also be isolated.
theorem prospective_left_diag_isolated {P : Family X}
    (hdiag : ∀ v, P v v) (v i s : X)
    (hc : prospectiveRight E P i s) : ¬ conflict E v v i s := by
  intro h
  exact hc ⟨v, ⟨s, hdiag s, h.2⟩, h.1⟩

theorem prospective_right_diag_isolated {Q : Family X}
    (hdiag : ∀ v, Q v v) (v p j : X)
    (hr : prospectiveLeft E Q p j) : ¬ conflict E p j v v := by
  intro h
  exact hr ⟨v, ⟨p, hdiag p, h.1⟩, h.2⟩

-- The old uncovered-point bound is a containment, with no counting needed.
theorem conflict_corner_is_old_uncovered (P Q : Family X) :
    Subset (cornerH E (prospectiveLeft E Q) (prospectiveRight E P))
      (uncovered E P Q) := by
  intro p s h
  obtain ⟨j, i, hr, hc, epi, esj⟩ := h
  constructor
  · intro old
    exact hc ⟨p, old, epi⟩
  · intro old
    exact hr ⟨s, old, esj⟩

-- Exact second neighbors equal second-walk endpoints minus first neighbors.
theorem no_two_step_return (asymm : ∀ x y, E x y → ¬ E y x)
    (v : X) : ¬ image E (image E (fun x => x = v)) v := by
  rintro ⟨u, ⟨x, hx, exu⟩, euv⟩
  subst x
  exact asymm v u exu euv

theorem exact_second_convention (asymm : ∀ x y, E x y → ¬ E y x)
    (v w : X) :
    (image E (image E (fun x => x = v)) w ∧ ¬ E v w) ↔
    (w ≠ v ∧ ¬ E v w ∧ ∃ u, E v u ∧ E u w) := by
  constructor
  · rintro ⟨⟨u, ⟨x, hx, exu⟩, euw⟩, hnot⟩
    subst x
    refine ⟨?_, hnot, u, exu, euw⟩
    intro hw
    subst w
    exact asymm v u exu euw
  · rintro ⟨_, hn, u, evu, euw⟩
    exact ⟨⟨u, ⟨v, rfl, evu⟩, euw⟩, hn⟩

-- Arithmetic is done over integers: natural truncated subtraction is unsafe.
theorem blowup_slack (m n delta defect : Int)
    (hm : n < m) (hd : delta ≤ -1) (hn : 0 ≤ n)
    (hbound : defect ≤ m * delta + n) : defect < 0 := by
  have hmpos : 0 ≤ m := by omega
  have hmul : m * delta ≤ m * (-1) := Int.mul_le_mul_of_nonneg_left hd hmpos
  have hneg : m * (-1) = -m := by omega
  omega

theorem cover_charge (deleted copies cover H Z q : Int)
    (hsize : deleted + copies = cover) (hcover : cover ≤ H + Z)
    (hcopies : Z - q ≤ copies) : deleted ≤ H + q := by
  omega

theorem complement_gain (N M a b a2 b2 d r c : Int)
    (hfirst : M + a2 + b2 < 2 * (a + b))
    (huncovered : d = N - a - b)
    (hleft : r = N - b2) (hright : c = N - a2) :
    M + 2 * d < r + c := by
  omega

theorem objective_improves (M d dnew candidates deleted kept : Int)
    (hgain : M + 2 * d < candidates)
    (hcost : deleted ≤ d + dnew)
    (hkeep : kept = candidates - deleted) : M + d < kept + dnew := by
  omega

-- This packages the final contradiction with its exact numerical inputs.
theorem no_extremal_replacement (M d dnew candidates deleted kept : Int)
    (hgain : M + 2 * d < candidates)
    (hcost : deleted ≤ d + dnew)
    (hkeep : kept = candidates - deleted)
    (hmaximal : kept + dnew ≤ M + d) : False := by
  have h := objective_improves M d dnew candidates deleted kept hgain hcost hkeep
  omega

-- A concrete pruning example, checked by kernel reduction on Fin 3.
namespace StarExample

def starRel (a b : Fin 3) : Prop := a = 0 ∧ (b = 1 ∨ b = 2)
def R (p j : Fin 3) : Prop := p = 0 ∧ (j = 1 ∨ j = 2)
def C (i s : Fin 3) : Prop := (i = 1 ∨ i = 2) ∧ s = 0

theorem all_four_conflict :
    ∀ p j i s, R p j → C i s → conflict starRel p j i s := by
  unfold R C conflict starRel
  decide

def keptR (p j : Fin 3) : Prop := p = 0 ∧ j = 1

theorem retained_covers_first_column :
    ∀ i j, first starRel keptR i j ↔ (i = 1 ∨ i = 2) ∧ j = 1 := by
  unfold first starRel keptR
  decide

theorem all_left_covers_targets :
    ∀ i j, first starRel R i j ↔ (i = 1 ∨ i = 2) ∧ (j = 1 ∨ j = 2) := by
  unfold first starRel R
  decide

end StarExample

#print axioms diagonal_compatible
#print axioms conflict_corner_is_old_uncovered
#print axioms exact_second_convention
#print axioms blowup_slack
#print axioms no_extremal_replacement
end SecondNeighborhood
