--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: MS5611-01BA03_Interface.vhd
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

entity MS5611_01BA03_Interface is
port (
    clk, reset, clk_1kHz: IN std_logic;

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

    C1 : OUT std_logic_vector(15 downto 0);
    C2 : OUT std_logic_vector(15 downto 0);
    C3 : OUT std_logic_vector(15 downto 0);
    C4 : OUT std_logic_vector(15 downto 0);
    C5 : OUT std_logic_vector(15 downto 0);
    C6 : OUT std_logic_vector(15 downto 0);

    pressure_time : OUT std_logic_vector(23 downto 0);
    pressure_raw : OUT std_logic_vector(23 downto 0);
    temp_raw : OUT std_logic_vector(23 downto 0);
    pressure_new_data : OUT std_logic;
    calibration_new_data : OUT std_logic
);
end MS5611_01BA03_Interface;

architecture architecture_MS5611_01BA03_Interface of MS5611_01BA03_Interface is
    constant address_r : std_logic_vector(7 downto 0) := "11101101";
    constant address_w : std_logic_vector(7 downto 0) := "11101100";

    constant cmd_readC1 : std_logic_vector(7 downto 0) := x"A2";
    constant cmd_readC2 : std_logic_vector(7 downto 0) := x"A4";
    constant cmd_readC3 : std_logic_vector(7 downto 0) := x"A6";
    constant cmd_readC4 : std_logic_vector(7 downto 0) := x"A8";
    constant cmd_readC5 : std_logic_vector(7 downto 0) := x"AA";
    constant cmd_readC6 : std_logic_vector(7 downto 0) := x"AC";
    constant cmd_reset : std_logic_vector(7 downto 0) := x"1E";
    constant cmd_convD1_OSR4096 : std_logic_vector(7 downto 0) := x"48";
    constant cmd_convD2_OSR4096 : std_logic_vector(7 downto 0) := x"58";
    constant cmd_readADC : std_logic_vector(7 downto 0) := x"00";

    constant ms_adc_wait : integer := 9;

    type state_type is (
        idle,
        do_reset,
        read_prom,
        select_pressure,
        read_pressure,
        select_temp,
        read_temp
    );

    signal state : state_type;
    signal subState : integer range 1 to 16;

    signal C_cnt : integer range 1 to 6;
    signal isSetup : std_logic;
    
    signal ms_cnt : integer range 0 to 255;
    signal old_clk_1kHz : std_logic;
   
begin

    process (clk, reset)
    begin
        if reset /= '0' then
            we <= '0';
            i2c_repeat_start <= '0';
            pressure_new_data <= '0';
            calibration_new_data <= '0';

            state <= idle;
            subState <= 1;
            isSetup <= '0';
            C_cnt <= 1;

            ms_cnt <= 0;
            old_clk_1kHz <= '0';

            C1 <= (others => '0');
            C2 <= (others => '0');
            C3 <= (others => '0');
            C4 <= (others => '0');
            C5 <= (others => '0');
            C6 <= (others => '0');
            data_out <= (others => '0');

            pressure_time <= (others => '0');
            pressure_raw <= (others => '0');
            temp_raw <= (others => '0');
            num_bytes <= (others => '0');

        elsif rising_edge(clk) then
            if i2c_s_ack_error = '1' then
                state <= idle;
            end if;

            if i2c_busy = '1' then
                we <= '0';
            end if;

            old_clk_1kHz <= clk_1kHz;

            if old_clk_1kHz = '0' AND clk_1kHz = '1' then
                ms_cnt <= ms_cnt + 1;
            end if;

            case state is
                when idle =>
                    subState <= 1;

                    if en = '1' AND i2c_busy = '0' then
                        if isSetup = '1' then
                            state <= select_pressure;
                        else
                            state <= do_reset;
                        end if;
                    end if;

                when do_reset =>
                    case subState is
                        when 1 =>
                            i2c_addr <= address_w;
                            data_out <= cmd_reset;
                            num_bytes <= x"1";
                            subState <= 2;
                            we <= '1';

                        when 2 =>
                            if i2c_write_done = '1' then
                                subState <= 3;
                                ms_cnt <= 0;
                            end if;

                        when 3 =>
                            if ms_cnt >= 9 then
                                subState <= 1;
                                C_cnt <= 1;
                                --state <= read_prom;
                                state <= idle;  -- Skip calibration readouts for flight version, this saves about 300 logic blocks.
                                isSetup <= '1';
                            end if;

                        when others => subState <= 1;
                    end case;

                when read_prom =>
                    case subState is
                        when 1 =>
                            if i2c_busy = '0' then
                                i2c_addr <= address_w;

                                case C_cnt is
                                    when 1 => data_out <= cmd_readC1;
                                    when 2 => data_out <= cmd_readC2;
                                    when 3 => data_out <= cmd_readC3;
                                    when 4 => data_out <= cmd_readC4;
                                    when 5 => data_out <= cmd_readC5;
                                    when 6 => data_out <= cmd_readC6;
                                end case;

                                num_bytes <= x"1";
                                we <= '1';
                                subState <= 2;
                            end if;

                        when 2 =>
                            if i2c_write_done = '1' then
                                subState <= 3;
                            end if;

                        when 3 =>
                            if i2c_busy = '0' then
                                i2c_addr <= address_r;
                                num_bytes <= x"2";
                                we <= '1';
                                subState <= 4;
                            end if;

                        when 4 =>
                            if i2c_data_rdy = '1' then
                                case C_cnt is
                                    when 1 => C1(15 downto 8) <= data_in;
                                    when 2 => C2(15 downto 8) <= data_in;
                                    when 3 => C3(15 downto 8) <= data_in;
                                    when 4 => C4(15 downto 8) <= data_in;
                                    when 5 => C5(15 downto 8) <= data_in;
                                    when 6 => C6(15 downto 8) <= data_in;
                                end case;

                                subState <= 5;
                            end if;

                        when 5 =>
                            if i2c_data_rdy = '0' then
                                subState <= 6;
                            end if;

                        when 6 =>
                            if i2c_data_rdy = '1' then
                                case C_cnt is
                                    when 1 => C1(7 downto 0) <= data_in;
                                    when 2 => C2(7 downto 0) <= data_in;
                                    when 3 => C3(7 downto 0) <= data_in;
                                    when 4 => C4(7 downto 0) <= data_in;
                                    when 5 => C5(7 downto 0) <= data_in;
                                    when 6 => C6(7 downto 0) <= data_in;
                                end case;

                                subState <= 1;

                                if C_cnt = 6 then
                                    isSetup <= '1';
                                    calibration_new_data <= '1';
                                    state <= select_pressure;
                                else
                                    C_cnt <= C_cnt + 1;
                                end if;
                            end if;

                        when others => subState <= 1;
                    end case;

                when select_pressure =>
                    calibration_new_data <= '0';

                    case subState is
                        when 1 =>
                            if i2c_busy = '0' then
                                i2c_addr <= address_w;
                                data_out <= cmd_convD1_OSR4096;
                                num_bytes <= x"1";
                                we <= '1';
                                subState <= 2;
                            end if;

                        when 2 =>
                            if i2c_write_done = '1' then
                                ms_cnt <= 0;
                                subState <= 3;
                            end if;

                        when 3 =>
                            pressure_time <= microseconds;

                            if ms_cnt > ms_adc_wait then
                                subState <= 1;
                                state <= read_pressure;
                            end if;

                        when others => subState <= 1;
                    end case;

                            
                when read_pressure =>
                    case subState is
                        when 1 =>
                            if i2c_busy = '0' then
                                i2c_addr <= address_w;
                                num_bytes <= x"1";
                                data_out <= cmd_readADC;
                                we <= '1';
                                subState <= 2;
                            end if;

                        when 2 =>
                            if i2c_write_done = '1' then
                                subState <= 3;
                            end if;

                        when 3 =>
                            if i2c_busy = '0' then
                                i2c_addr <= address_r;
                                num_bytes <= x"3";
                                we <= '1';
                                subState <= 4;
                            end if;

                        when 4 =>
                            if i2c_data_rdy = '1' then
                                pressure_raw(23 downto 16) <= data_in;
                                subState <= 5;
                            end if;

                        when 5 =>
                            if i2c_data_rdy = '0' then
                                subState <= 6;
                            end if;

                        when 6 =>
                            if i2c_data_rdy = '1' then
                                pressure_raw(15 downto 8) <= data_in;
                                subState <= 7;
                            end if;

                        when 7 =>
                            if i2c_data_rdy = '0' then
                                subState <= 8;
                            end if;

                        when 8 =>
                            if i2c_data_rdy = '1' then
                               pressure_raw(7 downto 0) <= data_in;
                                subState <= 1;
                                state <= select_temp;
                            end if;

                        when others => subState <= 1;
                    end case;

                when select_temp =>
                    case subState is
                        when 1 =>
                            if i2c_busy = '0' then
                                i2c_addr <= address_w;
                                data_out <= cmd_convD2_OSR4096;
                                num_bytes <= x"1";
                                we <= '1';
                                subState <= 2;
                            end if;

                        when 2 =>
                            if i2c_write_done = '1' then
                                ms_cnt <= 0;
                                subState <= 3;
                            end if;

                        when 3 =>
                            if ms_cnt > ms_adc_wait then
                                subState <= 1;
                                C_cnt <= 1;
                                state <= read_temp;
                            end if;

                        when others => subState <= 1;
                    end case;

                when read_temp =>
                    case subState is
                        when 1 =>
                            if i2c_busy = '0' then
                                i2c_addr <= address_w;
                                num_bytes <= x"1";
                                data_out <= cmd_readADC;
                                we <= '1';
                                subState <= 2;
                            end if;

                        when 2 =>
                            if i2c_write_done = '1' then
                                subState <= 3;
                            end if;

                        when 3 =>
                            if i2c_busy = '0' then
                                i2c_addr <= address_r;
                                num_bytes <= x"3";
                                we <= '1';
                                subState <= 4;
                            end if;

                        when 4 =>
                            if i2c_data_rdy = '1' then
                                i2c_repeat_start <= '0';
                                temp_raw(23 downto 16) <= data_in;
                                subState <= 5;
                            end if;

                        when 5 =>
                            if i2c_data_rdy = '0' then
                                subState <= 6;
                            end if;

                        when 6 =>
                            if i2c_data_rdy = '1' then
                                temp_raw(15 downto 8) <= data_in;
                                subState <= 7;
                            end if;

                        when 7 =>
                            if i2c_data_rdy = '0' then
                                subState <= 8;
                            end if;

                        when 8 =>
                            if i2c_data_rdy = '1' then
                                temp_raw(7 downto 0) <= data_in;
                                pressure_new_data <= '1';
                                subState <= 9;
                            end if;

                        when 9 =>
                            if i2c_busy = '0' then
                                pressure_new_data <= '0';
                                state <= idle;
                                subState <= 1;
                            end if;

                        when others => subState <= 1;
                    end case;


                when others => state <= idle;
            end case;
        end if;
    end process;
end architecture_MS5611_01BA03_Interface;
