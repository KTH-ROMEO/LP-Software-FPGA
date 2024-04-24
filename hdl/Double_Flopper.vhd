--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: Double_Flopper.vhd
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

entity Double_Flopper is
port (
    clk : IN std_logic;
    reset : IN std_logic;
    D : IN std_logic;

    Q : OUT std_logic
);
end Double_Flopper;
architecture architecture_Double_Flopper of Double_Flopper is
   signal I : std_logic;

begin
    process(clk, reset)
    begin
        if reset /= '0' then
            I <= '0';
            Q <= '0';

        elsif falling_edge(clk) then
            I <= D;
            Q <= I;
        end if;
    end process;
end architecture_Double_Flopper;
