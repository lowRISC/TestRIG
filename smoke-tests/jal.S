# Note: first mismatch caused by cheriot-ibex responding with dummy instruction (nop) instead of
#       actual instruction (addi x11 x0 0).
#
#>QCVENGINE_TEST_V2.0
.4byte 0x0b80106f # jal x0, 4280
.4byte 0x00000593 # addi x11, x0, 0
# Test end
#      halt token
