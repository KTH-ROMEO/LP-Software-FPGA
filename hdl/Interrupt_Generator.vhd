--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: Interrupt_Generator.vhd
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

entity Interrupt_Generator is
port (
    clk : IN std_logic;
    reset : IN std_logic;

	afull : IN  std_logic;

    uC_interrupt : OUT std_logic
);
end Interrupt_Generator;
architecture architecture_Interrupt_Generator of Interrupt_Generator is

    signal state : std_logic;

    signal counter : std_logic_vector(9 downto 0);

begin

process(clk, reset)
begin
    if reset /= '0' then
        state <= '1';
        uC_interrupt <= '0';

    elsif rising_edge(clk) then
        counter <= counter + 1;

        if counter(9) then
            if afull then
                uC_interrupt <= '1';
            end if;
        else
            uC_interrupt <= '0';
        end if;
    end if;

end process;

end architecture_Interrupt_Generator;