%% --- Example, with corresponding facts ---

%% ----------b4--------------------|-----------b8------------------------------------------
%% r3        gu3                   |           gu6             
%% ----------b3--------------------|-----------b7------------------------------------------
%% r2        gu2                   f1          gu5              |       gu8     |
%% ----------b2--------------------|-----------b6---------------|---------------|----------
%% r1        gu1                   |           gu4              f2      gu7     f3
%% ----------b1--------------------|-----------b5---------------|---------------|----------

layers([r1, r2, r3]) .
geological_units([gu1, gu2, gu3, gu4, gu5, gu6, gu7, gu8]) .
faults([f1, f2, f3]) .

contains_all(r1, [gu1, gu4, gu7]) .
contains_all(r2, [gu2, gu5, gu8]) .
contains_all(r3, [gu3, gu6]) .

goes_through_all(f1, [r1, r2, r3]) .
goes_through_all(f2, [r1, r2]) .
goes_through_all(f3, [r1, r2]) .

ontopof_base(r2, r1) .
ontopof_base(r3, r2) .

%% If we let mgt be the time of migration, we
%% have the following different scenarios:
%% [[youngerThan(mgt, f1)],

%%  [youngerThan(f1, mgt),
%%   youngerThan(f2, mgt)],

%%  [youngerThan(f1, mgt),
%%   youngerThan(mgt, f2)]] .


% --- Not used ---

connects(f1, gu1, gu4) .
connects(f1, gu2, gu5) .
connects(f1, gu3, gu6) .

connects(f2, gu5, gu8) .
connects(f2, gu4, gu7) .

%% geneticBondary(b1) .
%% geneticBondary(b2) .
%% geneticBondary(b3) .
%% geneticBondary(b4) .
%% geneticBondary(b5) .
%% geneticBondary(b6) .
%% geneticBondary(b7) .
%% geneticBondary(b8) .
%%
%% hasTopContact(b1, gu1) .
%% hasBotContact(b2, gu1) .
%% 
%% hasTopContact(b2, gu2) .
%% hasBotContact(b3, gu2) .
%% 
%% hasTopContact(b3, gu3) .
%% hasBotContact(b4, gu3) .
%% 
%% hasTopContact(b5, gu4) .
%% hasBotContact(b6, gu4) .
%% 
%% hasTopContact(b6, gu5) .
%% hasBotContact(b7, gu5) .
%% 
%% hasTopContact(b7, gu6) .
%% hasBotContact(b8, gu6) .

