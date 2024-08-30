quietly set ACTELLIBNAME ProASIC3
quietly set PROJECT_DIR "C:/Users/Lab-user1/Desktop/MasterThesis/Langmuir-DataHub-EMUScience-FPGA"

if {[file exists presynth/_info]} {
   echo "INFO: Simulation library presynth already exists"
} else {
   file delete -force presynth 
   vlib presynth
}
vmap presynth presynth
vmap proasic3 "C:/Microsemi/Libero_SoC_v11.9/Designer/lib/modelsim/precompiled/vhdl/proasic3"

vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/hdl/General_Controller.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/stimulus/General_Controller_Testbench.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/smartgen/SweepTable/SweepTable.vhd"

vsim -L proasic3 -L presynth  -t 1ps presynth.General_Controller_Testbench
add wave /General_Controller_Testbench/*
run 100ps
