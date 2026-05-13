library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity General_Controller is
port (
    clk         : IN std_logic;
    clk_1Hz     : IN std_logic;
    clk_4Hz     : IN std_logic;
    clk_256Hz   : IN std_logic;
    reset       : IN std_logic;
    
    uart_rx_byte  : IN std_logic_vector(7 downto 0);
    uart_tx_ready : IN std_logic;
    uart_rx_valid : IN std_logic;

    swt_rdata0  : IN std_logic_vector(15 downto 0);
    swt_rdata1  : IN std_logic_vector(15 downto 0);

    acc_packet       : IN std_logic_vector(63 downto 0);
    mag_packet       : IN std_logic_vector(63 downto 0);
    gyro_packet      : IN std_logic_vector(63 downto 0);
    pressure_packet  : IN std_logic_vector(63 downto 0);
    timestamp_packet : IN std_logic_vector(55 downto 0);

    sc_new     : IN std_logic;
    sc_data    : IN std_logic_vector(63 downto 0);

    swt_wdata : OUT std_logic_vector(15 downto 0);
    swt_waddr : OUT std_logic_vector(7 downto 0);
    swt_raddr : OUT std_logic_vector(7 downto 0);

    swt_wen0   : OUT std_logic;
    swt_wen1   : OUT std_logic;
    swt_ren    : OUT std_logic;

    uart_tx_byte : OUT std_logic_vector(7 downto 0);
    uart_tx_start  : OUT std_logic;
    uart_rx_ack    : OUT std_logic;

    led1 : OUT std_logic; -- not implemented --
    led2 : OUT std_logic; -- not implemented --
    
    C_bias_V0 : OUT std_logic_vector(15 downto 0); 
    C_bias_V1 : OUT std_logic_vector(15 downto 0);
    
    Bias_enabled            : OUT std_logic;
    Sweep_enabled           : OUT std_logic;
    swt_nof_steps           : OUT std_logic_vector(7 downto 0);
    swt_samples_per_step    : OUT std_logic_vector(15 downto 0);
    swt_samples_per_point   : OUT std_logic_vector(15 downto 0);
    swt_sample_skip         : OUT std_logic_vector(15 downto 0);
    swt_points_per_step     : OUT std_logic_vector(15 downto 0)
);
end General_Controller;

architecture architecture_General_Controller of General_Controller is

    -- TYPE DEFINITIONS --
    -- RX FSM --
    type tx_state_type is (
        TX_IDLE,
        TX_SEND_BYTE,
        TX_WAIT_RDY
    );

    -- TX FSM --
    type rx_state_type is (
        RX_IDLE,
        RX_GET_BYTE,
        RX_WAIT_RDY_LOW,
        RX_PROCESS_PREAMBLE,
        RX_COMMAND,
        RX_PAYLOAD,
        RX_POSTAMBLE,
        RX_EXECUTE
    );

    -- SWT FSM --
    type swt_engine_state_type is (
        SWT_IDLE,
        SWT_SINGLE_READ_WAIT,
        SWT_SINGLE_READ_LATCH,
        SWT_MACRO_ISSUE_READ,
        SWT_MACRO_WAIT_READ,
        SWT_MACRO_REQUEST_TX,
        SWT_MACRO_WAIT_TX_ACCEPT
    );

    type payload_array_type is array (0 to 3) of std_logic_vector(7 downto 0);          -- payload expected to be max 4 bytes (updatable)
    type rx_context_type    is (CTX_PREAMBLE, CTX_COMMAND, CTX_PAYLOAD, CTX_POSTAMBLE); -- context of the next byte read by RX FSM
    type byte_array_type    is array(0 to 11) of std_logic_vector(7 downto 0);          -- array of bytes used for sending in TX FSM
    subtype hk_period_cnt_type is natural range 0 to 255;                               -- used for HK periodic counters 

    -- Internal versions of sweep table memory interface OUT ports
    signal swt_wdata_i : std_logic_vector(15 downto 0) := (others => '0');
    signal swt_waddr_i : std_logic_vector(7 downto 0)  := (others => '0');
    signal swt_raddr_i : std_logic_vector(7 downto 0)  := (others => '0');
    signal swt_wen0_i  : std_logic := '0';
    signal swt_wen1_i  : std_logic := '0';
    signal swt_ren_i   : std_logic := '0';

    -- Internal versions of sweep table configuration parameters OUT ports
    signal swt_nof_steps_i           : std_logic_vector(7 downto 0)  := (others => '0');
    signal swt_samples_per_step_i    : std_logic_vector(15 downto 0) := (others => '0');
    signal swt_samples_per_point_i   : std_logic_vector(15 downto 0) := (others => '0');
    signal swt_sample_skip_i         : std_logic_vector(15 downto 0) := (others => '0');
    signal swt_points_per_step_i     : std_logic_vector(15 downto 0) := (others => '0');

    -- SCIENCE DATA
    signal cb_mode         : std_logic := '0';
    signal cb_voltage_0    : std_logic_vector(15 downto 0) := (others => '0');
    signal cb_voltage_1    : std_logic_vector(15 downto 0) := (others => '0');
    signal cb_voltage_tx   : std_logic_vector(15 downto 0) := (others => '0');
    signal cb_probe_id     : std_logic_vector(7 downto 0)  := (others => '0'); 
    signal swt_probe_id    : std_logic_vector(7 downto 0)  := (others => '0');
    signal swt_sweep_cnt   : std_logic_vector(15 downto 0) := (others => '0');
    signal swt_read_value  : std_logic_vector(15 downto 0) := (others => '0');

    -- MACRO SWEEP
    signal mac_swt_active       : std_logic := '0';
    signal mac_swt_tot_steps    : std_logic_vector(15 downto 0) := (others => '0'); -- last step index to send
    signal mac_swt_step         : std_logic_vector(7 downto 0)  := (others => '0');
    signal mac_swt_wait         : integer range 0 to 3 := 0;
    signal mac_swt_val0         : std_logic_vector(15 downto 0) := (others => '0');
    signal mac_swt_val1         : std_logic_vector(15 downto 0) := (others => '0');
    signal mac_swt_last_pkt     : std_logic := '0';
    signal swt_engine_state     : swt_engine_state_type := SWT_IDLE;

    constant MACRO_PKT_END_SIG  : std_logic_vector(23 downto 0) := x"EEEEEE";

    -- RX FSM
    signal rx_state                 : rx_state_type := RX_IDLE;
    signal preamble_cnt         : integer range 0 to 2 := 0;
    signal received_byte            : std_logic_vector(7 downto 0) := (others => '0');
    signal command_byte             : std_logic_vector(7 downto 0) := (others => '0');
    signal current_command          : std_logic_vector(4 downto 0) := (others => '0');
    signal expected_payload_length  : integer range 0 to 7 := 0;
    signal payload_buffer           : payload_array_type := (others => (others => '0'));
    signal payload_index            : integer range 0 to 7 := 0;
    signal rx_context               : rx_context_type := CTX_PREAMBLE;

    -- RX-generated TX request strobes
    signal acc_send_req            : std_logic := '0';
    signal mag_send_req            : std_logic := '0';
    signal gyro_send_req           : std_logic := '0';
    signal pressure_send_req       : std_logic := '0';
    signal timestamp_send_req      : std_logic := '0';
    signal T_send_req              : std_logic := '0';
    signal const_volt_send_req     : std_logic := '0';
    signal swt_swp_cnt_send_req    : std_logic := '0';
    signal swt_steps_send_req      : std_logic := '0';
    signal swt_sps_send_req        : std_logic := '0';
    signal swt_skip_send_req       : std_logic := '0';
    signal swt_spp_send_req        : std_logic := '0';
    signal swt_points_send_req     : std_logic := '0';
    signal macro_meta1_send_req    : std_logic := '0';
    signal macro_meta2_send_req    : std_logic := '0';

    -- RX-generated Sweep table engine request strobes/data
    signal swt_single_read_req     : std_logic := '0';
    signal swt_single_write_req    : std_logic := '0';
    signal swt_req_probe_id        : std_logic_vector(7 downto 0)  := (others => '0');
    signal swt_req_step_id         : std_logic_vector(7 downto 0)  := (others => '0');
    signal swt_req_wdata           : std_logic_vector(15 downto 0) := (others => '0');

    signal mac_swt_start_req       : std_logic := '0';
    signal mac_swt_mode            : std_logic_vector(7 downto 0)  := (others => '0'); -- 0x01=n_steps, 0x02=256

    -- Sweep table engine generated TX strobes/handshake
    signal swt_value_send_req    : std_logic := '0';
    signal macro_table_tx_flag   : std_logic := '0';
    signal macro_table_tx_ack    : std_logic := '0';

    -- TX FSM
    signal tx_state    : tx_state_type := TX_IDLE;
    signal msg_2send      : byte_array_type := (others => (others => '0'));
    signal start_tx       : std_logic := '0';
    signal tx_byte_index  : integer range 0 to 11 := 0;

    signal acc_tx_flag            : std_logic := '0';
    signal mag_tx_flag            : std_logic := '0';
    signal gyro_tx_flag           : std_logic := '0';
    signal pressure_tx_flag       : std_logic := '0';
    signal timestamp_tx_flag      : std_logic := '0';
    signal T_tx_flag              : std_logic := '0';
    signal const_volt_tx_flag     : std_logic := '0';
    signal swt_swp_cnt_tx_flag    : std_logic := '0';
    signal swt_steps_tx_flag      : std_logic := '0';
    signal swt_sps_tx_flag        : std_logic := '0';
    signal swt_skip_tx_flag       : std_logic := '0';
    signal swt_spp_tx_flag        : std_logic := '0';
    signal swt_points_tx_flag     : std_logic := '0';
    signal sc_data_tx_flag        : std_logic := '0';
    signal swt_value_tx_flag      : std_logic := '0';
    signal macro_meta1_tx_flag    : std_logic := '0';
    signal macro_meta2_tx_flag    : std_logic := '0';

    -- PERIODIC HK
    signal old_clk_256Hz   : std_logic := '0';
    signal old_clk_1Hz     : std_logic := '0';
    signal old_clk_4Hz     : std_logic := '0';

    signal acc_periodic_send_req       : std_logic := '0';
    signal mag_periodic_send_req       : std_logic := '0';
    signal gyro_periodic_send_req      : std_logic := '0';
    signal pressure_periodic_send_req  : std_logic := '0';

    signal acc_cnt_reset_req           : std_logic := '0';
    signal mag_cnt_reset_req           : std_logic := '0';
    signal gyro_cnt_reset_req          : std_logic := '0';
    signal pres_cnt_reset_req          : std_logic := '0';

    signal acc_tx_periodic_flag       : std_logic := '0';
    signal mag_tx_periodic_flag       : std_logic := '0';
    signal gyro_tx_periodic_flag      : std_logic := '0';
    signal pressure_tx_periodic_flag  : std_logic := '0';

    signal acc_period     : hk_period_cnt_type := 0;
    signal mag_period     : hk_period_cnt_type := 0;
    signal gyro_period    : hk_period_cnt_type := 0;
    signal pres_period    : hk_period_cnt_type := 0;
    signal acc_cnt        : hk_period_cnt_type := 0;
    signal mag_cnt        : hk_period_cnt_type := 0;
    signal gyro_cnt       : hk_period_cnt_type := 0;
    signal pres_cnt       : hk_period_cnt_type := 0;
    signal acc_scale_code  : std_logic_vector(1 downto 0) := (others => '0');
    signal mag_scale_code  : std_logic_vector(1 downto 0) := (others => '0');
    signal gyro_scale_code : std_logic_vector(1 downto 0) := (others => '0');
    signal pres_scale_code : std_logic_vector(1 downto 0) := (others => '0');
    signal acc_period_code  : std_logic_vector(7 downto 0) := (others => '0');
    signal mag_period_code  : std_logic_vector(7 downto 0) := (others => '0');
    signal gyro_period_code : std_logic_vector(7 downto 0) := (others => '0');
    signal pres_period_code : std_logic_vector(7 downto 0) := (others => '0');
    signal T_2rb            : std_logic_vector(7 downto 0) := (others => '0');
    signal HK_ID_2rb        : std_logic_vector(7 downto 0) := (others => '0');

    -- HK ERROR COUNTERS
    signal error_cnt_send_req  : std_logic := '0';
    signal error_cnt_tx_flag   : std_logic := '0';

    signal hk_error_cnt_packet : std_logic_vector(55 downto 0) := (others => '0');

    -- counters for building the error packet in dedicated process
    signal err_sc_cb_overrun_cnt        : std_logic_vector(7 downto 0) := (others => '0');
    signal err_periodic_hk_overrun_cnt  : std_logic_vector(7 downto 0) := (others => '0');
    signal err_readback_overrun_cnt     : std_logic_vector(7 downto 0) := (others => '0');

    signal err_rx_preamble_cnt          : std_logic_vector(3 downto 0) := (others => '0');
    signal err_rx_postamble_cnt         : std_logic_vector(3 downto 0) := (others => '0');
    signal err_unknown_cmd_cnt          : std_logic_vector(3 downto 0) := (others => '0');
    signal err_impossible_branch_cnt    : std_logic_vector(3 downto 0) := (others => '0');
    signal err_sweep_macro_busy_cnt     : std_logic_vector(3 downto 0) := (others => '0');
    signal err_fsm_illegal_state_cnt    : std_logic_vector(3 downto 0) := (others => '0');
    signal err_periodic_hk_unexp_cnt    : std_logic_vector(3 downto 0) := (others => '0');
    signal err_reserved_cnt             : std_logic_vector(3 downto 0) := (others => '0');

    -- events triggered and detected in HK ERROR process to increase counters
    signal err_sc_cb_overrun_evt        : std_logic := '0';
    signal err_periodic_hk_overrun_evt  : std_logic := '0';
    signal err_readback_overrun_evt     : std_logic := '0';
    signal err_rx_preamble_evt          : std_logic := '0';
    signal err_rx_postamble_evt         : std_logic := '0';
    signal err_unknown_cmd_evt          : std_logic := '0';
    signal err_impossible_branch_evt    : std_logic := '0';
    signal err_sweep_macro_busy_evt     : std_logic := '0';
    signal err_fsm_illegal_state_rx_evt : std_logic := '0';
    signal err_fsm_illegal_state_swt_evt: std_logic := '0';
    signal err_fsm_illegal_state_tx_evt : std_logic := '0';
    signal err_periodic_hk_unexp_evt    : std_logic := '0';


    -- frame constants 
    constant POSTAMBLE  : std_logic_vector(7 downto 0) := x"0A";
    constant PREAMBLE_1 : std_logic_vector(7 downto 0) := x"B5";
    constant PREAMBLE_2 : std_logic_vector(7 downto 0) := x"43";


    -- transforms a single vector of 12 bytes into an array of 1 byte per index
    -- used in TX FSM for sending byte to byte
    function vector_2array(v : std_logic_vector(95 downto 0)) return byte_array_type is
        variable result : byte_array_type;
    begin
        for i in 0 to 11 loop
            result(i) := v((95 - i*8) downto (88 - i*8));
        end loop;
        return result;
    end function;

    -- saturation function for HK ERROR counters of 8 bits
    function sat_inc8(v : std_logic_vector(7 downto 0)) return std_logic_vector is
    begin
        if v = x"FF" then
            return v;
        else
            return std_logic_vector(unsigned(v) + 1);
        end if;
    end function;

    -- saturation function for HK ERROR counters of 4 bits
    function sat_inc4(v : std_logic_vector(3 downto 0)) return std_logic_vector is
    begin
        if v = x"F" then
            return v;
        else
            return std_logic_vector(unsigned(v) + 1);
        end if;
    end function;

begin

    -- Mirroring of internal signals into OUT ports
    swt_wdata <= swt_wdata_i;
    swt_waddr <= swt_waddr_i;
    swt_raddr <= swt_raddr_i;
    swt_wen0  <= swt_wen0_i;
    swt_wen1  <= swt_wen1_i;
    swt_ren   <= swt_ren_i;

    swt_nof_steps         <= swt_nof_steps_i;
    swt_samples_per_step  <= swt_samples_per_step_i;
    swt_samples_per_point <= swt_samples_per_point_i;
    swt_sample_skip       <= swt_sample_skip_i;
    swt_points_per_step   <= swt_points_per_step_i;

    -- Mirroring of internal Error signals into TX used error packet
    hk_error_cnt_packet <=
        err_sc_cb_overrun_cnt &
        err_periodic_hk_overrun_cnt &
        err_readback_overrun_cnt &
        err_rx_preamble_cnt & err_rx_postamble_cnt &
        err_unknown_cmd_cnt & err_impossible_branch_cnt &
        err_sweep_macro_busy_cnt & err_fsm_illegal_state_cnt &
        err_periodic_hk_unexp_cnt & err_reserved_cnt;


-- ERROR COUNTER ACCUMULATOR --
    
    p_error_counters : process (clk, reset)
    begin
        if reset /= '0' then
            err_sc_cb_overrun_cnt       <= (others => '0');
            err_periodic_hk_overrun_cnt <= (others => '0');
            err_readback_overrun_cnt    <= (others => '0');
            err_rx_preamble_cnt         <= (others => '0');
            err_rx_postamble_cnt        <= (others => '0');
            err_unknown_cmd_cnt         <= (others => '0');
            err_impossible_branch_cnt   <= (others => '0');
            err_sweep_macro_busy_cnt    <= (others => '0');
            err_fsm_illegal_state_cnt   <= (others => '0');
            err_periodic_hk_unexp_cnt   <= (others => '0');
            err_reserved_cnt            <= (others => '0');

        elsif rising_edge(clk) then
            if err_sc_cb_overrun_evt = '1' then
                err_sc_cb_overrun_cnt <= sat_inc8(err_sc_cb_overrun_cnt);
            end if;

            if err_periodic_hk_overrun_evt = '1' then
                err_periodic_hk_overrun_cnt <= sat_inc8(err_periodic_hk_overrun_cnt);
            end if;

            if err_readback_overrun_evt = '1' then
                err_readback_overrun_cnt <= sat_inc8(err_readback_overrun_cnt);
            end if;

            if err_rx_preamble_evt = '1' then
                err_rx_preamble_cnt <= sat_inc4(err_rx_preamble_cnt);
            end if;

            if err_rx_postamble_evt = '1' then
                err_rx_postamble_cnt <= sat_inc4(err_rx_postamble_cnt);
            end if;

            if err_unknown_cmd_evt = '1' then
                err_unknown_cmd_cnt <= sat_inc4(err_unknown_cmd_cnt);
            end if;

            if err_impossible_branch_evt = '1' then
                err_impossible_branch_cnt <= sat_inc4(err_impossible_branch_cnt);
            end if;

            if err_sweep_macro_busy_evt = '1' then
                err_sweep_macro_busy_cnt <= sat_inc4(err_sweep_macro_busy_cnt);
            end if;

            if err_fsm_illegal_state_rx_evt = '1' or
               err_fsm_illegal_state_swt_evt = '1' or
               err_fsm_illegal_state_tx_evt = '1' then
                err_fsm_illegal_state_cnt <= sat_inc4(err_fsm_illegal_state_cnt);
            end if;

            if err_periodic_hk_unexp_evt = '1' then
                err_periodic_hk_unexp_cnt <= sat_inc4(err_periodic_hk_unexp_cnt);
            end if;
        end if;
    end process;




-- RX FSM --
 
    p_rx_and_execute : process (clk, reset)
        variable v_scale : std_logic_vector(1 downto 0) := (others => '0');
        variable v_val   : integer := 0;
    begin
        if reset /= '0' then
            led1 <= '0'; 
            led2 <= '0';
            uart_rx_ack   <= '0';


            Sweep_enabled <= '0';
            Bias_enabled  <= '0';
            cb_mode       <= '0';

            cb_voltage_0  <= (others => '0');
            cb_voltage_1  <= (others => '0');
            cb_voltage_tx <= (others => '0');
            cb_probe_id   <= (others => '0');

            C_bias_V0 <= (others => '0');
            C_bias_V1 <= (others => '0');

            swt_sweep_cnt              <= (others => '0');
            swt_nof_steps_i            <= (others => '0');
            swt_sample_skip_i          <= (others => '0');
            swt_samples_per_point_i    <= (others => '0');
            swt_points_per_step_i      <= (others => '0');
            swt_samples_per_step_i     <= (others => '0');

            acc_period  <= 0;
            mag_period  <= 0;
            gyro_period <= 0;
            pres_period <= 0;
            acc_scale_code     <= (others => '0');
            mag_scale_code     <= (others => '0');
            gyro_scale_code    <= (others => '0');
            pres_scale_code    <= (others => '0');
            acc_period_code  <= (others => '0');
            mag_period_code  <= (others => '0');
            gyro_period_code <= (others => '0');
            pres_period_code <= (others => '0');
            T_2rb     <= (others => '0');
            HK_ID_2rb <= (others => '0');

            rx_state                <= RX_IDLE;
            rx_context              <= CTX_PREAMBLE;
            preamble_cnt            <= 0;
            received_byte           <= (others => '0');
            command_byte            <= (others => '0');
            current_command         <= (others => '0');
            payload_index           <= 0;
            expected_payload_length <= 0;
            payload_buffer          <= (others => (others => '0'));

            acc_send_req         <= '0';
            mag_send_req         <= '0';
            gyro_send_req        <= '0';
            pressure_send_req    <= '0';
            timestamp_send_req   <= '0';
            T_send_req           <= '0';
            const_volt_send_req  <= '0';
            swt_swp_cnt_send_req <= '0';
            swt_steps_send_req   <= '0';
            swt_sps_send_req     <= '0';
            swt_skip_send_req    <= '0';
            swt_spp_send_req     <= '0';
            swt_points_send_req  <= '0';
            macro_meta1_send_req <= '0';
            macro_meta2_send_req <= '0';
            error_cnt_send_req   <= '0';

            err_rx_preamble_evt          <= '0';
            err_rx_postamble_evt         <= '0';
            err_unknown_cmd_evt          <= '0';
            err_impossible_branch_evt    <= '0';
            err_fsm_illegal_state_rx_evt <= '0';

            swt_single_read_req  <= '0';
            swt_single_write_req <= '0';
            swt_req_probe_id     <= (others => '0');
            swt_req_step_id      <= (others => '0');
            swt_req_wdata        <= (others => '0');
            mac_swt_start_req    <= '0';
            mac_swt_mode         <= (others => '0');
            acc_cnt_reset_req    <= '0';
            mag_cnt_reset_req    <= '0';
            gyro_cnt_reset_req   <= '0';
            pres_cnt_reset_req   <= '0';

        elsif rising_edge(clk) then

            -- one-clock strobes for RX logic
            Sweep_enabled        <= '0';
            acc_send_req         <= '0';
            mag_send_req         <= '0';
            gyro_send_req        <= '0';
            pressure_send_req    <= '0';
            timestamp_send_req   <= '0';
            T_send_req           <= '0';
            const_volt_send_req  <= '0';
            swt_swp_cnt_send_req <= '0';
            swt_steps_send_req   <= '0';
            swt_sps_send_req     <= '0';
            swt_skip_send_req    <= '0';
            swt_spp_send_req     <= '0';
            swt_points_send_req  <= '0';
            macro_meta1_send_req <= '0';
            macro_meta2_send_req <= '0';
            error_cnt_send_req   <= '0';

            -- one-clock strobes for error events in Error Counter Accumulator process
            err_rx_preamble_evt          <= '0';
            err_rx_postamble_evt         <= '0';
            err_unknown_cmd_evt          <= '0';
            err_impossible_branch_evt    <= '0';
            err_fsm_illegal_state_rx_evt <= '0';

            -- one-clock strobes for sweep table read/write/macro in SWT engine
            swt_single_read_req  <= '0';
            swt_single_write_req <= '0';
            mac_swt_start_req    <= '0';

            -- one-clock strobes for reset of periodic HK counters in Periodic HK proces
            acc_cnt_reset_req    <= '0';
            mag_cnt_reset_req    <= '0';
            gyro_cnt_reset_req   <= '0';
            pres_cnt_reset_req   <= '0';

            case rx_state is

                when RX_IDLE => -- partial reset, safe fallback state in case of errors occurring
                    uart_rx_ack             <= '0';
                    rx_context              <= CTX_PREAMBLE;
                    preamble_cnt            <= 0;
                    payload_index           <= 0;
                    expected_payload_length <= 0;
                    current_command         <= (others => '0');
                    command_byte            <= (others => '0');
                    received_byte           <= (others => '0');
                    payload_buffer          <= (others => (others => '0'));
                    rx_state                <= RX_GET_BYTE;

                when RX_GET_BYTE =>
                    if uart_rx_valid = '1' then
                        received_byte <= uart_rx_byte;
                        uart_rx_ack   <= '1';
                        rx_state      <= RX_WAIT_RDY_LOW;
                    end if;

                when RX_WAIT_RDY_LOW =>
                    if uart_rx_valid = '0' then
                        uart_rx_ack <= '0';
                        case rx_context is
                            when CTX_PREAMBLE  => rx_state <= RX_PROCESS_PREAMBLE;
                            when CTX_COMMAND   => rx_state <= RX_COMMAND;
                            when CTX_PAYLOAD   => rx_state <= RX_PAYLOAD;
                            when CTX_POSTAMBLE => rx_state <= RX_POSTAMBLE;
                            when others =>
                                err_fsm_illegal_state_rx_evt <= '1';
                                rx_state <= RX_IDLE;
                        end case;
                    end if;

                when RX_PROCESS_PREAMBLE =>
                    case preamble_cnt is
                        when 0 =>
                            if received_byte = PREAMBLE_1 then
                                preamble_cnt <= 1;
                            else
                                preamble_cnt <= 0;
                            end if;
                            rx_state <= RX_GET_BYTE;

                        when 1 =>
                            if received_byte = PREAMBLE_2 then
                                rx_context <= CTX_COMMAND;
                            else
                                err_rx_preamble_evt <= '1';
                            end if;
                            preamble_cnt <= 0;
                            rx_state      <= RX_GET_BYTE;

                        when others =>
                            err_fsm_illegal_state_rx_evt <= '1';
                            rx_state <= RX_IDLE;
                    end case;

                when RX_COMMAND =>
                    command_byte <= received_byte;

                    if to_integer(unsigned(received_byte(2 downto 0))) > 4 then
                        err_impossible_branch_evt <= '1';
                        rx_state <= RX_IDLE;
                    else
                        current_command         <= received_byte(7 downto 3);
                        expected_payload_length <= to_integer(unsigned(received_byte(2 downto 0)));

                        if received_byte(2 downto 0) = "000" then
                            rx_context <= CTX_POSTAMBLE;
                        else
                            payload_index <= 0;
                            rx_context    <= CTX_PAYLOAD;
                        end if;

                        rx_state <= RX_GET_BYTE;
                    end if;

                when RX_PAYLOAD =>
                    payload_buffer(payload_index) <= received_byte;

                    if payload_index + 1 = expected_payload_length then
                        rx_context <= CTX_POSTAMBLE;
                    else
                        payload_index <= payload_index + 1;
                        rx_context    <= CTX_PAYLOAD;
                    end if;

                    rx_state <= RX_GET_BYTE;

                when RX_POSTAMBLE =>
                    if received_byte = POSTAMBLE then
                        rx_state <= RX_EXECUTE;
                    else
                        err_rx_postamble_evt <= '1';
                        rx_state <= RX_IDLE;
                    end if;

                when RX_EXECUTE =>
                    case current_command is

                        -- Enable Constant Bias Mode
                        when "00001" =>
                            cb_mode      <= '1';
                            Bias_enabled <= '1';
                            C_bias_V0    <= cb_voltage_0;
                            C_bias_V1    <= cb_voltage_1;

                        -- Disable Constant Bias Mode
                        when "00010" =>
                            cb_mode      <= '0';
                            Bias_enabled <= '0';

                        -- Set Constant Bias Voltage
                        when "00011" =>
                            cb_probe_id <= payload_buffer(0);
                            case payload_buffer(0) is
                                when x"01" =>
                                    cb_voltage_0(15 downto 8) <= payload_buffer(1);
                                    cb_voltage_0(7 downto 0)  <= payload_buffer(2);
                                when x"02" =>
                                    cb_voltage_1(15 downto 8) <= payload_buffer(1);
                                    cb_voltage_1(7 downto 0)  <= payload_buffer(2);
                                when others =>
                                     
                            end case;

                        -- Readback Constant Bias Voltage
                        when "00100" =>
                            cb_probe_id <= payload_buffer(0);
                            case payload_buffer(0) is
                                when x"01" =>
                                    cb_voltage_tx       <= cb_voltage_0;
                                    const_volt_send_req <= '1';
                                when x"02" =>
                                    cb_voltage_tx       <= cb_voltage_1;
                                    const_volt_send_req <= '1';
                                when others =>
                                     
                            end case;

                        -- Activate Sweep mode
                        when "01010" =>
                            Sweep_enabled <= '1';
                            cb_mode       <= '0';
                            swt_sweep_cnt <= std_logic_vector(unsigned(swt_sweep_cnt) + 1);

                        -- Readback Sweep Count
                        when "01011" =>
                            swt_swp_cnt_send_req <= '1';

                        -- Set Sweep Table Steps
                        when "01100" =>
                            swt_nof_steps_i <= payload_buffer(0);

                        -- Readback Sweep Steps
                        when "01101" =>
                            swt_steps_send_req <= '1';

                        -- Set Samples per Step
                        when "01110" =>
                            swt_samples_per_step_i(15 downto 8) <= payload_buffer(0);
                            swt_samples_per_step_i(7 downto 0)  <= payload_buffer(1);

                        -- Readback Samples per Step
                        when "01111" =>
                            swt_sps_send_req <= '1';

                        -- Set Sweep Skip
                        when "10000" =>
                            swt_sample_skip_i(15 downto 8) <= payload_buffer(0);
                            swt_sample_skip_i(7 downto 0)  <= payload_buffer(1);

                        -- Readback Skip
                        when "10001" =>
                            swt_skip_send_req <= '1';

                        -- Set Samples per Point
                        when "10010" =>
                            swt_samples_per_point_i(15 downto 8) <= payload_buffer(0);
                            swt_samples_per_point_i(7 downto 0)  <= payload_buffer(1);

                        -- Readback Samples per Point
                        when "10011" =>
                            swt_spp_send_req <= '1';

                        -- Set Sweep Points
                        when "10100" =>
                            swt_points_per_step_i(15 downto 8) <= payload_buffer(0);
                            swt_points_per_step_i(7 downto 0)  <= payload_buffer(1);

                        -- Readback Sweep Points
                        when "10101" =>
                            swt_points_send_req <= '1';

                        -- Receive Sweep Table
                        when "10110" =>
                            if payload_buffer(0) = x"01" or payload_buffer(0) = x"02" then
                                swt_req_probe_id     <= payload_buffer(0);
                                swt_req_step_id      <= payload_buffer(1);
                                swt_req_wdata        <= payload_buffer(2) & payload_buffer(3);
                                swt_single_write_req <= '1';
                            end if;

                        -- Readback Sweep Table
                        when "10111" =>
                            if payload_buffer(0) = x"01" or payload_buffer(0) = x"02" then
                                swt_req_probe_id    <= payload_buffer(0);
                                swt_req_step_id     <= payload_buffer(1);
                                swt_single_read_req <= '1';
                            end if;

                        -- Macro metadata request
                        when "11010" =>
                            macro_meta1_send_req <= '1';
                            macro_meta2_send_req <= '1';

                        -- Macro sweep table request
                        when "11011" =>
                            if payload_buffer(0) = x"01" or payload_buffer(0) = x"02" then
                                mac_swt_mode <= payload_buffer(0);
                                mac_swt_start_req  <= '1';
                            end if;

                        -- Readback HK Period
                        when "11101" =>
                            HK_ID_2rb <= payload_buffer(0);
                            case payload_buffer(0) is
                                when x"01" =>
                                    T_2rb      <= acc_period_code;
                                    T_send_req <= '1';
                                when x"02" =>
                                    T_2rb      <= mag_period_code;
                                    T_send_req <= '1';
                                when x"03" =>
                                    T_2rb      <= gyro_period_code;
                                    T_send_req <= '1';
                                when x"04" =>
                                    T_2rb      <= pres_period_code;
                                    T_send_req <= '1';
                                when others =>
                                     
                            end case;

                        -- Set Periodic HK sending
                        when "11110" =>
                            v_scale := payload_buffer(1)(7 downto 6);
                            v_val   := to_integer(unsigned(payload_buffer(1)(5 downto 0)));

                            case payload_buffer(0) is
                                when x"01" =>
                                    acc_period_code <= payload_buffer(1);
                                    acc_scale_code       <= v_scale;
                                    if v_scale = "11" then
                                        acc_period <= 60 * v_val;
                                    else
                                        acc_period <= v_val;
                                    end if;
                                    acc_cnt_reset_req <= '1';

                                when x"02" =>
                                    mag_period_code <= payload_buffer(1);
                                    mag_scale_code       <= v_scale;
                                    if v_scale = "11" then
                                        mag_period <= 60 * v_val;
                                    else
                                        mag_period <= v_val;
                                    end if;
                                    mag_cnt_reset_req <= '1';

                                when x"03" =>
                                    gyro_period_code <= payload_buffer(1);
                                    gyro_scale_code       <= v_scale;
                                    if v_scale = "11" then
                                        gyro_period <= 60 * v_val;
                                    else
                                        gyro_period <= v_val;
                                    end if;
                                    gyro_cnt_reset_req <= '1';

                                when x"04" =>
                                    pres_period_code <= payload_buffer(1);
                                    pres_scale_code       <= v_scale;
                                    if v_scale = "11" then
                                        pres_period <= 60 * v_val;
                                    else
                                        pres_period <= v_val;
                                    end if;
                                    pres_cnt_reset_req <= '1';

                                when others =>
                                     
                            end case;

                        -- Readback HK Data, one-shot
                        when "11111" =>
                            case payload_buffer(0) is
                                when x"01" => acc_send_req       <= '1';
                                when x"02" => mag_send_req       <= '1';
                                when x"03" => gyro_send_req      <= '1';
                                when x"04" => pressure_send_req  <= '1';
                                when x"05" => error_cnt_send_req <= '1';
                                when x"06" => timestamp_send_req <= '1';
                                when others =>
                            end case;

                        when others =>
                            err_unknown_cmd_evt <= '1';
                    end case;

                    rx_state <= RX_IDLE;

                when others =>
                    err_fsm_illegal_state_rx_evt <= '1';
                    rx_state <= RX_IDLE;
            end case;
        end if;
    end process;



-- PERIODIC HK REQUEST GENERATOR --

    p_periodic_hk : process (clk, reset)
        variable tick_1Hz   : boolean := false;
        variable tick_4Hz   : boolean := false;
        variable tick_256Hz : boolean := false;
        variable acc_tick   : boolean := false;
        variable mag_tick   : boolean := false;
        variable gyro_tick  : boolean := false;
        variable pres_tick  : boolean := false;
    begin
        if reset /= '0' then
            old_clk_1Hz   <= '0';
            old_clk_4Hz   <= '0';
            old_clk_256Hz <= '0';

            acc_cnt  <= 0;
            mag_cnt  <= 0;
            gyro_cnt <= 0;
            pres_cnt <= 0;

            acc_periodic_send_req      <= '0';
            mag_periodic_send_req      <= '0';
            gyro_periodic_send_req     <= '0';
            pressure_periodic_send_req <= '0';

        elsif rising_edge(clk) then
            acc_periodic_send_req      <= '0';
            mag_periodic_send_req      <= '0';
            gyro_periodic_send_req     <= '0';
            pressure_periodic_send_req <= '0';

            -- rising edge detection of clocks, general ticks
            tick_1Hz   := (clk_1Hz = '1')   and (old_clk_1Hz = '0');
            tick_4Hz   := (clk_4Hz = '1')   and (old_clk_4Hz = '0');
            tick_256Hz := (clk_256Hz = '1') and (old_clk_256Hz = '0');

            old_clk_1Hz   <= clk_1Hz;
            old_clk_4Hz   <= clk_4Hz;
            old_clk_256Hz <= clk_256Hz;

            -- HK specific ticks, driven initially to default state
            acc_tick  := false;
            mag_tick  := false;
            gyro_tick := false;
            pres_tick := false;

            -- HK specific ticks matched to general ticks based on specific HK scale codes
            if acc_scale_code = "00" then
                acc_tick := tick_256Hz;
            elsif acc_scale_code = "01" then
                acc_tick := tick_4Hz;
            elsif acc_scale_code = "10" or acc_scale_code = "11" then
                acc_tick := tick_1Hz;
            end if;

            if mag_scale_code = "00" then
                mag_tick := tick_256Hz;
            elsif mag_scale_code = "01" then
                mag_tick := tick_4Hz;
            elsif mag_scale_code = "10" or mag_scale_code = "11" then
                mag_tick := tick_1Hz;
            end if;

            if gyro_scale_code = "00" then
                gyro_tick := tick_256Hz;
            elsif gyro_scale_code = "01" then
                gyro_tick := tick_4Hz;
            elsif gyro_scale_code = "10" or gyro_scale_code = "11" then
                gyro_tick := tick_1Hz;
            end if;

            if pres_scale_code = "00" then
                pres_tick := tick_256Hz;
            elsif pres_scale_code = "01" then
                pres_tick := tick_4Hz;
            elsif pres_scale_code = "10" or pres_scale_code = "11" then
                pres_tick := tick_1Hz;
            end if;

            -- reset request for HK periodic counters
            -- and generation of send request if counter reaches the period set
            if acc_cnt_reset_req = '1' then
                acc_cnt <= 0;
            elsif acc_tick then
                if acc_period = 0 then
                    acc_cnt <= 0;
                elsif acc_cnt + 1 = acc_period then
                    acc_cnt <= 0;
                    acc_periodic_send_req <= '1';
                else
                    acc_cnt <= acc_cnt + 1;
                end if;
            end if;

            if mag_cnt_reset_req = '1' then
                mag_cnt <= 0;
            elsif mag_tick then
                if mag_period = 0 then
                    mag_cnt <= 0;
                elsif mag_cnt + 1 = mag_period then
                    mag_cnt <= 0;
                    mag_periodic_send_req <= '1';
                else
                    mag_cnt <= mag_cnt + 1;
                end if;
            end if;

            if gyro_cnt_reset_req = '1' then
                gyro_cnt <= 0;
            elsif gyro_tick then
                if gyro_period = 0 then
                    gyro_cnt <= 0;
                elsif gyro_cnt + 1 = gyro_period then
                    gyro_cnt <= 0;
                    gyro_periodic_send_req <= '1';
                else
                    gyro_cnt <= gyro_cnt + 1;
                end if;
            end if;

            if pres_cnt_reset_req = '1' then
                pres_cnt <= 0;
            elsif pres_tick then
                if pres_period = 0 then
                    pres_cnt <= 0;
                elsif pres_cnt + 1 = pres_period then
                    pres_cnt <= 0;
                    pressure_periodic_send_req <= '1';
                else
                    pres_cnt <= pres_cnt + 1;
                end if;
            end if;
        end if;
    end process;



-- SWEEP TABLE ENGINE (single step read/write and Macro engine) --

    p_sweep_table_engine : process (clk, reset)
    begin
        if reset /= '0' then
            swt_wdata_i <= (others => '0');
            swt_waddr_i <= (others => '0');
            swt_raddr_i <= (others => '0');
            swt_wen0_i  <= '0';
            swt_wen1_i  <= '0';
            swt_ren_i   <= '0';

            swt_probe_id   <= (others => '0');
            swt_read_value <= (others => '0');
            swt_value_send_req <= '0';

            mac_swt_active    <= '0';
            mac_swt_tot_steps <= (others => '0');
            mac_swt_step      <= (others => '0');
            mac_swt_wait      <= 0;
            mac_swt_val0      <= (others => '0');
            mac_swt_val1      <= (others => '0');
            mac_swt_last_pkt  <= '0';

            macro_table_tx_flag  <= '0';
            swt_engine_state     <= SWT_IDLE;
            err_sweep_macro_busy_evt      <= '0';
            err_fsm_illegal_state_swt_evt <= '0';

        elsif rising_edge(clk) then
            swt_value_send_req <= '0';
            err_sweep_macro_busy_evt      <= '0';
            err_fsm_illegal_state_swt_evt <= '0';

            -- A new macro request restarts the macro transfer engine
            if mac_swt_start_req = '1' then
                if mac_swt_active = '1' or swt_engine_state /= SWT_IDLE or macro_table_tx_flag = '1' then
                    err_sweep_macro_busy_evt <= '1';
                end if;
                mac_swt_active      <= '1';
                mac_swt_step        <= (others => '0');
                mac_swt_wait        <= 0;
                macro_table_tx_flag <= '0';

                if mac_swt_mode = x"02" then
                    mac_swt_tot_steps <= x"00FF";
                else
                    mac_swt_tot_steps <= x"00" & swt_nof_steps_i;
                end if;

                swt_engine_state <= SWT_MACRO_ISSUE_READ;

            else
                if swt_engine_state /= SWT_IDLE and
                   (swt_single_read_req = '1' or swt_single_write_req = '1') then
                    err_sweep_macro_busy_evt <= '1';
                end if;

                case swt_engine_state is

                    when SWT_IDLE => -- detects if a request has been issued
                        -- single step write request performed directly
                        if swt_single_write_req = '1' then
                            swt_waddr_i <= swt_req_step_id;
                            swt_wdata_i <= swt_req_wdata;
                            swt_ren_i   <= '0';

                            if swt_req_probe_id = x"01" then
                                swt_wen0_i <= '1';
                                swt_wen1_i <= '0';
                            elsif swt_req_probe_id = x"02" then
                                swt_wen0_i <= '0';
                                swt_wen1_i <= '1';
                            end if;
                        -- single step read request jumps to READ_WAIT state
                        elsif swt_single_read_req = '1' then
                            swt_probe_id <= swt_req_probe_id;
                            swt_raddr_i  <= swt_req_step_id;
                            swt_wen0_i   <= '0';
                            swt_wen1_i   <= '0';
                            swt_ren_i    <= '1';
                            mac_swt_wait <= 0;
                            swt_engine_state <= SWT_SINGLE_READ_WAIT;
                        -- macro request (after macro trasfer engine restart) jumps to MACRO_ISSUE_READ state
                        elsif mac_swt_active = '1' then
                            swt_engine_state <= SWT_MACRO_ISSUE_READ;
                        end if;

                    when SWT_SINGLE_READ_WAIT => -- wait 3 clock cycles and jumps
                        if mac_swt_wait < 3 then
                            mac_swt_wait <= mac_swt_wait + 1;
                        else
                            mac_swt_wait <= 0;
                            swt_engine_state <= SWT_SINGLE_READ_LATCH;
                        end if;

                    when SWT_SINGLE_READ_LATCH => -- latch value and flag send_req to TX FSM
                        if swt_probe_id = x"01" then
                            swt_read_value <= swt_rdata0;
                        elsif swt_probe_id = x"02" then
                            swt_read_value <= swt_rdata1;
                        end if;

                        swt_value_send_req <= '1';
                        swt_engine_state <= SWT_IDLE;

                    when SWT_MACRO_ISSUE_READ =>
                        swt_raddr_i <= mac_swt_step;
                        swt_ren_i   <= '1';
                        mac_swt_wait <= 0;
                        swt_engine_state <= SWT_MACRO_WAIT_READ;

                    when SWT_MACRO_WAIT_READ =>
                        swt_ren_i <= '0';

                        if mac_swt_wait < 3 then
                            mac_swt_wait <= mac_swt_wait + 1;
                        else
                            mac_swt_wait <= 0;
                            mac_swt_val0 <= swt_rdata0;
                            mac_swt_val1 <= swt_rdata1;

                            if (x"00" & mac_swt_step) >= mac_swt_tot_steps then
                                mac_swt_last_pkt <= '1';
                            else
                                mac_swt_last_pkt <= '0';
                            end if;

                            swt_engine_state <= SWT_MACRO_REQUEST_TX;
                        end if;

                    when SWT_MACRO_REQUEST_TX =>
                        if macro_table_tx_flag = '0' then
                            macro_table_tx_flag <= '1';
                            swt_engine_state <= SWT_MACRO_WAIT_TX_ACCEPT;
                        end if;

                    when SWT_MACRO_WAIT_TX_ACCEPT =>
                        if  macro_table_tx_ack = '1' then
                             macro_table_tx_flag <= '0';

                            if mac_swt_last_pkt = '1' then
                                mac_swt_active <= '0';
                                swt_engine_state <= SWT_IDLE;
                            else
                                mac_swt_step <= mac_swt_step + 1;
                                swt_engine_state <= SWT_MACRO_ISSUE_READ;
                            end if;
                        end if;

                    when others =>
                        err_fsm_illegal_state_swt_evt <= '1';
                        macro_table_tx_flag <= '0';
                        swt_engine_state <= SWT_IDLE;
                end case;
            end if;
        end if;
    end process;


-- TX FSM --
    
    p_tx_manager : process (clk, reset)
    begin
        if reset /= '0' then
            uart_tx_byte <= (others => '0');
            uart_tx_start  <= '0';

            tx_state   <= TX_IDLE;
            start_tx      <= '0';
            tx_byte_index <= 0;
            msg_2send     <= (others => (others => '0'));

            acc_tx_flag         <= '0';
            mag_tx_flag         <= '0';
            gyro_tx_flag        <= '0';
            pressure_tx_flag    <= '0';
            timestamp_tx_flag   <= '0';
            T_tx_flag           <= '0';
            const_volt_tx_flag  <= '0';
            swt_swp_cnt_tx_flag <= '0';
            swt_steps_tx_flag   <= '0';
            swt_sps_tx_flag     <= '0';
            swt_skip_tx_flag    <= '0';
            swt_spp_tx_flag     <= '0';
            swt_points_tx_flag  <= '0';
            swt_value_tx_flag   <= '0';
            sc_data_tx_flag     <= '0';
            macro_meta1_tx_flag <= '0';
            macro_meta2_tx_flag <= '0';
            error_cnt_tx_flag   <= '0';

            err_sc_cb_overrun_evt        <= '0';
            err_periodic_hk_overrun_evt  <= '0';
            err_readback_overrun_evt     <= '0';
            err_fsm_illegal_state_tx_evt <= '0';

            acc_tx_periodic_flag      <= '0';
            mag_tx_periodic_flag      <= '0';
            gyro_tx_periodic_flag     <= '0';
            pressure_tx_periodic_flag <= '0';

            macro_table_tx_ack <= '0';

        elsif rising_edge(clk) then
             macro_table_tx_ack <= '0';
             err_sc_cb_overrun_evt        <= '0';
             err_periodic_hk_overrun_evt  <= '0';
             err_readback_overrun_evt     <= '0';
             err_fsm_illegal_state_tx_evt <= '0';

            -- error overrun detection --
            if cb_mode = '1' and sc_new = '1' and sc_data_tx_flag = '1' then
                err_sc_cb_overrun_evt <= '1';
            end if;
            if (acc_periodic_send_req = '1' and (acc_tx_periodic_flag = '1' or acc_tx_flag = '1')) or
               (mag_periodic_send_req = '1' and (mag_tx_periodic_flag = '1' or mag_tx_flag = '1')) or
               (gyro_periodic_send_req = '1' and (gyro_tx_periodic_flag = '1' or gyro_tx_flag = '1')) or
               (pressure_periodic_send_req = '1' and (pressure_tx_periodic_flag = '1' or pressure_tx_flag = '1')) then
                err_periodic_hk_overrun_evt <= '1';
            end if;
            if (acc_send_req = '1' and (acc_tx_flag = '1' or acc_tx_periodic_flag = '1')) or
               (mag_send_req = '1' and (mag_tx_flag = '1' or mag_tx_periodic_flag = '1')) or
               (gyro_send_req = '1' and (gyro_tx_flag = '1' or gyro_tx_periodic_flag = '1')) or
               (pressure_send_req = '1' and (pressure_tx_flag = '1' or pressure_tx_periodic_flag = '1')) or
               (T_send_req = '1' and T_tx_flag = '1') or
               (timestamp_send_req = '1' and timestamp_tx_flag = '1') or
               (const_volt_send_req = '1' and const_volt_tx_flag = '1') or
               (swt_swp_cnt_send_req = '1' and swt_swp_cnt_tx_flag = '1') or
               (swt_steps_send_req = '1' and swt_steps_tx_flag = '1') or
               (swt_sps_send_req = '1' and swt_sps_tx_flag = '1') or
               (swt_skip_send_req = '1' and swt_skip_tx_flag = '1') or
               (swt_spp_send_req = '1' and swt_spp_tx_flag = '1') or
               (swt_points_send_req = '1' and swt_points_tx_flag = '1') or
               (swt_value_send_req = '1' and swt_value_tx_flag = '1') or
               (macro_meta1_send_req = '1' and macro_meta1_tx_flag = '1') or
               (macro_meta2_send_req = '1' and macro_meta2_tx_flag = '1') or
               (error_cnt_send_req = '1' and error_cnt_tx_flag = '1') then
                err_readback_overrun_evt <= '1';
            end if;

            -- Convert one-clock request strobes from RX FSM into pending TX flags
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
            if timestamp_send_req = '1' then
                timestamp_tx_flag <= '1';
            end if;
            if T_send_req = '1' then
                T_tx_flag <= '1';
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
            if swt_value_send_req = '1' then
                swt_value_tx_flag <= '1';
            end if;
            if macro_meta1_send_req = '1' then
                macro_meta1_tx_flag <= '1';
            end if;
            if macro_meta2_send_req = '1' then
                macro_meta2_tx_flag <= '1';
            end if;
            if error_cnt_send_req = '1' then
                error_cnt_tx_flag <= '1';
            end if;

            if acc_periodic_send_req = '1' then
                acc_tx_periodic_flag <= '1';
            end if;
            if mag_periodic_send_req = '1' then
                mag_tx_periodic_flag <= '1';
            end if;
            if gyro_periodic_send_req = '1' then
                gyro_tx_periodic_flag <= '1';
            end if;
            if pressure_periodic_send_req = '1' then
                pressure_tx_periodic_flag <= '1';
            end if;

            if cb_mode = '1' and sc_new = '1' then
                sc_data_tx_flag <= '1';
            end if;


            -- packet selector: builds general packet msg_2send based on pending TX flags
            if tx_state = TX_IDLE and start_tx = '0' then

                if sc_data_tx_flag = '1' then
                    msg_2send <= vector_2array(PREAMBLE_1 & PREAMBLE_2 & x"09" & sc_data & POSTAMBLE);
                    sc_data_tx_flag <= '0';
                    start_tx <= '1';

                elsif const_volt_tx_flag = '1' then
                    msg_2send <= vector_2array(PREAMBLE_1 & PREAMBLE_2 & "00100" & "001" & cb_probe_id & cb_voltage_tx & (39 downto 0 => '0') & POSTAMBLE);
                    const_volt_tx_flag <= '0';
                    start_tx <= '1';

                elsif acc_tx_flag = '1' or acc_tx_periodic_flag = '1' then
                    msg_2send <= vector_2array(PREAMBLE_1 & PREAMBLE_2 & "11111" & "001" & acc_packet & POSTAMBLE);
                    acc_tx_flag <= '0';
                    acc_tx_periodic_flag <= '0';
                    start_tx <= '1';

                elsif mag_tx_flag = '1' or mag_tx_periodic_flag = '1' then
                    msg_2send <= vector_2array(PREAMBLE_1 & PREAMBLE_2 & "11111" & "001" & mag_packet & POSTAMBLE);
                    mag_tx_flag <= '0';
                    mag_tx_periodic_flag <= '0';
                    start_tx <= '1';

                elsif gyro_tx_flag = '1' or gyro_tx_periodic_flag = '1' then
                    msg_2send <= vector_2array(PREAMBLE_1 & PREAMBLE_2 & "11111" & "001" & gyro_packet & POSTAMBLE);
                    gyro_tx_flag <= '0';
                    gyro_tx_periodic_flag <= '0';
                    start_tx <= '1';

                elsif pressure_tx_flag = '1' or pressure_tx_periodic_flag = '1' then
                    msg_2send <= vector_2array(PREAMBLE_1 & PREAMBLE_2 & "11111" & "001" & pressure_packet & POSTAMBLE);
                    pressure_tx_flag <= '0';
                    pressure_tx_periodic_flag <= '0';
                    start_tx <= '1';

                elsif error_cnt_tx_flag = '1' then
                    msg_2send <= vector_2array(PREAMBLE_1 & PREAMBLE_2 & "11111" & "001" & x"05" & hk_error_cnt_packet & POSTAMBLE);
                    error_cnt_tx_flag <= '0';
                    start_tx <= '1';

                elsif timestamp_tx_flag = '1' then
                    msg_2send <= vector_2array(PREAMBLE_1 & PREAMBLE_2 & "11111" & "001" & x"06" & timestamp_packet & POSTAMBLE);
                    timestamp_tx_flag <= '0';
                    start_tx <= '1';

                elsif T_tx_flag = '1' then
                    msg_2send <= vector_2array(PREAMBLE_1 & PREAMBLE_2 & "11111" & "001" & HK_ID_2rb & T_2rb & (47 downto 0 => '0') & POSTAMBLE);
                    T_tx_flag <= '0';
                    start_tx <= '1';

                elsif swt_swp_cnt_tx_flag = '1' then
                    msg_2send <= vector_2array(PREAMBLE_1 & PREAMBLE_2 & "01011" & "000" & swt_sweep_cnt(15 downto 8) & swt_sweep_cnt(7 downto 0) & (47 downto 0 => '0') & POSTAMBLE);
                    swt_swp_cnt_tx_flag <= '0';
                    start_tx <= '1';

                elsif swt_steps_tx_flag = '1' then
                    msg_2send <= vector_2array(PREAMBLE_1 & PREAMBLE_2 & "01101" & "000" & swt_nof_steps_i & (55 downto 0 => '0') & POSTAMBLE);
                    swt_steps_tx_flag <= '0';
                    start_tx <= '1';

                elsif swt_sps_tx_flag = '1' then
                    msg_2send <= vector_2array(PREAMBLE_1 & PREAMBLE_2 & "01111" & "000" & swt_samples_per_step_i(15 downto 8) & swt_samples_per_step_i(7 downto 0) & (47 downto 0 => '0') & POSTAMBLE);
                    swt_sps_tx_flag <= '0';
                    start_tx <= '1';

                elsif swt_skip_tx_flag = '1' then
                    msg_2send <= vector_2array(PREAMBLE_1 & PREAMBLE_2 & "10001" & "000" & swt_sample_skip_i(15 downto 8) & swt_sample_skip_i(7 downto 0) & (47 downto 0 => '0') & POSTAMBLE);
                    swt_skip_tx_flag <= '0';
                    start_tx <= '1';

                elsif swt_spp_tx_flag = '1' then
                    msg_2send <= vector_2array(PREAMBLE_1 & PREAMBLE_2 & "10011" & "000" & swt_samples_per_point_i(15 downto 8) & swt_samples_per_point_i(7 downto 0) & (47 downto 0 => '0') & POSTAMBLE);
                    swt_spp_tx_flag <= '0';
                    start_tx <= '1';

                elsif swt_points_tx_flag = '1' then
                    msg_2send <= vector_2array(PREAMBLE_1 & PREAMBLE_2 & "10101" & "000" & swt_points_per_step_i(15 downto 8) & swt_points_per_step_i(7 downto 0) & (47 downto 0 => '0') & POSTAMBLE);
                    swt_points_tx_flag <= '0';
                    start_tx <= '1';

                elsif swt_value_tx_flag = '1' then
                    msg_2send <= vector_2array(PREAMBLE_1 & PREAMBLE_2 & "10111" & "010" & swt_probe_id & swt_raddr_i & swt_read_value(15 downto 8) & swt_read_value(7 downto 0) & (31 downto 0 => '0') & POSTAMBLE);
                    swt_value_tx_flag <= '0';
                    start_tx <= '1';

                elsif macro_meta1_tx_flag = '1' then
                    msg_2send <= vector_2array(PREAMBLE_1 & PREAMBLE_2 & "11010" & "000" &
                                               swt_sweep_cnt(15 downto 8) & swt_sweep_cnt(7 downto 0) &
                                               swt_nof_steps_i &
                                               swt_samples_per_step_i(15 downto 8) & swt_samples_per_step_i(7 downto 0) &
                                               (23 downto 0 => '0') & POSTAMBLE);
                    macro_meta1_tx_flag <= '0';
                    start_tx <= '1';

                elsif macro_meta2_tx_flag = '1' then
                    msg_2send <= vector_2array(PREAMBLE_1 & PREAMBLE_2 & "11010" & "000" &
                                               swt_sample_skip_i(15 downto 8) & swt_sample_skip_i(7 downto 0) &
                                               swt_samples_per_point_i(15 downto 8) & swt_samples_per_point_i(7 downto 0) &
                                               swt_points_per_step_i(15 downto 8) & swt_points_per_step_i(7 downto 0) &
                                               (15 downto 0 => '0') & POSTAMBLE);
                    macro_meta2_tx_flag <= '0';
                    start_tx <= '1';

                elsif  macro_table_tx_flag = '1' then
                    if mac_swt_last_pkt = '1' then
                        msg_2send <= vector_2array(PREAMBLE_1 & PREAMBLE_2 & "11011" & "001" &
                                                   mac_swt_step &
                                                   mac_swt_val0(15 downto 8) & mac_swt_val0(7 downto 0) &
                                                   mac_swt_val1(15 downto 8) & mac_swt_val1(7 downto 0) &
                                                   MACRO_PKT_END_SIG & POSTAMBLE);
                    else
                        msg_2send <= vector_2array(PREAMBLE_1 & PREAMBLE_2 & "11011" & "001" &
                                                   mac_swt_step &
                                                   mac_swt_val0(15 downto 8) & mac_swt_val0(7 downto 0) &
                                                   mac_swt_val1(15 downto 8) & mac_swt_val1(7 downto 0) &
                                                   (23 downto 0 => '0') & POSTAMBLE);
                    end if;

                     macro_table_tx_ack <= '1';
                    start_tx <= '1';
                end if;
            end if;


            -- FSM for sending byte to byte via UART
            case tx_state is
                when TX_IDLE =>
                    uart_tx_start <= '0';
                    if start_tx = '1' then
                        tx_byte_index <= 0;
                        tx_state      <= TX_SEND_BYTE;
                        start_tx      <= '0';
                    end if;

                when TX_SEND_BYTE =>
                    if uart_tx_ready = '1' then
                        uart_tx_byte    <= msg_2send(tx_byte_index);
                        uart_tx_start   <= '1';
                        tx_state        <= TX_WAIT_RDY;
                    end if;

                when TX_WAIT_RDY =>
                    if uart_tx_ready = '0' then
                        uart_tx_start <= '0';
                        if tx_byte_index < 11 then
                            tx_byte_index <= tx_byte_index + 1;
                            tx_state      <= TX_SEND_BYTE;
                        else
                            tx_state      <= TX_IDLE;
                        end if;
                    end if;

                when others =>
                    err_fsm_illegal_state_tx_evt <= '1';
                    uart_tx_start <= '0';
                    tx_byte_index <= 0;
                    tx_state      <= TX_IDLE;
            end case;
        end if;
    end process;

end architecture_General_Controller;
