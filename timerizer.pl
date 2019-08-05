#!/usr/bin/env swipl

:- [timing/timing] .
:- [parser/regexp] .
:- initialization(main, main).

main([File, Out]) :-
    add_relative_times(File, Out) .

add_relative_times(File, Out) :-
    read_file_to_string(File, Str, []),
    assert_config(Str),
    compute_complete_orders("timeOf(Migration)", Orders),
    maplist(order_to_maude_str, Orders, OrderStrs),
    length(Orders, NumOrders),
    split_on_equation_parts(Str, Preamble, Op, _, OPDeclEq, LHS, RHS, Dot, End), %% LHSOp = LHS
    make_new_LHS(LHS, NumOrders, NewLHSs),
    maplist(string_concat(Op), NewLHSs, NewLHSOps),               %% op <newName>
    maplist(string_concat(OPDeclEq), NewLHSs, NewDeclLHSs),       %% : <opdecl> . \s+ eq <NewName>
    maplist(string_concat(RHS), OrderStrs, NewRHSs),                 %% RHS <orders>
    maplist(string_concat, NewLHSOps, NewDeclLHSs, NewFullDecls), %% op <NewName> : <opdecl> .\s+ ew <NewName>
    maplist(string_concat, NewFullDecls, NewRHSs, NewEqs),        %% op <NewName> : <opdecl> .\s+ ew <NewName> = <NewRHSs>
    maplist(concat_to_end(Dot), NewEqs, NewFullEqs),              %% op <NewName> : <opdecl> .\s+ ew <NewName> = <NewRHSs>\s+ . \s+
    foldl(string_concat, NewFullEqs, "", AllEqs),                 %% All Eqs together
    foldl(string_concat, [End, AllEqs, Preamble], "", OutStr),    %% Add Preabmle and End before and after eqs
    open(Out, append, OStream),
    write(OStream, OutStr),
    close(OStream) .

make_new_LHS(_, 0, []) .
make_new_LHS(LHS, N, [NewLHS | NewLHSs]) :-
    succ(M, N),
    number_string(N, NStr),
    foldl(string_concat, [NStr, '-', LHS], "", NewLHS),
    make_new_LHS(LHS, M, NewLHSs) .

concat_to_end(End, Str, NewStr) :-
    string_concat(Str, End, NewStr) .
