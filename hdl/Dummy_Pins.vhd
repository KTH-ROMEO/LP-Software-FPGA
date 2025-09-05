--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: Dummy_Pins.vhd
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

entity Dummy_Pins is
port (
    --<port_name> : <direction> <type>;
    --clk : IN std_logic;
    --reset : IN std_logic;
    RESET       : in  std_logic;
	p13 : OUT  std_logic;
    p15 : OUT  std_logic;
    p16 : OUT  std_logic;
    p19 : OUT  std_logic;
    p22 : OUT  std_logic;
    MAX_SDA : INOUT  std_logic;
    MAX_SCL : OUT  std_logic;
    p59 : OUT  std_logic;
    p69 : OUT  std_logic;
    p70 : OUT  std_logic;
    p71 : OUT  std_logic;
    FRSTDATA : INOUT  std_logic;
    p96 : OUT  std_logic

    --<other_ports>;
);
end Dummy_Pins;
architecture behavioral of Dummy_Pins is
   -- signal, component etc. declarations
begin
    process (RESET)
	begin
		if RESET = '1' then
            p13 <= '0';
            p15 <= '0';
            p16 <= '0';
            p19 <= '0';
            p22 <= '0';
            p59 <= '0';
            p69 <= '0';
            p70 <= '0';
            p71 <= '0';
            p96 <= '0';
            FRSTDATA <= '0';
            MAX_SDA <= '0';
            MAX_SCL <='0';
        
        end if;
        
    end process;
   -- architecture body
end behavioral;
