--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: Packet_Saver.vhd
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

entity Packet_Saver is
port (
    clk, reset, en : IN std_logic;

    sync : IN std_logic;

    acc_packet : IN std_logic_vector(87 downto 0);
    acc_new_data : IN std_logic;

    mag_packet : IN std_logic_vector(87 downto 0);
    mag_new_data : IN std_logic;

    gyro_packet : IN std_logic_vector(87 downto 0);
    gyro_new_data : IN std_logic;

    pressure_packet : IN std_logic_vector(87 downto 0);
    pressure_new_data : IN std_logic;

    status_packet : IN std_logic_vector(87 downto 0);
    status_new_data : IN std_logic;

    pres_cal1_packet : IN std_logic_vector(87 downto 0);
    pres_cal2_packet : IN std_logic_vector(87 downto 0);
    pres_cal_new_data : IN std_logic;

    ch_0_packet : IN std_logic_vector(63 downto 0);
    ch_1_packet : IN std_logic_vector(87 downto 0);
    ch_2_packet : IN std_logic_vector(87 downto 0);
    ch_3_packet : IN std_logic_vector(87 downto 0);
    ch_4_packet : IN std_logic_vector(87 downto 0);
    ch_5_packet : IN std_logic_vector(87 downto 0);
    ch_0_new_data : IN std_logic;
    ch_1_new_data : IN std_logic;
    ch_2_new_data : IN std_logic;
    ch_3_new_data : IN std_logic;
    ch_4_new_data : IN std_logic;
    ch_5_new_data : IN std_logic;

    data_out : OUT std_logic_vector(63 downto 0);
    we : OUT std_logic
);
end Packet_Saver;
architecture architecture_Packet_Saver of Packet_Saver is
    type state_type is (select_packet, clock_out_data);
    type packet is (acc, mag, pressure, gyro, status, pres_cal1, pres_cal2, ch_0, ch_1, ch_2, ch_3, ch_4, ch_5);

    signal state : state_type;
    signal packet_select : packet;

    signal acc_flag : std_logic;
    signal mag_flag : std_logic;
    signal gyro_flag : std_logic;
    signal pressure_flag : std_logic;
    signal status_flag : std_logic;
    signal pres_cal1_flag : std_logic;
    signal pres_cal2_flag : std_logic;
    signal ch_0_flag : std_logic;
    signal ch_1_flag : std_logic;
    signal ch_2_flag : std_logic;
    signal ch_3_flag : std_logic;
    signal ch_4_flag : std_logic;
    signal ch_5_flag : std_logic;

    signal old_acc_new_data : std_logic;
    signal old_mag_new_data : std_logic;
    signal old_gyro_new_data : std_logic;
    signal old_pressure_new_data : std_logic;
    signal old_status_new_data : std_logic;
    signal old_pres_cal_new_data : std_logic;
    signal old_ch_0_new_data : std_logic;
    signal old_ch_1_new_data : std_logic;
    signal old_ch_2_new_data : std_logic;
    signal old_ch_3_new_data : std_logic;
    signal old_ch_4_new_data : std_logic;
    signal old_ch_5_new_data : std_logic;

    signal selected_packet : std_logic_vector(87 downto 0);
    signal word_cnt : integer range 1 to 3;
begin

    with packet_select select selected_packet(63 downto 0) <= 
                                                 ch_0_packet(63 downto 0) when ch_0,
                                                 (others => '0') when others;

    -- with packet_select select selected_packet(84 downto 0) <= acc_packet(84 downto 0) when acc,
    --                                              mag_packet(84 downto 0) when mag,
    --                                              gyro_packet(84 downto 0) when gyro,
    --                                              pressure_packet(84 downto 0) when pressure,
    --                                              status_packet(84 downto 0) when status,
    --                                              pres_cal1_packet(84 downto 0) when pres_cal1,
    --                                              pres_cal2_packet(84 downto 0) when pres_cal2,
    --                                              --ch_0_packet when ch_0,
    --                                              ch_1_packet(84 downto 0) when ch_1,
    --                                              ch_2_packet(84 downto 0) when ch_2,
    --                                              ch_3_packet(84 downto 0) when ch_3,
    --                                              ch_4_packet(84 downto 0) when ch_4,
    --                                              ch_5_packet(84 downto 0) when ch_5,
    --                                              (others => '0') when others;

    selected_packet(85) <= sync;

    process (clk, reset)
    begin
        if reset /= '0' then
            state <= select_packet;
            packet_select <= acc;

            acc_flag <= '0';
            mag_flag <= '0';
            gyro_flag <= '0';
            pressure_flag <= '0';
            status_flag <= '0';
            pres_cal1_flag <= '0';
            pres_cal2_flag <= '0';
            ch_0_flag <= '0';
            ch_1_flag <= '0';
            ch_2_flag <= '0';
            ch_3_flag <= '0';
            ch_4_flag <= '0';
            ch_5_flag <= '0';

            old_acc_new_data <= '0';
            old_mag_new_data <= '0';
            old_gyro_new_data <= '0';
            old_pressure_new_data <= '0';
            old_status_new_data <= '0';
            old_pres_cal_new_data <= '0';
            old_ch_0_new_data <= '0';
            old_ch_1_new_data <= '0';
            old_ch_2_new_data <= '0';
            old_ch_3_new_data <= '0';
            old_ch_4_new_data <= '0';
            old_ch_5_new_data <= '0';

            word_cnt <= 1;

            data_out <= x"0000000000000000";
            we <= '0';
            

        elsif falling_edge(clk) then
            old_acc_new_data <= acc_new_data;
            old_mag_new_data <= mag_new_data;
            old_gyro_new_data <= gyro_new_data;
            old_pressure_new_data <= pressure_new_data;
            old_status_new_data <= status_new_data;
            old_pres_cal_new_data <= pres_cal_new_data;
            old_ch_0_new_data <= ch_0_new_data;
            old_ch_1_new_data <= ch_1_new_data;
            old_ch_2_new_data <= ch_2_new_data;
            old_ch_3_new_data <= ch_3_new_data;
            old_ch_4_new_data <= ch_4_new_data;
            old_ch_5_new_data <= ch_5_new_data;
            
            if en = '1' then
                if pres_cal_new_data = '1' AND old_pres_cal_new_data = '0' then
                    pres_cal1_flag <= '1';
                    pres_cal2_flag <= '1';
                end if;

                if ch_0_new_data = '1' AND old_ch_0_new_data = '0' then
                    ch_0_flag <= '1';
                end if;

                if ch_1_new_data = '1' AND old_ch_1_new_data = '0' then
                    ch_1_flag <= '1';
                end if;

                if ch_2_new_data = '1' AND old_ch_2_new_data = '0' then
                    ch_2_flag <= '1';
                end if;

                if ch_3_new_data = '1' AND old_ch_3_new_data = '0' then
                    ch_3_flag <= '1';
                end if;

                if ch_4_new_data = '1' AND old_ch_4_new_data = '0' then
                    ch_4_flag <= '1';
                end if;

                if ch_5_new_data = '1' AND old_ch_5_new_data = '0' then
                    ch_5_flag <= '1';
                end if;

                if acc_new_data = '1' AND old_acc_new_data = '0' then 
                    acc_flag <= '1';
                end if;

                if mag_new_data = '1' AND old_mag_new_data = '0' then 
                    mag_flag <= '1';
                end if;

                if gyro_new_data = '1' AND old_gyro_new_data = '0' then 
                    gyro_flag <= '1';
                end if;

                if pressure_new_data = '1' AND old_pressure_new_data = '0' then 
                    pressure_flag <= '1';
                end if;

                if status_new_data = '1' AND old_status_new_data = '0' then 
                    status_flag <= '1';
                end if;

                if state = select_packet then
                    word_cnt <= 1;
                    we <= '0';
                    

                    if pres_cal1_flag = '1' then
                        packet_select <= pres_cal1;
                        pres_cal1_flag <= '0';
                        state <= clock_out_data;
                    elsif pres_cal2_flag = '1' then
                        packet_select <= pres_cal2;
                        pres_cal2_flag <= '0';
                        state <= clock_out_data;
                    elsif ch_0_flag = '1' then
                        packet_select <= ch_0;
                        ch_0_flag <= '0';
                        state <= clock_out_data;
                    elsif ch_1_flag = '1' then
                        packet_select <= ch_1;
                        ch_1_flag <= '0';
                        state <= clock_out_data;
                    elsif ch_2_flag = '1' then
                        packet_select <= ch_2;
                        ch_2_flag <= '0';
                        state <= clock_out_data;
                    elsif ch_3_flag = '1' then
                        packet_select <= ch_3;
                        ch_3_flag <= '0';
                        state <= clock_out_data;
                    elsif ch_4_flag = '1' then
                        packet_select <= ch_4;
                        ch_4_flag <= '0';
                        state <= clock_out_data;
                    elsif ch_5_flag = '1' then
                        packet_select <= ch_5;
                        ch_5_flag <= '0';
                        state <= clock_out_data;
                    elsif acc_flag = '1' then
                        packet_select <= acc;
                        acc_flag <= '0';
                        state <= clock_out_data;
                    elsif mag_flag = '1' then
                        packet_select <= mag;
                        mag_flag <= '0';
                        state <= clock_out_data;
                    elsif gyro_flag = '1' then
                        packet_select <= gyro;
                        gyro_flag <= '0';
                        state <= clock_out_data;
                    elsif pressure_flag = '1' then
                        packet_select <= pressure;
                        pressure_flag <= '0';
                        state <= clock_out_data;
                    elsif status_flag = '1' then
                        packet_select <= status;
                        status_flag <= '0';
                        state <= clock_out_data;
                    end if;
                else
                    we <= '1';
                    word_cnt <= word_cnt + 1;

                    data_out <= selected_packet(63 downto 0);

                    case word_cnt is
                        when 1 => data_out <= selected_packet(63 downto 0);
                                    state <= select_packet;
                        when others => word_cnt <= 1;
                    end case;

                    -- case word_cnt is
                    --     when 1 => data_out <= selected_packet(63 downto 56) & selected_packet(71 downto 64) & selected_packet(79 downto 72) & selected_packet(87 downto 80);
                    --     when 2 => data_out <= selected_packet(31 downto 24) & selected_packet(39 downto 32) & selected_packet(47 downto 40) & selected_packet(55 downto 48);
                    --     when 3 => data_out <= x"0A" & selected_packet(7 downto 0) & selected_packet(15 downto 8) & selected_packet(23 downto 16);
                    --                state <= select_packet;
                    --     when others => word_cnt <= 1;
                    -- end case;
                end if;
            end if;
        end if;
    end process;
end architecture_Packet_Saver;
