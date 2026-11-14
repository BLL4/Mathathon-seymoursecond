import SeymourLean.Defs
import SeymourLean.Konig

/-!
# The augmented graph `Γ` and the reduction of the pruning lemma to a matching bound

(`sec4-pruning.tex`, Definition `def:gamma`, Claims `cl:isolated`, `cl:cover-to-pruning`,
`cl:konig`.)

The left side of `Γ` is `R ⊔ Z_L` and the right side `C ⊔ Z_R`; we realise both on the type
`(X × X) ⊕ (X × X)` (members outside `R`, `C`, `Z` are isolated and play no role).
-/

open Finset

namespace Seymour

variable {X : Type*} [Fintype X] [DecidableEq X] (adj : X → X → Prop) [DecidableRel adj]

/-- `r = (p,j)` covers `z = (i,j)` under `F₁`. -/
def CovL (r z : X × X) : Prop := r.2 = z.2 ∧ adj r.1 z.1

/-- `c = (i,s)` covers `z = (i,j)` under `F₂`. -/
def CovR (c z : X × X) : Prop := c.1 = z.1 ∧ adj c.2 z.2

/-- The augmented bipartite graph `Γ` (edges E1, E2, E3). -/
def Gam (R C : Finset (X × X)) : (X × X) ⊕ (X × X) → (X × X) ⊕ (X × X) → Prop
  | .inl r, .inl c => r ∈ R ∧ c ∈ C ∧ Conflict adj r c
  | .inl r, .inr z => r ∈ R ∧ z ∈ Zset adj R C ∧ CovL adj r z
  | .inr z, .inl c => z ∈ Zset adj R C ∧ c ∈ C ∧ CovR adj c z
  | .inr _, .inr _ => False

instance (R C : Finset (X × X)) : DecidableRel (Gam adj R C) := by
  intro a b
  rcases a with r | z <;> rcases b with c | z' <;> unfold Gam CovL CovR <;> infer_instance

/-- **Matching bound** (Proposition `prop:matching-bound`): `ν(Γ) ≤ |Z| + |H|`. -/
def MatchingBound : Prop :=
  ∀ (X : Type) [Fintype X] [DecidableEq X] (adj : X → X → Prop) [DecidableRel adj]
    (R C : Finset (X × X)) (M : Finset (((X × X) ⊕ (X × X)) × ((X × X) ⊕ (X × X)))),
    IsMatching (Gam adj R C) M → M.card ≤ (Zset adj R C).card + (Hset adj R C).card

lemma mem_Zset {R C : Finset (X × X)} {z : X × X} :
    z ∈ Zset adj R C ↔ ∃ r ∈ R, ∃ c ∈ C, Conflict adj r c ∧ z = (c.1, r.2) := by
  simp [Zset]

/-- Claim `cl:cover-to-pruning` combined with Kőnig: the matching bound implies the pruning
lemma. -/
theorem pruning_of_matchingBound (hMB : MatchingBound) : PruningLemma := by
  intro X _ _ adj _ R C
  set Z := Zset adj R C with hZ
  obtain ⟨M, hM, KL0, KR0, hK0, hKM⟩ := konig (Gam adj R C)
  have hMb := hMB X adj R C M hM
  -- remove isolated vertices from the cover
  set KL := KL0.filter (fun a => ∃ b, Gam adj R C a b) with hKL
  set KR := KR0.filter (fun b => ∃ a, Gam adj R C a b) with hKR
  have hK : IsCover (Gam adj R C) KL KR := by
    intro a b hab
    rcases hK0 a b hab with h | h
    · left; exact mem_filter.mpr ⟨h, b, hab⟩
    · right; exact mem_filter.mpr ⟨h, a, hab⟩
  have hKLle : KL.card ≤ KL0.card := card_filter_le _ _
  have hKRle : KR.card ≤ KR0.card := card_filter_le _ _
  set R' := R.filter (fun r => Sum.inl r ∉ KL) with hR'
  set C' := C.filter (fun c => Sum.inl c ∉ KR) with hC'
  refine ⟨R', filter_subset _ _, C', filter_subset _ _, ?_, ?_, ?_, ?_⟩
  · -- (P1)
    intro r hr c hc hrc
    simp only [hR', hC', mem_filter] at hr hc
    rcases hK (.inl r) (.inl c) ⟨hr.1, hc.1, hrc⟩ with h | h
    · exact hr.2 h
    · exact hc.2 h
  · -- (P2), left
    intro r hr hfree
    refine mem_filter.mpr ⟨hr, fun h => ?_⟩
    obtain ⟨-, b, hb⟩ := mem_filter.mp h
    rcases b with c | z
    · exact hfree c hb.2.1 hb.2.2
    · obtain ⟨-, hz, hcov⟩ := hb
      obtain ⟨r0, hr0, c0, hc0, hconf, rfl⟩ := (mem_Zset adj).mp hz
      exact hfree c0 hc0 ⟨hcov.2, hcov.1 ▸ hconf.2⟩
  · -- (P2), right
    intro c hc hfree
    refine mem_filter.mpr ⟨hc, fun h => ?_⟩
    obtain ⟨-, a, ha⟩ := mem_filter.mp h
    rcases a with r | z
    · exact hfree r ha.1 ha.2.2
    · obtain ⟨hz, -, hcov⟩ := ha
      obtain ⟨r0, hr0, c0, hc0, hconf, rfl⟩ := (mem_Zset adj).mp hz
      exact hfree r0 hr0 ⟨hcov.1 ▸ hconf.1, hcov.2⟩
  · -- (P3)
    set Zc := Z.filter (fun z => z ∈ F1 adj R' ∪ F2 adj C') with hZc
    have hZcov : ∀ z ∈ Zc, Sum.inr z ∈ KL ∨ Sum.inr z ∈ KR := by
      intro z hz
      obtain ⟨hzZ, hz⟩ := mem_filter.mp hz
      rcases mem_union.mp hz with h | h
      · simp only [F1, mem_filter, mem_univ, true_and] at h
        obtain ⟨p, hp, hpz⟩ := h
        obtain ⟨hpR, hpK⟩ := mem_filter.mp hp
        rcases hK (.inl (p, z.2)) (.inr z) ⟨hpR, hzZ, rfl, hpz⟩ with h' | h'
        · exact absurd h' hpK
        · exact Or.inr h'
      · simp only [F2, mem_filter, mem_univ, true_and] at h
        obtain ⟨s, hs, hsz⟩ := h
        obtain ⟨hsC, hsK⟩ := mem_filter.mp hs
        rcases hK (.inr z) (.inl (z.1, s)) ⟨hzZ, hsC, rfl, hsz⟩ with h' | h'
        · exact Or.inl h'
        · exact absurd h' hsK
    set ZL := Zc.filter (fun z => Sum.inr z ∈ KL)
    set ZR := Zc.filter (fun z => ¬ Sum.inr z ∈ KL)
    have hL : (R \ R').disjSum ZL ⊆ KL := by
      intro x hx
      rcases x with r | z
      · simp only [inl_mem_disjSum, mem_sdiff, hR', mem_filter, not_and, not_not] at hx
        exact hx.2 hx.1
      · simp only [inr_mem_disjSum] at hx
        exact (mem_filter.mp hx).2
    have hR : (C \ C').disjSum ZR ⊆ KR := by
      intro x hx
      rcases x with c | z
      · simp only [inl_mem_disjSum, mem_sdiff, hC', mem_filter, not_and, not_not] at hx
        exact hx.2 hx.1
      · simp only [inr_mem_disjSum] at hx
        obtain ⟨hz, hzL⟩ := mem_filter.mp hx
        rcases hZcov z hz with h | h
        · exact absurd h hzL
        · exact h
    have c1 := card_le_card hL
    have c2 := card_le_card hR
    rw [card_disjSum] at c1 c2
    have c3 : ZL.card + ZR.card = Zc.card :=
      card_filter_add_card_filter_not (s := Zc) (fun z => Sum.inr z ∈ KL)
    have c4 : Zc.card + (Z \ (F1 adj R' ∪ F2 adj C')).card = Z.card := by
      rw [sdiff_eq_filter, hZc]
      exact card_filter_add_card_filter_not (s := Z) (fun z => z ∈ F1 adj R' ∪ F2 adj C')
    have hZd : Z.card = (Zset adj R C).card := by rw [hZ]
    omega

end Seymour
