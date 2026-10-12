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
- [Sail RISC-V model](https://github.com/rems-project/sail-riscv.git)
- [CHERI Sail RISC-V model](https://github.com/CTSRD-CHERI/sail-cheri-riscv.git)
- [CHERIoT Sail RISC-V model](https://github.com/lowRISC/cheriot-sail.git)
- [Ibex (with CHERIoT support)](https://github.com/lowRISC/ibex.git)
- [CHERIoT Ibex](https://github.com/lowRISC/cheriot-ibex.git)

## Getting started

In order to get the different submodules provided by **TestRIG**, run the following command:

```sh
git clone https://github.com/lowRISC/TestRIG.git
cd TestRIG
git checkout cheriot
git submodule update --init --recursive
```

The root makefile can currently build the QuickCheck Verification Engine, the CHERIoT Sail implementation, and the CHERIoT Ibex implementation.

### Dependencies

The dependencies for the Haskell-based QuickCheck Verification Engine can be installed by:

```sh
sudo apt install gcc g++ make
curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh
# -> press the Enter/Return key when prompted
# -> reload your shell

ghcup tui
# -> press "i", then Enter/Return, then "q"
```

The dependencies for a Sail model can be installed by:

```sh
# Ubuntu dependencies for sail
sudo apt install opam z3 libgmp-dev

# Install Sail compiler using opam
opam init
opam install sail
eval $(opam env)
```

The dependency for the Ibex UVM TestRIG testbench is Xcelium, which you will need to install separately.

## Custom Configurations

Look at the `Makefile` to see different targets to compare against each other. Also use the following command to figure out the different options for running TestRIG:

```sh
utils/scripts/runTestRIG.py --help
```

## CHERIoT: Sail vs. Ibex

Executing the following commands will build and compare the CHERIoT Sail model with the CHERIoT version of Ibex across all compatible test templates (test generators), assuming that you've initialized the submodules and have installed all the dependencies described above.

First run only, build test generation and golden model programs:
```sh
# Build QCVE and CHERIoT Sail
make vengines
make sail-rv32-cheriot
```

Start the RTL simulation:
```sh
# Build and run Ibex with Xcelium with coverage collection...
cd riscv-implementations/ibex/dv/uvm/core_ibex
./testrig_xlm_build.sh -c
./testrig_xlm_run.sh -c
```

In a separate window, run TestRIG:
```sh
# ...against CHERIoT Sail for a failure
utils/scripts/runTestRIG.py -a sail -b manual --implementation-B-port 6000 -r rv32ecZifencei_Xcheriot --test-exclude-regex '(rvc)|(interrupt)|(all)|(unstructured)' --force-rvfi-v1
```

### Test Selection

A subset of test gen can be specified using the `--test-include-regex <regex>` and `--test-exclude-regex <regex>` arguments. For example:

```sh
# Run the "arith" RV32 arithmetic instruction test template
utils/scripts/runTestRIG.py ... --test-include-regex '^arith$'
# Run all but the "compressed" and "caprvcrandom" compressed instruction test templates
utils/scripts/runTestRIG.py ... --test-exclude-regex 'compress|rvc'
```

### Replay Failing Test

You can replay a test previously saved as a trace file (ext. `.S`) using the `-t <file>` (`--trace-file <file>`) argument:

```sh
# Replay last failure
utils/scripts/runTestRIG.py ... -t last_failure.S
```

### RVFI Version

You can force both implementations to provide RVFI V1 packets instead of V2 packets (if supported) to work around an implementation that doesn't yet have V2 support using the `--force-rvfi-v1` argument:

```sh
utils/scripts/runTestRIG.py ... --force-rvfi-v1
```

### Strict Comparison

By default, only a core set of RVFI fields are always compared for mismatches. Many are only compared when the Trap field is not set, or when a memory mask is non-zero. You can force all fields to be checked using the `--strict-comparison` argument.

```sh
utils/scripts/runTestRIG.py ... --strict-comparison
```

### Xcelium Trace Capture

You can optionally capture the waveform traces from an Xcelium run using the `-w` argument:

```sh
./testrig_xlm_run.sh -w
```

This will reduce performance.

An instruction trace is always captured (when using the UVM testbench) in the file "riscv-implementations/ibex/dv/uvm/core_ibex/trace_core_00000000.log".

### Xcelium Coverage Collection

You can optionally collect many forms of coverage with Xcelium using the `-c` argument:

```sh
cd riscv-implementations/ibex/dv/uvm/core_ibex
./testrig_xlm_build.sh -c
./testrig_xlm_run.sh -c
```

The resulting database will be stored in a sub-directory of "xlm_testrig_out/coverage/" named after the date+time of the run.

### Xcelium Coverage Reporting

Coverage collected with Xcelium can be viewed directly using `imc`:

```sh
imc -64bit -load xlm_testrig_out/coverage/2026-07-31_1102.37
```

Or in report form using:

```sh
./testrig_xlm_report.sh xlm_testrig_out/coverage/2026-07-31_1102.37
```

Outputs are written into to "xlm_testrig_out/report/".

### VCS Simulation

You can try to use VCS instead of Xcelium if you want:

```sh
# Build and run Ibex with VCS...
cd riscv-implementations/ibex/dv/uvm/core_ibex
./testrig_vcs_build.sh
./vcs_testrig_out/simv -ucli -do ./vcs_testrig.tcl +UVM_TESTNAME=core_ibex_testrig_test -l vcs_testrig_out/run.log
```

Remember to start TestRIG in a separate terminal as for Xcelium.

### Save all traces

Instead of just saving failures you may want to know all the tests that have been run:

```sh
mkdir -p all-tests
utils/scripts/runTestRIG.py ... --no-shrink --continue-on-fail --save-all --save-dir all-tests
```

### Smoke Tests

Some smoke tests (fixed test sequences/traces) for CHERIoT are collected in the "smoke-tests/" directory. You can run all of these tests using the `-d <dir>` (`--trace-dir <dir>`) argument:

```sh
# Run fixed test sequences/traces in the "smoke-tests/" directory
utils/scripts/runTestRIG.py ... -d smoke-tests
```

## Cleaning

To clean all implementations and the verification engine, run:

```sh
make clean
```

Note that cleaning is not guaranteed to be exhaustive for all implementations.

## Additional

### Logs

You can get some logging information out of the implementations using the `--implementation-A-log <filename>`/`--implementation-B-log <filename>` arguments:

```sh
utils/scripts/runTestRIG.py ... --implementation-A-log a.log --implementation-B-log b.log
```

You can get even more (or less) information out of the verification engine and some implementations using the `-v <level>` (`--verbosity <level>`) argument:

```sh
# More
utils/scripts/runTestRIG.py ... -v3
# (or less)
utils/scripts/runTestRIG.py ... -v0
```

### RISCV-DV coverage

Since Ibex produces a trace log with all the instructions, we can use RISCV-DV to output architectural coverage:

```sh
cd riscv-implementation/cheriot-ibex/dv/uvm/core_ibex
# Convert log to CSV
python3 riscv_dv_extension/ibex_log_to_trace_csv.py --log trace_core_00000000.log --csv rtl_trace.csv
# Convert CSV to coverage database
python3 ../../../vendor/google_riscv-dv/cov.py --core ibex --dir . -o riscv-dv-arch-cov --simulator vcs --isa rv32imcb --custom_target riscv_dv_extension
# Convert coverage database to HTML
urg -full64 -dir riscv-dv-arch-cov/test.vdb
# Open coverage in browser
xdg-open urgReport/dashboard.html
```
