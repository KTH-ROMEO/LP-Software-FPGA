onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench_cnt/SYSCLK
add wave -noupdate /testbench_cnt/NSYSRESET
add wave -noupdate /testbench_cnt/test_sim_0/clk
add wave -noupdate /testbench_cnt/test_sim_0/reset
add wave -noupdate -radix binary -expand /testbench_cnt/test_sim_0/cnt
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1050000 ps} 0} {{Cursor 2} {1150000 ps} 0}
quietly wave cursor active 2
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
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
WaveRestoreZoom {629392 ps} {1470608 ps}
