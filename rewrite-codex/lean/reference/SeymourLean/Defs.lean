import Mathlib.Data.Fintype.Prod
import Mathlib.Data.Fintype.Sum
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Algebra.Order.BigOperators.Group.Finset

/-!
# Basic definitions

* `N1 adj v`  : first out-neighbourhood of `v`.
* `N2 adj v`  : vertices at distance exactly two from `v`.
* `IsOriented adj` : `adj` is irreflexive and asymmetric (an oriented graph).
* `img adj S` : the forward image `F(S)`.
* `F1`, `F2` : the coordinate images on `X × X` (paper, Def. "Coordinate images").
* `Conflict`, `Zset`, `Hset` : conflicts, conflict points and opposite corners.
* `PruningLemma` : the statement of the pruning lemma (P1)–(P3).
-/

open Finset

namespace Seymour

section Graph

variable {V : Type*} [Fintype V] [DecidableEq V] (adj : V → V → Prop) [DecidableRel adj]

/-- First out-neighbourhood `N⁺₁(v)`. -/
def N1 (v : V) : Finset V := univ.filter (fun w => adj v w)

/-- Second out-neighbourhood `N⁺₂(v)`: vertices at directed distance exactly two from `v`. -/
def N2 (v : V) : Finset V :=
  univ.filter (fun w => w ≠ v ∧ ¬ adj v w ∧ ∃ u, adj v u ∧ adj u w)

/-- Forward image `F(S) = {y | ∃ x ∈ S, x → y}`. -/
def img (S : Finset V) : Finset V := univ.filter (fun y => ∃ x ∈ S, adj x y)

/-- The set of arcs. -/
def arcs : Finset (V × V) := univ.filter (fun p => adj p.1 p.2)

variable {adj}

@[simp] lemma mem_N1 {v w : V} : w ∈ N1 adj v ↔ adj v w := by simp [N1]

@[simp] lemma mem_N2 {v w : V} :
    w ∈ N2 adj v ↔ w ≠ v ∧ ¬ adj v w ∧ ∃ u, adj v u ∧ adj u w := by simp [N2]

@[simp] lemma mem_img {S : Finset V} {y : V} : y ∈ img adj S ↔ ∃ x ∈ S, adj x y := by
  simp [img]

@[simp] lemma mem_arcs {p : V × V} : p ∈ arcs adj ↔ adj p.1 p.2 := by simp [arcs]

end Graph

/-- An oriented graph: irreflexive and asymmetric relation. -/
def IsOriented {V : Type*} (adj : V → V → Prop) : Prop :=
  (∀ x, ¬ adj x x) ∧ ∀ x y, adj x y → ¬ adj y x

/-- **Seymour's second neighbourhood conjecture** (statement): every nonempty finite
oriented graph has a vertex `v` with `|N⁺₁(v)| ≤ |N⁺₂(v)|`. -/
def SeymourStatement : Prop :=
  ∀ (V : Type) [Fintype V] [DecidableEq V] [Nonempty V] (adj : V → V → Prop) [DecidableRel adj],
    IsOriented adj → ∃ v, (N1 adj v).card ≤ (N2 adj v).card

/-- Strict concavity `|U| + |F²U| < 2|FU|` for all nonempty proper `U`. -/
def StrictlyConcave {V : Type*} [Fintype V] [DecidableEq V] (adj : V → V → Prop)
    [DecidableRel adj] : Prop :=
  ∀ U : Finset V, U.Nonempty → U ≠ univ →
    U.card + (img adj (img adj U)).card < 2 * (img adj U).card

/-- Every vertex has an in-neighbour. -/
def PosIndeg {V : Type*} (adj : V → V → Prop) : Prop := ∀ y, ∃ x, adj x y

section Grid

variable {X : Type*} [Fintype X] [DecidableEq X] (adj : X → X → Prop) [DecidableRel adj]

/-- `F₁ S`: move the first coordinate along an arrow. -/
def F1 (S : Finset (X × X)) : Finset (X × X) :=
  univ.filter (fun z => ∃ p, (p, z.2) ∈ S ∧ adj p z.1)

/-- `F₂ S`: move the second coordinate along an arrow. -/
def F2 (S : Finset (X × X)) : Finset (X × X) :=
  univ.filter (fun z => ∃ s, (z.1, s) ∈ S ∧ adj s z.2)

/-- A left member `r = (p,j)` and a right member `c = (i,s)` conflict iff `p → i` and `s → j`. -/
def Conflict (r c : X × X) : Prop := adj r.1 c.1 ∧ adj c.2 r.2

instance (r c : X × X) : Decidable (Conflict adj r c) := by
  unfold Conflict; infer_instance

/-- Conflict points `Z`: `(i,j)` for a conflict between `(p,j) ∈ R` and `(i,s) ∈ C`. -/
def Zset (R C : Finset (X × X)) : Finset (X × X) :=
  univ.filter (fun z => ∃ r ∈ R, ∃ c ∈ C, Conflict adj r c ∧ z = (c.1, r.2))

/-- Opposite corners `H`: `(p,s)` for a conflict between `(p,j) ∈ R` and `(i,s) ∈ C`. -/
def Hset (R C : Finset (X × X)) : Finset (X × X) :=
  univ.filter (fun h => ∃ r ∈ R, ∃ c ∈ C, Conflict adj r c ∧ h = (r.1, c.2))

end Grid

/-- **The pruning lemma** (Lemma "Pruning lemma" of `sec4-pruning.tex`), for an arbitrary finite
set `X` with an arbitrary relation `adj`, and arbitrary `R, C ⊆ X × X`:
there are `R' ⊆ R`, `C' ⊆ C` with
* (P1) `R'` and `C'` are compatible (no conflicts);
* (P2) every member of `R` (resp. `C`) that conflicts with no member of the other family is kept;
* (P3) `|R \ R'| + |C \ C'| ≤ |H| + |Z \ (F₁ R' ∪ F₂ C')|`. -/
def PruningLemma : Prop :=
  ∀ (X : Type) [Fintype X] [DecidableEq X] (adj : X → X → Prop) [DecidableRel adj]
    (R C : Finset (X × X)),
    ∃ R' ⊆ R, ∃ C' ⊆ C,
      (∀ r ∈ R', ∀ c ∈ C', ¬ Conflict adj r c) ∧
      (∀ r ∈ R, (∀ c ∈ C, ¬ Conflict adj r c) → r ∈ R') ∧
      (∀ c ∈ C, (∀ r ∈ R, ¬ Conflict adj r c) → c ∈ C') ∧
      (R \ R').card + (C \ C').card ≤
        (Hset adj R C).card + (Zset adj R C \ (F1 adj R' ∪ F2 adj C')).card

end Seymour
