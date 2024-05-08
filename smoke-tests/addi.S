# Simple nop + addi trace
# Note: initial mismatch caused by cheriot-ibex not supporting RVFI V2 traces (fixed by forcing V1),
#       then mismatched because of cheriot-ibex setting MRM bits when not performing a memory op.
#
#>QCVENGINE_TEST_V2.0
.4byte 0x00000013 # nop
.4byte 0x10000113 # addi x2, x0, 256
# Test end
#      halt token
