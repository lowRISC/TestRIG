# Note: was illegal instruction for 0x00000032 (c.slli HINT) in cheriot-sail because of
#       not including the file defining the HINT encodings.
#>QCVENGINE_TEST_V2.0
.4byte 0x000071bd # Unknown instruction
.4byte 0x0000776a # Unknown instruction
.4byte 0x0000d2ba # Unknown instruction
.4byte 0x00000032 # Unknown instruction
.4byte 0x0000e1ec # Unknown instruction
.4byte 0x156637b7 # lui x15, 87651
.4byte 0x55c78793 # addi x15, x15, 1372
.4byte 0x00009575 # Unknown instruction
.4byte 0x00000042 # Unknown instruction
.4byte 0xa4155337 # lui x6, 672085
.4byte 0x1cc30313 # addi x6, x6, 460
.4byte 0x0000ea74 # Unknown instruction
.4byte 0x00000042 # Unknown instruction
.4byte 0x00009da1 # Unknown instruction
.4byte 0x0000a93e # Unknown instruction
.4byte 0x00008d25 # Unknown instruction
.4byte 0x00001004 # Unknown instruction
.4byte 0x0000cc1d # Unknown instruction
.4byte 0x3d6051b7 # lui x3, 251397
.4byte 0x8bd18193 # addi x3, x3, -1859
# Test end