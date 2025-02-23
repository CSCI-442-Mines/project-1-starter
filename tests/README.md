# Provided Tests

The files in this directory are named as follows:

```
input/<INPUT TEST NUMBER>/description.txt # Test description
input/<INPUT TEST NUMBER>/input.txt # Test input (Optional)
input/<INPUT TEST NUMBER>/run.sh # Test script
output/<INPUT TEST NUMBER>/exit.<OUTPUT TYPE> # Exit code
output/<INPUT TEST NUMBER>/output.<OUTPUT TYPE> # Test output (Optional)
output/<INPUT TEST NUMBER>/stderr.<OUTPUT TYPE> # Standard error
output/<INPUT TEST NUMBER>/stdout.<OUTPUT TYPE> # Standard output
```

- `<INPUT TEST NUMBER>` is the number of the input test file that the output is based on.
- `<OUTPUT TYPE>` is one of:
  - `expected`: the expected output of your program
  - `actual`: the actual output of your program

For example, if you run your program with these parameters,

```
./pzip ./tests/input/tiny ./tests/output/tiny/2.actual 2
```

The output file `./tests/output/tiny/2.actual` should look like the contents of the following file:

```
./tests/output/tiny/2.expected
```
