import Mathlib.Combinatorics.Hall.Basic
import Mathlib.Data.Fintype.Sum
import Mathlib.Data.Fintype.Prod
import Mathlib.Algebra.Order.Ring.Int

/-!
# Kőnig's theorem for finite bipartite graphs (via the defect version of Hall's theorem)

A bipartite graph is a relation `r : α → β → Prop` between finite types.
* `IsMatching r M` : `M ⊆ α × β` is a set of edges with injective projections.
* `IsCover r KL KR` : every edge has its left end in `KL` or its right end in `KR`.
* `card_le_cover` : weak duality `|M| ≤ |KL| + |KR|`.
* `konig` : there is a matching `M` and a cover with `|KL| + |KR| ≤ |M|`.
-/

open Finset

namespace Seymour

variable {α β : Type*} [Fintype α] [Fintype β] [DecidableEq α] [DecidableEq β]

/-- A matching of the bipartite graph `r`. -/
def IsMatching (r : α → β → Prop) (M : Finset (α × β)) : Prop :=
  (∀ e ∈ M, r e.1 e.2) ∧ Set.InjOn Prod.fst (M : Set (α × β)) ∧
    Set.InjOn Prod.snd (M : Set (α × β))

/-- A vertex cover of the bipartite graph `r`. -/
def IsCover (r : α → β → Prop) (KL : Finset α) (KR : Finset β) : Prop :=
  ∀ a b, r a b → a ∈ KL ∨ b ∈ KR

/-- Weak duality. -/
lemma card_le_cover {r : α → β → Prop} {M : Finset (α × β)} {KL : Finset α} {KR : Finset β}
    (hM : IsMatching r M) (hK : IsCover r KL KR) : M.card ≤ KL.card + KR.card := by
  classical
  let f : α × β → α ⊕ β := fun e => if e.1 ∈ KL then Sum.inl e.1 else Sum.inr e.2
  rw [← card_disjSum]
  refine card_le_card_of_injOn f ?_ ?_
  · intro e he
    simp only [f]
    split_ifs with h
    · simp [h]
    · rcases hK e.1 e.2 (hM.1 e he) with h' | h'
      · exact absurd h' h
      · simp [h']
  · intro e he e' he' hee
    simp only [f] at hee
    split_ifs at hee with h1 h2 h2
    all_goals first
      | exact hM.2.1 he he' (Sum.inl_injective hee)
      | exact hM.2.2 he he' (Sum.inr_injective hee)

/-- **Kőnig's theorem**: some matching is at least as large as some vertex cover. -/
theorem konig (r : α → β → Prop) [DecidableRel r] :
    ∃ M, IsMatching r M ∧ ∃ KL KR, IsCover r KL KR ∧ KL.card + KR.card ≤ M.card := by
  let nbr : Finset α → Finset β := fun s => univ.filter (fun b => ∃ a ∈ s, r a b)
  obtain ⟨S0, -, hS0⟩ := exists_max_image (univ : Finset (Finset α))
    (fun s => (s.card : ℤ) - (nbr s).card) ⟨∅, mem_univ _⟩
  have hδ : (0 : ℤ) ≤ (S0.card : ℤ) - (nbr S0).card := by
    have := hS0 ∅ (mem_univ _); simpa [nbr] using this
  set d : ℕ := S0.card - (nbr S0).card with hd
  have hd' : (d : ℤ) = (S0.card : ℤ) - (nbr S0).card := by omega
  -- Hall's condition for the graph with `d` extra universal right vertices
  let t : α → Finset (β ⊕ Fin d) := fun a => (univ.filter (r a)).disjSum univ
  have hall : ∀ s : Finset α, s.card ≤ (s.biUnion t).card := by
    intro s
    rcases s.eq_empty_or_nonempty with rfl | ⟨a0, ha0⟩
    · simp
    have hsub : (nbr s).disjSum (univ : Finset (Fin d)) ⊆ s.biUnion t := by
      intro x hx
      rw [mem_biUnion]
      rcases x with b | i
      · simp only [inl_mem_disjSum, nbr, mem_filter, mem_univ, true_and] at hx
        obtain ⟨a, ha, hab⟩ := hx
        exact ⟨a, ha, by simp [t, hab]⟩
      · exact ⟨a0, ha0, by simp [t]⟩
    have h1 := card_le_card hsub
    rw [card_disjSum, card_univ, Fintype.card_fin] at h1
    have h2 : (s.card : ℤ) - (nbr s).card ≤ (S0.card : ℤ) - (nbr S0).card := hS0 s (mem_univ _)
    omega
  obtain ⟨f, hfinj, hft⟩ := (all_card_le_biUnion_card_iff_exists_injective t).mp hall
  let M : Finset (α × β) := univ.filter (fun e => f e.1 = Sum.inl e.2)
  have hM : IsMatching r M := by
    refine ⟨?_, ?_, ?_⟩
    · intro e he
      simp only [M, mem_filter, mem_univ, true_and] at he
      have := hft e.1
      rw [he] at this
      simpa [t] using this
    · intro e he e' he' h
      simp only [M, coe_filter, mem_univ, true_and, Set.mem_ofPred_eq] at he he'
      have : (Sum.inl e.2 : β ⊕ Fin d) = Sum.inl e'.2 := by rw [← he, ← he', h]
      exact Prod.ext h (Sum.inl_injective this)
    · intro e he e' he' h
      simp only [M, coe_filter, mem_univ, true_and, Set.mem_ofPred_eq] at he he'
      have : f e.1 = f e'.1 := by rw [he, he', h]
      exact Prod.ext (hfinj this) h
  refine ⟨M, hM, univ \ S0, nbr S0, ?_, ?_⟩
  · intro a b hab
    by_cases ha : a ∈ S0
    · right; simp only [nbr, mem_filter, mem_univ, true_and]; exact ⟨a, ha, hab⟩
    · left; simp [ha]
  · -- size of the matching
    let A : Finset α := univ.filter (fun a => (f a).isLeft)
    have hMA : M.card = A.card := by
      rw [← card_image_of_injOn hM.2.1]
      congr 1
      ext a
      simp only [M, A, mem_image, mem_filter, mem_univ, true_and]
      constructor
      · rintro ⟨e, he, rfl⟩; rw [he]; rfl
      · intro ha
        rcases hfa : f a with b | i
        · exact ⟨(a, b), hfa, rfl⟩
        · rw [hfa] at ha; simp at ha
    have hB : (univ.filter (fun a => ¬ (f a).isLeft)).card ≤ d := by
      have := card_le_card_of_injOn f (s := univ.filter (fun a => ¬ (f a).isLeft))
        (t := (univ : Finset (Fin d)).map Function.Embedding.inr) (by
          intro a ha
          simp only [coe_filter, mem_univ, true_and, Set.mem_ofPred_eq] at ha
          rcases hfa : f a with b | i
          · rw [hfa] at ha; simp at ha
          · simp) hfinj.injOn
      simpa using this
    have hsplit := card_filter_add_card_filter_not (s := (univ : Finset α))
      (fun a => (f a).isLeft)
    have hS0le : S0.card ≤ Fintype.card α := card_le_univ _
    rw [card_sdiff_of_subset (subset_univ _), card_univ, hMA]
    simp only [A] at *
    rw [card_univ] at hsplit
    omega

end Seymour
