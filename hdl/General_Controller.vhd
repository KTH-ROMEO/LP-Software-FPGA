library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;


entity General_Controller is
port (
	clk     : IN  std_logic;
    clk_1Hz : IN std_logic;
    reset   : IN std_logic;
    
    status_packet_clk : IN std_logic;

    milliseconds : IN std_logic_vector(23 downto 0);

    ffu_ejected  : IN std_logic;
    low_pressure : IN std_logic;

    ext_rx_rdy : IN std_logic;
    ext_recv   : IN std_logic_vector(7 downto 0);

    uc_recv   : IN std_logic_vector(7 downto 0);
    uc_tx_rdy : IN std_logic;
    uc_rx_rdy : IN std_logic;

    cu_sync : IN std_logic;

    st_rdata0  : IN std_logic_vector(15 downto 0);
    st_rdata1  : IN std_logic_vector(15 downto 0);

    acc_packet      : IN std_logic_vector(63 downto 0);
    mag_packet      : IN std_logic_vector(63 downto 0);
    gyro_packet     : IN std_logic_vector(63 downto 0);
    pressure_packet : IN std_logic_vector(63 downto 0);
    new_data        : IN std_logic; -- example for periodic data

    st_wdata : OUT std_logic_vector(15 downto 0);
    st_waddr : OUT std_logic_vector(7 downto 0);
    st_raddr : OUT std_logic_vector(7 downto 0);


    st_wen0   : OUT std_logic;
    st_wen1   : OUT std_logic;
    st_ren0   : OUT std_logic;
    st_ren1   : OUT std_logic;

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
    DAC_max_value  : OUT std_logic;
    

    --TODO: clarify with Jesus
    C_bias_V0 : OUT std_logic_vector(15 downto 0); 
    C_bias_V1 : OUT std_logic_vector(15 downto 0);
    
    Bias_enabled                    : OUT std_logic;
    Sweep_enabled                   : OUT std_logic;
    sweep_table_nof_steps           : OUT std_logic_vector(7 downto 0);
    sweep_table_samples_per_step    : OUT std_logic_vector(15 downto 0);
    sweep_table_samples_per_point   : OUT std_logic_vector(15 downto 0);
    sweep_table_sample_skip         : OUT std_logic_vector(15 downto 0);
    sweep_table_points              : OUT std_logic_vector(15 downto 0) 

);
end General_Controller;

architecture architecture_General_Controller of General_Controller is

    
    type uc_tx_state_type is (
        TX_IDLE,
        TX_SEND_BYTE,
        TX_WAIT_RDY
    );

    type uc_rx_state_type is (
        RX_IDLE,
        RX_GET_BYTE,
        RX_WAIT_RDY_LOW,
        RX_PROCESS_PREAMBLE,
        RX_COMMAND,
        RX_PAYLOAD,
        RX_POSTAMBLE,
        RX_EXECUTE
    );

    type payload_array_type is array (0 to 3) of std_logic_vector(7 downto 0); -- payload buffer
    type rx_context_type    is (CTX_PREAMBLE, CTX_PAYLOAD, CTX_POSTAMBLE); -- Context for wait state in RX FSM
    type byte_array_type    is array(0 to 11) of std_logic_vector(7 downto 0); --msg_2send



    -- SCIENCE DATA
    signal constant_bias_mode         : std_logic;
    signal constant_bias_voltage_0    : std_logic_vector(15 downto 0);
    signal constant_bias_voltage_1    : std_logic_vector(15 downto 0);
    signal constant_bias_probe_id     : std_logic_vector(7 downto 0);
    signal sweep_table_activate_sweep : std_logic; --TODO NEED of having this strobe
    signal sweep_table_sweep_cnt      : std_logic_vector(15 downto 0); -- Number of activated sweeps since last FPGA power on.
    signal sweep_table_read_value     : std_logic_vector(15 downto 0);
--    signal sweep_table_nof_steps : std_logic_vector(7 downto 0);
--    signal sweep_table_samples_per_step : std_logic_vector(15 downto 0);
--    signal sweep_table_sample_skip : std_logic_vector(15 downto 0);
--    signal sweep_table_samples_per_point : std_logic_vector(15 downto 0);
--    signal sweep_table_points : std_logic_vector(15 downto 0);


    -- RX FSM
    signal uc_rx_state              : uc_rx_state_type;
    signal preamble_counter         : integer range 0 to 2 := 0;
    signal received_byte            : std_logic_vector(7 downto 0);
    signal command_byte             : std_logic_vector(7 downto 0);
    signal current_command          : std_logic_vector(4 downto 0);
    signal expected_payload_length  : integer range 0 to 7 := 0;
    signal payload_buffer           : payload_array_type; 
    signal payload_index            : integer range 0 to 7 := 0;
    signal rx_context               : rx_context_type := CTX_PREAMBLE;
    signal long_command_active      : std_logic := '0';
    signal swt_wr_substate          : integer range 0 to 2 := 0;
    signal sweep_table_write_wait   : integer range 0 to 3;
    signal swt_rd_substate          : integer range 0 to 2 := 0;
    signal sweep_table_read_wait    : integer range 0 to 3;
    signal acc_send_req             : std_logic := '0';
    signal mag_send_req             : std_logic := '0';
    signal gyro_send_req            : std_logic := '0';
    signal pressure_send_req        : std_logic := '0';
    signal const_volt_send_req      : std_logic := '0';
    signal swt_swp_cnt_send_req     : std_logic := '0';
    signal swt_steps_send_req       : std_logic := '0';
    signal swt_sps_send_req         : std_logic := '0';
    signal swt_skip_send_req        : std_logic := '0';
    signal swt_spp_send_req         : std_logic := '0';
    signal swt_points_send_req      : std_logic := '0';
    signal const_measure_send_req   : std_logic := '0';
    signal swt_value_send_req       : std_logic := '0';

    constant POSTAMBLE  : std_logic_vector(7 downto 0) := x"0A";
    constant PREAMBLE_1 : std_logic_vector(7 downto 0) := x"B5";
    constant PREAMBLE_2 : std_logic_vector(7 downto 0) := x"43";

    -- TX FSM
    signal uc_tx_state               : uc_tx_state_type;
    signal msg_2send                 : byte_array_type := (others => (others => '0'));
    signal start_tx                  : std_logic := '0';
    signal tx_byte_index             : integer range 0 to 11 := 0;
    signal acc_tx_flag               : std_logic := '0';
    signal mag_tx_flag               : std_logic := '0';
    signal gyro_tx_flag              : std_logic := '0';
    signal pressure_tx_flag          : std_logic := '0';
    signal const_volt_tx_flag        : std_logic := '0';
    signal swt_swp_cnt_tx_flag       : std_logic := '0';
    signal swt_steps_tx_flag         : std_logic := '0';
    signal swt_sps_tx_flag           : std_logic := '0';
    signal swt_skip_tx_flag          : std_logic := '0';
    signal swt_spp_tx_flag           : std_logic := '0';
    signal swt_points_tx_flag        : std_logic := '0';
    signal const_measure_tx_flag     : std_logic := '0';
    signal swt_value_tx_flag         : std_logic := '0';
    signal constant_bias_voltage_tx  : std_logic_vector(15 downto 0);


    -- PERIODIC TX
    signal old_new_data              : std_logic;
    signal acc_tx_periodic_flag      : std_logic := '0';
    signal mag_tx_periodic_flag      : std_logic := '0';
    signal gyro_tx_periodic_flag     : std_logic := '0';
    signal pressure_tx_periodic_flag : std_logic := '0';

    -- FLIGHT STATES
    signal flight_state : std_logic_vector(7 downto 0);
    signal old_status_packet_clk : std_logic;
    signal state_seconds : std_logic_vector(19 downto 0);
    signal send_flight_state : std_logic;
    signal mission_mode : std_logic;
    signal old_1Hz : std_logic;
    constant boot : std_logic_vector(7 downto 0) := x"01";
    constant idle : std_logic_vector(7 downto 0) := x"02";
    constant inside_rocket : std_logic_vector(7 downto 0) := x"03";
    constant freefall : std_logic_vector(7 downto 0) := x"04";
    constant cutter : std_logic_vector(7 downto 0) := x"05";
    constant parachute : std_logic_vector(7 downto 0) := x"06";
    constant landed : std_logic_vector(7 downto 0) := x"07";
    constant power_save : std_logic_vector(7 downto 0) := x"08";
    constant debug : std_logic_vector(7 downto 0) := x"09";

    -- EXT RX
    signal ext_rx_state : integer range 1 to 4;
    signal command : std_logic_vector(7 downto 0);
    signal send_console_enable : std_logic;
    signal send_led3 : std_logic;
    signal send_led4 : std_logic;
    signal send_telemetry_request : std_logic;


    -- ADDED by Angelo on 03/08 -- 
    function vector_2array(v : std_logic_vector(95 downto 0)) return byte_array_type is
    variable result : byte_array_type;
    begin
        for i in 0 to 11 loop
            result(i) := v((95 - i*8) downto (88 - i*8));
        end loop;
        return result;
    end function;

begin

    process (clk, reset)
    begin
        if reset /= '0' then
       
            constant_bias_mode <= '0';

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
            uc_tx_state <= TX_IDLE;
            send_console_enable <= '0';
            send_led3 <= '0';
            send_led4 <= '0';
            send_telemetry_request <= '0';

            uc_rx_state <= RX_IDLE;

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


            constant_bias_voltage_0 <= (others => '0');
            constant_bias_voltage_1 <= (others => '0');
            constant_bias_voltage_tx <= (others => '0');
            constant_bias_probe_id <= (others => '0');
            
            sweep_table_activate_sweep <= '0';
            sweep_table_sweep_cnt <= (others => '0');

            sweep_table_nof_steps <= (others => '0');
            sweep_table_sample_skip <= (others => '0');
            sweep_table_samples_per_point <= (others => '0');
            sweep_table_points <= (others => '0');

            st_wdata <= (others => '0');
            st_waddr <= (others => '0');
            st_raddr <= (others => '0');

            st_wen0  <= '0';
            st_wen1  <= '0';
            st_ren0  <= '0';
            st_ren1  <= '0';

            -- ADDED by Angelo on 2025-06-22 --
            old_new_data <= '0';
            acc_send_req <= '0';
            mag_send_req <= '0';
            gyro_send_req <= '0';
            pressure_send_req <= '0';
            -- ADDED by Angelo on 2025-07-01 --
            preamble_counter <= 0;
            payload_index <= 0;
            command_byte <= (others => '0');
            current_command <= (others => '0');
            expected_payload_length <= 0;
            rx_context <= CTX_PREAMBLE;
            for i in 0 to 3 loop
                payload_buffer(i) <= (others => '0');
            end loop;
            long_command_active <= '0';
            swt_rd_substate <= 0;
            swt_wr_substate <= 0;
            sweep_table_write_wait <= 0;
            sweep_table_read_wait <= 0;
            -- ADDED by Angelo on 2025-07-26 --
            tx_byte_index <= 0;
            start_tx <= '0';
            msg_2send <= (others => (others => '0'));
            -- ADDED by Angelo on 2025-08-03
            const_volt_send_req  <= '0';
            swt_swp_cnt_send_req     <= '0';
            swt_steps_send_req   <= '0';
            swt_sps_send_req     <= '0';
            swt_skip_send_req    <= '0';
            swt_spp_send_req     <= '0';
            swt_points_send_req  <= '0';
            const_measure_send_req  <= '0';
            swt_value_send_req   <= '0';
            -- ADDED by Angelo on 2025-08-18
            acc_tx_flag               <= '0';
            mag_tx_flag               <= '0';
            gyro_tx_flag              <= '0';
            pressure_tx_flag          <= '0';
            const_volt_tx_flag        <= '0';
            swt_swp_cnt_tx_flag       <= '0';
            swt_steps_tx_flag         <= '0';
            swt_sps_tx_flag           <= '0';
            swt_skip_tx_flag          <= '0';
            swt_spp_tx_flag           <= '0';
            swt_points_tx_flag        <= '0';
            const_measure_tx_flag     <= '0';
            swt_value_tx_flag         <= '0';
            acc_tx_periodic_flag      <= '0';
            mag_tx_periodic_flag      <= '0';
            gyro_tx_periodic_flag     <= '0';
            pressure_tx_periodic_flag <= '0';

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

    --------- TX FSM ------------

            -- RX strobes to internal TX flags --
            if acc_send_req = '1' then
                acc_tx_flag <= '1';
            end if;
            if mag_send_req = '1' then
                mag_tx_flag <= '1';
            end if;   
            if gyro_send_req = '1' then
                gyro_tx_flag <= '1';
            end if;
            if pressure_send_req = '1' then
                pressure_tx_flag <= '1';
            end if;  
            if const_volt_send_req = '1' then
                const_volt_tx_flag <= '1';
            end if;
            if swt_swp_cnt_send_req = '1' then
                swt_swp_cnt_tx_flag <= '1';
            end if;
            if swt_steps_send_req = '1' then
                swt_steps_tx_flag <= '1';
            end if;
            if swt_sps_send_req = '1' then
                swt_sps_tx_flag <= '1';
            end if;
            if swt_skip_send_req = '1' then
                swt_skip_tx_flag <= '1';
            end if;
            if swt_spp_send_req = '1' then
                swt_spp_tx_flag <= '1';
            end if;
            if swt_points_send_req = '1' then
                swt_points_tx_flag <= '1';
            end if;
            if const_measure_send_req = '1' then
                const_measure_tx_flag <= '1';
            end if;
            if swt_value_send_req = '1' then
                swt_value_tx_flag <= '1';
            end if;


            -- Handle TX flags, building packet to send --
            if uc_tx_state = TX_IDLE then

                if (acc_tx_flag = '1') or (acc_tx_periodic_flag = '1') then
                    msg_2send <= vector_2array(PREAMBLE_1 & PREAMBLE_2 &"11111"&"001"& acc_packet & POSTAMBLE); 
                    acc_tx_flag <= '0';
                    start_tx <= '1';

                elsif (mag_tx_flag = '1') or (mag_tx_periodic_flag = '1') then
                    msg_2send <= vector_2array(PREAMBLE_1 & PREAMBLE_2 &"11111"&"001"& mag_packet & POSTAMBLE);
                    mag_tx_flag <= '0';
                    start_tx <= '1';

                elsif (gyro_tx_flag = '1') or (gyro_tx_periodic_flag = '1') then
                    msg_2send <= vector_2array(PREAMBLE_1 & PREAMBLE_2 &"11111"&"001"& gyro_packet & POSTAMBLE);
                    gyro_tx_flag <= '0';
                    start_tx <= '1';

                elsif (pressure_tx_flag = '1') or (pressure_tx_periodic_flag = '1') then
                    msg_2send <= vector_2array(PREAMBLE_1 & PREAMBLE_2 &"11111"&"001"& pressure_packet & POSTAMBLE);
                    pressure_tx_flag <= '0';
                    start_tx <= '1';
                
                elsif const_volt_tx_flag = '1' then
                    msg_2send <= vector_2array(PREAMBLE_1 & PREAMBLE_2 &"00100"&"001"& constant_bias_voltage_tx(7 downto 0)& constant_bias_voltage_tx(15 downto 8)&(47 downto 0 => '0') & POSTAMBLE);
                    const_volt_tx_flag <= '0';
                    start_tx <= '1';

                elsif swt_swp_cnt_tx_flag = '1' then
                    msg_2send <= vector_2array(PREAMBLE_1 & PREAMBLE_2 &"01011"&"000"& sweep_table_sweep_cnt(7 downto 0)& sweep_table_sweep_cnt(15 downto 8)&(47 downto 0 => '0') & POSTAMBLE);
                    swt_swp_cnt_tx_flag <= '0';
                    start_tx <= '1';

                elsif swt_steps_tx_flag = '1' then
                    msg_2send <= vector_2array(PREAMBLE_1 & PREAMBLE_2 &"01101"&"000"& sweep_table_nof_steps &(55 downto 0 => '0') & POSTAMBLE);
                    swt_steps_tx_flag <= '0';
                    start_tx <= '1';

                elsif swt_sps_tx_flag = '1' then
                    msg_2send <= vector_2array(PREAMBLE_1 & PREAMBLE_2 &"01111"&"000"& sweep_table_samples_per_step(7 downto 0)& sweep_table_samples_per_step(15 downto 8)&(47 downto 0 => '0') & POSTAMBLE);
                    swt_sps_tx_flag <= '0';
                    start_tx <= '1';

                elsif swt_skip_tx_flag = '1' then
                    msg_2send <= vector_2array(PREAMBLE_1 & PREAMBLE_2 &"10001"&"000"& sweep_table_sample_skip(7 downto 0)& sweep_table_sample_skip(15 downto 8)&(47 downto 0 => '0') & POSTAMBLE);
                    swt_skip_tx_flag <= '0';
                    start_tx <= '1';

                elsif swt_spp_tx_flag = '1' then
                    msg_2send <= vector_2array(PREAMBLE_1 & PREAMBLE_2 &"10011"&"000"& sweep_table_samples_per_point(7 downto 0)& sweep_table_samples_per_point(15 downto 8)&(47 downto 0 => '0') & POSTAMBLE);
                    swt_spp_tx_flag <= '0';
                    start_tx <= '1';

                elsif swt_points_tx_flag = '1' then
                    msg_2send <= vector_2array(PREAMBLE_1 & PREAMBLE_2 &"10101"&"000"& sweep_table_points(7 downto 0)& sweep_table_points(15 downto 8)&(47 downto 0 => '0') & POSTAMBLE);
                    swt_points_tx_flag <= '0';
                    start_tx <= '1';

                elsif const_measure_tx_flag = '1' then
                    msg_2send <= vector_2array(PREAMBLE_1 & PREAMBLE_2 &"00001"&"000"&x"aabb"&(47 downto 0 => '0') & POSTAMBLE);
                    const_measure_tx_flag <= '0';
                    start_tx <= '1';

                elsif swt_value_tx_flag = '1' then
                    msg_2send <= vector_2array(PREAMBLE_1 & PREAMBLE_2 &"10111"&"010"& sweep_table_read_value(7 downto 0)& sweep_table_read_value(15 downto 8)&(47 downto 0 => '0') & POSTAMBLE);
                    swt_value_tx_flag <= '0';
                    start_tx <= '1';

                end if;
            end if;

            case uc_tx_state is

                when TX_IDLE =>
                    if start_tx = '1' then
                        tx_byte_index <= 0;
                        uc_tx_state   <= TX_SEND_BYTE;
                        start_tx <= '0';

                    end if;

                when TX_SEND_BYTE =>
                    if uc_tx_rdy = '1' then
                        uc_send <= msg_2send(tx_byte_index);
                        uc_wen  <= '1';
                        uc_tx_state <= TX_WAIT_RDY;
                    end if;

                when TX_WAIT_RDY =>
                    if uc_tx_rdy = '0' then
                        uc_wen <= '0';
                        if tx_byte_index < 11 then
                            tx_byte_index <= tx_byte_index + 1;
                            uc_tx_state   <= TX_SEND_BYTE;
                        else
                            uc_tx_state   <= TX_IDLE;
                        end if;
                    end if;

                when others =>
                    uc_tx_state <= TX_IDLE;

            end case;

    --------- PERIODIC FLAGS ------------
       --     old_new_data <= new_data;    -- this will not be needed if new_data is a strobe, but for now
       --     if (new_data = '1') and (old_new_data = '0') then    -- detects the "rising edge" of new data, 
       --                                                         -- not needed when new_data is a strobe
       --         acc_tx_periodic_flag <= '0';
       --         mag_tx_periodic_flag <= '0';
       --         gyro_tx_periodic_flag <= '0';
       --         pressure_tx_periodic_flag <= '0';
       --     end if;


-- NEW RX FSM --

            case uc_rx_state is

                when RX_IDLE =>   -- TODO: is the "idle state" really needed?

                    -- strobes --
                    Sweep_enabled              <= '0'; -- set to 1 in command 01010
                    sweep_table_activate_sweep <= '0';  -- set to 1 in command 01010
                    acc_send_req               <= '0';
                    mag_send_req               <= '0';
                    gyro_send_req              <= '0';
                    pressure_send_req          <= '0';
                    const_volt_send_req        <= '0';
                    swt_swp_cnt_send_req       <= '0';
                    swt_steps_send_req         <= '0';
                    swt_sps_send_req           <= '0';
                    swt_skip_send_req          <= '0';
                    swt_spp_send_req           <= '0';
                    swt_points_send_req        <= '0';
                    const_measure_send_req     <= '0';
                    swt_value_send_req         <= '0';




                    if uc_rx_rdy = '1' then
                        uc_rx_state <= RX_GET_BYTE;
                    end if;

                when RX_GET_BYTE =>
                    if uc_rx_rdy = '1' then
                        received_byte <= uc_recv;  
                        uc_oen <= '1';             
                        uc_rx_state <= RX_WAIT_RDY_LOW;
                    end if;

                when RX_WAIT_RDY_LOW =>
                    if uc_rx_rdy = '0' then
                        uc_oen <= '0';
                        case rx_context is
                            when CTX_PREAMBLE =>
                                uc_rx_state <= RX_PROCESS_PREAMBLE;
                            when CTX_PAYLOAD =>
                                uc_rx_state <= RX_PAYLOAD;
                            when CTX_POSTAMBLE =>
                                uc_rx_state <= RX_POSTAMBLE;
                        end case;
                    end if;

                when RX_PROCESS_PREAMBLE =>
                    case preamble_counter is
                        when 0 =>
                            if received_byte = PREAMBLE_1 then
                                preamble_counter <= 1;
                            else
                                preamble_counter <= 0;  
                            end if;
                            uc_rx_state <= RX_IDLE;

                        when 1 =>
                            if received_byte = PREAMBLE_2 then
                                preamble_counter <= 2;
                            else
                                preamble_counter <= 0;
                            end if;
                            uc_rx_state <= RX_IDLE;  

                        when 2 =>
                            command_byte <= received_byte;  
                            preamble_counter <= 0;
                            uc_rx_state <= RX_COMMAND;
                    end case;

                when RX_COMMAND =>
                    current_command <= command_byte(7 downto 3);
                    expected_payload_length <= to_integer(unsigned(command_byte(2 downto 0)));

                    if (command_byte(2 downto 0)) = "000" then
                        rx_context <= CTX_POSTAMBLE;  
                    else
                        payload_index <= 0;
                        rx_context <= CTX_PAYLOAD;   
                    end if;

                    uc_rx_state <= RX_IDLE;

                when RX_PAYLOAD =>
                    payload_buffer( payload_index ) <= received_byte;

                    if payload_index + 1 = expected_payload_length then
                        rx_context <= CTX_POSTAMBLE;
                    else
                        payload_index <= payload_index + 1;
                        rx_context <= CTX_PAYLOAD;
                    end if;    

                    uc_rx_state <= RX_IDLE;

                when RX_POSTAMBLE =>
                    if received_byte = POSTAMBLE then
                        if current_command = "10111" or current_command = "10110" then -- commands on sweep table (readback, write)
                            long_command_active <= '1';
                        else
                            long_command_active <= '0';
                        end if;
                        uc_rx_state <= RX_EXECUTE;  
                    else
                        uc_rx_state <= RX_IDLE;
                        rx_context <= CTX_PREAMBLE;
                    end if;   

                when RX_EXECUTE =>
                    case current_command is

                        -- ZERO BYTES PAYLOAD --

                        -- Enable Constant Bias Mode (and send measurements)
                        when "00001" =>  
                            led1 <= '1';
                            constant_bias_mode <= '1';
                            Bias_enabled <= '1';
                            const_measure_send_req <= '1';

                        -- Disable Constant Bias Mode
                        when "00010" => 
                            led1 <= '0';
                            led2 <= '0';
                            constant_bias_mode <= '0';
                            Bias_enabled <= '0';

                        -- Activate Sweep mode
                        when "01010" =>  
                            Sweep_enabled <= '1';  
                            sweep_table_activate_sweep <= '1'; 
                            constant_bias_mode <= '0';  -- Disable CB mode --TODO: Should this be done? -Jesus
                            sweep_table_sweep_cnt <= sweep_table_sweep_cnt + 1;

                        -- Readback Sweep Count
                        when "01011" => 
                            swt_swp_cnt_send_req <= '1';

                        -- Readback Sweep Steps
                        when "01101" =>  
                            swt_steps_send_req <= '1';

                        -- Readback Samples per Step
                        when "01111" =>  
                            swt_sps_send_req <= '1';

                        -- Readback Skip
                        when "10001" =>  
                            swt_skip_send_req <= '1';

                        -- Readback Samples per Point
                        when "10011" =>  
                            swt_spp_send_req <= '1';

                        -- Readback Sweep Points
                        when "10101" =>  
                            swt_points_send_req <= '1';


                        -- 1 BYTE PAYLOAD --

                        -- Readback Constant Bias 
                        when "00100" =>
                            case payload_buffer(0) is -- payload_buffer(0) is constant_bias_probe_id
                                when x"00" => constant_bias_voltage_tx <= constant_bias_voltage_0;
                                when x"01" => constant_bias_voltage_tx <= constant_bias_voltage_1;
                                when others =>
                            end case;
                            const_volt_send_req <= '1';

                        -- Set Sweep Table Steps 
                        when "01100" =>  
                            sweep_table_nof_steps <= payload_buffer(0);

                        -- Readback HK Data (oneshot)
                        when "11111" =>  
                            case payload_buffer(0) is
                                when x"00" => acc_send_req      <= '1';
                                when x"01" => mag_send_req      <= '1';
                                when x"02" => gyro_send_req     <= '1';
                                when x"03" => pressure_send_req <= '1';
                                when others => 
                            end case;
                            

                        -- 2 BYTES PAYLOAD --
                                                       
                        -- Readback Sweep Table
                        when "10111" =>  
                            case swt_rd_substate is

                                when 0 =>
                                    -- payload_buffer(0) is sweep_table_probe_id
                                    -- payload_buffer(1) is sweep_table_step_id
            
                                    st_raddr <= payload_buffer(1);
                                    st_wen0  <= '0';
                                    st_wen1  <= '0';

                                    case payload_buffer(0) is
                                        when x"00" =>
                                            st_ren0 <= '1';
                                            st_ren1 <= '0';
                                        when x"01" =>
                                            st_ren0 <= '0';
                                            st_ren1 <= '1';
                                        when others =>
                                    end case;

                                    swt_rd_substate <= 1;  

                                -- Wait 3 clock cycles
                                when 1 =>
                                    if sweep_table_read_wait < 3 then
                                        sweep_table_read_wait <= sweep_table_read_wait + 1;
                                    else
                                        sweep_table_read_wait <= 0;
                                        swt_rd_substate <= 2;
                                        long_command_active <= '0'; -- set 1 clock cycle before  
                                    end if;   

                                when 2 =>
                                    if payload_buffer(0) = x"00" then
                                        sweep_table_read_value <= st_rdata0;
                                    elsif payload_buffer(0) = x"01" then
                                        sweep_table_read_value <= st_rdata1;
                                    end if;

                                    swt_value_send_req <= '1';
                                    swt_rd_substate <= 0;

                                when others => -- additional reset 
                                    swt_rd_substate <= 0;
                                    long_command_active <= '0';
                                    uc_rx_state <= RX_IDLE;
                                    rx_context <= CTX_PREAMBLE;
                            end case;


                        -- Set Samples per Step 
                        when "01110" =>   
                            sweep_table_samples_per_step(7 downto 0)  <= payload_buffer(0);
                            sweep_table_samples_per_step(15 downto 8) <= payload_buffer(1);
                            
                        -- Set Sweep Skip 
                        when "10000" => 
                            sweep_table_sample_skip(7 downto 0)  <= payload_buffer(0);
                            sweep_table_sample_skip(15 downto 8) <= payload_buffer(1);

                        -- Set Samples per Point
                        when "10010" =>  
                            sweep_table_samples_per_point(7 downto 0)  <= payload_buffer(0);
                            sweep_table_samples_per_point(15 downto 8) <= payload_buffer(1);

                        -- Set Sweep Points
                        when "10100" => 
                            sweep_table_points(7 downto 0)  <= payload_buffer(0);
                            sweep_table_points(15 downto 8) <= payload_buffer(1);


                        -- 3 BYTES PAYLOAD --

                        -- Set Constant Bias Voltage
                        when "00011" =>  
                            constant_bias_probe_id <= payload_buffer(0);

                            case payload_buffer(0) is
                                when x"00" =>
                                    constant_bias_voltage_0(7 downto 0)  <= payload_buffer(1);
                                    constant_bias_voltage_0(15 downto 8) <= payload_buffer(2);
                                when x"01" =>
                                    constant_bias_voltage_1(7 downto 0)  <= payload_buffer(1);
                                    constant_bias_voltage_1(15 downto 8) <= payload_buffer(2);
                                when others =>
                            end case;


                        -- 4 BYTES PAYLOAD --

                        -- Receive Sweep Table 
                        when "10110" =>  
                            case swt_wr_substate is

                                when 0 =>
                                    -- payload_buffer(0) -> sweep_table_probe_id
                                    -- payload_buffer(1) -> sweep_table_step_id

                                    case payload_buffer(0) is
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
                                    st_waddr <= payload_buffer(1);
                                    st_wdata <= payload_buffer(3) & payload_buffer(2);

                                    swt_wr_substate <= 1;

                                -- Wait 3 clock cycles
                                when 1 =>

                                    if sweep_table_write_wait < 2 then
                                        sweep_table_write_wait <= sweep_table_write_wait + 1;
                                    elsif sweep_table_write_wait = 2 then
                                        long_command_active <= '0';
                                        sweep_table_write_wait <= sweep_table_write_wait + 1;
                                    else
                                        sweep_table_write_wait <= 0;
                                        swt_wr_substate <= 0;
                                    end if;

                                when others => -- additional reset
                                    swt_wr_substate <= 0;
                                    long_command_active <= '0';
                                    uc_rx_state <= RX_IDLE; 
                                    rx_context <= CTX_PREAMBLE; 
                            end case;

                        when others =>

                    end case;

                    if long_command_active /= '1' then 
                        uc_rx_state <= RX_IDLE;
                        rx_context <= CTX_PREAMBLE;
                        for i in 0 to 3 loop
                            payload_buffer(i) <= (others => '0');
                        end loop;
                    end if;


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