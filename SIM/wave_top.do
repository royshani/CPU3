onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_top/TBactive
add wave -noupdate /tb_top/so_done
add wave -noupdate /tb_top/rst
add wave -noupdate /tb_top/ITCM_tb_wr
add wave -noupdate -radix hexadecimal /tb_top/ITCM_tb_in
add wave -noupdate -radix hexadecimal /tb_top/ITCM_tb_addr_in
add wave -noupdate /tb_top/gen
add wave -noupdate /tb_top/ena
add wave -noupdate /tb_top/DTCM_tb_wr
add wave -noupdate -radix hexadecimal /tb_top/DTCM_tb_out
add wave -noupdate -radix hexadecimal /tb_top/DTCM_tb_in
add wave -noupdate -radix decimal /tb_top/DTCM_tb_addr_out
add wave -noupdate -radix hexadecimal /tb_top/DTCM_tb_addr_in
add wave -noupdate /tb_top/clk
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1200000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 182
configure wave -valuecolwidth 52
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
WaveRestoreZoom {0 ps} {4240465 ps}
