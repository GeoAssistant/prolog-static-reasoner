:- [timing_ex] .

%% --- Helpers ---

geological_unit(GU) :-
    geological_units(GUS), member(GU, GUS) .

layer(R) :-
    layers(RS), member(R, RS) .

contains(X, Y) :-
    contains_all(X, YS),
    member(Y, YS) .

fault(F) :-
    faults(FS),
    member(F, FS) .

goes_through(F, R) :-
    goes_through_all(F, RS),
    member(R, RS) .

%% --- Actual formalization ---

ontopof(GU1, GU2) :- %% SLOW
    contains(R1, GU1),
    contains(R2, GU2), 
    GU1 \= GU2,
    ontopof_base(R1, R2) .

same_age_base(R, GU) :-
    contains(R, GU) .
same_age_base(GU1, GU2) :-
    contains(R, GU1),
    contains(R, GU2),
    GU1 \= GU2 .

same_age(X, Y) :-
    same_age_base(X, Y) .
same_age(X, Y) :-
    same_age_base(Y, X) .
same_age(F1, F2) :-
    fault(F1),
    fault(F2),
    top_layer(F1, R),
    top_layer(F2, R) .

top_layer(F, R) :-
    fault(F),
    layer(R),
    goes_through(F, R),
    \+ (ontopof_base(R2, R), goes_through(F, R2)) .

younger_than_refl_base(X, Y) :-
    same_age(X, Y) .
younger_than_refl_base(F, R) :-
    fault(F),
    layer(R),
    goes_through(F, R) .
younger_than_refl_base(R1, R2) :-
    ontopof(R1, R2) .
younger_than_refl_base(R, F) :-
    fault(F),
    layer(R),
    \+ goes_through(F, R),
    goes_through(F, RO),
    ontopof_base(R, RO) .

younger_than_refl(X, Y, L) :-
    younger_than_refl_base(X, Y),
    \+ member(Y, L).
younger_than_refl(X, Y, L) :-
    younger_than_refl_base(X, Z),
    \+ member(Z, L),
    younger_than_refl(Z, Y, [Z | L]) .

younger_than(X, Y) :-
    younger_than_refl(X, Y, [X]),
    \+ same_age(X, Y) .

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
    setof(rel(younger_than,X,Y), younger_than(X,Y), YRels),
    setof(rel(same_age,X,Y), same_age(X,Y), SRels),
    append(YRels, SRels, Rels).

all_elements(Elems) :-
    setof(E, (fault(E); layer(E); geological_unit(E)), Elems) .

% --- Insert I into order ---

compute_all_orders(I, AllRels) :-
    all_elements(Elems),
    setof(Rels, compute_order(I, Elems, Rels), AllRelsL),
    maplist(sort, AllRelsL, AllRelsS),
    sort(AllRelsS, AllRels) .

remove_uninteresting(_, [], []) .
remove_uninteresting(I, [Rels | RRels], IRels) :-
    setof(F, fault(F), Faults),
    maplist(younger_than_in(I, Rels), Faults),
    remove_uninteresting(I, RRels, IRels) .
remove_uninteresting(I, [Rels | RRels], [Rels | IRels]) :-
    remove_uninteresting(I, RRels, IRels) .

younger_than_in(I, Rels, Elem) :-
    member(rel(younger_than,I, Elem), Rels) .

write_orders([]) .
write_orders([O | Os]) :-
    writeln(O),
    nl,
    write_orders(Os) .

compute_order(_, [], []) .
compute_order(I, [E | Rem], [rel(younger_than,E, I) | Rels]) :-
    get_younger(E, EYounger),
    get_same_age(E, ESame),
    append(EYounger, ESame, Younger),
    subtract(Rem, Younger, ORem),
    findall(rel(younger_than, X, I), member(X, Younger), NRels),
    compute_order(I, ORem, ORels),
    append(ORels, NRels, Rels) .
compute_order(I, [E | Rem], [rel(younger_than,I, E) | Rels]) :-
    get_older(E, EOlder),
    get_same_age(E, ISame),
    append(EOlder, ISame, Older),
    subtract(Rem, Older, ORem),
    findall(rel(younger_than, I, X), member(X, Older), NRels),
    compute_order(I, ORem, ORels),
    append(ORels, NRels, Rels) .

%% TODO: Only need layers and faults, which are totally ordered

