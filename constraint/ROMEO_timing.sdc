create_clock -name {Toplevel|CLOCK} -period 31.250000 -waveform {0.000000 15.625000} [get_ports {CLOCK}]
create_clock -name {Toplevel|FMC_CLK} -period 27.777778 -waveform {0.000000 13.888889} [get_ports {FMC_CLK}]
create_generated_clock -name {CLK_800KHZ} -source [get_ports {CLOCK}] -divide_by 40 [get_nets {Timing_0.clk_800kHz_i}]

set_max_delay 31.250 -from [get_clocks {Toplevel|CLOCK}] -to [get_clocks {Toplevel|FMC_CLK}]
set_max_delay 27.778 -from [get_clocks {Toplevel|FMC_CLK}] -to [get_clocks {Toplevel|CLOCK}]