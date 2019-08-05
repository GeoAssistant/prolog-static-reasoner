%% --- Helpers ---

goes_through(F, R) :-
    goes_through_all(F, RS),
    member(R, RS) .

%% --- Actual formalization ---

above(G1, G2) :-
    ontopof(G1, G2) .
above(G1, G2) :-
    ontopof(G1, G),
    above(G, G2) .

same_age(F1, F2) :-
    fault(F1),
    fault(F2),
    top_layer(F1, R),
    top_layer(F2, R) .

top_layer(F, R) :-
    fault(F),
    geological_unit(R),
    goes_through(F, R),
    \+ (ontopof(R2, R), goes_through(F, R2)) .

younger_than(F1, F2) :-
    fault(F1),
    fault(F2),
    top_layer(F1, R1),
    top_layer(F2, R2),
    above(R1, R2) .

get_younger(X, Younger) :-
    findall(Y, younger_than(X,Y), LYounger),
    sort(LYounger, Younger) .

get_older(X, Older) :-
    findall(Y, younger_than(Y,X), LOlder),
    sort(LOlder, Older).

get_same_age(X, Same) :-
    findall(Y, same_age(X,Y), LSame),
    sort(LSame, Same) .

all_rels(Rels) :-
    setof(younger(X,Y), younger_than(X,Y), YRels),
    setof(sameAge(X,Y), (same_age(X,Y), X \= Y), SRels),
    append(YRels, SRels, Rels).

all_faults(Faults) :-
    setof(F, fault(F), Faults) .

% --- Insert I into order ---

compute_all_orders(I, Orders) :-
    all_faults(Faults),
    order_faults(Faults, Ordered),
    place_elem(I, Ordered, Orders) .

order_faults([], []) .
order_faults([F | FS], Ordered) :-
    order_faults(FS, OrderedOld),
    insert_ordered(F, OrderedOld, Ordered) .

insert_ordered(F, [], [[F]]) .
insert_ordered(F, [[FI | FIS] | FGS], [[F | [FI | FIS]] | FGS]) :-
    same_age(F, FI) .
insert_ordered(F, [[FI | FIS] | FGS], [[F] | [[FI | FIS] | FGS]]) :-
    younger_than(F, FI) .
insert_ordered(F, [[FI | FIS] | FGS], [[FI | FIS] | FGSIns]) :-
    younger_than(FI, F),
    insert_ordered(F, FGS, FGSIns) .

place_elem(I, Ordered, Orders) :-
    findall(Os, (length(Ordered, L), between(0, L, At), place_elem_at(I, At, Ordered, Os)), Orders) .

place_elem_at(_, _, [], []) .
place_elem_at(I, N, [Fs | Ordered], OrderedNew) :-
    ((N > 0) ->
        findall(younger(F, I), member(F, Fs), Rels) ;
        findall(younger(I, F), member(F, Fs), Rels)),
    M is N - 1,
    place_elem_at(I, M, Ordered, OrderedOld),
    append(Rels, OrderedOld, OrderedNew) .

% --- Append static rels to computed orders ---

append_all_rels(Orders, Completes) :-
    all_rels(Rels),
    findall(C, (member(O, Orders), append(Rels, O, C)), Completes) .

compute_complete_orders(I, COrders) :-
    compute_all_orders(I, Orders),
    append_all_rels(Orders, COrders) .

write_orders([]) .
write_orders([O | Os]) :-
    writeln(O),
    nl,
    write_orders(Os) .
