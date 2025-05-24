onerror {resume}
add list -width 59 /tb_top/mapTop/mapControl/ControlLines_inst/DTCM_addr_out
add list -width 17 /tb_top/so_done
add list /tb_top/mapTop/mapDatapath/mapALU/reg_a_q
add list /tb_top/mapTop/mapDatapath/mapALU/reg_b_r
add list /tb_top/mapTop/mapDatapath/mapALU/result
add list /tb_top/mapTop/mapDatapath/mapALU/i_ctrl
add list /tb_top/mapTop/mapDatapath/mapALU/Ain
add list /tb_top/mapTop/mapDatapath/mapRegisterFile/WregEn
add list /tb_top/mapTop/mapDatapath/mapRegisterFile/WregData
add list /tb_top/mapTop/mapDatapath/mapRegisterFile/WregAddr
add list /tb_top/mapTop/mapControl/ControlLines_inst/ALU_op
add list /tb_top/mapTop/mapControl/ControlLines_inst/CtrlLogic/state_v
add list /tb_top/mapTop/mapDatapath/opcode
add list /tb_top/mapTop/mapDatapath/mapPC/i_PCin
add list /tb_top/mapTop/mapDatapath/mapIR/IR_q
add list /tb_top/mapTop/mapDatapath/IRin
add list /tb_top/mapTop/mapDatapath/RF_addr_rd
add list /tb_top/mapTop/mapDatapath/RF_addr_wr
add list /tb_top/mapTop/mapDatapath/mapIR/imm_to_PC
add list /tb_top/mapTop/mapDatapath/imm1_ext_r
add list /tb_top/mapTop/mapDatapath/imm2_ext_r
add list /tb_top/mapTop/mapDatapath/imm2_ext_r
add list /tb_top/mapTop/mapDatapath/data_mem_out_r
add list /tb_top/mapTop/mapDatapath/data_rd_addr_mux_r
add list /tb_top/mapTop/mapDatapath/data_wr_addr_mux_r
add list /tb_top/mapTop/mapDatapath/data_addr_in_mux_r
add list /tb_top/mapTop/mapDatapath/data_wr_addr_mux_q
add list /tb_top/mapTop/mapControl/ControlLines_inst/DTCM_addr_in
add list /tb_top/mapTop/mapControl/ControlLines_inst/DTCM_addr_sel
add list /tb_top/mapTop/mapDatapath/data_wr_addr_mux_r
configure list -usestrobe 0
configure list -strobestart {0 ps} -strobeperiod {0 ps}
configure list -usesignaltrigger 1
configure list -delta collapse
configure list -signalnamewidth 0
configure list -datasetprefix 0
configure list -namelimit 5
