--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: Data_Packer.vhd
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

entity Data_Packer is
port (
    clk, reset : IN std_logic;

    acc_new_data : IN std_logic;
    mag_new_data : IN std_logic;
    gyro_new_data : IN std_logic;
    pressure_new_data : IN std_logic;
    pressure_cal_new_data : IN std_logic;

    acc_x : IN std_logic_vector(11 downto 0);
    acc_y : IN std_logic_vector(11 downto 0);
    acc_z : IN std_logic_vector(11 downto 0);
    acc_temp : IN std_logic_vector(7 downto 0);

    mag_x : IN std_logic_vector(11 downto 0);
    mag_y : IN std_logic_vector(11 downto 0);
    mag_z : IN std_logic_vector(11 downto 0);

    gyro_x : IN std_logic_vector(15 downto 0);
    gyro_y : IN std_logic_vector(15 downto 0);
    gyro_z : IN std_logic_vector(15 downto 0);
    gyro_temp : IN std_logic_vector(7 downto 0);

    pressure_raw : IN std_logic_vector(23 downto 0);
    pressure_temp_raw : IN std_logic_vector(23 downto 0);

    C1 : IN std_logic_vector(15 downto 0);
    C2 : IN std_logic_vector(15 downto 0);
    C3 : IN std_logic_vector(15 downto 0);
    C4 : IN std_logic_vector(15 downto 0);
    C5 : IN std_logic_vector(15 downto 0);
    C6 : IN std_logic_vector(15 downto 0);

    status_new_data : IN std_logic;
    status_bits : IN std_logic_vector(63 downto 0);

    milliseconds : IN std_logic_vector(23 downto 0);

    acc_packet : OUT std_logic_vector(95 downto 0);
    mag_packet : OUT std_logic_vector(95 downto 0);
    gyro_packet : OUT std_logic_vector(95 downto 0);
    pressure_packet : OUT std_logic_vector(95 downto 0);
    pres_cal1_packet : OUT std_logic_vector(95 downto 0);
    pres_cal2_packet : OUT std_logic_vector(95 downto 0);
    status_packet : OUT std_logic_vector(95 downto 0)
    
);
end Data_Packer;
architecture architecture_Data_Packer of Data_Packer is
    signal old_acc_new_data : std_logic;
    signal old_mag_new_data : std_logic;
    signal old_gyro_new_data : std_logic;
    signal old_pressure_new_data : std_logic;
    signal old_status_new_data : std_logic;
    signal old_pressure_cal_new_data : std_logic;
begin

    process(clk, reset)
    begin
        if reset /= '0' then
            old_acc_new_data <= '0';
            old_mag_new_data <= '0';
            old_gyro_new_data <= '0';
            old_pressure_new_data <= '0';
            old_status_new_data <= '0';
            old_pressure_cal_new_data <= '0';

            acc_packet <= (others => '0');
            mag_packet <= (others => '0');
            gyro_packet <= (others => '0');
            pressure_packet <= (others => '0');
            status_packet <= (others => '0');
            pres_cal1_packet <= (others => '0');
            pres_cal2_packet <= (others => '0');

        elsif rising_edge(clk) then
            old_acc_new_data <= acc_new_data;
            old_mag_new_data <= mag_new_data;
            old_gyro_new_data <= gyro_new_data;
            old_pressure_new_data <= pressure_new_data;
            old_status_new_data <= status_new_data;
            old_pressure_cal_new_data <= pressure_cal_new_data;
            
            if old_acc_new_data = '0' AND acc_new_data = '1' then
                acc_packet <= x"41" & milliseconds & acc_x & acc_y & acc_z & x"0" & acc_temp & x"00" & x"0A";
            end if;

            if old_mag_new_data = '0' AND mag_new_data = '1' then
                mag_packet <= x"4D" & milliseconds & mag_x & mag_y & mag_z & x"0" & acc_temp & x"00" & x"0A";
            end if;

            if old_gyro_new_data = '0' AND gyro_new_data = '1' then
                gyro_packet <= x"59" & milliseconds & gyro_x & gyro_y & gyro_z & gyro_temp & x"0A";
            end if;

            if old_pressure_new_data = '0' AND pressure_new_data = '1' then
                pressure_packet <= x"50" & milliseconds & pressure_raw & pressure_temp_raw & x"00" & x"0A";
            end if;

            if old_status_new_data = '0' AND status_new_data = '1' then
                status_packet <= x"53" & x"0000" & status_bits & x"0A";
            end if;

            if old_pressure_cal_new_data = '0' AND pressure_cal_new_data = '1' then
                pres_cal1_packet <= x"43" & x"31" & C1 & C2 & C3 & x"000000" & x"0A";
                pres_cal2_packet <= x"43" & x"32" & C4 & C5 & C6 & x"000000" & x"0A";
            end if;
        end if;
    end process;

end architecture_Data_Packer;
