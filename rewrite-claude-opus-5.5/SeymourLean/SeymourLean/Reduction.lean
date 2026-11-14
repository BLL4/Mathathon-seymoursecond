import SeymourLean.Defs
import Mathlib.Algebra.Order.Ring.Int

/-!
# Minimal counterexamples: closedness and the subset deficit

(`sec2-reduction.tex`, Lemma `lem:strong` and Lemma `lem:subset-deficit`.)

Instead of the strongly-connected-component argument we use the equivalent formulation needed
later: in a minimal counterexample no nonempty proper vertex set is *closed* (has no arc leaving
it).
-/

open Finset

namespace Seymour

section Closed

variable {V : Type} [Fintype V] [DecidableEq V] {adj : V → V → Prop} [DecidableRel adj]

/-- If a nonempty proper vertex set `S` has no arc leaving it, the induced subgraph on `S`
(which has fewer vertices) provides a Seymour vertex of the whole graph. -/
lemma seymour_of_closed
    (IH : ∀ (W : Type) [Fintype W] [DecidableEq W] [Nonempty W] (adj' : W → W → Prop)
      [DecidableRel adj'], Fintype.card W < Fintype.card V → IsOriented adj' →
      ∃ v, (N1 adj' v).card ≤ (N2 adj' v).card)
    (hor : IsOriented adj) (S : Finset V) (hS : S.Nonempty) (hSne : S ≠ univ)
    (hcl : ∀ x ∈ S, ∀ y, adj x y → y ∈ S) :
    ∃ v, (N1 adj v).card ≤ (N2 adj v).card := by
  have : Nonempty S := ⟨⟨hS.choose, hS.choose_spec⟩⟩
  let adj' : S → S → Prop := fun a b => adj a.1 b.1
  have : DecidableRel adj' := fun a b => by unfold adj'; infer_instance
  have hcard : Fintype.card S < Fintype.card V := by
    rw [Fintype.card_coe, ← card_univ]
    exact card_lt_card (ssubset_univ_iff.mpr hSne)
  have hor' : IsOriented adj' := ⟨fun x => hor.1 x.1, fun x y => hor.2 x.1 y.1⟩
  obtain ⟨a, ha⟩ := IH S adj' hcard hor'
  refine ⟨a.1, ?_⟩
  have e1 : (N1 adj' a).map (Function.Embedding.subtype _) = N1 adj a.1 := by
    ext y
    simp only [mem_map, mem_N1, Function.Embedding.subtype_apply, adj']
    constructor
    · rintro ⟨b, hb, rfl⟩; exact hb
    · intro h; exact ⟨⟨y, hcl _ a.2 _ h⟩, h, rfl⟩
  have e2 : (N2 adj' a).map (Function.Embedding.subtype _) = N2 adj a.1 := by
    ext y
    simp only [mem_map, mem_N2, Function.Embedding.subtype_apply, adj']
    constructor
    · rintro ⟨b, ⟨hb1, hb2, u, hu1, hu2⟩, rfl⟩
      exact ⟨fun h => hb1 (Subtype.ext h), hb2, u.1, hu1, hu2⟩
    · rintro ⟨h1, h2, u, hu1, hu2⟩
      have huS : u ∈ S := hcl _ a.2 _ hu1
      refine ⟨⟨y, hcl _ huS _ hu2⟩, ⟨fun h => h1 (congrArg Subtype.val h), h2,
        ⟨u, huS⟩, hu1, hu2⟩, rfl⟩
  rw [← e1, ← e2, card_map, card_map]
  exact ha

end Closed

section Deficit

variable {V : Type} [Fintype V] [DecidableEq V]

/-- Delete all arcs from `S` to `B`. -/
def delArcs (adj : V → V → Prop) (S B : Finset V) : V → V → Prop :=
  fun x y => adj x y ∧ ¬ (x ∈ S ∧ y ∈ B)

instance (adj : V → V → Prop) [DecidableRel adj] (S B : Finset V) :
    DecidableRel (delArcs adj S B) := fun x y => by unfold delArcs; infer_instance

/-- Abstract summing step (Step 3 of the subset-deficit proof). -/
lemma sum_of_steps (E : Finset V) (g : Finset V → ℤ)
    (hstep : ∀ T ⊆ E, T ≠ E → ∃ Q : Finset V, Q.Nonempty ∧ Q ⊆ E \ T ∧
      g (T ∪ Q) < g T + Q.card) :
    ∀ T ⊆ E, T ≠ E → g E < g T + (E \ T).card := by
  intro T
  induction h : (E \ T).card using Nat.strong_induction_on generalizing T with
  | _ n ih =>
    intro hTE hne
    obtain ⟨Q, hQne, hQ, hg⟩ := hstep T hTE hne
    have hQE : Q ⊆ E := fun x hx => (mem_sdiff.mp (hQ hx)).1
    have hdisj : Disjoint T Q := by
      rw [Finset.disjoint_right]; intro x hx; exact (mem_sdiff.mp (hQ hx)).2
    have hcardQ : (E \ T).card = (E \ (T ∪ Q)).card + Q.card := by
      have h1 := card_sdiff_add_card_eq_card hTE
      have h2 := card_sdiff_add_card_eq_card (union_subset hTE hQE)
      have h3 := card_union_of_disjoint hdisj
      omega
    by_cases hTQ : T ∪ Q = E
    · rw [hTQ] at hg hcardQ
      simp at hcardQ
      omega
    · have hlt : (E \ (T ∪ Q)).card < n := by
        have := hQne.card_pos; omega
      have := ih _ hlt (T ∪ Q) rfl (union_subset hTE hQE) hTQ
      omega

variable {adj : V → V → Prop} [DecidableRel adj]

/-- **Subset deficit** (Lemma `lem:subset-deficit`). Let `adj` be a counterexample (every vertex
has `|N₂| < |N₁|`) such that no nonempty proper set is closed and every oriented graph on the same
vertex set with fewer arcs has a Seymour vertex. Then `|F²S \ FS| < |FS \ S|` for every nonempty
proper `S`. -/
lemma subset_deficit (hor : IsOriented adj)
    (hce : ∀ v, (N2 adj v).card < (N1 adj v).card)
    (hsc : ∀ S : Finset V, S.Nonempty → S ≠ univ → ∃ x ∈ S, ∃ y ∉ S, adj x y)
    (IHa : ∀ (adj' : V → V → Prop) [DecidableRel adj'], (arcs adj').card < (arcs adj).card →
      IsOriented adj' → ∃ v, (N1 adj' v).card ≤ (N2 adj' v).card)
    (S : Finset V) (hS : S.Nonempty) (hSne : S ≠ univ) :
    ((img adj (img adj S)) \ img adj S).card < (img adj S \ S).card := by
  set I := img adj S ∩ S with hI
  set E := img adj S \ S with hE
  let g : Finset V → ℤ := fun T => ((img adj T \ (I ∪ T)).card : ℤ)
  -- Step 2: one batch
  have hstep : ∀ T ⊆ E, T ≠ E → ∃ Q : Finset V, Q.Nonempty ∧ Q ⊆ E \ T ∧
      g (T ∪ Q) < g T + Q.card := by
    intro T hTE hTne
    set D := delArcs adj S (E \ T) with hD
    have hEsub : ∀ y ∈ E, ∃ x ∈ S, adj x y := by
      intro y hy; rw [hE, mem_sdiff, mem_img] at hy; exact hy.1
    obtain ⟨y0, hy0⟩ : (E \ T).Nonempty := by
      rw [sdiff_nonempty]; intro h; exact hTne (Subset.antisymm hTE h)
    have harcs : (arcs D).card < (arcs adj).card := by
      apply card_lt_card
      rw [Finset.ssubset_iff_of_subset]
      · obtain ⟨x0, hx0, hxy⟩ := hEsub y0 (mem_sdiff.mp hy0).1
        refine ⟨(x0, y0), by simpa using hxy, ?_⟩
        simp [hD, delArcs, hx0, hy0]
      · intro p hp; simp only [mem_arcs, hD, delArcs] at hp ⊢; exact hp.1
    have horD : IsOriented D :=
      ⟨fun x h => hor.1 x h.1, fun x y h h' => hor.2 x y h.1 h'.1⟩
    obtain ⟨v, hv⟩ := IHa D harcs horD
    -- v lost an out-neighbour
    by_cases hlost : ∃ y, adj v y ∧ v ∈ S ∧ y ∈ E \ T
    swap
    · exfalso
      push Not at hlost
      have h1 : N1 D v = N1 adj v := by
        ext y; simp only [mem_N1, hD, delArcs]
        constructor
        · exact fun h => h.1
        · intro h; exact ⟨h, fun h' => hlost y h h'.1 h'.2⟩
      have h2 : N2 D v ⊆ N2 adj v := by
        intro w hw
        simp only [mem_N2, hD, delArcs] at hw ⊢
        obtain ⟨hw1, hw2, u, hu1, hu2⟩ := hw
        refine ⟨hw1, fun h => hw2 ⟨h, fun h' => hlost w h h'.1 h'.2⟩, u, hu1.1, hu2.1⟩
      have := card_le_card h2
      rw [h1] at hv
      have := hce v
      omega
    obtain ⟨y1, hvy1, hvS, hy1⟩ := hlost
    set Q := N1 adj v ∩ (E \ T) with hQ
    have hQne : Q.Nonempty := ⟨y1, by simp [hQ, hvy1, hy1]⟩
    have hQET : Q ⊆ E \ T := inter_subset_right
    have hQN1 : Q ⊆ N1 adj v := inter_subset_left
    refine ⟨Q, hQne, hQET, ?_⟩
    -- basic facts
    have hSE : ∀ x, x ∈ E → x ∉ S := fun x hx => (mem_sdiff.mp hx).2
    have hQS : ∀ x, x ∈ Q → x ∉ S := fun x hx => hSE x (mem_sdiff.mp (hQET hx)).1
    have hQT : ∀ x, x ∈ Q → x ∉ T := fun x hx => (mem_sdiff.mp (hQET hx)).2
    have hQI : ∀ x, x ∈ Q → x ∉ I := fun x hx hxI => hQS x hx (mem_inter.mp hxI).2
    have hN1sub : ∀ y, adj v y → y ∈ I ∨ y ∈ T ∨ y ∈ Q := by
      intro y hy
      have hyF : y ∈ img adj S := mem_img.mpr ⟨v, hvS, hy⟩
      by_cases hyS : y ∈ S
      · left; exact mem_inter.mpr ⟨hyF, hyS⟩
      · by_cases hyT : y ∈ T
        · right; left; exact hyT
        · right; right
          simp [hQ, hy, hE, hyF, hyS, hyT]
    -- (a) N1 D v = N1 v \ Q
    have hN1D : N1 D v = N1 adj v \ Q := by
      ext y
      rw [mem_N1, mem_sdiff, mem_N1]
      simp only [hD, delArcs]
      constructor
      · rintro ⟨h1, h2⟩; exact ⟨h1, fun hyQ => h2 ⟨hvS, hQET hyQ⟩⟩
      · rintro ⟨h1, h2⟩
        refine ⟨h1, fun h3 => h2 ?_⟩
        rw [hQ]; exact mem_inter.mpr ⟨mem_N1.mpr h1, h3.2⟩
    have ca : (N1 D v).card + Q.card = (N1 adj v).card := by
      rw [hN1D]; exact card_sdiff_add_card_eq_card hQN1
    -- (b) gains and losses
    set Cc := img adj Q \ (I ∪ T ∪ Q ∪ img adj T) with hCc
    have hreach : ∀ w, w ∈ N2 D v → w ∈ I ∨ w ∈ T ∨ w ∈ img adj T := by
      intro w hw
      simp only [mem_N2, hD, delArcs] at hw
      obtain ⟨_, _, u, ⟨hu1, hu1'⟩, ⟨hu2, hu2'⟩⟩ := hw
      have huIT : u ∈ I ∨ u ∈ T := by
        rcases hN1sub u hu1 with h | h | h
        · exact Or.inl h
        · exact Or.inr h
        · exact absurd ⟨hvS, hQET h⟩ hu1'
      rcases huIT with hu | hu
      · have huS : u ∈ S := (mem_inter.mp hu).2
        have hwF : w ∈ img adj S := mem_img.mpr ⟨u, huS, hu2⟩
        by_cases hwS : w ∈ S
        · left; exact mem_inter.mpr ⟨hwF, hwS⟩
        · right; left
          by_contra hwT
          exact hu2' ⟨huS, by simp [hE, hwF, hwS, hwT]⟩
      · right; right; exact mem_img.mpr ⟨u, hu, hu2⟩
    have hN2D : N2 D v ⊆ (N2 adj v \ Cc) ∪ (Q ∩ img adj T) := by
      intro w hw
      have hr := hreach w hw
      have hwC : w ∉ Cc := by
        intro hc
        simp only [hCc, mem_sdiff, mem_union, not_or] at hc
        rcases hr with h | h | h
        · exact hc.2.1.1.1 h
        · exact hc.2.1.1.2 h
        · exact hc.2.2 h
      simp only [mem_N2, hD, delArcs] at hw
      obtain ⟨hw1, hw2, u, ⟨hu1, _⟩, ⟨hu2, _⟩⟩ := hw
      rw [mem_union]
      by_cases hvw : adj v w
      · right
        have hwQ : w ∈ Q := by
          by_contra hwQ
          apply hw2
          refine ⟨hvw, ?_⟩
          rintro ⟨_, h⟩
          exact hwQ (by simp [hQ, hvw, h])
        refine mem_inter.mpr ⟨hwQ, ?_⟩
        rcases hr with h | h | h
        · exact absurd h (hQI w hwQ)
        · exact absurd h (hQT w hwQ)
        · exact h
      · left
        refine mem_sdiff.mpr ⟨?_, hwC⟩
        simp only [mem_N2]
        exact ⟨hw1, hvw, u, hu1, hu2⟩
    have hCN2 : Cc ⊆ N2 adj v := by
      intro c hc
      simp only [hCc, mem_sdiff, mem_union, not_or, mem_img] at hc
      obtain ⟨⟨q, hq, hqc⟩, ⟨⟨hcI, hcT⟩, hcQ⟩, _⟩ := hc
      have hvq : adj v q := hQN1 hq |> mem_N1.mp
      simp only [mem_N2]
      refine ⟨?_, ?_, q, hvq, hqc⟩
      · rintro rfl; exact hor.2 _ _ hvq hqc
      · intro hvc
        rcases hN1sub c hvc with h | h | h
        · exact hcI h
        · exact hcT h
        · exact hcQ h
    have cb1 := card_le_card hN2D
    have cb2 := card_union_le (N2 adj v \ Cc) (Q ∩ img adj T)
    have cb3 := card_sdiff_add_card_eq_card hCN2
    -- (c) increment of g
    have hgsub : img adj (T ∪ Q) \ (I ∪ (T ∪ Q)) ⊆
        ((img adj T \ (I ∪ T)) \ (Q ∩ img adj T)) ∪ Cc := by
      intro w hw
      simp only [mem_sdiff, mem_union, not_or, mem_img, mem_inter] at hw ⊢
      obtain ⟨⟨x, hx, hxw⟩, hwI, hwT, hwQ⟩ := hw
      rcases hx with hx | hx
      · left; exact ⟨⟨⟨x, hx, hxw⟩, hwI, hwT⟩, fun h => hwQ h.1⟩
      · by_cases hwF : ∃ x ∈ T, adj x w
        · left; exact ⟨⟨hwF, hwI, hwT⟩, fun h => hwQ h.1⟩
        · right
          simp only [hCc, mem_sdiff, mem_union, not_or, mem_img]
          exact ⟨⟨x, hx, hxw⟩, ⟨⟨hwI, hwT⟩, hwQ⟩, hwF⟩
    have cc1 := card_le_card hgsub
    have cc2 := card_union_le ((img adj T \ (I ∪ T)) \ (Q ∩ img adj T)) Cc
    have hQFsub : Q ∩ img adj T ⊆ img adj T \ (I ∪ T) := by
      intro w hw
      obtain ⟨hwQ, hwF⟩ := mem_inter.mp hw
      simp only [mem_sdiff, mem_union, not_or]
      exact ⟨hwF, hQI w hwQ, hQT w hwQ⟩
    have cc3 := card_sdiff_add_card_eq_card hQFsub
    have hce' := hce v
    simp only [g]
    omega
  -- Step 3
  have hEne : E.Nonempty := by
    obtain ⟨x, hx, y, hy, hxy⟩ := hsc S hS hSne
    exact ⟨y, by simp [hE, hy]; exact ⟨x, hx, hxy⟩⟩
  have hsum := sum_of_steps E g hstep ∅ (empty_subset _) (by
    intro h; rw [← h] at hEne; exact not_nonempty_empty hEne)
  have hg0 : g ∅ = 0 := by simp [g, img]
  rw [hg0, sdiff_empty] at hsum
  -- Step 1
  have h1 : img adj (img adj S) \ img adj S ⊆ img adj E \ (I ∪ E) := by
    intro w hw
    simp only [mem_sdiff, mem_img] at hw
    obtain ⟨⟨u, hu, huw⟩, hwF⟩ := hw
    have hwF' : w ∉ img adj S := by simpa using hwF
    simp only [mem_sdiff, mem_union, mem_img, not_or]
    refine ⟨⟨u, ?_, huw⟩, fun h => hwF' (mem_inter.mp h).1, fun h => hwF' (mem_sdiff.mp h).1⟩
    rw [hE, mem_sdiff]
    refine ⟨mem_img.mpr hu, fun huS => hwF' (mem_img.mpr ⟨u, huS, huw⟩)⟩
  have := card_le_card h1
  simp only [g] at hsum
  omega

end Deficit

end Seymour
