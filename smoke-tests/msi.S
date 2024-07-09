# Note: first mismatched because of cheriot-ibex setting MA bits on a lui/cincaddr/cspecialrw/etc.,
#       then because of jumping to trap (mtcc) address on different instructions, more to go...
#
#>QCVENGINE_TEST_V2.0
#>START_NO_SHRINK
.4byte 0x00000617 # auipc x12, 0
.4byte 0x0f200193 # addi x3, x0, 242
.4byte 0x00419193 # slli x3, x3, 4
.4byte 0x00818193 # addi x3, x3, 8
.4byte 0x223600db # cincaddr x1, x12, x3
.4byte 0x03c0805b # cspecialrw x0, mtcc, x1
.4byte 0x30446073 # csrrsi x0, mie (0x304), 8
.4byte 0x30046073 # csrrsi x0, mstatus (0x300), 8
#>END_NO_SHRINK
#>START_NO_SHRINK
#>INTERRUPT_REQUEST 3
#>END_NO_SHRINK
#>START_NO_SHRINK
#>INTERRUPT_BARRIER
#>END_NO_SHRINK
#>START_NO_SHRINK
.4byte 0x03d0065b # cspecialrw x12, mtdc, x0
.4byte 0x020001b7 # lui x3, 8192
.4byte 0x203600db # csetaddr x1, x12, x3
.4byte 0x0000a023 # sw x0, x1[0]
.4byte 0x30200073 # mret
#>END_NO_SHRINK
# Test end
