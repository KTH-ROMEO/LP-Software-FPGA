--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: UARTLineReleaser.vhd
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

entity UARTLineReleaser is
port (
    transmitting : IN std_logic;
    tx_in : IN std_logic;

    tx_out : OUT std_logic

);
end UARTLineReleaser;
architecture architecture_UARTLineReleaser of UARTLineReleaser is
begin

tx_out <= tx_in when transmitting = '1' else 'Z';

end architecture_UARTLineReleaser;
