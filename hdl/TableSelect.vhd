--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: TableSelect.vhd
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

entity TableSelect is
port (
    -- General Controller read interface
	GCREN      : IN  std_logic; 
    GCRADDR    : IN  std_logic_vector (7 downto 0);
    -- Science data read interface
    ScREN       : IN  std_logic;
    ScRADDR     : IN  std_logic_vector (7 downto 0);
    -- Sweep table read control outputs
    REN         : OUT  std_logic;
    RADDR       : OUT  std_logic_vector (7 downto 0)
   
);
end TableSelect;
architecture architecture_TableSelect of TableSelect is
begin
    process(GCREN, ScREN, GCRADDR, ScRADDR)
    begin
        -- defaults
        REN     <= '0';
        RADDR   <= (others => '0');

        if GCREN = '1' then
            REN <= '1';
            RADDR <= GCRADDR;
        elsif ScREN = '1' then
            REN <= '1';
            RADDR <= ScRADDR;
        end if;

    end process;
end architecture_TableSelect;
