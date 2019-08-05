
%% --- Helper preficates --- 

add_elem(E, L, [E | L]) .

add_first_match(Match, L, [Match.1 | L]) .

%% --- Regexp predicates

split_on_equation_parts(Str, Preamble, Op, LHSOp, OPDeclEq, LHS, RHS, Dot, End) :- %% LHSOp = LHS
    re_compile("(.*)(op[\s\n]+)([^\s\n:]+)(\s+:.*eq[\n\s]+)([^\s\n]+)([\n\s]*=[^.]+)([.][\s\n]*)(.*)", R, [dotall(true),multiline(true)]),
    re_matchsub(R, Str, M, []),
    Preamble = M.1,
    Op = M.2,
    LHSOp = M.3,
    OPDeclEq = M.4,
    LHS = M.5,
    RHS = M.6,
    Dot = M.7,
    End = M.8 .

%% Assumes Str to be the string from (and including) "=" in a file, i.e. everything after the equation name (LHS)
%% as After returned from split_on_equation_name
split_file_at_eq_end(Str, Before, After) :-
    re_split("[.]", Str, [Before, Dot, AfterDot], []),
    string_concat(Dot, AfterDot, After) .

insert_at_end_of_eq(Str, Content, NewStr) :-
    split_file_at_eq_end(Str, Before, After),
    foldl(string_concat, [After, "\n    ", Content, " ", Before], "", NewStr) .


get_faults(Str, FaultMaps) :-
    re_compile("<\s*([0-9]+)\s*:\s*Fault[^>]+InContactWith:\s+(.+)\s+[>]", R, [dotall(true),multiline(true),ungreedy(true)]),
    re_foldl(add_elem, R, Str, [], FaultMaps, []) .

get_cuts(CStr, Cuts) :-
    re_compile("[(][0-9]+,([0-9]+),[^,]+,[^,]+,[^)]+[)]", R, [dotall(true),multiline(true),ungreedy(true)]),
    re_foldl(add_first_match, R, CStr, [], CutsList, []),
    list_to_set(CutsList, Cuts) .

get_contacts(Str, Contacts) :-
    re_compile("depositionalContact[(](.+)nil[)]+[)]", R, [dotall(true),multiline(true),ungreedy(true)]),
    re_matchsub(R, Str, ContactListStr, []),
    re_compile("[(]([0-9]+),([0-9]+)[)]", ReElem, [dotall(true),multiline(true),ungreedy(true)]),
    re_foldl(add_elem, ReElem, ContactListStr.1, [], Contacts, []) .

%% --- Assertional predicates ---

make_fault(FID, Fault) :-
    foldl(string_concat, [")", FID, "timeOf(Fault,"], "", Fault),
    ((\+ current_predicate(fault/1) ; \+ fault(Fault))
        %% Only assert if not asserted before (or predicate does not exist)
        -> assert(fault(Fault)) ; true) .

make_geounit(GID, GeoUnit) :-
    foldl(string_concat, [")", GID, "timeOf(GeoUnit,"], "", GeoUnit),
    ((\+ current_predicate(geological_unit/1) ; \+ geological_unit(GeoUnit))
        %% Only assert if not asserted before (or predicate does not exist)
        -> assert(geological_unit(GeoUnit)) ; true) .

assert_fault(FaultMap) :-
    make_fault(FaultMap.1, Fault),
    get_cuts(FaultMap.2, Cuts),
    assert_cuts(Fault, Cuts) .

assert_cuts(Fault, GIDS) :-
    maplist(make_geounit, GIDS, GeoUnits),
    assert(goes_through_all(Fault, GeoUnits)) .

assert_contact(Contact) :-
    make_geounit(Contact.1, GU1),
    make_geounit(Contact.2, GU2),
    assert(ontopof(GU2, GU1)) .

assert_faults(Str) :-
    get_faults(Str, Faults),
    maplist(assert_fault, Faults) .

assert_contacts(Str) :-
    get_contacts(Str, Contacts),
    maplist(assert_contact, Contacts) .

assert_config(Str) :-
    assert_faults(Str),
    assert_contacts(Str) .

%% --- To Maude format ---

order_to_maude_str(Order, MaudeOrderStr) :-
    order_to_inner_maude_str(Order, InnerStr),
    foldl(string_concat, [")\n", InnerStr, "\nageComparison("], "", MaudeOrderStr) .

order_to_inner_maude_str([], "") .
order_to_inner_maude_str([O | OS], InnerStr) :-
    order_to_inner_maude_str(OS, InnerStrO),
    format(string(OStr), "~w", O),
    (InnerStrO = "" ->
        InnerStr = OStr ;
        foldl(string_concat, [InnerStrO, " :: ", OStr], "", InnerStr)) .
    
%% --- Assumptions ---

% - File consists only of "mod"-preabmle, one "op" and one "eq" in that order
% - There are no spaces between the elements and commas in tuples


%% --- Notes ---

%% Use this to first get match between "eq" and ".", then find each "< fault ... >" and "< geounit ... >" and extract info

%% Translate to prolog assertions of geounits and faults

%% Compute timing etc.

%% Finally split file on ".", append relations as string between the two matches from split, and concat the strings together
%% with a "." in between.
