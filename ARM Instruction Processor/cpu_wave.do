onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /cpu_testbench/dut/clk
add wave -noupdate -radix unsigned /cpu_testbench/dut/pc
add wave -noupdate /cpu_testbench/dut/inst
add wave -noupdate /cpu_testbench/dut/run/inst0
add wave -noupdate /cpu_testbench/dut/run/inst1
add wave -noupdate /cpu_testbench/dut/run/inst2
add wave -noupdate /cpu_testbench/dut/run/inst3
add wave -noupdate /cpu_testbench/dut/run/inst4
add wave -noupdate -radix unsigned /cpu_testbench/dut/regaddrIn
add wave -noupdate -radix unsigned /cpu_testbench/dut/regaddrOut1
add wave -noupdate /cpu_testbench/dut/regdata1
add wave -noupdate -radix unsigned /cpu_testbench/dut/regaddrOut2
add wave -noupdate /cpu_testbench/dut/regdata2
add wave -noupdate -radix unsigned /cpu_testbench/dut/regwr
add wave -noupdate -radix unsigned /cpu_testbench/dut/regrd1
add wave -noupdate -radix unsigned /cpu_testbench/dut/regrd2
add wave -noupdate -radix unsigned /cpu_testbench/dut/memwr
add wave -noupdate -radix unsigned /cpu_testbench/dut/memrd
add wave -noupdate -radix unsigned /cpu_testbench/dut/regdataIn
add wave -noupdate -radix unsigned /cpu_testbench/dut/memaddrIn
add wave -noupdate -radix unsigned /cpu_testbench/dut/memaddrOut
add wave -noupdate /cpu_testbench/dut/memdata
add wave -noupdate -radix unsigned /cpu_testbench/dut/memdataIn
add wave -noupdate /cpu_testbench/dut/bf
add wave -noupdate /cpu_testbench/dut/branchimm
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {33 ps} 0}
quietly wave cursor active 1
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
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {59 ps}
