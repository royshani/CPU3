onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /tb_controlunit/status_bits
add wave -noupdate /tb_controlunit/rst
add wave -noupdate /tb_controlunit/RF_WregEn
add wave -noupdate /tb_controlunit/RF_out
add wave -noupdate /tb_controlunit/RF_addr_wr
add wave -noupdate /tb_controlunit/RF_addr_rd
add wave -noupdate /tb_controlunit/PCsel
add wave -noupdate /tb_controlunit/PCin
add wave -noupdate /tb_controlunit/opcode
add wave -noupdate /tb_controlunit/IRin
add wave -noupdate /tb_controlunit/Imm2_in
add wave -noupdate /tb_controlunit/Imm1_in
add wave -noupdate /tb_controlunit/ena
add wave -noupdate /tb_controlunit/DTCM_wr
add wave -noupdate /tb_controlunit/DTCM_out
add wave -noupdate /tb_controlunit/DTCM_addr_sel
add wave -noupdate /tb_controlunit/DTCM_addr_out
add wave -noupdate /tb_controlunit/DTCM_addr_in
add wave -noupdate /tb_controlunit/done
add wave -noupdate /tb_controlunit/clk
add wave -noupdate /tb_controlunit/ALU_z
add wave -noupdate /tb_controlunit/ALU_op
add wave -noupdate /tb_controlunit/ALU_n
add wave -noupdate /tb_controlunit/ALU_c
add wave -noupdate /tb_controlunit/Ain
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1725000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 177
configure wave -valuecolwidth 39
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
WaveRestoreZoom {803353 ps} {1862807 ps}
