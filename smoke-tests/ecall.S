# Note: initial mismatch caused by cheriot-sail having a trap address (mtcc) of 0x0 (outside of sram)
#       rather than 0x80000000 (sram base), then because of cheriot-sail jumping PCC address
#       to the trap *on* the ecall instruction rather than the following instruction.
#
#>QCVENGINE_TEST_V2.0
.4byte 0x00000013 # nop
.4byte 0x03C000DB # cspecialrw 1 28 0
.4byte 0x00000073 # ecall
# Test end
#      halt token
