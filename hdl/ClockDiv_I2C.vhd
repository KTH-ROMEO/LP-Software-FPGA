--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: ClockDiv_I2C.vhd
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

entity ClockDiv_I2C is
port (
	clk : IN  std_logic;
	reset : IN  std_logic;

    i2c_clk : OUT std_logic

);
end ClockDiv_I2C;

architecture architecture_ClockDiv_I2C of ClockDiv_I2C is
	signal s_count : std_logic_vector(5 downto 0);
begin

process(clk, reset)
begin
    if reset /= '0' then
        s_count <= (others => '0');
        i2c_clk <= '0';

    elsif rising_edge(clk) then
        s_count <= s_count + 1;

        if s_count = 19 then
            i2c_clk <= not i2c_clk;
            s_count <= (others => '0');
        end if;
    end if;

end process;

end architecture_ClockDiv_I2C;
