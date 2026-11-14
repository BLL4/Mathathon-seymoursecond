# Charter (revised v2): what it means to make this write-up more readable

*This is the operative document. It is the checklist I hold the rewrite to. Version 1 is kept
in `00-charter-draft-v1.md`; the review that produced this version is in §9.*

---

## 0. The one-sentence version

Making the write-up readable means **engineering the reader's path through the proof**: at every
point the reader should know what is being asserted, why it is plausible, what the current goal
is, and which earlier facts are in play — while **not one mathematical step is lost, weakened or
paraphrased away**.

The measure of success is not length, elegance or prettiness. It is the number of times a
competent reader has to stop and reconstruct something the text should have told them.

## 1. Why this particular paper is hard to read

Readability work has to be aimed at real defects. Reading `original/build/source` carefully, the
obstacles are the following. They drive everything in §2–§7.

**(D1) Flat architecture.** The paper is six sections of roughly equal weight, but the proof is
*not* uniform: §2 (reduction) and §4 (contradiction) are structural, §3 (pruning) is an algebraic
engine dropped in from outside graph theory, and §5–§6 are consequences that play no role in the
main theorem. Nothing tells the reader which is which. A reader who does not know in advance that
§5–§6 are optional will read them as prerequisites.

**(D2) No statement of the plan at the point of use.** The introduction contains a good overview,
but §3 and §4 open with one sentence and then dive into index sets. The reader is asked to hold
"compatible families", "uncovered points" and "the pruning cost" in mind with no reminder of what
they are for.

**(D3) Overloaded symbols.** `F` is the vertex-set image operator in §2 and §4, and `F₁`, `F₂` are
coordinate image operators in §4, while `f` is the block-internal image in §2 — three objects, one
letter. `d` is a degree in §2 (`d₁`, `d₂`) and the number of uncovered points in §4, and `d'` its
pruned analogue. `T` is a subset of `E` in §2 and a transitive tournament in §2's prose. `C` is a
set of vertices newly reached through `Q` in §2 and a family of pairs in §3. `S` is a vertex set in
§2 and a set of second coordinates in §3 (`S_i`). Every one of these forces a re-read.

**(D4) The two hardest arguments are the least visual.** Lemma 2.2 (subset deficit) is a
seven-object counting argument (`I`, `E`, `g`, `T`, `D_T`, `Q`, `C`) compressed into one display;
Lemma 3.1 (pruning) is a rank argument with four maps, two maximum matchings and a family of
auxiliary matrices. These are exactly the places where a picture and a step-by-step "what we are
counting now" would pay for themselves.

**(D5) Design decisions are stated as facts.** Why maximise `M + d` and not `M`? Why take
complements of the *second* images? Why does the pruning lemma charge uncovered points? Why is the
blowup done at all? Each is a decision that makes the proof work, and each is mentioned once, in
passing. A reader who misses one is lost for the rest of the section.

**(D6) Uniformly dense typography.** Long paragraphs, run-in italic headings, displays without
labels where a label would help, and no visual distinction between a definition, a computation, a
warning and an intuition.

**(D7) "Likewise", "similarly", "the same argument".** Used for arguments that are genuinely
symmetric (fine) and occasionally for arguments that are not obviously so (not fine): e.g. the
mirror arguments for rows vs columns of the pair families, and for the `α`/`β` matchings.

**(D8) No correctness scaffolding.** The paper asserts things like "the change in `g` is exact"
and "up to row and column ordering, block diagonal". These are true, and each takes a minute to
check. Nothing in the document records that they were checked, or how a reader should check them.

## 2. Rules for the global architecture

**R1 (three reading levels).** The paper must be usable at three resolutions:
*Level 1, five minutes:* the conjecture, the theorem, and one figure that shows the shape of the
proof. *Level 2, an hour:* the five steps, their statements, and the mechanism of each.
*Level 3, a day:* every proof, estimate and index set.
Concretely: an abstract that names the method; a "How to read this paper" section with an explicit
route for each level; a proof-map figure; a lemma dependency graph in an appendix.

**R2 (section contract).** Each section opens with a boxed contract: *what we assume*, *what we
prove*, *why the section exists*, *what the reader should take away*. Each section closes with
*what just happened* in three sentences.

**R3 (explicit place in the proof).** Every section says, in its first paragraph, which of the
main steps it implements and which earlier section it consumes. §5 and §6 are explicitly marked
as consequences, not prerequisites.

**R4 (a dependency graph).** An appendix figure with one node per numbered statement and an edge
for each use. This is what lets a reader skip §5–§6 without anxiety, and lets a checker see that
the main theorem uses exactly two propositions.

## 3. Rules for the local architecture of a proof

**R5 (five-part template).** Every numbered statement is presented as

1. **Gloss** — one sentence in words, no symbols, saying what it says.
2. **Statement** — the formal statement, all quantifiers explicit.
3. **Plan** — two to five bullets naming the steps, in order.
4. **Proof** — with the steps visibly labelled `Step 1`, `Step 2`, … and each step's goal stated
   before it is carried out.
5. **Where it is used** — one line naming the later statements that consume it.

**R6 (no dropped steps).** Routine verifications stay. They may be shortened to a sentence or
moved into a remark, but nothing that is needed for the truth of a claim may disappear. Anything
that is genuinely omitted must be flagged as a deliberate omission with a reason.

**R7 ("similarly" is a promise).** "Similarly" is allowed only when the mirrored argument is
literally the same with two symbols exchanged, and when the text says which two symbols. Otherwise
the argument is written out.

**R8 (every inequality gets a sentence).** Any displayed inequality chain longer than two lines is
followed by one sentence naming the input used at each step, or is presented as a labelled table.

**R9 (goal before computation).** Before a computation, state its target; after it, state what was
achieved. A reader should never have to reverse-engineer the purpose of a display.

## 4. Notation discipline

**R10 (one table).** A notation table in the front matter: symbol, meaning, first used.

**R11 (no overloading).** No symbol carries two meanings. The renamings adopted here are:

| original | rewritten | why |
|---|---|---|
| `F`, `F_D` | `F` (vertex-set image only) | one meaning, one letter |
| `F_1`, `F_2` | `Φ₁`, `Φ₂` | distinct glyphs for coordinate images |
| `f` (block-internal) | `τ` | removes the F/f confusion |
| `d` (uncovered count) | `u` | frees `d` for degrees |
| `d_1`, `d_2` (degrees) | `d₁`, `d₂` | kept, now unambiguous |
| `T` (subset of `E`) | `Y` | `T` is reserved for the transitive tournament |
| `T_m` | `T_m` (tournament) | now unique |
| `C` (set in Lemma 2.2) | `Λ` | the *lost* second out-neighbours; `C` is a family of pairs in §3 |
| `H_0` (= `F(S) ∪ F²(S)`, Lemma 2.3) | `W` | `H` is a set of pairs in §3; `W` = blocks that are full |
| `S` (vertex set) | `S` | unchanged |
| `S_i`, `J_p` | `S_i`, `J_p` | unchanged, now clearly subscripted |
| `R`, `C` (families, Lemma 3.1) | `𝓛`, `𝓡` (left / right) | "left/right" is what they are |
| `R`, `C` (complements, §4) | `𝓛`, `𝓡` | same role after pruning |
| `P'`, `Q'` (pruned families) | `𝓛'`, `𝓡'` | no primes on the extremal pair itself |
| `Z`, `H` | `Z`, `H` | unchanged |
| `P`, `Q` (extremal families) | `P`, `Q` | unchanged |
| `k, ℓ, t` (matching counts) | `k, ℓ, t` | unchanged |

A dictionary appendix maps the original notation to the new one, statement by statement, so the
two versions can be read side by side.

**R12 (names that mean something).** Operators are named for what they do (`Φ₁` advances the first
coordinate; `Φ₂` advances the second), families for their role (left, right), and points for their
status (uncovered, conflict point, collision).

**R13 (each symbol defined once).** A symbol is introduced at exactly one place, in a display or a
sentence that says what it is; later uses point back only for the unusual ones.

## 5. Figures

**R14 (a figure wherever the reader must hold more than three objects).** The inventory is fixed in
advance and is part of the contract; each figure is listed in a "figures at a glance" appendix.
Planned figures, one per construction:

1. definitions: first and second out-neighborhood, and why `N₂` is *exact* distance two;
2. proof map: the whole architecture, two pillars, the optional consequences off to the side;
3. the subset deficit: `S`, `I`, `E`, `F(S)`, `F²(S)\F(S)`, and the inequality it must satisfy;
4. the deletion step: `v`, its out-neighbours split into `I`-part, `Y`-part and `Q`, the sets `K₀`
   and `Q ∩ F(Y)`, with the paths that prove the inclusions;
5. the gain/loss ledger for that step, as a table-figure;
6. the blowup: block structure, internal transitive tournament, complete block-to-block arcs;
7. the blowup ledger: which blocks contribute to `F_G(U)` and to `F_G²(U)`;
8. the grid `X × X` with a family of pairs, its columns and rows, and the two coordinate maps;
9. compatibility: `Φ₁P` and `Φ₂Q` disjoint, conflicts as crossings;
10. the pruning graph: the augmented bipartite graph, one conflict's forced path, two conflicts
    sharing a vertex;
11. the cover and the charge: why `|Z| - q` points of `Z` must lie in the cover;
12. the four maps: the commuting square, two routes from a left member to a right member;
13. the extremal picture: `P`, `Q`, the covered region, the uncovered count `u`, the complements,
    and the gain `M + 2u`;
14. the diagonal: why `Δ` survives both second images, and why diagonals never conflict;
15. the consequences: a 3-cycle-free graph, `N₂(v) ⊆ Z(v)`, and the degree count;
16. the lemma dependency graph.

**R15 (visual grammar).** Same shape and colour ⇒ same kind of object, in all figures: vertices as
discs, families of *pairs* as cells/rectangles, families as boxes, "advance" as a solid arrow,
"conflict" as a red dashed arrow, "deleted" as grey. Stated once, in the figure-conventions note.

**R16 (caption = self-contained).** Every caption has three parts: what is drawn; what the reader
should look at; why it matters. A reader who reads only the figure and its caption should get the
point.

**R17 (legibility and no overlap).** Every figure is compiled and inspected as a raster image at
100% and at slide size. No label may overlap a line, another label, or the frame; nothing may be
clipped. Figures are TikZ (no external bits), so they scale and stay editable.

**R18 (a figure never replaces a proof).** Figures illustrate; the argument is in the text. Every
figure is referenced from the proof at the exact step it depicts.

## 6. Intuition, motivation, and "what happens next"

**R19 (intuition is labelled and separated).** Three kinds of box appear, visually distinct:
*Idea* (why the definition or the strategy is the right one), *Warning* (a trap: what fails if a
hypothesis is dropped), *Checkpoint* (the state of the proof, for orientation). Intuition is never
inside a proof where it could be mistaken for an argument.

**R20 (next-step sentences).** The last paragraph of every section and of every long proof says
what the next section/proof will do with what was just proved.

**R21 (the three inventions).** The paper must make explicit, early and repeatedly, which steps are
the genuinely new ideas: (i) the strengthened subset deficit with `|F(S)\S|` on the right; (ii) the
pruning lemma whose cost is charged to the points still uncovered; (iii) the extremal objective
`M + u`, which is designed so that the pruning cost is exactly refunded. Everything else is
reduction, bookkeeping, or a standard consequence.

**R22 (why-questions answered at the point they arise).** A fixed list of questions must be
answered in place: why minimise order *and then* arcs; why blow up by a transitive tournament;
why `m > n`; why maximise `M + u`; why complement the second images; why a vertex cover; why
matrix ranks bound a matching; why the auxiliary matrices `D^{p,i}` are needed.

**R23 (no duplication).** Every added element must answer a question a reader would actually have
at that point. If information appears twice, one copy is deleted. Additional prose that does not
change what the reader knows is a defect, not an improvement.

## 7. Typography and layout

**R24.** Article class, 11pt, generous margins (≈1in), `microtype`, coloured internal links,
numbered equations that are referenced, `tcolorbox` for the contract/idea/warning/checkpoint boxes,
consistent theorem style, running heads naming the section. Figures float but each is referenced
before it appears; where a figure is essential to a step, it is placed with `[H]`-like discipline.
No overfull box beyond 3pt; no widow theorem statements.

**R25.** A "How to read" page, a notation table, a table of the numbered statements with one-line
versions, and an index of figures.

## 8. Correctness scaffolding

**R26 (re-derive everything).** Every inequality, inclusion and index count of the original is
re-derived from scratch during the rewrite; discrepancies are reported, not silently fixed.

**R27 (computational checks).** Small-instance brute-force checks for the combinatorial claims:
the pruning lemma on random small relations, the blowup estimates on random small graphs, the
extremal gain arithmetic, and the consequences for 3-cycle-free graphs. Scripts are kept in the
repository and their results summarised in a verification appendix.

**R28 (formalisation).** A Lean 4 development containing: the definitions; the precise statements
of the main theorem and of the two key propositions; fully checked proofs of everything that can
be checked in the time available; and an explicit, honest list of what is assumed rather than
proved. Statement fidelity is part of the check: the Lean statements are compared with the paper's
statements line by line.

**R29 (verification appendix).** A table: claim, how it was checked (re-derivation / computation /
Lean), residual risk.

## 9. The same principles for the 20-minute presentation

**R30.** The deck is not the paper read aloud. It carries the same five steps with the same
notation, one idea per slide, the same figures (redrawn at slide scale), and a timing budget of
about 45 seconds per slide for 24–26 slides. It must answer, in order: what is the conjecture; why
is it hard; what are the three inventions; how do they fit; what do the consequences look like.
Every slide has a one-line takeaway. No slide is a wall of text; no figure overlaps text; the deck
is compiled and every page inspected as an image.

## 10. Review of v1: what changed and why

v1 was written before reading the paper closely. It was correct but generic: it described
readability in the abstract and could have been attached to any mathematics paper. The review found
five weaknesses, each of which produced a change:

1. **No diagnosis.** v1 had no account of *this* paper's defects, so its rules could not be checked
   against anything. → Added §1 with eight concrete defects (D1)–(D8), located in the text.
2. **No priority.** v1 treated all sections alike, which is precisely defect (D1). → Added R3, R21:
   the paper must say which section is the engine, which is structure, and which is optional.
3. **Rules were unmeasurable.** "Add figures", "explain the intuition" cannot be checked. → Rules
   are now countable or inspectable: a fixed figure inventory (R14), a five-part template (R5), a
   named rename table (R11), a question list (R22), an appendix of checks (R29).
4. **The risk of making things worse was not addressed.** Boxes, figures and glosses can inflate a
   paper and *reduce* readability; renaming symbols can introduce errors. → Added R23 (no
   duplication), R26 (re-derive, report discrepancies), and the rename table with a dictionary
   appendix so that renaming is auditable.
5. **The deck and the formalisation were afterthoughts.** → §9 and R28 fix their relationship to
   the paper: same notation, same five steps, and Lean statements checked against the paper's.

Two further changes of substance: v1's checklist mixed "must" and "nice"; v2 separates the
*contract* (R1–R29, all mandatory) from the *inventory* (figures, boxes), and v2 adds the explicit
"three inventions" spine (R21), which is the single organising idea of the rewrite.

**Second pass over v2.** Re-reading v2 against the source found two remaining collisions that the
first table had missed, both in the same reading chain: `H₀` (the block set `F(S) ∪ F²(S)` of
Lemma 2.3) against `H` (the collision set of the pruning lemma), and `C` (the lost second
out-neighbourhood inside the proof of Lemma 2.2) against `C` (the right family of Lemma 3.1).
Both are now renamed, and `P'`, `Q'` are renamed `𝓛'`, `𝓡'` so that primes never attach to the
extremal pair. The rule that emerged, and that v2 states in R11 only implicitly: rename a symbol
when it names objects of *different kinds* that appear in the same argument chain, and leave it
alone otherwise — gratuitous renaming is itself a source of error.

## 11. Acceptance checklist (run at the end, results recorded)

- [ ] every numbered statement has gloss, plan, proof, usage note (R5)
- [ ] every section has a contract and a closing summary (R2, R20)
- [ ] no symbol overloaded; notation table and dictionary appendix present (R10–R13)
- [ ] all sixteen planned figures present, each referenced at the step it depicts (R14, R18)
- [ ] every figure inspected at 100% zoom; no overlap, no clipping (R17)
- [ ] the eight why-questions of R22 answered in place
- [ ] no step of the original proof missing; every "similarly" justified (R6, R7)
- [ ] compiles cleanly; no overfull box > 3pt (R24)
- [ ] computational checks run, results in the appendix (R27)
- [ ] Lean development compiles; assumptions listed explicitly (R28)
- [ ] deck compiles, 20 minutes, pages inspected (R30)

## 12. Third pass, written after the rewrite was built

Two rules turned out to need adjusting once they met the actual text. Both adjustments are recorded
here rather than silently applied.

**(a) Gloss placement.** R5 put the gloss *before* the formal statement. In practice a gloss placed
before the statement reads as a continuation of the preceding paragraph, and the eye finds the
theorem number first. The paper therefore puts the gloss immediately *after* the statement, as a grey
"In words" line: statement, gloss, plan, proof, usage. The reader gets the same information in the
same order; only the visual attachment changed, and it is now unambiguous.

**(b) The ledger is a remark, not a float.** R14 planned a separate figure for the gain/loss ledger
of Lemma 2.2. A float would have been two centimetres tall and would have broken the page; the ledger
is instead a table inside a numbered remark (Remark 2.3) placed directly after the proof, where the
reader needs it. It carries the same content as the planned figure and is easier to read.

A third, unplanned change: numbering. Remarks share the statement counter, so inserting remarks moved
the numbers of later statements (the blowup lemma is Lemma 2.4, not 2.3). Rather than fight this, the
paper uses `\cref` everywhere and the dictionary in Appendix B records every shift against the
original. This is exactly the sort of silent inconsistency the charter's rule R11 was meant to
prevent, and it was caught by checking the compiled numbers against the plan.

## 13. Acceptance checklist, with the result

| rule | status |
|---|---|
| R2/R20 every section has a contract and a closing summary | done, except §5–§6 whose closing summary is the checkpoint of §4 plus their own remarks |
| R5 five-part template for every statement | done (gloss after the statement, see §12(a)) |
| R6 no step dropped | done; three easily-misread steps are flagged in Appendix C |
| R7 "similarly" justified | done; the two places where the mirror is not literal are written out |
| R10–R13 notation table, no overloading, dictionary | done; Appendix B |
| R14 figures | 15 figures: every construction in the plan except the ledger, which is Remark 2.3 |
| R16 caption = what / look at / why | done for all 15 |
| R17 no overlap, legible | every page inspected as a raster image at 100%; five figures were rebuilt after inspection (roadmap, diagonal, beta, cycles, blowup) |
| R21 the three engines stated early and repeated | done: §1.2, the Idea box in §3.1, the checkpoint of §3, and the closing slide |
| R22 the eight why-questions | answered in place (why minimal order then arcs, why blow up, why m > n, why maximise M+u, why complement the second images, why a vertex cover, why ranks, why the auxiliary matrices) |
| R24 compiles with no overfull box > 3pt | yes: 0 overfull boxes, 0 undefined references, 0 duplicate labels |
| R26 re-derive everything | done; discrepancies: none found |
| R27 computational checks | `checks/verify.py`, all pass; results in Appendix C |
| R28 Lean | `lean/`: definitions, statements, assembly, Corollary 6.1 proved; the three deep lemmas stated, not proved |
| R30 deck | 21 frames, 20 minutes, every page inspected; five frames were adjusted after inspection |
