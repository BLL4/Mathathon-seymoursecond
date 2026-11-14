import SeymourLean.MatchingCore
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

/-!
# Proof of the matching bound and of the pruning lemma

(`sec4-pruning.tex`, Section `sec:strategy` and the final proof.)

Instead of choosing a maximum matching of `Γ` with the fewest conflict edges and then arguing with
augmenting paths (Claim `cl:alpha-max`), we encode a matching by its three parts
`M₁` (conflict edges, `s1 → C` via `π`), `α` (`sα → Z` via `gα`) and `β` (`sβ → Z` via `gβ`) and
choose such a decomposition maximising `k + ℓ + t`, then minimising `k`. The two maximality
properties needed by `core_bound` are then immediate exchange arguments.
-/

open Finset

set_option linter.unusedSectionVars false

namespace Seymour

section

variable {X : Type} [Fintype X] [DecidableEq X] {adj : X → X → Prop} [DecidableRel adj]
variable {R C : Finset (X × X)}

/-- A decomposed matching ("data"): conflict part, `α`-part, `β`-part. -/
abbrev Dat (R C : Finset (X × X)) :=
  Finset R × Finset R × Finset C × (R → X × X) × (R → X × X) × (C → X × X)

/-- Validity of decomposed-matching data. -/
def DatValid (adj : X → X → Prop) [DecidableRel adj] (R C : Finset (X × X)) : Dat R C → Prop
  | (s1, sα, sβ, π, gα, gβ) =>
    (∀ r ∈ s1, π r ∈ C ∧ Conflict adj r.1 (π r)) ∧ Set.InjOn π s1 ∧
    (∀ r ∈ sα, gα r ∈ Zset adj R C ∧ CovL adj r.1 (gα r)) ∧ Set.InjOn gα sα ∧
    (∀ c ∈ sβ, gβ c ∈ Zset adj R C ∧ CovR adj c.1 (gβ c)) ∧ Set.InjOn gβ sβ ∧
    Disjoint s1 sα ∧ (∀ r ∈ s1, ∀ c ∈ sβ, c.1 ≠ π r)

/-- Every matching of `Γ` gives valid data of at least the same size. -/
lemma exists_dat_of_matching (M : Finset (((X × X) ⊕ (X × X)) × ((X × X) ⊕ (X × X))))
    (hM : IsMatching (Gam adj R C) M) :
    ∃ d : Dat R C, DatValid adj R C d ∧ M.card ≤ d.1.card + d.2.1.card + d.2.2.1.card := by
  classical
  obtain ⟨hE, hfst, hsnd⟩ := hM
  let s1 : Finset R := univ.filter (fun r : R => ∃ c, (Sum.inl r.1, Sum.inl c) ∈ M)
  let sα : Finset R := univ.filter (fun r : R => ∃ z, (Sum.inl r.1, Sum.inr z) ∈ M)
  let sβ : Finset C := univ.filter (fun c : C => ∃ z, (Sum.inr z, Sum.inl c.1) ∈ M)
  let π : R → X × X := fun r =>
    if h : ∃ c, (Sum.inl r.1, Sum.inl c) ∈ M then h.choose else r.1
  let gα : R → X × X := fun r =>
    if h : ∃ z, (Sum.inl r.1, Sum.inr z) ∈ M then h.choose else r.1
  let gβ : C → X × X := fun c =>
    if h : ∃ z, (Sum.inr z, Sum.inl c.1) ∈ M then h.choose else c.1
  have hπM : ∀ r ∈ s1, (Sum.inl r.1, Sum.inl (π r)) ∈ M := by
    intro r hr
    have h : ∃ c, (Sum.inl r.1, Sum.inl c) ∈ M := by simpa [s1] using hr
    simp only [π, dif_pos h]; exact h.choose_spec
  have hαM : ∀ r ∈ sα, (Sum.inl r.1, Sum.inr (gα r)) ∈ M := by
    intro r hr
    have h : ∃ z, (Sum.inl r.1, Sum.inr z) ∈ M := by simpa [sα] using hr
    simp only [gα, dif_pos h]; exact h.choose_spec
  have hβM : ∀ c ∈ sβ, (Sum.inr (gβ c), Sum.inl c.1) ∈ M := by
    intro c hc
    have h : ∃ z, (Sum.inr z, Sum.inl c.1) ∈ M := by simpa [sβ] using hc
    simp only [gβ, dif_pos h]; exact h.choose_spec
  refine ⟨(s1, sα, sβ, π, gα, gβ), ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩, ?_⟩
  · intro r hr
    have := hE _ (hπM r hr)
    exact ⟨this.2.1, this.2.2⟩
  · intro r hr r' hr' h
    have := hsnd (hπM r hr) (hπM r' hr') (by simp [h])
    simp only [Prod.mk.injEq, Sum.inl.injEq] at this
    exact Subtype.ext this.1
  · intro r hr
    have := hE _ (hαM r hr)
    exact ⟨this.2.1, this.2.2⟩
  · intro r hr r' hr' h
    have := hsnd (hαM r hr) (hαM r' hr') (by simp [h])
    simp only [Prod.mk.injEq, Sum.inl.injEq] at this
    exact Subtype.ext this.1
  · intro c hc
    have := hE _ (hβM c hc)
    exact ⟨this.1, this.2.2⟩
  · intro c hc c' hc' h
    have := hfst (hβM c hc) (hβM c' hc') (by simp [h])
    simp only [Prod.mk.injEq, Sum.inl.injEq] at this
    exact Subtype.ext this.2
  · rw [Finset.disjoint_left]
    intro r hr hr'
    have := hfst (hπM r hr) (hαM r hr') rfl
    simp at this
  · intro r hr c hc h
    have := hsnd (hπM r hr) (hβM c hc) (by simp [h])
    simp at this
  · -- size
    simp only
    let f : ((X × X) ⊕ (X × X)) × ((X × X) ⊕ (X × X)) → (X × X) ⊕ ((X × X) ⊕ (X × X)) :=
      fun e => match e with
        | (.inl r, .inl _) => .inl r
        | (.inl r, .inr _) => .inr (.inl r)
        | (.inr _, .inl c) => .inr (.inr c)
        | (.inr z, .inr _) => .inl z
    have h := card_le_card_of_injOn f
      (t := (s1.map (Function.Embedding.subtype _)).disjSum
        ((sα.map (Function.Embedding.subtype _)).disjSum (sβ.map (Function.Embedding.subtype _))))
      (by
        rintro ⟨a | a, b | b⟩ he
        · have hr := (hE _ he).1
          simp only [f, mem_coe, inl_mem_disjSum, mem_map, Function.Embedding.coe_subtype]
          exact ⟨⟨a, hr⟩, mem_filter.mpr ⟨mem_univ _, b, he⟩, rfl⟩
        · have hr := (hE _ he).1
          simp only [f, mem_coe, inr_mem_disjSum, inl_mem_disjSum, mem_map,
            Function.Embedding.coe_subtype]
          exact ⟨⟨a, hr⟩, mem_filter.mpr ⟨mem_univ _, b, he⟩, rfl⟩
        · have hc := (hE _ he).2.1
          simp only [f, mem_coe, inr_mem_disjSum, mem_map, Function.Embedding.coe_subtype]
          exact ⟨⟨b, hc⟩, mem_filter.mpr ⟨mem_univ _, a, he⟩, rfl⟩
        · exact absurd (hE _ he) (by simp [Gam]))
      (by
        rintro ⟨a | a, b | b⟩ he ⟨a' | a', b' | b'⟩ he' hf <;>
          simp only [f, Sum.inl.injEq, Sum.inr.injEq, reduceCtorEq] at hf <;>
          first
            | (apply hfst he he'; simpa using hf)
            | (apply hsnd he he'; simpa using hf)
            | (exfalso; have := hE _ he; simp [Gam] at this; done)
            | (exfalso; have := hE _ he'; simp [Gam] at this; done))
    simp only [card_disjSum, card_map] at h
    omega

end

/-- **Matching bound** (Proposition `prop:matching-bound`). -/
theorem matchingBound : MatchingBound := by
  intro X _ _ adj _ R C M hM
  classical
  obtain ⟨d0, hd0, hMd0⟩ := exists_dat_of_matching M hM
  set N : ℤ := (Fintype.card (X × X) : ℤ)
  let tot : Dat R C → ℤ := fun d =>
    (N + 1) * ((d.1.card : ℤ) + d.2.1.card + d.2.2.1.card) - d.1.card
  obtain ⟨d, hd, hmax⟩ := exists_max_image ((univ : Finset (Dat R C)).filter (DatValid adj R C))
    tot ⟨d0, by simp [hd0]⟩
  simp only [mem_filter, mem_univ, true_and] at hd hmax
  obtain ⟨s1, sα, sβ, π, gα, gβ⟩ := d
  obtain ⟨hπ, hπinj, hα, hαinj, hβ, hβinj, hdisj, hπβ⟩ := hd
  have hk : ∀ s : Finset R, (s.card : ℤ) ≤ N := by
    intro s
    have h1 : s.card ≤ Fintype.card R := card_le_univ s
    have h2 : Fintype.card R ≤ Fintype.card (X × X) := by
      rw [Fintype.card_coe]; exact card_le_univ R
    simp only [N]; exact_mod_cast h1.trans h2
  have hbound := core_bound s1 sα sβ π gα gβ hπ hα hαinj hβ hβinj hdisj hπβ
    (by
      intro r0 hr0 g' hg' hcond
      have hr0α : r0 ∉ sα := fun h => Finset.disjoint_left.mp hdisj hr0 h
      have := hmax (s1.erase r0, insert r0 sα, sβ, π, g', gβ) ⟨
        fun r hr => hπ r (mem_of_mem_erase hr),
        hπinj.mono (by simp only [coe_erase]; exact Set.diff_subset),
        hcond, (by rw [coe_insert]; exact hg'), hβ, hβinj,
        by
          rw [Finset.disjoint_left]
          intro r hr hr'
          rcases mem_insert.mp hr' with rfl | h
          · exact (ne_of_mem_erase hr) rfl
          · exact Finset.disjoint_left.mp hdisj (mem_of_mem_erase hr) h,
        fun r hr c hc => hπβ r (mem_of_mem_erase hr) c hc⟩
      simp only [tot] at this
      rw [card_erase_of_mem hr0, card_insert_of_notMem hr0α] at this
      have h1 : 1 ≤ s1.card := card_pos.mpr ⟨r0, hr0⟩
      rw [Nat.cast_sub h1] at this
      push_cast at this
      have e : (N + 1) * (((s1.card : ℤ) - 1) + (sα.card + 1) + sβ.card) - ((s1.card : ℤ) - 1) =
          (N + 1) * (s1.card + sα.card + sβ.card) - s1.card + 1 := by ring
      linarith)
    (by
      intro r0 hr0 c0 hc0 g' hg' hcond
      have hc0β : c0 ∉ sβ := fun h => hπβ r0 hr0 c0 h hc0
      have := hmax (s1.erase r0, sα, insert c0 sβ, π, gα, g') ⟨
        fun r hr => hπ r (mem_of_mem_erase hr),
        hπinj.mono (by simp only [coe_erase]; exact Set.diff_subset),
        hα, hαinj, hcond, (by rw [coe_insert]; exact hg'),
        Finset.disjoint_of_subset_left (erase_subset _ _) hdisj,
        by
          intro r hr c hc
          rcases mem_insert.mp hc with rfl | h
          · rw [hc0]
            intro heq
            exact (ne_of_mem_erase hr) (hπinj (mem_coe.mpr (mem_of_mem_erase hr))
              (mem_coe.mpr hr0) heq.symm)
          · exact hπβ r (mem_of_mem_erase hr) c h⟩
      simp only [tot] at this
      rw [card_erase_of_mem hr0, card_insert_of_notMem hc0β] at this
      have h1 : 1 ≤ s1.card := card_pos.mpr ⟨r0, hr0⟩
      rw [Nat.cast_sub h1] at this
      push_cast at this
      have e : (N + 1) * (((s1.card : ℤ) - 1) + sα.card + (sβ.card + 1)) - ((s1.card : ℤ) - 1) =
          (N + 1) * (s1.card + sα.card + sβ.card) - s1.card + 1 := by ring
      linarith)
  -- compare with the data of `M`
  have h0 := hmax d0 hd0
  simp only [tot] at h0
  have hk0 := hk d0.1
  have hk1 := hk s1
  have hN : 0 ≤ N := Int.natCast_nonneg _
  have : (d0.1.card : ℤ) + d0.2.1.card + d0.2.2.1.card ≤ s1.card + sα.card + sβ.card := by
    by_contra hlt
    push Not at hlt
    have : (N + 1) * ((s1.card : ℤ) + sα.card + sβ.card + 1) ≤
        (N + 1) * ((d0.1.card : ℤ) + d0.2.1.card + d0.2.2.1.card) :=
      mul_le_mul_of_nonneg_left (by omega) (by omega)
    nlinarith
  have hM' : (M.card : ℤ) ≤ d0.1.card + d0.2.1.card + d0.2.2.1.card := by exact_mod_cast hMd0
  have hb : ((s1.card + sα.card + sβ.card : ℕ) : ℤ) ≤
      ((Zset adj R C).card + (Hset adj R C).card : ℕ) := by exact_mod_cast hbound
  push_cast at hb
  omega

/-- **The pruning lemma** (Lemma `lem:pruning`), proved. -/
theorem pruningLemma : PruningLemma := pruning_of_matchingBound matchingBound

end Seymour
