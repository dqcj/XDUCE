vlib work
vlog glbl.v
vlog ../verilog/*.v
vsim -voptargs="+acc" work.tb_digit_recognition
add wave -r /*
run -all