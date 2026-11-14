"""Independent small finite checks. No third-party dependencies."""
from itertools import product
from random import Random
import json
from pathlib import Path

def image(n, rel, S):
    return {j for i in S for j in range(n) if (i,j) in rel}

def pruning_check(n, rel, R, C):
    R=list(R); C=list(C)
    conflicts=[(r,c) for r in R for c in C if (r[0],c[0]) in rel and (c[1],r[1]) in rel]
    H={(r[0],c[1]) for r,c in conflicts}; Z={(c[0],r[1]) for r,c in conflicts}
    isoR={r for r in R if not any(a==r for a,b in conflicts)}
    isoC={c for c in C if not any(b==c for a,b in conflicts)}
    # Every potential survivor on the right is kept: extra deletion cannot
    # improve either the deletion count or the uncovered count.
    for mask in range(1<<len(R)):
        rp={r for k,r in enumerate(R) if mask>>k&1}
        if not isoR<=rp: continue
        cp={c for c in C if not any(a in rp and b==c for a,b in conflicts)}
        assert isoC<=cp
        covered={(i,j) for p,j in rp for i in range(n) if (p,i) in rel}
        covered|={(i,j) for i,s in cp for j in range(n) if (s,j) in rel}
        deleted=len(R)+len(C)-len(rp)-len(cp)
        if deleted<=len(H)+len(Z-covered): return True
    return False

def main():
    result={}
    n=2; pairs=list(product(range(n),repeat=2)); sets=[{p for k,p in enumerate(pairs) if mask>>k&1} for mask in range(1<<len(pairs))]
    count=0
    for rel in sets:
        for R in sets:
            for C in sets:
                assert pruning_check(n,rel,R,C),(rel,R,C)
                count+=1
    result['pruning_all_relations_and_families_n2']=count

    star={(0,1),(0,2)}
    starR={(0,1),(0,2)}; starC={(1,0),(2,0)}
    assert pruning_check(3,star,starR,starC)
    starZ={(1,1),(1,2),(2,1),(2,2)}
    kept={(0,1)}
    covered={(i,j) for p,j in kept for i in range(3) if (p,i) in star}
    assert len(starZ-covered)==2
    assert len(starR)+len(starC)-len(kept)==3
    all_left_covered={(i,j) for p,j in starR for i in range(3) if (p,i) in star}
    assert starZ<=all_left_covered
    assert 2>1+len(starZ-all_left_covered)
    result['worked_star_example']={'H':1,'Z':4,'deletions':3,'uncovered':2}

    rng=Random(20261113)
    count=0
    for n in [3,4]:
        pairs=list(product(range(n),repeat=2))
        for _ in range(500):
            rel={p for p in pairs if rng.randrange(2)}
            R={p for p in pairs if rng.randrange(3)==0}
            C={p for p in pairs if rng.randrange(3)==0}
            assert pruning_check(n,rel,R,C)
            count+=1
    result['pruning_seeded_samples_n3_n4']=count
    counts={}
    for n in range(1,6):
        pairs=[(i,j) for i in range(n) for j in range(i+1,n)]
        count=0
        for choices in product(range(3),repeat=len(pairs)):
            rel=set()
            for (i,j),c in zip(pairs,choices):
                if c==1: rel.add((i,j))
                if c==2: rel.add((j,i))
            good=[]
            for v in range(n):
                first=image(n,rel,{v}); second=image(n,rel,first)-first-{v}
                if len(first)<=len(second): good.append(v)
            assert good
            count+=1
        counts[n]=count
    result['second_neighborhood_all_labeled_oriented_graphs']=counts
    # Exact potential increment, independent of minimality or orientation.
    pairs=list(product(range(3),repeat=2))
    checks=0
    for _ in range(10000):
        rel={p for p in pairs if rng.randrange(2)}
        I={i for i in range(3) if rng.randrange(2)}
        T={i for i in range(3) if rng.randrange(2)}
        Q={i for i in range(3) if rng.randrange(2)}-(I|T)
        g=lambda W:len(image(3,rel,W)-(I|W))
        C=image(3,rel,Q)-(I|T|Q|image(3,rel,T))
        assert g(T|Q)-g(T)==len(C)-len(Q&image(3,rel,T))
        checks+=1
    result['potential_increment_seeded_checks']=checks
    text=json.dumps(result,indent=2)+'\n'
    Path(__file__).with_name('finite-results.json').write_text(text)
    print(text)

if __name__=='__main__': main()
