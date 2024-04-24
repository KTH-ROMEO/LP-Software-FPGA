--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: UART_Ext2uC_Switch.vhd
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

entity UART_Ext2uC_Switch is
port (
    en : IN std_logic;

    fpga2ext : IN std_logic;
    ext2fpga : OUT std_logic;

    fpga2uc : IN std_logic;
    uc2fpga : OUT std_logic;

    ext_tx : IN std_logic;
    ext_rx : OUT std_logic;
    uc_tx : IN std_logic;
    uc_rx : OUT std_logic

);
end UART_Ext2uC_Switch;
architecture architecture_UART_Ext2uC_Switch of UART_Ext2uC_Switch is
begin

    uc_rx <= ext_tx when en = '1' else fpga2uc;
    ext_rx <= uc_tx when en = '1' else fpga2ext;
    ext2fpga <= '1' when en = '1' else ext_tx;
    uc2fpga <= '1' when en = '1' else uc_tx;

end architecture_UART_Ext2uC_Switch;
