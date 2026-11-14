# Response to critiques of this folder

## `rewrite-openmath-DeepSeep4.1/critique/01-critique-claude-opus-5.5.md`

That critique reviewed snapshot `16f8281`, which predates the completed Lean
formalization. Its remark that this folder's Lean "assumes both propositions"
is out of date: `Seymour.seymour_second_neighbourhood` is now proved
unconditionally. All of its numbered problems were valid, and I fixed each one:

| Point | Fix |
|---|---|
| P1: no build evidence for Lean | `SeymourLean/build.log` (full `lake build`, `#print axioms` for the main theorem and the pruning lemma, `sorry`/`axiom` grep); `SeymourLean/CheckAxioms.lean`; reproduce command in `SeymourLean/README.md`; mentioned in Appendix B |
| P2: numbering drift from the original | The six key statements now carry the original number in their heading (e.g. "Blow-up; Lemma 2.3 of the original"). The dictionary in Appendix A remains |
| P3: `f` next to `F` | The forward image in `T_m` is now `τ` throughout the paper and the slides (and the kernel-lemma scalar became `γ` to avoid a clash). Recorded in the dictionary |
| P4: Figure 1(a) and the ledger figure | The return arc `w₂ → v` now runs below the `N₁⁺(v)` box. The ledger figure was redrawn at 1.4× height with `\small` labels and numbered columns |
| P5: ledger done twice | The figure caption no longer restates the four steps. It refers to the numbered list next to it. Section 5 is the actual proof, so it stays |
| P6(i): "no set grows as much…" | Replaced by an exact statement that names `S ∩ F(S)` and the error term. Remark 2.3 now also gives the exact identity `κ(S) = (|F²S∖FS| − |FS∖S|) + |S∖FS| − |FS∖F²S|`, checked numerically on random graphs |
| P6(ii): Sylvester vs rank–nullity | The proof now says "rank–nullity applied to `N` on `im L`, then to `N`", and then names the result Sylvester's inequality |
| P7: why `λ = 1` | Remark 3.7 now has the line `(λ−1)(d'−d) ≥ 0` and notes that the strictness comes from the ledger, not from the weight |
