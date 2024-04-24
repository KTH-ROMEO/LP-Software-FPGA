--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: L3GD20H_Interface.vhd
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

entity L3GD20H_Interface is
port (
    clk, reset : IN std_logic;
    
    en : IN std_logic;
   
    microseconds : IN std_logic_vector(23 downto 0);

    i2c_busy : IN std_logic;
    i2c_data_rdy : IN std_logic;
    i2c_write_done : IN std_logic;
    i2c_s_ack_error : IN std_logic;
    data_in : IN std_logic_vector(7 downto 0);

    i2c_addr : OUT std_logic_vector(7 downto 0);
    i2c_repeat_start : OUT std_logic;
    data_out : OUT std_logic_vector(7 downto 0);
    num_bytes : OUT std_logic_vector(3 downto 0);
    we : OUT std_logic;

    gyro_time : OUT std_logic_vector(23 downto 0);
    gyro_x : OUT std_logic_vector(15 downto 0);
    gyro_y : OUT std_logic_vector(15 downto 0);
    gyro_z : OUT std_logic_vector(15 downto 0);
    temp : OUT std_logic_vector(7 downto 0);
    gyro_new_data : OUT std_logic
);
end L3GD20H_Interface;
architecture architecture_L3GD20H_Interface of L3GD20H_Interface is
    constant gyro_address_r : std_logic_vector(7 downto 0) := "11010111";
    constant gyro_address_w : std_logic_vector(7 downto 0) := "11010110";

    constant reg_ctrl1 : std_logic_vector(7 downto 0) := x"20";
    constant reg_ctrl4 : std_logic_vector(7 downto 0) := x"23";
    constant reg_ctrl1_settings : std_logic_vector(7 downto 0) := "11101111";    -- Disables powerdown mode, selects 800 Hz ODR and enables all axes.
    constant reg_ctrl4_settings : std_logic_vector(7 downto 0) := "11100000";    -- Block data update until read, selects big endian and uses +/- 2000 deg/s scale.
    constant reg_status : std_logic_vector(7 downto 0) := x"27";

    constant out_x_l : std_logic_vector(7 downto 0) := x"A8";
    constant out_temp : std_logic_vector(7 downto 0) := x"26";

    type state_type is (
        idle,
        setup,
        check_gyro,
        read_gyro,
        read_temp
    );

    signal state : state_type;
    signal subState : integer range 1 to 16;

    signal isSetup : std_logic;

begin

    process (clk, reset)
    begin
        if reset /= '0' then
            we <= '0';
            i2c_repeat_start <= '0';
            gyro_new_data <= '0';

            state <= idle;
            subState <= 1;
            isSetup <= '0';

        elsif rising_edge(clk) then
            if i2c_s_ack_error = '1' then
                state <= idle;
            end if;

            if i2c_busy = '1' then
                we <= '0';
            end if;

            case state is
                when idle =>
                    subState <= 1;

                    if en = '1' AND i2c_busy = '0' then
                        if isSetup = '1' then
                            state <= check_gyro;
                        else
                            state <= setup;
                        end if;
                    end if;

                when setup =>
                    case subState is
                        when 1 =>
                            i2c_addr <= gyro_address_w;
                            data_out <= reg_ctrl1;
                            num_bytes <= x"2";
                            subState <= 2;
                            we <= '1';

                        when 2 =>
                            if i2c_write_done = '1' then
                                data_out <= reg_ctrl1_settings;
                                subState <= 3;
                            end if;

                        when 3 =>
                            if i2c_busy = '0' then
                                i2c_addr <= gyro_address_w;
                                data_out <= reg_ctrl4;
                                num_bytes <= x"2";
                                subState <= 4;
                                we <= '1';
                            end if;

                        when 4 =>
                            if i2c_write_done = '1' then
                                data_out <= reg_ctrl4_settings;
                                subState <= 5;
                            end if;

                        when 5 =>
                            if i2c_busy = '0' then
                                isSetup <= '1';
                                state <= check_gyro;
                                subState <= 1;
                            end if;

                        when others => subState <= 1;
                    end case;

                when check_gyro =>
                    case subState is
                        when 1 =>
                            if i2c_busy = '0' then
                                i2c_addr <= gyro_address_w;
                                data_out <= reg_status;
                                num_bytes <= x"1";
                                subState <= 2;
                                we <= '1';
                            end if;

                        when 2 =>
                            if i2c_write_done = '1' then
                                i2c_repeat_start <= '1';
                                i2c_addr <= gyro_address_r;
                                num_bytes <= x"1";
                                subState <= 3;
                            end if;

                        when 3 =>
                            if i2c_data_rdy = '1' then
                                i2c_repeat_start <= '0';
                                subState <= 1;

                                if data_in(3) = '1' then
                                    gyro_time <= microseconds;
                                    state <= read_gyro;
                                end if;
                            end if;

                        when others => subState <= 1;
                    end case;

                when read_gyro =>
                    case subState is
                        when 1 =>
                            if i2c_busy = '0' then
                                i2c_addr <= gyro_address_w;
                                data_out <= out_x_l;
                                num_bytes <= x"1";
                                subState <= 2;
                                we <= '1';
                            end if;

                        when 2 =>
                            if i2c_write_done = '1' then
                                i2c_repeat_start <= '1';
                                i2c_addr <= gyro_address_r;
                                num_bytes <= x"6";
                                subState <= 3;
                            end if;

                        when 3 =>
                            if i2c_data_rdy = '1' then
                                i2c_repeat_start <= '0';
                                gyro_x(15 downto 8) <= data_in;
                                subState <= 4;
                            end if;

                        when 4 =>
                            if i2c_data_rdy = '0' then
                                subState <= 5;
                            end if;

                        when 5 =>
                            if i2c_data_rdy = '1' then
                                gyro_x(7 downto 0) <= data_in;
                                subState <= 6;
                            end if;

                        when 6 =>
                            if i2c_data_rdy = '0' then
                                subState <= 7;
                            end if;

                        when 7 =>
                            if i2c_data_rdy = '1' then
                                gyro_y(15 downto 8) <= data_in;
                                subState <= 8;
                            end if;

                        when 8 =>
                            if i2c_data_rdy = '0' then
                                subState <= 9;
                            end if;

                        when 9 =>
                            if i2c_data_rdy = '1' then
                                gyro_y(7 downto 0) <= data_in;
                                subState <= 10;
                            end if;

                        when 10 =>
                            if i2c_data_rdy = '0' then
                                subState <= 11;
                            end if;

                        when 11 =>
                            if i2c_data_rdy = '1' then
                                gyro_z(15 downto 8) <= data_in;
                                subState <= 12;
                            end if;

                        when 12 =>
                            if i2c_data_rdy = '0' then
                                subState <= 13;
                            end if;

                        when 13 =>
                            if i2c_data_rdy = '1' then
                                gyro_z(7 downto 0) <= data_in;
                                subState <= 1;
                                state <= read_temp;
                            end if;

                        when others => subState <= 1;
                    end case;

                when read_temp =>
                    case subState is
                        when 1 =>
                            if i2c_busy = '0' then
                                i2c_addr <= gyro_address_w;
                                data_out <= out_temp;
                                num_bytes <= x"1";
                                subState <= 2;
                                we <= '1';
                            end if;

                        when 2 =>
                            if i2c_write_done = '1' then
                                i2c_repeat_start <= '1';
                                i2c_addr <= gyro_address_r;
                                num_bytes <= x"1";
                                subState <= 3;
                            end if;

                        when 3 =>
                            if i2c_data_rdy = '1' then
                                i2c_repeat_start <= '0';
                                temp <= data_in;
                                subState <= 4;
                                gyro_new_data <= '1';
                            end if;

                        when 4 =>
                            if i2c_busy = '0' then
                                gyro_new_data <= '0';
                                subState <= 1;
                                state <= idle;
                            end if;

                        when others => subState <= 1;
                    end case;
                when others => state <= idle;
            end case;
        end if;
    end process;
end architecture_L3GD20H_Interface;
