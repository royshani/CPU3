onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_datapath/tb_active
add wave -noupdate /tb_datapath/rst
add wave -noupdate /tb_datapath/RF_WregEn
add wave -noupdate /tb_datapath/RF_out
add wave -noupdate /tb_datapath/RF_addr_wr
add wave -noupdate /tb_datapath/RF_addr_rd
add wave -noupdate /tb_datapath/PCsel
add wave -noupdate /tb_datapath/PCin
add wave -noupdate /tb_datapath/opcode
add wave -noupdate /tb_datapath/ITCM_tb_wr
add wave -noupdate /tb_datapath/ITCM_tb_in
add wave -noupdate /tb_datapath/ITCM_tb_addr_in
add wave -noupdate /tb_datapath/IRin
add wave -noupdate /tb_datapath/Imm2_in
add wave -noupdate /tb_datapath/Imm1_in
add wave -noupdate /tb_datapath/ena
add wave -noupdate /tb_datapath/Dwidth
add wave -noupdate /tb_datapath/DTCM_wr
add wave -noupdate /tb_datapath/DTCM_tb_wr
add wave -noupdate /tb_datapath/DTCM_tb_out
add wave -noupdate /tb_datapath/DTCM_tb_in
add wave -noupdate /tb_datapath/DTCM_tb_addr_out
add wave -noupdate /tb_datapath/DTCM_tb_addr_in
add wave -noupdate /tb_datapath/DTCM_out
add wave -noupdate /tb_datapath/DTCM_addr_sel
add wave -noupdate /tb_datapath/DTCM_addr_out
add wave -noupdate /tb_datapath/DTCM_addr_in
add wave -noupdate /tb_datapath/dept
add wave -noupdate /tb_datapath/clk
add wave -noupdate /tb_datapath/Awidth
add wave -noupdate /tb_datapath/alu_z
add wave -noupdate /tb_datapath/ALU_op
add wave -noupdate /tb_datapath/alu_n
add wave -noupdate /tb_datapath/alu_c
add wave -noupdate /tb_datapath/Ain
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {1 ns}
