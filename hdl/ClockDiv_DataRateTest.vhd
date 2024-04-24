--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: ClockDiv_DataRateTest.vhd
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
use IEEE.std_logic_unsigned.all;

entity ClockDiv_DataRateTest is
port (
	clk : IN  std_logic;
	reset : IN  std_logic;

    dr_test_clk : OUT std_logic
);
end ClockDiv_DataRateTest;
architecture architecture_ClockDiv_DataRateTest of ClockDiv_DataRateTest is
	signal s_count : std_logic_vector(3 downto 0);
    signal s_clk : std_logic := '0';

begin
process(clk, reset)
begin
    if reset /= '0' then
        s_count <= (others => '0');
    elsif rising_edge(clk) then
        s_count <= s_count + 1;

        if s_count = 4 then             -- Set data rate here. It will be: clk / ((s_count_max + 1)*2) * 12*8 bit/s.
            s_clk <= not s_clk;
            s_count <= (others => '0');
        end if;
    end if;

dr_test_clk <= s_clk;

end process;
end architecture_ClockDiv_DataRateTest;
