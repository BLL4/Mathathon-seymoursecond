"""Independent finite checks of the statement-review counterexamples."""
from itertools import product
from pathlib import Path
import json

def subsets(items):
    items=sorted(items)
    for mask in range(1<<len(items)):
        yield {v for k,v in enumerate(items) if mask>>k&1}

def main():
    vertices=range(3)
    arcs={(0,2),(1,2)}
    left={(0,2),(1,2)}
    right={(2,0),(2,1)}
    conflicts={(a,b) for a in left for b in right if (a[0],b[0]) in arcs and (b[1],a[1]) in arcs}
    H={(a[0],b[1]) for a,b in conflicts}
    Z={(b[0],a[1]) for a,b in conflicts}
    assert H==set(product(range(2),repeat=2)) and Z=={(2,2)}
    assert all((v,u) not in arcs for u,v in arcs)
    compatible=[]
    for keptL in subsets(left):
        for keptR in subsets(right):
            if any(a in keptL and b in keptR for a,b in conflicts):continue
            covered={(i,j) for p,j in keptL for i in vertices if (p,i) in arcs}
            covered|={(i,j) for i,s in keptR for j in vertices if (s,j) in arcs}
            cost=len(left-keptL)+len(right-keptR)
            q=len(Z-covered)
            assert cost>len(Z)+q
            assert cost<=len(H)+q
            compatible.append({'left_survivors':len(keptL),'right_survivors':len(keptR),'deletions':cost,'uncovered_Z':q})
    assert len(compatible)==7
    # Empty graph: every universal vertex condition and every conditional
    # statement for nonempty subsets is true. No witness vertex exists.
    empty_vertices=[]
    empty_pos=all(any(False for _ in empty_vertices) for _ in empty_vertices)
    empty_strict=all(len(S)==0 for S in subsets(empty_vertices))
    assert empty_pos and empty_strict
    triangle={(0,1),(1,2),(2,0)}
    image=lambda S:{v for u in S for v in vertices if (u,v) in triangle}
    U={0}; first=image(U); second=image(first)
    assert first=={1} and second=={2}
    assert not len(U)+len(second)<2*len(first)
    result={'oriented_fork':{'arcs':sorted(arcs),'left':sorted(left),'right':sorted(right),'H':sorted(H),'Z':sorted(Z),'retained_pairs_examined':16,'compatible_pairs':7,'wrong_Z_bound_witnesses':0,'correct_H_bound_witnesses':7,'compatible_cases':compatible},
            'empty_graph':{'positive_indegree_vacuous':empty_pos,'strict_subset_condition_vacuous':empty_strict},
            'unrelated_triangle':{'U':sorted(U),'F_U':sorted(first),'F2_U':sorted(second),'strict_defect':len(U)+len(second)-2*len(first)}}
    text=json.dumps(result,indent=2)+'\n'
    Path(__file__).with_name('review-case-results.json').write_text(text)
    print(text,end='')

if __name__=='__main__':main()
