--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: Data_Hub_Packets.vhd
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

entity Data_Hub_Packets is
port (
    acc_time : IN std_logic_vector(23 downto 0);
    acc_x : IN std_logic_vector(11 downto 0);
    acc_y : IN std_logic_vector(11 downto 0);
    acc_z : IN std_logic_vector(11 downto 0);
    acc_temp : IN std_logic_vector(7 downto 0);

    mag_time : IN std_logic_vector(23 downto 0);
    mag_x : IN std_logic_vector(11 downto 0);
    mag_y : IN std_logic_vector(11 downto 0);
    mag_z : IN std_logic_vector(11 downto 0);

    gyro_time : IN std_logic_vector(23 downto 0);
    gyro_x : IN std_logic_vector(15 downto 0);
    gyro_y : IN std_logic_vector(15 downto 0);
    gyro_z : IN std_logic_vector(15 downto 0);
    gyro_temp : IN std_logic_vector(7 downto 0);

    pressure_time : IN std_logic_vector(23 downto 0);
    pressure_raw : IN std_logic_vector(23 downto 0);
    pressure_temp_raw : IN std_logic_vector(23 downto 0);

    acc_packet : OUT std_logic_vector(55 downto 0);
    mag_packet : OUT std_logic_vector(55 downto 0);
    gyro_packet : OUT std_logic_vector(55 downto 0);
    pressure_packet : OUT std_logic_vector(55 downto 0)

);
end Data_Hub_Packets;
architecture architecture_Data_Hub_Packets of Data_Hub_Packets is
begin
    --    acc_packet      <= acc_x  & acc_y  & acc_z  & acc_temp   & x"0" & x"00";
    --    mag_packet      <= mag_x  & mag_y  & mag_z               & x"0" & x"0000";
    --    gyro_packet     <= gyro_x & gyro_y & gyro_z & gyro_temp; 
    --    pressure_packet <= pressure_raw             & pressure_temp_raw & x"00";

    acc_packet      <= x"a0a1a2a3a4a5a6"; -- for debugging
    mag_packet      <= x"b0b1b2b3b4b5b6"; -- for debugging
    gyro_packet     <= x"c0c1c2c3c4c5c6"; -- for debugging 
    pressure_packet <= x"d0d1d2d3d4d5d6"; -- for debugging

end architecture_Data_Hub_Packets;
