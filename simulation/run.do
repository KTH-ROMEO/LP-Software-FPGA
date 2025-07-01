quietly set ACTELLIBNAME ProASIC3
quietly set PROJECT_DIR "C:/Users/Utente/Desktop/ROMEO_FPGA/LP-Software-FPGA"

if {[file exists presynth/_info]} {
   echo "INFO: Simulation library presynth already exists"
} else {
   file delete -force presynth 
   vlib presynth
}
vmap presynth presynth
vmap proasic3 "C:/Microsemi/Libero_SoC_v11.9/Designer/lib/modelsim/precompiled/vhdl/proasic3"

vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/hdl/UART_RX_FSM.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/hdl/UART_RX_FSM_tb.vhd"

vsim -L proasic3 -L presynth  -t 1ps presynth.UART_RX_FSM_tb
# The following lines are commented because no testbench is associated with the project
# add wave /UART_RX_FSM_tb/*
# run 5000ns
