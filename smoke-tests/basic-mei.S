# Basic Machine External Interrupt trace
#
#>QCVENGINE_TEST_V2.0
.4byte 0x00310093 # addi x1, x2, 3
#>START_NO_SHRINK
#>INTERRUPT_REQUEST 11 # foo
#>END_NO_SHRINK
#>START_NO_SHRINK
#>INTERRUPT_BARRIER
#>END_NO_SHRINK
.4byte 0x00310093 # addi x1, x2, 3
# Test end