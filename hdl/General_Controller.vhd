--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: General_Controller.vhd
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
use IEEE.numeric_std.all;

entity General_Controller is
port (
	clk : IN  std_logic;
    clk_1Hz : IN std_logic;
    reset: IN std_logic;
    
    status_packet_clk : IN std_logic;

    milliseconds : IN std_logic_vector(23 downto 0);

    ffu_ejected : IN std_logic;
    low_pressure : IN std_logic;

    ext_rx_rdy : IN std_logic;
    ext_recv : IN std_logic_vector(7 downto 0);

    uc_recv : IN std_logic_vector(7 downto 0);
    uc_tx_rdy : IN std_logic;
    uc_rx_rdy : IN std_logic;

    cu_sync : IN std_logic;

    st_rdata0  : IN std_logic_vector(15 downto 0);
    st_rdata1  : IN std_logic_vector(15 downto 0);

    st_wdata : OUT std_logic_vector(15 downto 0);
    st_waddr : OUT std_logic_vector(7 downto 0);
    st_raddr : OUT std_logic_vector(7 downto 0);


    st_wen0   : OUT std_logic;
    st_wen1   : OUT std_logic;
    st_ren0   : OUT std_logic;
    st_ren1   : OUT std_logic;

    unit_id : OUT std_logic_vector(7 downto 0);
    ffu_id : OUT std_logic_vector(7 downto 0);
    gs_id : OUT std_logic_vector(7 downto 0);

    uc_send : OUT std_logic_vector(7 downto 0);
    uc_wen : OUT std_logic;
    uc_oen : OUT std_logic;

    ext_oen : OUT std_logic;

    readout_en : OUT std_logic;

    uc_reset : OUT std_logic;
    uc_pwr_en : OUT std_logic;

    en_sensors : OUT std_logic;
    en_data_saving : OUT std_logic;

    led1 : OUT std_logic;
    led2 : OUT std_logic;

    status_bits : OUT std_logic_vector(63 downto 0);
    status_new_data : OUT std_logic;

    en_science_packets : OUT std_logic;
    sweep_en : OUT std_logic;
    ramp : OUT std_logic_vector(3 downto 0);
    exp_adc_reset : OUT std_logic;
    man_gain1 : OUT std_logic_vector(1 downto 0);
    man_gain2 : OUT std_logic_vector(1 downto 0);
    man_gain3 : OUT std_logic_vector(1 downto 0);
    man_gain4 : OUT std_logic_vector(1 downto 0);
    DAC_zero_value : OUT std_logic;
    DAC_max_value  : OUT std_logic
);
end General_Controller;
architecture architecture_General_Controller of General_Controller is
    type uc_tx_state_type is (
        uc_tx_idle,
        uc_tx_preamble,
        uc_tx_send_console_en,
        uc_tx_postamble,
        uc_tx_led3,
        uc_tx_led4,
        uc_tx_telemetry,
        uc_tx_send_state,

        uc_tx_send_cb_mode,
        uc_tx_send_const_bias,
        uc_tx_send_swt_mode,
        uc_tx_send_sweep_table,
        uc_tx_send_swt_steps,
        uc_tx_send_swt_skip,
        uc_tx_send_swt_samples_per_point,
        uc_tx_send_swt_points
    );

    type uc_rx_state_type is (
        uc_rx_idle,
        uc_rx_preamble,
        uc_rx_get_byte,
        uc_rx_wait,
        uc_rx_receive_ffu_id,
        uc_rx_receive_unit_id,
        uc_rx_receive_gs_id,

        uc_rx_receive_en_cb_mode,
        uc_rx_receive_const_bias,

        uc_rx_readback_en_cb_mode,
        uc_rx_readback_const_bias,

        uc_rx_receive_en_swt_mode,
        uc_rx_receive_sweep_table,
        uc_rx_receive_swt_steps,
        uc_rx_receive_swt_skip,
        uc_rx_receive_swt_samples_per_point,
        uc_rx_receive_swt_points,

        uc_rx_readback_swt_mode,
        uc_rx_readback_sweep_table,
        uc_rx_readback_swt_steps,
        uc_rx_readback_swt_skip,
        uc_rx_readback_swt_samples_per_point,
        uc_rx_readback_swt_points,
        uc_rx_postamble
    );

    signal temp_first_byte : std_logic_vector(7 downto 0);

    signal constant_bias_mode : std_logic_vector(7 downto 0); -- Saved as a vector for simpler readback.
    signal constant_bias_voltage_0 : std_logic_vector(15 downto 0);
    signal constant_bias_voltage_1 : std_logic_vector(15 downto 0);
    signal constant_bias_probe_id : std_logic_vector(7 downto 0);

    signal sweep_table_mode : std_logic_vector(7 downto 0); -- Saved as a vector for simpler readback.
    signal sweep_table_write_value : std_logic_vector(15 downto 0);
    signal sweep_table_read_value  : std_logic_vector(15 downto 0);

    signal sweep_table_probe_id : std_logic_vector(7 downto 0);
    signal sweep_table_step_id : std_logic_vector(7 downto 0);

    signal sweep_table_nof_steps : std_logic_vector(7 downto 0);
    signal sweep_table_sample_skip : std_logic_vector(15 downto 0);
    signal sweep_table_samples_per_point : std_logic_vector(15 downto 0);
    signal sweep_table_points : std_logic_vector(15 downto 0);

    signal sweep_table_write_wait : integer range 0 to 3;
    signal sweep_table_read_wait : integer range 0 to 3;

    signal flight_state : std_logic_vector(7 downto 0);
    constant boot : std_logic_vector(7 downto 0) := x"01";
    constant idle : std_logic_vector(7 downto 0) := x"02";
    constant inside_rocket : std_logic_vector(7 downto 0) := x"03";
    constant freefall : std_logic_vector(7 downto 0) := x"04";
    constant cutter : std_logic_vector(7 downto 0) := x"05";
    constant parachute : std_logic_vector(7 downto 0) := x"06";
    constant landed : std_logic_vector(7 downto 0) := x"07";
    constant power_save : std_logic_vector(7 downto 0) := x"08";
    constant debug : std_logic_vector(7 downto 0) := x"09";

    signal ext_rx_state : integer range 1 to 4;
    signal command : std_logic_vector(7 downto 0);

    signal uc_tx_state : uc_tx_state_type;
    signal uc_tx_nextstate : uc_tx_state_type;
    signal uc_tx_substate : integer range 1 to 16;
    signal send_console_enable : std_logic;
    signal send_led3 : std_logic;
    signal send_led4 : std_logic;
    signal send_telemetry_request : std_logic;

    signal uc_rx_state : uc_rx_state_type;
    signal uc_rx_prev_state : uc_rx_state_type;
    signal uc_rx_byte : std_logic_vector(7 downto 0);
    signal uc_rx_substate : integer range 1 to 16;

    signal old_status_packet_clk : std_logic;

    signal state_seconds : std_logic_vector(19 downto 0);
    signal send_flight_state : std_logic;

    signal old_1Hz : std_logic;

    signal mission_mode : std_logic;
begin
    process (clk, reset)
    begin
        if reset /= '0' then
            unit_id <= x"21";       -- Default unit identifier - before microcontroller reads out the stored value.
            ffu_id <= x"00";        -- Default FFU identifier - before microcontroller reads out the stored value.
            gs_id <= x"00";        -- Default FFU identifier - before microcontroller reads out the stored value.

            flight_state <= boot;

            uc_reset <= 'Z';
            uc_pwr_en <= '0';
            led1 <= '0';
            led2 <= '0';

            ext_oen <= '0';
            ext_rx_state <= 1;

            uc_send <= (others => '0');
            uc_wen <= '0';
            uc_oen <= '0';
            uc_tx_state <= uc_tx_idle;
            uc_tx_substate <= 1;
            send_console_enable <= '0';
            send_led3 <= '0';
            send_led4 <= '0';
            send_telemetry_request <= '0';

            uc_rx_state <= uc_rx_idle;
            uc_rx_prev_state <= uc_rx_idle;
            uc_rx_substate <= 1;

            en_sensors <= '0';
            en_data_saving <= '0';

            old_status_packet_clk <= '0';
            status_new_data <= '0';

            mission_mode <= '0';
            readout_en <= '0';

            en_science_packets <= '0';
            sweep_en <= '0';
            ramp <= (others => '0');
            exp_adc_reset <= '0';
            man_gain1 <= (others => '0');
            man_gain2 <= (others => '0');
            man_gain3 <= (others => '0');
            man_gain4 <= (others => '0');
            DAC_zero_value <= '1';
            DAC_max_value  <= '0';

            old_1Hz <= '0';
            state_seconds <= (others => '0');
            send_flight_state <= '0';

            temp_first_byte <= (others => '0');

            constant_bias_mode <= (others =>'0');
            constant_bias_voltage_0 <= (others => '0');
            constant_bias_voltage_1 <= (others => '0');
            constant_bias_probe_id <= (others => '0');

            sweep_table_mode <= (others => '0');
            sweep_table_probe_id <= (others => '0');
            sweep_table_step_id <= (others => '0');

            sweep_table_nof_steps <= (others => '0');
            sweep_table_sample_skip <= (others => '0');
            sweep_table_samples_per_point <= (others => '0');
            sweep_table_points <= (others => '0');

            sweep_table_write_wait <= 0;
            sweep_table_read_wait <= 0;
            st_wdata <= (others => '0');
            st_waddr <= (others => '0');
            st_raddr <= (others => '0');

            st_wen0  <= '0';
            st_wen1  <= '0';
            st_ren0  <= '0';
            st_ren1  <= '0';

        elsif rising_edge(clk) then
    ----------------------- Seconds counter -----------------------------
            old_1Hz <= clk_1Hz;

            if old_1Hz = '0' AND clk_1Hz = '1' then
                state_seconds <= state_seconds + 1;

                if milliseconds > 1000 then
                    send_flight_state <= '1';
                end if;
            end if;

    --------- General state machine - mission sequence, etc. ------------
            case flight_state is
                when boot =>
                    uc_pwr_en <= '1';
                    
                    if milliseconds > 100 then
                        en_sensors <= '1';
                    end if;

                    if milliseconds > 1000 then
                        flight_state <= idle;
                    end if;

                when idle =>
                    if mission_mode = '1' then
                        flight_state <= inside_rocket;
                        state_seconds <= (others => '0');
                    end if;

                    if low_pressure = '1' then
                        mission_mode <= '1';
                    end if;

                when inside_rocket =>
                    en_data_saving <= '1';

                    if state_seconds < 2 then
                        exp_adc_reset <= '0';
                    else
                        exp_adc_reset <= '1';

                        if ffu_ejected = '1' then
                            flight_state <= freefall;
                            state_seconds <= (others => '0');
                        end if;
                    end if;

                when freefall =>
                    en_science_packets <= '1';
                    sweep_en <= '1';

                    if state_seconds > 360 then
                        flight_state <= landed;
                        state_seconds <= (others => '0');
                    end if;

                when landed =>
                    en_science_packets <= '0';
                    sweep_en <= '0';
                    en_data_saving <= '0';

                when others => flight_state <= idle;

            end case;

    -------- External UART receive ------------
            readout_en <= '0';  -- Default state low. Only a pulse is needed to start the readout controller.

            case ext_rx_state is
                when 1 =>
                    if ext_rx_rdy = '1' then
                        command <= ext_recv;
                        ext_oen <= '1';
                        ext_rx_state <= 2;
                    end if;

                when 2 =>
                    if ext_rx_rdy = '0' then
                        ext_oen <= '0';
                        ext_rx_state <= 3;
                    end if;

                when 3 =>
                    case command is
                        when x"40" => readout_en <= '1';                    -- "@"
                        when x"A4" => send_telemetry_request <= '1';        -- "�"
                        when x"58" => mission_mode <= '1';                  -- "X"
                        when x"41" => led1 <= not led1;                     -- "A"
                        when x"42" => led2 <= not led2;                     -- "B"
                        when x"43" => send_console_enable <= '1';           -- "C"
                        when x"44" => send_led3 <= '1';                     -- "D"
                        when x"45" => send_led4 <= '1';                     -- "E"
                        when x"46" => en_data_saving <= not en_data_saving; -- "F"
                        when x"47" => en_science_packets <= '1';            -- "G"
                        when x"48" => en_science_packets <= '0';            -- "H"
                        when x"4A" => sweep_en <= not sweep_en;             -- "J" : Toggle sweep
                        when x"4F" => ramp <= (others => '0');              -- "O"
                        when x"50" => ramp <= (others => '1');              -- "P"
                        when x"52" =>      -- "R": gain debug - set gain to 1
                            man_gain1 <= "00";
                            man_gain2 <= "00";
                            man_gain3 <= "00";
                            man_gain4 <= "00";
                        when x"54" =>      -- "T": gain debug - set gain to 10
                            man_gain1 <= "01";
                            man_gain2 <= "01";
                            man_gain3 <= "01";
                            man_gain4 <= "01";
                        when x"59" =>      -- "Y": gain debug - set gain to 100
                            man_gain1 <= "10";
                            man_gain2 <= "10";
                            man_gain3 <= "10";
                            man_gain4 <= "10";
                        when x"55" =>      -- "U": gain debug - set gain to 1000
                            man_gain1 <= "11";
                            man_gain2 <= "11";
                            man_gain3 <= "11";
                            man_gain4 <= "11";
                        when x"5A" => DAC_zero_value <= '1';                -- "Z"
                        when x"4C" => DAC_zero_value <= '0';                -- "L"
                        when x"49" => DAC_max_value <= not DAC_max_value;   -- "I"
                        when x"51" => exp_adc_reset <= not exp_adc_reset;   -- "Q"

                        when others =>

                    end case;

                    ext_rx_state <= 1;
                when others =>
                    ext_rx_state <=1;

            end case;

    --------- Microcontroller UART transmit ------------
            case uc_tx_state is
                when uc_tx_idle =>

                when uc_tx_preamble =>
                    case uc_tx_substate is
                        when 1 =>
                            if uc_tx_rdy = '1' then
                                uc_send <= x"B5";
                                uc_wen <= '1';
                                uc_tx_substate <= 2;
                            end if;
                        when 2 =>
                            if uc_tx_rdy = '0' then
                                uc_wen <= '0';
                                uc_tx_substate <= 3;
                            end if;
                        when 3 =>
                            if uc_tx_rdy = '1' then
                                uc_send <= x"43";
                                uc_wen <= '1';
                                uc_tx_substate <= 4;
                            end if;
                        when 4 =>
                            if uc_tx_rdy = '0' then
                                uc_wen <= '0';
                                uc_tx_substate <= 1;
                                uc_tx_state <= uc_tx_nextstate;
                            end if;
                        when others =>
                    end case;


                when uc_tx_send_cb_mode =>
                    case uc_tx_substate is
                        when 1 => 
                            if uc_tx_rdy = '1' then
                                uc_send <= x"C0";
                                uc_wen <= '1';
                                uc_tx_substate <= uc_tx_substate + 1;
                            end if;
                        when 2 =>
                            if uc_tx_rdy = '0' then
                                uc_wen <= '0';
                                uc_tx_substate <= 1;
                                uc_tx_state <= uc_tx_postamble;
                            end if;
                        when 3 => 
                            if uc_tx_rdy = '1' then
                                uc_send <= constant_bias_mode;
                                uc_wen <= '1';
                                uc_tx_substate <= uc_tx_substate + 1;
                            end if;
                        when 4 =>
                            if uc_tx_rdy = '0' then
                                uc_wen <= '0';
                                uc_tx_substate <= 1;
                                uc_tx_state <= uc_tx_postamble;
                            end if;
                        when others =>
                    end case;


                when uc_tx_send_const_bias =>
                    case uc_tx_substate is
                        when 1 => 
                            if uc_tx_rdy = '1' then
                                uc_send <= x"CC";
                                uc_wen <= '1';
                                uc_tx_substate <= uc_tx_substate + 1;
                            end if;
                        when 2 =>
                            if uc_tx_rdy = '0' then
                                uc_wen <= '0';
                                uc_tx_substate <= 1;
                                uc_tx_substate <= uc_tx_substate + 1;
                            end if;
                        when 3 => 
                            if uc_tx_rdy = '1' then
                                case constant_bias_probe_id is
                                    when x"00" => uc_send <= constant_bias_voltage_0(7 downto 0);
                                    when x"01" => uc_send <= constant_bias_voltage_1(7 downto 0);
                                    when others =>
                                end case;
                                uc_wen <= '1';
                                uc_tx_substate <= uc_tx_substate + 1;
                            end if;
                        when 4 =>
                            if uc_tx_rdy = '0' then
                                uc_wen <= '0';
                                uc_tx_substate <= 1;
                                uc_tx_substate <= uc_tx_substate + 1;
                            end if;
                        when 5 => 
                            if uc_tx_rdy = '1' then
                                case constant_bias_probe_id is
                                    when x"00" => uc_send <= constant_bias_voltage_0(15 downto 8);
                                    when x"01" => uc_send <= constant_bias_voltage_1(15 downto 8);
                                    when others =>
                                end case;
                                uc_wen <= '1';
                                uc_tx_substate <= uc_tx_substate + 1;
                            end if;
                        when 6 =>
                            if uc_tx_rdy = '0' then
                                uc_wen <= '0';
                                uc_tx_substate <= 1;
                                uc_tx_state <= uc_tx_postamble;
                            end if;
                        when others =>
                    end case;


                when uc_tx_send_swt_mode =>
                    case uc_tx_substate is
                        when 1 => 
                            if uc_tx_rdy = '1' then
                                uc_send <= x"A0";
                                uc_wen <= '1';
                                uc_tx_substate <= uc_tx_substate + 1;
                            end if;
                        when 2 =>
                            if uc_tx_rdy = '0' then
                                uc_wen <= '0';
                                uc_tx_substate <= 1;
                                uc_tx_state <= uc_tx_postamble;
                            end if;
                        when 3 => 
                            if uc_tx_rdy = '1' then
                                uc_send <= sweep_table_mode;
                                uc_wen <= '1';
                                uc_tx_substate <= uc_tx_substate + 1;
                            end if;
                        when 4 =>
                            if uc_tx_rdy = '0' then
                                uc_wen <= '0';
                                uc_tx_substate <= 1;
                                uc_tx_state <= uc_tx_postamble;
                            end if;
                        when others =>
                    end case;


                when uc_tx_send_sweep_table =>
                    case uc_tx_substate is
                        when 1 => 
                            if uc_tx_rdy = '1' then
                                uc_send <= x"A1";
                                uc_wen <= '1';
                                uc_tx_substate <= uc_tx_substate + 1;
                            end if;
                        when 2 =>
                            if uc_tx_rdy = '0' then
                                uc_wen <= '0';
                                uc_tx_substate <= 1;
                                uc_tx_substate <= uc_tx_substate + 1;
                            end if;
                        when 3 => 
                            if uc_tx_rdy = '1' then
                                uc_send <= sweep_table_read_value(7 downto 0);
                                uc_wen <= '1';
                                uc_tx_substate <= uc_tx_substate + 1;
                            end if;
                        when 4 =>
                            if uc_tx_rdy = '0' then
                                uc_wen <= '0';
                                uc_tx_substate <= 1;
                                uc_tx_substate <= uc_tx_substate + 1;
                            end if;
                        when 5 => 
                            if uc_tx_rdy = '1' then
                                uc_send <= sweep_table_read_value(15 downto 8);
                                uc_wen <= '1';
                                uc_tx_substate <= uc_tx_substate + 1;
                            end if;
                        when 6 =>
                            if uc_tx_rdy = '0' then
                                uc_wen <= '0';
                                uc_tx_substate <= 1;
                                uc_tx_state <= uc_tx_postamble;
                            end if;
                        when others =>
                    end case;





--
--                    when uc_tx_send_swt_steps =>
--                        case uc_tx_substate is
--                            when 1 => 
--                                if uc_tx_rdy = '1' then
--                                    uc_send <= SPECIFIC_DATA_BYTE_0;
--                                    uc_wen <= '1';
--                                    uc_tx_substate <= uc_tx_substate + 1;
--                                end if;
--                            when others =>
--                        end case;
--
--
--                    when uc_tx_send_swt_skip =>
--                        case uc_tx_substate is
--                            when 1 => 
--                                if uc_tx_rdy = '1' then
--                                    uc_send <= SPECIFIC_DATA_BYTE_0;
--                                    uc_wen <= '1';
--                                    uc_tx_substate <= uc_tx_substate + 1;
--                                end if;
--                            when others =>
--                        end case;
--
--
--                    when uc_tx_send_swt_samples_per_point =>
--                        case uc_tx_substate is
--                            when 1 => 
--                                if uc_tx_rdy = '1' then
--                                    uc_send <= SPECIFIC_DATA_BYTE_0;
--                                    uc_wen <= '1';
--                                    uc_tx_substate <= uc_tx_substate + 1;
--                                end if;
--                            when others =>
--                        end case;
--
--
--                    when uc_tx_send_swt_point =>
--                        case uc_tx_substate is
--                            when 1 => 
--                                if uc_tx_rdy = '1' then
--                                    uc_send <= SPECIFIC_DATA_BYTE_0;
--                                    uc_wen <= '1';
--                                    uc_tx_substate <= uc_tx_substate + 1;
--                                end if;
--                            when others =>
--                        end case;
--
--
--                    end case;
                when uc_tx_postamble =>
                    case uc_tx_substate is
                        when 1 =>
                            if uc_tx_rdy = '1' then
                                uc_send <= x"0A";
                                uc_wen <= '1';
                                uc_tx_substate <= 2;
                            end if;
                        when 2 =>
                            if uc_tx_rdy = '0' then
                                uc_wen <= '0';
                                uc_tx_substate <= 1;
                                uc_tx_state <= uc_tx_idle;
                            end if;
                        when others =>
                            uc_tx_state <= uc_tx_idle;
                    end case;
                when others =>
                     uc_tx_state <= uc_tx_idle;

            end case;

    --------- Microcontroller UART receive ------------
            if uc_rx_state /= uc_rx_wait AND uc_rx_state /= uc_rx_get_byte then
                uc_rx_prev_state <= uc_rx_state;
            end if;

            case uc_rx_state is
                when uc_rx_idle =>
                    uc_rx_substate <= 1;

                    if uc_rx_rdy = '1' then
                        uc_rx_state <= uc_rx_preamble;
                    end if;

                when uc_rx_get_byte =>
                    if uc_rx_rdy = '1' then
                        uc_rx_byte <= uc_recv;
                        uc_oen <= '1';
                        uc_rx_state <= uc_rx_wait;
                    end if;

                when uc_rx_wait =>
                    if uc_rx_rdy = '0' then
                        uc_rx_substate <= uc_rx_substate + 1;
                        uc_rx_state <= uc_rx_prev_state;
                        uc_oen <= '0';
                    end if;

                when uc_rx_preamble =>
                    case uc_rx_substate is
                        when 1 =>
                            uc_rx_state <= uc_rx_get_byte;

                        when 2 =>
                            if uc_rx_byte = x"B5" then          -- "�"
                                uc_rx_state <= uc_rx_get_byte;
                            else
                                uc_rx_state <= uc_rx_idle;
                            end if;

                        when 3 =>
                            if uc_rx_byte = x"43" then          -- "C"
                                uc_rx_state <= uc_rx_get_byte;
                            else
                                uc_rx_state <= uc_rx_idle;
                            end if;

                        when 4 =>
                            uc_rx_substate <= 1;

                            case uc_rx_byte is
                                when x"46" => uc_rx_state <= uc_rx_receive_ffu_id;              -- "F" - FFU ID
                                when x"47" => uc_rx_state <= uc_rx_receive_gs_id;               -- "G" - GS ID for FPGA
                                when x"55" => uc_rx_state <= uc_rx_receive_unit_id;             -- "U" - Unit ID

                                when x"CA" => uc_rx_state <= uc_rx_receive_en_cb_mode;
                                when x"CB" => uc_rx_state <= uc_rx_receive_const_bias;
                                when x"C0" => uc_rx_state <= uc_rx_readback_en_cb_mode;
                                when x"CC" => uc_rx_state <= uc_rx_readback_const_bias;

                                when x"AA" => uc_rx_state <= uc_rx_receive_en_swt_mode;
                                when x"AB" => uc_rx_state <= uc_rx_receive_sweep_table;
                                when x"AC" => uc_rx_state <= uc_rx_receive_swt_steps;
                                when x"AD" => uc_rx_state <= uc_rx_receive_swt_skip;
                                when x"AE" => uc_rx_state <= uc_rx_receive_swt_samples_per_point;
                                when x"AF" => uc_rx_state <= uc_rx_receive_swt_points;

                                when x"A0" => uc_rx_state <= uc_rx_readback_swt_mode;
                                when x"A1" => uc_rx_state <= uc_rx_readback_sweep_table;
                                when x"A2" => uc_rx_state <= uc_rx_readback_swt_steps;
                                when x"A3" => uc_rx_state <= uc_rx_readback_swt_skip;
                                when x"A4" => uc_rx_state <= uc_rx_readback_swt_samples_per_point;
                                when x"A5" => uc_rx_state <= uc_rx_readback_swt_points;

                                when others => uc_rx_state <= uc_rx_idle;                       -- Unknown message, ignore.
                            end case;
                    when others =>
                    end case;

                when uc_rx_receive_ffu_id =>
                    case uc_rx_substate is
                        when 1 => uc_rx_state <= uc_rx_get_byte;
                        when 2 => ffu_id <= uc_rx_byte; uc_rx_state <= uc_rx_postamble; uc_rx_substate <= 1;
                        when others =>
                    end case;

                when uc_rx_receive_unit_id =>
                    case uc_rx_substate is
                        when 1 => uc_rx_state <= uc_rx_get_byte;
                        when 2 => 
                            if uc_rx_byte /= x"00" then
                                unit_id <= uc_rx_byte;
                            end if;

                            uc_rx_state <= uc_rx_postamble;
                            uc_rx_substate <= 1;
                        when others =>
                    end case;

                when uc_rx_receive_gs_id =>
                    case uc_rx_substate is
                        when 1 => uc_rx_state <= uc_rx_get_byte;
                        when 2 => gs_id <= uc_rx_byte; uc_rx_state <= uc_rx_postamble; uc_rx_substate <= 1;
                        when others =>
                    end case;


                when uc_rx_receive_en_cb_mode => 
                    case uc_rx_substate is
                        when 1 =>
                            constant_bias_mode <= x"01";
                            sweep_table_mode   <= x"00";
                            uc_rx_state <= uc_rx_postamble;
                            uc_rx_substate <= 1;
                        when others =>
                    end case;


                when uc_rx_receive_const_bias =>
                    case uc_rx_substate is 
                        when 1 => uc_rx_state <= uc_rx_get_byte;
                        when 2 => 
                            constant_bias_probe_id <= uc_rx_byte;
                            uc_rx_state <= uc_rx_get_byte;
                        when 3 =>
                                temp_first_byte <= uc_rx_byte;
                                uc_rx_state <= uc_rx_get_byte;
                        when 4 =>
                            case constant_bias_probe_id is
                                when x"00" =>
                                    constant_bias_voltage_0(7 downto 0) <= temp_first_byte;
                                    constant_bias_voltage_0(15 downto 8) <= uc_rx_byte;
                                when x"01" =>
                                    constant_bias_voltage_1(7 downto 0) <= temp_first_byte;
                                    constant_bias_voltage_1(15 downto 8) <= uc_rx_byte;
                                when others =>
                            end case;
                            uc_rx_state <= uc_rx_postamble;
                            uc_rx_substate <= 1;
                        when others =>
                    end case;


                when uc_rx_readback_en_cb_mode =>
                    case uc_rx_substate is
                        when 1 =>
                            uc_tx_state <= uc_tx_preamble;
                            uc_tx_nextstate <= uc_tx_send_cb_mode;
                            uc_rx_state <= uc_rx_postamble;
                            uc_rx_substate <= 1;
                        when others =>
                    end case;

                
                when uc_rx_readback_const_bias =>
                    case uc_rx_substate is
                        when 1 => uc_rx_state <= uc_rx_get_byte;
                        when 2 =>
                            constant_bias_probe_id <= uc_rx_byte;
                            uc_tx_state <= uc_tx_preamble;
                            uc_tx_nextstate <= uc_tx_send_const_bias;
                            uc_rx_state <= uc_rx_postamble;
                            uc_rx_substate <= 1;
                        when others =>
                    end case;


                when uc_rx_receive_en_swt_mode => 
                    case uc_rx_substate is
                        when 1 =>
                            sweep_table_mode   <= x"01";
                            constant_bias_mode <= x"00";
                            uc_rx_state <= uc_rx_postamble;
                            uc_rx_substate <= 1; 
                       when others =>
                    end case;


                when uc_rx_receive_sweep_table =>
                    case uc_rx_substate is 
                        when 1 => uc_rx_state <= uc_rx_get_byte;
                        when 2 => 
                            sweep_table_probe_id <= uc_rx_byte;
                            uc_rx_state <= uc_rx_get_byte;
                        when 3 => 
                            sweep_table_step_id <= uc_rx_byte;
                            uc_rx_state <= uc_rx_get_byte;
                        when 4 =>
                            temp_first_byte <= uc_rx_byte;
                            uc_rx_state <= uc_rx_get_byte;
                        when 5 =>
                            sweep_table_write_value(7 downto 0) <= temp_first_byte;
                            sweep_table_write_value(15 downto 8) <= uc_rx_byte;
                            uc_rx_substate <= uc_rx_substate + 1;
                        when 6 =>
                            -- Write to SweepTable RAM
                            case sweep_table_probe_id is
                                when x"00" =>
                                    st_wen0 <= '1';
                                    st_wen1 <= '0';
                                when x"01" =>
                                    st_wen0 <= '0';
                                    st_wen1 <= '1';
                                when others =>
                            end case;
                            st_ren0 <= '0';
                            st_ren1 <= '0';
                            st_waddr <= sweep_table_step_id;
                            st_wdata <= sweep_table_write_value;
                            uc_rx_substate <= uc_rx_substate + 1;
                        when 7 => 
                            -- Wait 3 CLK cycles for data to be written.
                            if sweep_table_write_wait /= 3 then
                               sweep_table_write_wait <= sweep_table_write_wait + 1;
                            else
                                uc_rx_substate <= uc_rx_substate + 1;
                            end if;
                        when 8 =>
                            sweep_table_write_wait <= 0;
                            uc_rx_state <= uc_rx_postamble;
                            uc_rx_substate <= 1;
                        when others =>
                    end case;


                when uc_rx_receive_swt_steps => 
                    case uc_rx_substate is
                        when 1 => uc_rx_state <= uc_rx_get_byte;
                        when 2 =>
                            sweep_table_nof_steps <= uc_rx_byte;
                            uc_rx_state <= uc_rx_postamble;
                            uc_rx_substate <= 1;
                        when others =>
                    end case;


                when uc_rx_receive_swt_skip => 
                    case uc_rx_substate is
                        when 1 => uc_rx_state <= uc_rx_get_byte;
                        when 2 =>
                            temp_first_byte <= uc_rx_byte;
                            uc_rx_state <= uc_rx_get_byte;
                        when 3 => 
                            sweep_table_sample_skip(7 downto 0) <= temp_first_byte;
                            sweep_table_sample_skip(15 downto 8) <= uc_rx_byte;
                            uc_rx_state <= uc_rx_postamble;
                            uc_rx_substate <= 1;
                        when others =>
                    end case;


                when uc_rx_receive_swt_samples_per_point => 
                    case uc_rx_substate is
                        when 1 => uc_rx_state <= uc_rx_get_byte;
                        when 2 =>
                            temp_first_byte <= uc_rx_byte;
                            uc_rx_state <= uc_rx_get_byte;
                        when 3 => 
                            sweep_table_samples_per_point(7 downto 0) <= temp_first_byte;
                            sweep_table_samples_per_point(15 downto 8) <= uc_rx_byte;
                            uc_rx_state <= uc_rx_postamble;
                            uc_rx_substate <= 1;
                        when others =>
                    end case;


                when uc_rx_receive_swt_points => 
                    case uc_rx_substate is
                        when 1 => uc_rx_state <= uc_rx_get_byte;
                        when 2 =>
                            temp_first_byte <= uc_rx_byte;
                            uc_rx_state <= uc_rx_get_byte;
                        when 3 => 
                            sweep_table_points(7 downto 0) <= temp_first_byte;
                            sweep_table_points(15 downto 8) <= uc_rx_byte;
                            uc_rx_state <= uc_rx_postamble;
                            uc_rx_substate <= 1;
                        when others =>
                    end case;


                when uc_rx_readback_swt_mode =>
                    case uc_rx_substate is
                        when 1 =>
                            uc_tx_state <= uc_tx_preamble;
                            uc_tx_nextstate <= uc_tx_send_swt_mode;
                            uc_rx_state <= uc_rx_postamble;
                            uc_rx_substate <= 1; 
                       when others =>
                    end case;


                when uc_rx_readback_sweep_table =>
                    case uc_rx_substate is
                        when 1 => uc_rx_state <= uc_rx_get_byte;
                        when 2 =>
                            sweep_table_probe_id <= uc_rx_byte;
                            uc_rx_state <= uc_rx_get_byte;
                        when 3 =>
                            sweep_table_step_id <= uc_rx_byte;
                            uc_rx_substate <= uc_rx_substate + 1;
                        when 4 =>
                            st_raddr <= sweep_table_step_id;
                            st_wen0 <= '0';
                            st_wen1 <= '0';
                            case sweep_table_probe_id is
                                when x"00" =>
                                    st_ren0 <= '1';
                                    st_ren1 <= '0';
                                when x"01" =>
                                    st_ren0 <= '0';
                                    st_ren1 <= '1';
                                when others =>
                            end case;
                            uc_rx_substate <= uc_rx_substate + 1;
                        when 5 => 
                            -- Wait 3 CLK cycles for data to be read.
                            if sweep_table_read_wait /= 3 then
                               sweep_table_read_wait <= sweep_table_read_wait + 1;
                            else
                                uc_rx_substate <= uc_rx_substate + 1;
                            end if;
                        when 6 =>
                            sweep_table_read_wait <= 0;
                            case sweep_table_probe_id is
                                when x"00" =>
                                    sweep_table_read_value <= st_rdata0;
                                when x"01" =>
                                    sweep_table_read_value <= st_rdata1;
                                when others =>
                            end case;

                            uc_tx_state <= uc_tx_preamble;
                            uc_tx_nextstate <= uc_tx_send_sweep_table;
                            uc_rx_state <= uc_rx_postamble;
                            uc_rx_substate <= 1;
                        when others =>
                    end case;


                when uc_rx_readback_swt_steps =>
                    case uc_rx_substate is
                        when 1 =>
                            uc_tx_state <= uc_tx_preamble;
                            uc_tx_nextstate <= uc_tx_send_swt_steps;
                            uc_rx_state <= uc_rx_postamble;
                        when others =>
                    end case;


                when uc_rx_readback_swt_skip =>
                    case uc_rx_substate is
                        when 1 =>
                            uc_tx_state <= uc_tx_preamble;
                            uc_tx_nextstate <= uc_tx_send_swt_skip;
                            uc_rx_state <= uc_rx_postamble;
                        when others =>
                    end case;


                when uc_rx_readback_swt_samples_per_point =>
                    case uc_rx_substate is
                        when 1 =>
                            uc_tx_state <= uc_tx_preamble;
                            uc_tx_nextstate <= uc_tx_send_swt_samples_per_point;
                            uc_rx_state <= uc_rx_postamble;
                        when others =>
                    end case;


                when uc_rx_readback_swt_points =>
                    case uc_rx_substate is
                        when 1 =>
                            uc_tx_state <= uc_tx_preamble;
                            uc_tx_nextstate <= uc_tx_send_swt_points;
                            uc_rx_state <= uc_rx_postamble;
                        when others =>
                    end case;


                when uc_rx_postamble =>
                    case uc_rx_substate is
                        when 1 => uc_rx_state <= uc_rx_get_byte;
                        when 2 => uc_rx_state <= uc_rx_idle;
                        when others =>
                    end case;

                when others =>
                     uc_rx_state <= uc_rx_idle;
            end case;

----------------- Status bits generation ---------------------
            old_status_packet_clk <= status_packet_clk;

            if status_packet_clk = '1' AND old_status_packet_clk = '0' then
                status_bits(63 downto 40) <= milliseconds;
                status_bits(39 downto 7) <= (others => '0');
                status_bits(6 downto 0) <=  cu_sync & en_data_saving & en_sensors & uc_pwr_en & low_pressure & ffu_ejected & mission_mode;

                status_new_data <= '1';
            else
                status_new_data <= '0';
            end if;
        end if;
    end process;
end architecture_General_Controller;
