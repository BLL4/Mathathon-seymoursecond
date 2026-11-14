import SeymourLean

/-! Run `lake env lean CheckAxioms.lean` after `lake build`.
The expected output is recorded in `build.log`. -/

#check @Seymour.seymour_second_neighbourhood
#print axioms Seymour.seymour_second_neighbourhood
#print axioms Seymour.pruningLemma
