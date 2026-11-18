# Top Level Design Parameters

# Clocks

create_clock -name {Toplevel|CLOCK} -period 31.250000 -waveform {0.000000 15.625000} CLOCK
create_clock -name {Toplevel|FMC_CLK} -period 27.777700 -waveform {0.000000 13.888800} FMC_CLK
create_clock -name {CLK_800KHZ} -period 1250.000000 -waveform {0.000000 625.000000} Timing_0/clk_800kHz_i_RNIBEP9:Y

# False Paths Between Clocks


# False Path Constraints


# Maximum Delay Constraints


# Multicycle Constraints


# Virtual Clocks
# Output Load Constraints
# Driving Cell Constraints
# Wire Loads
# set_wire_load_mode top

# Other Constraints
