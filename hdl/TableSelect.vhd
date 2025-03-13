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

	GCREN0      : IN  std_logic; 
    GCREN1      : IN  std_logic;
    GCRADDR     : IN  std_logic_vector (7 downto 0);
    ScREN0      : IN  std_logic;
    ScREN1      : IN  std_logic;
    ScRADDR     : IN  std_logic_vector (7 downto 0);
    REN0        : OUT  std_logic;
    REN1        : OUT  std_logic;
    RADDR       : OUT  std_logic_vector (7 downto 0)
   
);
end TableSelect;
architecture architecture_TableSelect of TableSelect is
begin
    process(GCREN0, ScREN0, GCREN1, ScREN1, GCRADDR, ScRADDR)
    begin
        -- Prioritize GC REN over Sc REN and Table 0 over Table 1
        if GCREN0 = '1' then
            REN0 <= '1';
            REN1 <= '0';
            RADDR <= GCRADDR;
        elsif GCREN1 = '1' then
            REN0 <= '0';
            REN1 <= '1';
            RADDR <= GCRADDR;
        elsif ScREN0 = '1' then
            REN0 <= '1';
            REN1 <= '0';
            RADDR <= ScRADDR;
        elsif ScREN1 = '1' then
            REN0 <= '0';
            REN1 <= '1';
            RADDR <= ScRADDR;
        else
            REN0 <= '0';
            REN1 <= '0';
            RADDR <= (others => '0');
        end if;

    end process;
end architecture_TableSelect;
