quietly set ACTELLIBNAME ProASIC3
quietly set PROJECT_DIR "C:/Users/Jesus/Documents/KTH/ROMEO/test_vhdl/Master-Thesis-Code-FPGA"

if {[file exists presynth/_info]} {
   echo "INFO: Simulation library presynth already exists"
} else {
   file delete -force presynth 
   vlib presynth
}
vmap presynth presynth
vmap proasic3 "C:/Microsemi/Libero_SoC_v11.9/Designer/lib/modelsim/precompiled/vhdl/proasic3"

vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/hdl/ADC_READ.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/component/Actel/Simulation/CLK_GEN/1.0.1/CLK_GEN.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/hdl/DAC_SET.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/component/Actel/Simulation/RESET_GEN/1.0.1/RESET_GEN.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/hdl/SWEEP_SPIDER2.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/smartgen/SweepTable/SweepTable.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/component/work/RomeoSweep_Test/RomeoSweep_Test.vhd"

vsim -L proasic3 -L presynth  -t 1ps presynth.RomeoSweep_Test
add wave /RomeoSweep_Test/*
run 5000ns
