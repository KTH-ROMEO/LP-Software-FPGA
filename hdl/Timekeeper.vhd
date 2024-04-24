--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: Timekeeper.vhd
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

entity Timekeeper is
port (
    clk : IN std_logic;
    clk_1MHz : IN std_logic;
	clk_1kHz : IN  std_logic;
    clk_1Hz : IN std_logic;
    reset : IN std_logic;

    microseconds : OUT std_logic_vector(23 downto 0);
    milliseconds : OUT std_logic_vector(23 downto 0);
    seconds : OUT std_logic_vector(19 downto 0)
);
end Timekeeper;
architecture architecture_Timekeeper of Timekeeper is
    signal old_1MHz : std_logic;
    signal old_1kHz : std_logic;
    signal old_1Hz : std_logic;
begin
    process(clk, reset)
    begin
        if reset /= '0' then
            microseconds <= (others => '0');
            milliseconds <= (others => '0');
            seconds <= (others => '0');

        elsif rising_edge(clk) then
            old_1MHz <= clk_1MHz;
            old_1kHz <= clk_1kHz;
            old_1Hz <= clk_1Hz;

            if old_1MHz = '0' AND clk_1MHz = '1' then
                microseconds <= microseconds + 1;
            end if;

            if old_1kHz = '0' AND clk_1kHz = '1' then
                milliseconds <= milliseconds + 1;
            end if;

            if old_1Hz = '0' AND clk_1Hz = '1' then
                seconds <= seconds + 1;
            end if;
        end if;
    end process;
end architecture_Timekeeper;
