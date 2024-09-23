--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: Constant_Bias_Fake_Data_Generator.vhd
-- File history:
--      <Revision number>: <Date>: <Comments>
--      <Revision number>: <Date>: <Comments>
--      <Revision number>: <Date>: <Comments>
--
-- Description: 
--
-- <Description here>
--
-- Targeted device: <Family::ProASIC3> <Die::A3P250> <Package::100 VQFP>
-- Author: <Name>
--
--------------------------------------------------------------------------------

library IEEE;

use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity Constant_Bias_Fake_Data_Generator is
port (
    --<port_name> : <direction> <type>;
    clk_32k : IN std_logic;
	samples_per_measurement : IN  std_logic_vector(15 downto 0);
    reset: IN std_logic;

    measurement_rdy  : OUT std_logic;
    fake_measurement : OUT std_logic_vector(15 downto 0)
    --<other_ports>;
);
end Constant_Bias_Fake_Data_Generator;
architecture architecture_Constant_Bias_Fake_Data_Generator of Constant_Bias_Fake_Data_Generator is

    --attribute syn_preserve : boolean;
    signal sample_counter   : unsigned(15 downto 0);
    signal counter          : unsigned(15 downto 0);
    signal current_smp_msr  : std_logic_vector(15 downto 0);
    --attribute syn_preserve of sample_counter : signal is true;

begin
fake_measurement(15 downto 12) <= (others => '0');
process(clk_32k, reset, samples_per_measurement)
begin
    if reset /= '0' then
        sample_counter  <= (others => '0');
        counter         <= (others => '0');
        current_smp_msr <= samples_per_measurement;

        measurement_rdy <= '0';

    elsif rising_edge(clk_32k) then
        sample_counter <= sample_counter + 1;
        counter <= counter + 1;
        current_smp_msr <= samples_per_measurement;
        
        -- If the samples per measurement are changed then restart sampling from scratch to avoid incorrectly processesed point.
        -- Sample counter needs to be reset to 1 instead of 0, since the internal value "counter" is still incremented in this cycle.
    
        measurement_rdy <= '1' when sample_counter = unsigned(current_smp_msr) else '0';
        fake_measurement(11 downto 0) <= std_logic_vector(counter) when sample_counter = unsigned(current_smp_msr(11 downto 0));
        sample_counter  <= x"001" when sample_counter = unsigned(current_smp_msr(11 downto 0));
        counter <= x"000" when counter = x"FFF";

    end if;
    sample_counter  <= x"001" when current_smp_msr /= samples_per_measurement;
end process;
end architecture_Constant_Bias_Fake_Data_Generator;
