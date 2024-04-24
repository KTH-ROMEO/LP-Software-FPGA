--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: Datarate_Test_Packets.vhd
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

entity Datarate_Test_Packets is
port (
    clk : IN std_logic;
    reset : IN std_logic;
    
    enable : IN std_logic;

    dr_test_saving : IN std_logic;

    dr_test_counter : OUT std_logic_vector(47 downto 0);
    dr_test_new_data : OUT std_logic
);
end Datarate_Test_Packets;
architecture architecture_Datarate_Test_Packets of Datarate_Test_Packets is


begin

    process (clk, reset, dr_test_saving)
    begin
        if reset /= '0' then
            dr_test_new_data <= '0';
            dr_test_counter <= (others => '0');

        elsif dr_test_saving = '1' then
            dr_test_new_data <= '0';

        -- every falling edge, 12 bytes are added to the data stream going to the uC. (preamble byte, 10 byte packet (of only 6 are used), postamble byte)
        -- for example: driving clk with 250 kHz will give 250 kHz * 12 bytes * 8 bits/byte = 24 Mbit/s
        -- as it is a 48-bit counter that won't overflow, data can be checked afterwards easily if anything is missing.
        elsif falling_edge(clk) then        
            if enable = '1' then
                dr_test_counter <= dr_test_counter + 1;
                dr_test_new_data <= '1';
            end if;

        end if;

    end process;
end architecture_Datarate_Test_Packets;
