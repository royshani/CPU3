onerror {resume}
add list -width 24 /tb_datapath/tb_active
add list /tb_datapath/rst
add list /tb_datapath/RF_WregEn
add list /tb_datapath/RF_out
add list /tb_datapath/RF_addr_wr
add list /tb_datapath/RF_addr_rd
add list /tb_datapath/PCsel
add list /tb_datapath/PCin
add list /tb_datapath/opcode
add list /tb_datapath/ITCM_tb_wr
add list /tb_datapath/ITCM_tb_in
add list /tb_datapath/ITCM_tb_addr_in
add list /tb_datapath/IRin
add list /tb_datapath/Imm2_in
add list /tb_datapath/Imm1_in
add list /tb_datapath/ena
add list /tb_datapath/Dwidth
add list /tb_datapath/DTCM_wr
add list /tb_datapath/DTCM_tb_wr
add list /tb_datapath/DTCM_tb_out
add list /tb_datapath/DTCM_tb_in
add list /tb_datapath/DTCM_tb_addr_out
add list /tb_datapath/DTCM_tb_addr_in
add list /tb_datapath/DTCM_out
add list /tb_datapath/DTCM_addr_sel
add list /tb_datapath/DTCM_addr_out
add list /tb_datapath/DTCM_addr_in
add list /tb_datapath/dept
add list /tb_datapath/clk
add list /tb_datapath/Awidth
add list /tb_datapath/alu_z
add list /tb_datapath/ALU_op
add list /tb_datapath/alu_n
add list /tb_datapath/alu_c
add list /tb_datapath/Ain
configure list -usestrobe 0
configure list -strobestart {0 ps} -strobeperiod {0 ps}
configure list -usesignaltrigger 1
configure list -delta collapse
configure list -signalnamewidth 0
configure list -datasetprefix 0
configure list -namelimit 5
