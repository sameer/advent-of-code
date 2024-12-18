# Part 2 solved with Z3 Theorem Prover

from z3 import *

optimizer = Optimize()

execute = Function('execute', BitVecSort(48), BitVecSort(48))


a = BitVec('a', 48)
a_state = [BitVec(f"a_{i}", 48) for i in range(16)]
intermediate_b_state = [BitVec(f"b_intermediate_{i}", 48) for i in range(16)]
b_state = [BitVec(f"b_{i}", 48) for i in range(16)]

out_state = [BitVec(f"out_{i}", 48) for i in range(16)]

for i in range(16):
    if i == 0:
        optimizer.add(a_state[i] == a)
    else:
        optimizer.add(a_state[i] == a_state[i-1] >> 3)

    optimizer.add(intermediate_b_state[i] == (a_state[i] & 7) ^ 6)
    optimizer.add(b_state[i] == (intermediate_b_state[i] ^
               (a_state[i] >> intermediate_b_state[i])) ^ 4)

    if i == 0:
        optimizer.add(out_state[i] == (b_state[i] & 7))
    else:
        optimizer.add(out_state[i] == (b_state[i] & 7)
                   << (i * 3) | out_state[i-1])


optimizer.add(out_state[15] == 2
    | 4 << 3
    | 1 << 6
    | 6 << 9
    | 7 << 12
    | 5 << 15
    | 4 << 18
    | 6 << 21
    | 1 << 24
    | 4 << 27
    | 5 << 30
    | 5 << 33
    | 0 << 36
    | 3 << 39
    | 3 << 42
    | 0 << 45)

optimizer.minimize(a)

if optimizer.check() == sat:
    print(f"{optimizer.model()}")
else:
    print(f"unsat: {optimizer}")
    # print(f"{solver.}")
