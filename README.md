# TestRIG
Framework for testing RISC-V processors with Random Instruction Generation.

## Glorious vision
TestRIG is a framework for RISC-V processor verification using the RVFI-DII (pronounced "rividy") interface.
TestRIG supports two types of components:

1. Vengines (verification engines)
2. Implementations (including models, simulators, and SoCs)

Vengines generate one or more DII streams of instruction traces, and consume one
or more RVFI streams of execution traces. Implementations consume a DII
instruction trace, and generate an RVFI execution trace. A Vengine can, for
example, produce two equivalent DII streams for two implementations and check
that the two generated RVFI streams are equivalent.

<img src="diagram.svg" width="450">

TestRIG eliminates the "test gap" between specification and implementation.
If the specification is an executable model (see Sail, L3, and many other efforts), then TestRIG allows automated verification of any specified property without passing through human interpretation and hand-writing tests.
While TestRIG should require work to construct trace generators for classes of ISA behaviour, new instructions in a class can automatically be included in new traces and will be run in many more variations than hand-written tests would allow.

TestRIG verifies the pipeline as well as specification compliance.
Test suites are designed to test as many aspects of an instruction set specification as possible, but cannot be expected to provide any reasonable verification of complex pipeline behaviour.
TestRIG can verify every register value read in the pipeline under random sequence generation, while a test suite will only report a prescribed test result.

TestRIG greatly increases debugging efficiency.
In-memory test suites require a significant amount of boiler plate in order to construct a valid test state which cannot be automatically reduced without disturbing instruction layout in complex ways.
As TestRIG relies on direct instruction injection, bypassing fetch through PC, a sequence of instructions can easily be shortened by simply eliminating instructions from the trace to see if we still find divergence.
As a result we can expect automatically reduced counterexamples on the order of a handful of instructions.

We hope that TestRIG will prove fertile ground to inspire innovation in instruction trace generation, counterexample reduction, and model construction such that trace-based verification can approach formal verification for many practical purposes with a much friendlier user experience than either test-suite verification or formal verification currently enable.

## Vengines
A vengine typically includes instruction trace (itrace) generators targeting various classes of behaviour.
The vengine then feeds these itraces into both a model and an implementation through two TCP sockets in the RVFI-DII format.
The model and implementation return an RVFI-DII execution trace (etrace) that details the state observation and state change of each instruction.
The vengine compares these two traces and identifies any divergence between the model and the implementation.
Any failure is reported nicely to the user with a means of conveniently replaying the failing itrace for debugging.
A capable vengine will also attempt to reduce the failing trace to a minimal example that diverges.

## Implementations (including Models)
Any implementation that wants to be verified using TestRIG will need to support RVFI-DII itrace format as an instruction source and etrace reporting format.
The implementation should have a mode where instructions are consumed exclusively from the RVFI-DII instruction port, bypassing any actual instruction memory, ignoring the architectural program counter.
An implementation should then deliver a trace report at the end of execution detailing implementation behaviour in response to that instruction in the RVFI-DII format.
The RVFI-DII communication uses a single socket with the itrace consumed and the etrace be delivered over the same socket. Please look at [the RVFI-DII](https://github.com/CTSRD-CHERI/TestRIG/blob/master/RVFI-DII.md) specification for more details

Currently, the provided modules are:
- [BSV-RVFI-DII](https://github.com/CTSRD-CHERI/BSV-RVFI-DII.git)
- [RVBS](https://github.com/CTSRD-CHERI/RVBS.git)
- [CHERI Spike](https://github.com/CTSRD-CHERI/riscv-isa-sim.git)
- [Sail RISC-V model](https://github.com/rems-project/sail-riscv.git)
- [CHERI Sail RISC-V model](https://github.com/CTSRD-CHERI/sail-cheri-riscv.git)
- [CHERIoT Sail RISC-V model](https://github.com/microsoft/cheriot-sail.git)
- [Piccolo](https://github.com/CTSRD-CHERI/Piccolo.git)
- [Flute](https://github.com/CTSRD-CHERI/Flute.git)
- [Toooba](https://github.com/CTSRD-CHERI/Toooba.git)
- [Ibex](https://github.com/CTSRD-CHERI/ibex.git)
- [CHERIoT Ibex](https://github.com/microsoft/cheriot-ibex.git)
- [QEMU](https://github.com/CTSRD-CHERI/qemu.git)

## Getting started

In order to get the different submodules provided by **TestRIG**, run the following command:

```sh
$ git clone https://github.com/lowRISC/TestRIG.git
$ cd TestRIG
$ git checkout cheriot
$ git submodule update --init --recursive
```

The root makefile can currently build the QuickCheck Verification Engine, the CHERIoT Sail implementation, and the CHERIoT Ibex implementation.

### Dependencies

The dependencies for the Haskell-based QuickCheck Verification Engine can be installed by:

```sh
$ sudo apt install gcc g++ make
$ curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh
# -> press the Enter/Return key when prompted
# -> reload your shell

$ ghcup tui
# -> press "i", then Enter/Return, then "q"
```

The dependencies for a Sail model with built-in coverage collection can be built from source by:

```sh
# Ubuntu dependencies for sail and sailcov
$ sudo apt install ocaml opam build-essential libgmp-dev z3 pkg-config zlib1g-dev cargo

# Create and enter a directory for TestRIG-related builds of tools
$ mkdir -p ~/tr_tools
$ cd ~/tr_tools

# Build Sail model compiler.
# Instructions based on: https://github.com/rems-project/sail/blob/sail2/INSTALL.md#building-from-source-without-opam
$ git clone https://github.com/rems-project/sail.git
$ cd sail
$ opam init
$ eval $(opam env --switch=default)
$ opam install . --deps-only
$ make

# Build Sail model coverage library (libsail_coverage.a)
# and coverage processing tool (sailcov).
# Instructions based on: https://github.com/rems-project/sail/tree/sail2/sailcov
$ make -C lib/coverage
$ make -C sailcov

$ cd ../../
```

The dependencies for Ibex are verilator:

```sh
$ sudo apt install verilator python3-pip libelf-dev
$ pip install -r riscv-implementations/cheriot-ibex/python-requirements.txt
$ export PATH=/home/$USER/.local/bin:$PATH
```

## Custom Configurations

Look at the `Makefile` to see different targets to compare against each other. Also use the following command to figure out the different options for running TestRIG:

```sh
$ utils/scripts/runTestRIG.py --help
```

## CHERIoT: Sail vs. Ibex

Executing the following commands will build and compare the CHERIoT Sail model with the CHERIoT version of Ibex across all compatible test templates (test generators), assuming that you've initialized the submodules and have installed all the dependencies described above.

```sh
# Build and run CHERIoT Sail vs. CHERIoT Ibex
$ make vengines
$ make sail-rv32-cheriot SAILCOV=1 SAIL_DIR='/home/${USER}/tr_tools/sail/'
$ make ibex-cheriot
$ utils/scripts/runTestRIG.py -a sail -b ibex -r rv32ecZifencei_Xcheriot
```

### Test Selection

A subset of test gen can be specified using the `--test-include-regex <regex>` and `--test-exclude-regex <regex>` arguments. For example:

```sh
# Run the "arith" RV32 arithmetic instruction test template
$ utils/scripts/runTestRIG.py -a sail -b ibex -r rv32ecZifencei_Xcheriot --test-include-regex '^arith$'
# Run all but the "compressed" and "caprvcrandom" compressed instruction test templates
$ utils/scripts/runTestRIG.py -a sail -b ibex -r rv32ecZifencei_Xcheriot --test-exclude-regex 'compress|rvc'
```

### Replay Failing Test

You can replay a test previously saved as a trace file (ext. `.S`) using the `-t <file>` (`--trace-file <file>`) argument:

```sh
# Replay last failure
$ utils/scripts/runTestRIG.py -a sail -b ibex -r rv32ecZifencei_Xcheriot -t last_failure.S
```

### Smoke Tests

Some smoke tests (fixed test sequences/traces) for CHERIoT are collected in the "smoke-tests/" directory. You can run all of these tests using the `-d <dir>` (`--trace-dir <dir>`) argument:

```sh
# Run fixed test sequences/traces in the "smoke-tests/" directory
$ utils/scripts/runTestRIG.py -a sail -b ibex -r rv32ecZifencei_Xcheriot -d smoke-tests
```

## Cleaning

To clean all implementations and the verification engine, run:

```sh
$ make clean
```

Note that this is not guaranteed to be exhaustive for all implementations.

## Additional

### Logs

You can get some logging information out of the implementations using the `--implementation-A-log <filename>`/`--implementation-B-log <filename>` arguments:

```sh
utils/scripts/runTestRIG.py -a sail -b ibex -r rv32ecZifencei_Xcheriot --implementation-A-log a.log --implementation-B-log b.log
```

You can get even more information out of the verification engine and some implementations using the `-v <level>` (`--verbosity <level>`) argument:

```sh
utils/scripts/runTestRIG.py -a sail -b ibex -r rv32ecZifencei_Xcheriot --implementation-A-log a.log --implementation-B-log b.log -v3
```

### Sail Coverage

You can use the [sailcov](https://github.com/rems-project/sail/tree/sail2/sailcov) utility to turn the raw coverage files output by the Sail compiler and the compiled Sail model into human-readable HTML files. Here is an example for cheriot-sail:

```sh
# ...After running TestRIG with Sail
# (having built the Sail model using a Sail compiler built with SAILCOV=1)

# Generate HTML files showing Sail model line coverage.
# Put all but the index into a new "sailcov-html/" directory.
$ mkdir -p sailcov-html
$ ~/tr_tools/sail/sailcov/sailcov -a riscv-implementations/cheriot-sail/generated_definitions/c/all_branches -t sail_coverage --index 'index' --prefix 'sailcov-html/' riscv-implementations/cheriot-sail/src/*.sail riscv-implementations/cheriot-sail/sail-riscv/model/*.sail
# Open index.html in a web browser...
```


### Cleaning Sail Tooling

Here are some commands for cleaning the Sail tools, just in case the need arises:

```sh
# Clean sail compiler, coverage collection library and coverage parser binary
$ cd ~/tr_tools/sail
$ make clean
$ rm -f lib/coverage/libsail_coverage.a sailcov/sailcov
```
