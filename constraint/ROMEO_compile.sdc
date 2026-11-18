create_clock -name {Toplevel|CLOCK} -period 31.250000 -waveform {0.000000 15.625000} [get_ports {CLOCK}]
create_clock -name {Toplevel|FMC_CLK} -period 27.777778 -waveform {0.000000 13.888889} [get_ports {FMC_CLK}]
create_generated_clock -name {CLK_800KHZ} -source [get_ports {CLOCK}] -divide_by 40 [get_pins {Timing_0/clk_800kHz_i:Q}]
set_clock_groups -asynchronous -group [get_clocks {Toplevel|CLOCK CLK_800KHZ}] -group [get_clocks {Toplevel|FMC_CLK}]