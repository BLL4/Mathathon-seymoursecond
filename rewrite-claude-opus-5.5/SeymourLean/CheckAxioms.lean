import SeymourLean

/-! Run `lake env lean CheckAxioms.lean` after `lake build`.
The expected output is recorded in `build.log`. -/

#check @Seymour.seymour_second_neighbourhood
#print axioms Seymour.seymour_second_neighbourhood
#print axioms Seymour.pruningLemma

-- Added in the insights pass (paper §3.1, §4.4, §5, remarks)
#print axioms Seymour.complex_count
#print axioms Seymour.dimension_count
#print axioms Seymour.F1_F2_comm
#print axioms Seymour.kronecker_comm
#print axioms Seymour.exists_admissible_iff_oriented
#print axioms Seymour.Zset_swap
#print axioms Seymour.gain_identity
#print axioms Seymour.step_value

-- Triangles.lean (Corollary cor:triangles and the grid form of triangle-freeness)
#print axioms Seymour.exists_two_out_add_in_le
#print axioms Seymour.ch3_symmetric
#print axioms Seymour.ch3_symmetric_loopless
#print axioms Seymour.regular_girth_four
#print axioms Seymour.triangleFree_iff_grid
#print axioms Seymour.seed_compatible_iff
