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

    C1 : IN std_logic_vector(15 downto 0);
    C2 : IN std_logic_vector(15 downto 0);
    C3 : IN std_logic_vector(15 downto 0);
    C4 : IN std_logic_vector(15 downto 0);
    C5 : IN std_logic_vector(15 downto 0);
    C6 : IN std_logic_vector(15 downto 0);

    status_bits : IN std_logic_vector(63 downto 0);

    acc_packet : OUT std_logic_vector(87 downto 0);
    mag_packet : OUT std_logic_vector(87 downto 0);
    gyro_packet : OUT std_logic_vector(87 downto 0);
    pressure_packet : OUT std_logic_vector(87 downto 0);
    pres_cal1_packet : OUT std_logic_vector(87 downto 0);
    pres_cal2_packet : OUT std_logic_vector(87 downto 0);
    status_packet : OUT std_logic_vector(87 downto 0)
);
end Data_Hub_Packets;
architecture architecture_Data_Hub_Packets of Data_Hub_Packets is
begin
    acc_packet <= x"41" & acc_time & acc_x & acc_y & acc_z & x"0" & acc_temp & x"00";
    mag_packet <= x"4D" & mag_time & mag_x & mag_y & mag_z & x"0" & acc_temp & x"00";
    gyro_packet <= x"59" & gyro_time & gyro_x & gyro_y & gyro_z & gyro_temp;
    pressure_packet <= x"50" & pressure_time & pressure_raw & pressure_temp_raw & x"00";
    status_packet <= x"53" & x"0000" & status_bits;
    pres_cal1_packet <= x"43" & x"31" & C1 & C2 & C3 & x"000000";
    pres_cal2_packet <= x"43" & x"32" & C4 & C5 & C6 & x"000000";
end architecture_Data_Hub_Packets;
