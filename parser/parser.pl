:- use_module(library(pio)).
:- set_prolog_flag(double_quotes, chars).

ws --> [W], { char_type(W, space) }, ws.
ws --> [].

line_end --> ['\n'] .
line_end --> [' '], line_end .

wsp --> [W], { char_type(W, space) }, ws.

file(Preamble, Equations) --> "mod", ws, all(Preamble), ws, equations(Equations), ws, "endm", ws .

preamble(X) --> Y, { atom_string(X, Y) } .

all([])     --> [].
all([L|Ls]) --> [L], all(Ls).

rest_of_line([])     --> [].
rest_of_line([L|Ls]) --> [L], { L \= '\n' }, rest_of_line(Ls).

equations([Eq | Eqs]) --> equation(Eq), ws, equations(Eqs) .
equations([]) --> [] .

equation(eq(Op, Lhs, Rhs)) --> "op", ws, all(Op), ws, ".", ws, "eq", wsp, term(Lhs), ws, "=", ws, terms(Rhs), ws, "." .
equation(eq(Op, Lhs, Rhs)) --> "op", ws, all(Op), ws, ".", ws, comment(_), "eq", wsp, term(Lhs), ws, "=", ws, terms(Rhs), ws, "." .

terms([T | TS]) --> term(T), wsp, terms(TS), { TS \= [] } .
terms([T]) --> term(T) .
terms([]) --> [] .

struct(struct(X, Atts)) --> "<", ws, attribute(X), ws, "|", ws, attributes(Atts), ws, ">" .
struct(struct(X, Atts)) --> "<", ws, term(X), ws, "|", ws, attributes(Atts), ws, ">" .

attributes([A | AS]) --> attribute(A), ",", ws, attributes(AS), { AS \= [] } .
attributes([comment(C) | AS]) --> comment(C), ws, attributes(AS), { AS \= [] } .
attributes([A]) --> attribute(A) .
attributes([]) --> [] .

attribute(att(Name, Val)) --> term(Name), ws, ":", ws, term(Val) .

comment(comment(X)) --> "---", rest_of_line(X), line_end .

term(X) --> base_term(X) .
term(X) --> maudelist(X) .

base_term(identifier(X)) --> identifier(X), { X \= "nil" } .
base_term(number(X)) --> number(X) .
base_term(X) --> comment(X) .
base_term(X) --> functional(X) .
base_term(X) --> struct(X) .
base_term(tup(X)) --> "(", ws, maudetuple(X), ws, ")" .

identifier([A|As]) --> [A], { char_type(A, alpha) ; A = '"' }, symbol_r(As).

symbol_r([A|As]) --> [A], { char_type(A, csym) ; A = '-' ; A = '"' }, symbol_r(As).
symbol_r([])     --> [].

number(0) --> ['0'] .
number(Num) --> [D], { char_type(D, digit(V)), V \= 0 }, inner_number(VS), { to_number([V | VS], Num) } .

inner_number([V | DS]) --> [D], { char_type(D, digit(V)) }, inner_number(DS) .
inner_number([]) --> [] .

functional(functional(F,Args)) --> identifier(F), "(", ws, maudetuple(Args), ws, ")" .

maudelist(mlist(nil)) --> "nil" .
maudelist(mlst(X, XS)) --> "(", ws, base_term(X), ws, "::", ws, maudelist(XS), ws, ")" .
maudelist(mlst(X, XS)) --> base_term(X), ws, "::", ws, maudelist(XS) .

maudetuple([A]) --> term(A) .
maudetuple([A | AS]) --> term(A), ",", ws, maudetuple(AS) .


%% Util Predicates

to_number(VS, Num) :-
    to_number_iter(VS, Num, _) .

to_number_iter([], 0, 1) .
to_number_iter([V | VS], Num, Exp) :-
    to_number_iter(VS, NumO, ExpO),
    Num is ((V * ExpO) + NumO),
    Exp is ExpO * 10 .

%% To Prolog assertions

%% Need: Fault and GeoUnit IDs, GeoUnit PartOfs, depositionalContact, InContactWith

