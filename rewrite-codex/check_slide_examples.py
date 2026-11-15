"""Check the concrete graph, grid and pruning examples in the visual talk."""
from itertools import combinations
from pathlib import Path
import re


def image(arcs, vertices):
    return {y for x, y in arcs if x in vertices}


def neighborhoods(arcs, v):
    first = image(arcs, {v})
    return first, image(arcs, first) - first - {v}


def first_coordinate(arcs, family):
    return {(i, j) for p, j in family for x, i in arcs if x == p}


def second_coordinate(arcs, family):
    return {(i, j) for i, s in family for x, j in arcs if x == s}


# Slides 2/4: the same local graph before and after deleting v->b.
arcs = {('v', 'a'), ('v', 'b'), ('a', 'b'), ('a', 'c'), ('b', 'c')}
assert neighborhoods(arcs, 'v') == ({'a', 'b'}, {'c'})
assert neighborhoods(arcs - {('v', 'b')}, 'v') == ({'a'}, {'b', 'c'})
assert neighborhoods(arcs, 'c') == (set(), set())
print('Slides 2/4: local counts 2>1 become 1<=2; c is a sink.')

# Slides 8/9: exact cells used by CycleBoard in diagrams.tex.
cycle = {(1, 2), (2, 3), (3, 1)}
diagonal = {(i, i) for i in (1, 2, 3)}
vertical = first_coordinate(cycle, diagonal)
horizontal = second_coordinate(cycle, diagonal)
assert vertical == {(2, 1), (3, 2), (1, 3)}
assert horizontal == {(1, 2), (2, 3), (3, 1)}
assert not vertical & horizontal
assert {(i, j) for i in (1, 2, 3) for j in (1, 2, 3)} - vertical - horizontal == diagonal
print('Slides 8/9: both image layers match the drawn cells; M=6, d=3, score=9.')

# Slide 12: all four conflicts and the two depicted retained-family choices.
star = {(0, 1), (0, 2)}
left, right = {(0, 1), (0, 2)}, {(1, 0), (2, 0)}
conflicts = {(r, c) for r in left for c in right
             if (r[0], c[0]) in star and (c[1], r[1]) in star}
H = {(r[0], c[1]) for r, c in conflicts}
Z = {(c[0], r[1]) for r, c in conflicts}
assert len(conflicts) == 4 and H == {(0, 0)}
assert Z == {(1, 1), (1, 2), (2, 1), (2, 2)}
for kept_left, kept_right, deleted, uncovered in [
    (left, set(), 2, set()),
    ({(0, 1)}, set(), 3, {(1, 2), (2, 2)}),
]:
    assert len(left - kept_left) + len(right - kept_right) == deleted
    assert Z - first_coordinate(star, kept_left) - second_coordinate(star, kept_right) == uncovered
assert 2 > len(H) + 0 and 3 == len(H) + 2
print('Slide 12: H=1, Z=4; deleting right side costs 2 with q=0; keeping r1 costs 3 with q=2.')

# Slide 13: chosen cover meets all edges; survivor forces an opposite copy.
edges = {frozenset(e) for e in [('r', 'c'), ('r', 'zR'), ('zL', 'c')]}
cover = {'r', 'zL'}
assert all(cover & edge for edge in edges)
assert 'c' not in cover and 'zL' in cover
assert all(not all(set(c) & edge for edge in edges)
           for n in (0, 1) for c in combinations(['r', 'c', 'zL', 'zR'], n))
print('Slide 13: {r,zL} is a minimum cover of the illustrated local pattern.')

# Speaker allocations must be continuous and total exactly twenty minutes.
source = Path(__file__).with_name('talk.tex').read_text()
slots = re.findall(r'\\note\{(\d+):(\d+)--(\d+):(\d+)\.', source)
intervals = [(60*int(a)+int(b), 60*int(c)+int(d)) for a,b,c,d in slots]
assert len(intervals) == source.count('\\begin{frame}') == 17
assert intervals[0][0] == 0 and intervals[-1][1] == 1200
assert all(a < b for a, b in intervals)
assert all(a[1] == b[0] for a, b in zip(intervals, intervals[1:]))
print('17 continuous speaker-note allocations: 0:00 through 20:00 (planned, not rehearsed).')
