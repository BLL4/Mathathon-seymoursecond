/-
  The two arithmetic facts that the revision of the paper isolates:

  * the ledger of the extremal argument closes for every `d, d'` exactly when the
    weight on uncovered points is 1 (`ledger_weight`);
  * the blowup works with `m ≥ n`, not only with `m > n` (`blowup_size_ok`).

  Both are statements about integers, so they are cheap to check and they pin down
  two choices that the paper says are forced.  Nothing here depends on the graph
  theory of the other files.
-/
import Mathlib

namespace Seymour

/-- The extremal ledger with weight `lam` on uncovered points.  `mu = |P|+|Q|`,
`d` = uncovered points of the extremal pair, `d'` = uncovered points after pruning.
The gain gives strictly more than `mu + 2d`; pruning deletes at most `d + d'`
members; the survivors' uncovered points `d'` are counted with weight `lam`.

`ledger_ok lam d d'` says: the value of the survivors is strictly larger than the
value of the extremal pair.  The hypothesis `0 ≤ lam` and `d' ≤ ...` are what the
paper verifies for the specific instance; here we only record the arithmetic. -/
def ledger_ok (lam d dp : ℚ) : Prop := ((1 - lam) * d + (lam - 1) * dp : ℚ) ≥ 0

/-- With weight 1 the ledger closes for every `d, d' ≥ 0`. -/
theorem ledger_weight_one (d dp : ℚ) (_h1 : 0 ≤ d) (_h2 : 0 ≤ dp) : ledger_ok 1 d dp := by
  simp [ledger_ok]

/-- With any other weight there are `d, d' ≥ 0` for which the ledger fails. -/
theorem ledger_other_weight_fails (lam : ℚ) (h : lam ≠ 1) :
    ∃ d dp : ℚ, 0 ≤ d ∧ 0 ≤ dp ∧ ¬ ledger_ok lam d dp := by
  by_cases hlt : lam < 1
  · -- take d' bigger than d
    refine ⟨0, 1, le_refl 0, by norm_num, ?_⟩
    simp only [ledger_ok, mul_zero, mul_one, zero_add]
    nlinarith
  · -- take d bigger than d'
    push Not at hlt
    have hgt : 1 < lam := lt_of_le_of_ne hlt (Ne.symm h)
    refine ⟨1, 0, by norm_num, le_refl 0, ?_⟩
    simp only [ledger_ok, mul_zero]
    nlinarith

/-- The hypothesis `m ≥ n` suffices for the blowup: a proper `S` has
`|S \ F(S)| ≤ |S| ≤ n - 1 < m`, so the amplified deficit beats the error term. -/
theorem blowup_size_ok (m n sdef : ℕ) (hn : 0 < n) (hm : n ≤ m)
    (hs : sdef ≤ n - 1) : sdef < m := by
  omega

end Seymour
