# Static reasoner

Static reasoner written in Prolog for deriving configurations for the
GeoRL engine.

The main-program is in the file `timerizer.pl` which calls `parser/regexp.pl` to
parse the input Maude-file and extract the geometrical information recorded in that
config file, and then it uses `time/timing.pl` to derive the temporal relationships
between the different events and use that to generate all possible relative time orders
between the time of migration and faulting.

## Use

To call the program, simply run
```
swipl -s timerizer.pl <input> <output>
```
where `<input>` is the input Maude configuration file and `<output>` is the file to which
output should be written.

To test the file, one can use the example Maude configuration in `tests/geo-init.maude` and e.g.
run
```
swipl -s timerizer.pl tests/geo-init.maude out.maude
```
