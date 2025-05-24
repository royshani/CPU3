onerror {resume}
add list -width 29 /tb_controlunit/status_bits
add list /tb_controlunit/rst
add list /tb_controlunit/RF_WregEn
add list /tb_controlunit/RF_out
add list /tb_controlunit/RF_addr_wr
add list /tb_controlunit/RF_addr_rd
add list /tb_controlunit/PCsel
add list /tb_controlunit/PCin
add list /tb_controlunit/opcode
add list /tb_controlunit/IRin
add list /tb_controlunit/Imm2_in
add list /tb_controlunit/Imm1_in
add list /tb_controlunit/ena
add list /tb_controlunit/DTCM_wr
add list /tb_controlunit/DTCM_out
add list /tb_controlunit/DTCM_addr_sel
add list /tb_controlunit/DTCM_addr_out
add list /tb_controlunit/DTCM_addr_in
add list /tb_controlunit/done
add list /tb_controlunit/clk
add list /tb_controlunit/ALU_z
add list /tb_controlunit/ALU_op
add list /tb_controlunit/ALU_n
add list /tb_controlunit/ALU_c
add list /tb_controlunit/Ain
configure list -usestrobe 0
configure list -strobestart {0 ps} -strobeperiod {0 ps}
configure list -usesignaltrigger 1
configure list -delta collapse
configure list -signalnamewidth 0
configure list -datasetprefix 0
configure list -namelimit 5
