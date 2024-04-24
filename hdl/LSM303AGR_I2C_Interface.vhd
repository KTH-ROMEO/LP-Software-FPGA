--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: LSM303AGR_I2C_Interface.vhd
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

entity LSM303AGR_I2C_Interface is
port (
    clk : IN std_logic;
    reset : IN std_logic;

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

    acc_time : OUT std_logic_vector(23 downto 0);
    acc_x : OUT std_logic_vector(11 downto 0);
    acc_y : OUT std_logic_vector(11 downto 0);
    acc_z : OUT std_logic_vector(11 downto 0);
    mag_time : OUT std_logic_vector(23 downto 0);
    mag_x : OUT std_logic_vector(11 downto 0);
    mag_y : OUT std_logic_vector(11 downto 0);
    mag_z : OUT std_logic_vector(11 downto 0);
    temp : OUT std_logic_vector(7 downto 0);

    acc_new_data : OUT std_logic;
    mag_new_data : OUT std_logic
);
end LSM303AGR_I2C_Interface;
architecture architecture_LSM303AGR_I2C_Interface of LSM303AGR_I2C_Interface is
    constant acc_address_r : std_logic_vector(7 downto 0) := "00110011";
    constant acc_address_w : std_logic_vector(7 downto 0) := "00110010";
    constant mag_address_r : std_logic_vector(7 downto 0) := "00111101";
    constant mag_address_w : std_logic_vector(7 downto 0) := "00111100";

    constant ctrl_reg1_a : std_logic_vector(7 downto 0) := x"20";
    constant ctrl_reg4_a : std_logic_vector(7 downto 0) := x"23";
    constant cfg_reg_a_m : std_logic_vector(7 downto 0) := x"60";
    constant temp_cfg_reg_a : std_logic_vector(7 downto 0) := x"1F";
    constant status_reg_a : std_logic_vector(7 downto 0) := x"27";
    constant status_reg_m : std_logic_vector(7 downto 0) := x"67";
    constant status_reg_aux_a : std_logic_vector(7 downto 0) := x"07";

    --constant ctrl_reg1_a_settings : std_logic_vector(7 downto 0) := "01000111";    -- Acc: Selects 50 Hz ODR, Low power mode OFF and enables all axes.
    constant ctrl_reg1_a_settings : std_logic_vector(7 downto 0) := "10010111";    -- Acc: Selects 1.344 kHz ODR, Low power mode OFF and enables all axes.
    constant ctrl_reg4_a_settings : std_logic_vector(7 downto 0) := "10001000";    -- Acc: Blocks data update until value is read, little endian, uses +/- 2g scale and enables high resolution.
    constant cfg_reg_a_m_settings : std_logic_vector(7 downto 0) := "00001100";    -- Mag: No temp. compensation, low power mode off, 100 Hz ODR, continuous conversions.
    constant temp_cfg_reg_a_settings : std_logic_vector(7 downto 0) := "11000000"; -- Temp: Enable temperature sensor
    
    constant out_x_l_a : std_logic_vector(7 downto 0) := x"A8";    -- out_x_l_a address x28, with multiple reads enabled = xA8
    constant out_x_l_m : std_logic_vector(7 downto 0) := x"E8";    -- out_x_l_m address x68, with multiple reads enabled = xE8
    constant out_temp_l_a : std_logic_vector(7 downto 0) := x"8C";    -- out_temp_l_a address x0C, with multiple reads enabled = x8C

    type state_type is (
        idle,
        setup,
        check_acc,
        check_mag,
        check_temp,
        read_wait,
        read_acc,
        read_mag,
        read_temp
    );

    signal state : state_type;
    signal prev_state : state_type;
    signal subState : integer range 1 to 8;

    signal isSetup : std_logic;

begin

    process (clk, reset)
    begin
        if reset /= '0' then
            we <= '0';
            i2c_repeat_start <= '0';
            acc_new_data <= '0';
            mag_new_data <= '0';

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

            if state /= read_wait then
                prev_state <= state;
            end if;

            case state is
                when idle =>
                    subState <= 1;

                    if en = '1' then
                        if isSetup = '1' then
                            state <= check_acc;
                        else
                            state <= setup;
                        end if;
                    end if;

                when setup =>
                    case subState is
                        when 1 =>
                            if i2c_busy = '0' then
                                i2c_addr <= acc_address_w;
                                data_out <= ctrl_reg1_a;
                                num_bytes <= x"2";
                                subState <= 2;
                                we <= '1';
                            end if;

                        when 2 =>
                            if i2c_write_done = '1' then
                                data_out <= ctrl_reg1_a_settings;
                                subState <= 3;
                            end if;

                        when 3 =>
                            if i2c_busy = '0' then
                                i2c_addr <= acc_address_w;
                                data_out <= ctrl_reg4_a;
                                num_bytes <= x"2";
                                subState <= 4;
                                we <= '1';
                            end if;

                        when 4 =>
                            if i2c_write_done = '1' then
                                data_out <= ctrl_reg4_a_settings;
                                subState <= 5;
                            end if;

                        when 5 =>
                            if i2c_busy = '0' then
                                i2c_addr <= mag_address_w;
                                data_out <= cfg_reg_a_m;
                                num_bytes <= x"2";
                                subState <= 6;
                                we <= '1';
                            end if;

                        when 6 =>
                            if i2c_write_done = '1' then
                                data_out <= cfg_reg_a_m_settings;
                                subState <= 7;
                            end if;

                        when 7 =>
                            if i2c_busy = '0' then
                                i2c_addr <= acc_address_w;
                                data_out <= temp_cfg_reg_a;
                                num_bytes <= x"2";
                                subState <= 8;
                                we <= '1';
                            end if;

                        when 8 =>
                            if i2c_write_done = '1' then
                                data_out <= temp_cfg_reg_a_settings;
                                isSetup <= '1';
                                state <= check_acc;
                                subState <= 1;
                            end if;

                        when others => subState <= 1;
                    end case;

                when check_acc =>
                    case subState is
                        when 1 =>
                            if i2c_busy = '0' then
                                i2c_addr <= acc_address_w;
                                data_out <= status_reg_a;
                                num_bytes <= x"1";
                                subState <= 2;
                                we <= '1';
                            end if;

                        when 2 =>
                            if i2c_write_done = '1' then
                                i2c_repeat_start <= '1';
                                i2c_addr <= acc_address_r;
                                num_bytes <= x"1";
                                subState <= 3;
                            end if;

                        when 3 =>
                            if i2c_data_rdy = '1' then
                                i2c_repeat_start <= '0';
                                subState <= 1;

                                if data_in(3) = '1' then
                                    acc_time <= microseconds;
                                    state <= read_acc;
                                else
                                    state <= check_mag;
                                end if;
                            end if;

                        when others => subState <= 1;
                    end case;

                when check_mag =>
                    acc_new_data <= '0';

                    case subState is
                        when 1 =>
                            if i2c_busy = '0' then
                                i2c_addr <= mag_address_w;
                                data_out <= status_reg_m;
                                num_bytes <= x"1";
                                subState <= 2;
                                we <= '1';
                            end if;

                        when 2 =>
                            if i2c_write_done = '1' then
                                i2c_repeat_start <= '1';
                                i2c_addr <= mag_address_r;
                                num_bytes <= x"1";
                                subState <= 3;
                            end if;

                        when 3 =>
                            if i2c_data_rdy = '1' then
                                i2c_repeat_start <= '0';
                                subState <= 1;

                                if data_in(3) = '1' then
                                    mag_time <= microseconds;
                                    state <= read_mag;
                                else
                                    state <= check_temp;
                                end if;
                            end if;

                        when others => subState <= 1;
                    end case;

                when check_temp =>
                    mag_new_data <= '0';

                    case subState is
                        when 1 =>
                            if i2c_busy = '0' then
                                i2c_addr <= acc_address_w;
                                data_out <= status_reg_aux_a;
                                num_bytes <= x"1";
                                subState <= 2;
                                we <= '1';
                            end if;

                        when 2 =>
                            if i2c_write_done = '1' then
                                i2c_repeat_start <= '1';
                                i2c_addr <= acc_address_r;
                                num_bytes <= x"1";
                                subState <= 3;
                            end if;

                        when 3 =>
                            if i2c_data_rdy = '1' then
                                i2c_repeat_start <= '0';
                                subState <= 1;

                                if data_in(2) = '1' then
                                    state <= read_temp;
                                else
                                    state <= check_acc;
                                end if;
                            end if;

                        when others => subState <= 1;
                    end case;

                when read_wait =>
                    if i2c_data_rdy = '0' then
                        state <= prev_state;
                        subState <= subState + 1;
                    end if;

                when read_acc =>
                    if subState = 1 then
                        if i2c_busy = '0' then
                            i2c_addr <= acc_address_w;
                            data_out <= out_x_l_a;
                            num_bytes <= x"1";
                            subState <= 2;
                            we <= '1';
                        end if;
                    elsif subState = 2 then
                        if i2c_write_done = '1' then
                            i2c_repeat_start <= '1';
                            i2c_addr <= acc_address_r;
                            num_bytes <= x"6";
                            subState <= 3;
                        end if; 
                    else
                        if i2c_data_rdy = '1' then
                            i2c_repeat_start <= '0';

                            if subState = 8 then
                                state <= check_mag;
                                subState <= 1;
                            else
                                state <= read_wait;
                            end if;

                            case subState is
                                when 3 => acc_x(3 downto 0) <= data_in(7 downto 4);
                                when 4 => acc_x(11 downto 4) <= data_in;
                                when 5 => acc_y(3 downto 0) <= data_in(7 downto 4);
                                when 6 => acc_y(11 downto 4) <= data_in;
                                when 7 => acc_z(3 downto 0) <= data_in(7 downto 4);
                                when 8 => acc_z(11 downto 4) <= data_in;
                                          acc_new_data <= '1';

                                when others => state <= idle;
                            end case;
                        end if;
                    end if;

                when read_mag =>
                    if subState = 1 then
                        if i2c_busy = '0' then
                            i2c_addr <= mag_address_w;
                            data_out <= out_x_l_m;
                            num_bytes <= x"1";
                            subState <= 2;
                            we <= '1';
                        end if;
                    elsif subState = 2 then
                        if i2c_write_done = '1' then
                            i2c_repeat_start <= '1';
                            i2c_addr <= mag_address_r;
                            num_bytes <= x"6";
                            subState <= 3;
                        end if;
                    else
                        if i2c_data_rdy = '1' then
                            i2c_repeat_start <= '0';

                            if subState = 8 then
                                state <= check_temp;
                                subState <= 1;
                            else
                                state <= read_wait;
                            end if;

                            case subState is
                                when 3 => mag_x(7 downto 0) <= data_in;
                                when 4 => mag_x(11 downto 8) <= data_in(3 downto 0);
                                when 5 => mag_y(7 downto 0) <= data_in;
                                when 6 => mag_y(11 downto 8) <= data_in(3 downto 0);
                                when 7 => mag_z(7 downto 0) <= data_in;
                                when 8 => mag_z(11 downto 8) <= data_in(3 downto 0);
                                          mag_new_data <= '1';
                                when others => state <= idle;
                            end case;
                        end if;
                    end if;

                when read_temp =>
                    case subState is
                        when 1 =>
                            if i2c_busy = '0' then
                                i2c_addr <= acc_address_w;
                                data_out <= out_temp_l_a;
                                num_bytes <= x"1";
                                subState <= 2;
                                we <= '1';
                            end if;

                        when 2 =>
                            if i2c_write_done = '1' then
                                i2c_repeat_start <= '1';
                                i2c_addr <= acc_address_r;
                                num_bytes <= x"2";
                                subState <= 3;
                            end if;

                        when 3 =>
                            if i2c_data_rdy = '1' then
                                i2c_repeat_start <= '0';
                                subState <= 4;
                            end if;

                        when 4 =>
                            if i2c_data_rdy = '0' then
                                subState <= 5;
                            end if;

                        when 5 =>
                            if i2c_data_rdy = '1' then
                                temp <= data_in;
                                subState <= 1;
                                state <= idle;
                            end if;

                        when others => subState <= 1;
                    end case;

                when others => state <= idle;

            end case;
        end if;
    end process;
end architecture_LSM303AGR_I2C_Interface;
