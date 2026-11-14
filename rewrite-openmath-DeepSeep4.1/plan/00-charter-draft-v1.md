# Charter (draft v1): what does it mean to make this write-up more readable?

## 0. Purpose

We are not producing a new proof. We are producing a *new presentation of an existing proof*,
such that a competent reader — a beginning graduate student in combinatorics, or a
mathematician from another field — can

* understand **what is being claimed** within five minutes,
* understand **why the proof must look the way it does** within half an hour,
* and **verify every step** if they are willing to spend the time.

Readability is therefore a property of the *reader's path through the document*, not a
property of the sentences. The measure of success is: at every point of the document, the
reader knows (i) what is being asserted, (ii) why it is plausible, (iii) what the current
goal is, and (iv) what was assumed earlier.

## 1. What readability is not

* It is not summarising. A shorter paper is not a more readable one; a proof that omits a
  case is unreadable at that case.
* It is not dumbing down. We keep the full generality, the full strength, and the exact
  hypotheses. We add explanation around the mathematics, not in place of it.
* It is not decoration. Figures must carry content; a figure that only restates the
  previous display is noise.
* It is not "intuition instead of proof". Intuition is labelled as such and kept separate
  from the argument, which remains complete.

## 2. The dimensions of readability

### 2.1 Global architecture

The paper must be readable at three levels of resolution:

* **Level 1 (5 minutes):** the conjecture, the theorem, one picture of the proof.
* **Level 2 (1 hour):** the five main steps, their statements, and the mechanism of each.
* **Level 3 (a day):** every proof, every estimate, every index set.

This requires: an abstract that says the result *and* the method; a "how to read" section;
a proof-map figure; and a dependency graph of lemmas so the reader knows which results are
used where.

Each section opens with a *contract*: what goes in, what comes out, and why the section
exists. Each section closes with a summary of the mechanism in a few sentences.

### 2.2 Local architecture of a proof

Every nontrivial statement (theorem, proposition, lemma) is presented in a fixed order:

1. a **gloss**: one sentence in words, no symbols;
2. the **formal statement**;
3. a **plan**: the proof in 2–5 bullets, naming the steps;
4. the **proof**, with the steps visibly marked and cross-referenced to the plan;
5. a **usage note**: where the statement is used later.

Long proofs are cut into named parts with their own mini-summaries.

### 2.3 Notation

* One notation table, early, with a one-line meaning for every symbol.
* No symbol with two meanings in different sections.
* Names that recall their meaning (an image operator called `F`, a family of pairs called
  `R`, `C`, a set of "bad" points called `Z`, a set of "collisions" called `H`).
* A dictionary mapping the original paper's notation to ours, so the two can be read side
  by side.

### 2.4 Figures

* One figure for every construction that a reader cannot easily hold in their head:
  neighborhoods, the subset deficit, the deletion loop, the blowup, the augmented bipartite
  graph, the four maps, the pair families in the grid, the extremal gain, the cover.
* A consistent visual grammar: same shape/colour means same kind of object in every figure.
* Captions that state what the figure shows and what to look at, so the figure is
  intelligible without the surrounding text.
* No overlap, no clipped labels, legible at 100% zoom in print.

### 2.5 Intuition, signposted

Short boxes that answer the questions a reader actually asks:
*Why is this definition the right one? What breaks if we drop this hypothesis?
Which of these steps is the real idea, and which is bookkeeping?*

### 2.6 Correctness

Readability includes trust. We add:
* a verification appendix recording which steps were re-derived and how;
* computational sanity checks on small random instances for the combinatorial lemmas;
* a formalisation in Lean of the statements and as much of the argument as is feasible.

## 3. Non-goals

* No new results, no strengthened hypotheses, no change of proof strategy.
* No cosmetic rewriting of sentences that are already clear.
* No removal of "routine" verifications; they may be moved to a remark, but they stay.

## 4. Acceptance checklist

- [ ] every lemma has gloss, plan, proof, usage note
- [ ] notation table exists and is respected
- [ ] at least a dozen content-bearing figures
- [ ] figures inspected at 100% zoom for overlap
- [ ] proof map + dependency graph
- [ ] cross-reference dictionary vs the original
- [ ] the paper compiles from scratch with no errors and no overfull boxes
- [ ] a 20-minute beamer deck mirrors the same five steps
