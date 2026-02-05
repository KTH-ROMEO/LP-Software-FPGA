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
    
    uc_recv   : IN std_logic_vector(7 downto 0);
    uc_tx_rdy : IN std_logic;
    uc_rx_rdy : IN std_logic;

    st_rdata0  : IN std_logic_vector(15 downto 0);
    st_rdata1  : IN std_logic_vector(15 downto 0);

    acc_packet      : IN std_logic_vector(63 downto 0);
    mag_packet      : IN std_logic_vector(63 downto 0);
    gyro_packet     : IN std_logic_vector(63 downto 0);
    pressure_packet : IN std_logic_vector(63 downto 0);

    sc_bias_new     : IN std_logic;
    sc_bias_data    : IN std_logic_vector(63 downto 0);

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


    en_sensors : OUT std_logic;
    en_data_saving : OUT std_logic;

    led1 : OUT std_logic;
    led2 : OUT std_logic;


    exp_adc_reset : OUT std_logic;
    

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

    type payload_array_type is array (0 to 3) of std_logic_vector(7 downto 0); 
    type rx_context_type    is (CTX_PREAMBLE, CTX_COMMAND, CTX_PAYLOAD, CTX_POSTAMBLE); -- Context for wait state in RX FSM
    type byte_array_type    is array(0 to 11) of std_logic_vector(7 downto 0); 
    subtype sec_t           is natural range 0 to 255;



    -- SCIENCE DATA
    signal constant_bias_mode         : std_logic;
    signal constant_bias_voltage_0    : std_logic_vector(15 downto 0);
    signal constant_bias_voltage_1    : std_logic_vector(15 downto 0);
    signal constant_bias_probe_id     : std_logic_vector(7 downto 0); 
    signal sweep_table_probe_id       : std_logic_vector(7 downto 0);
    signal sweep_table_activate_sweep : std_logic; 
    signal sweep_table_sweep_cnt      : std_logic_vector(15 downto 0); -- Number of activated sweeps since last FPGA power on.
    signal sweep_table_read_value     : std_logic_vector(15 downto 0);
    signal old_sc_bias_new            : std_logic := '0';
    signal sc_bias_new_rise           : std_logic := '0';


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
    
    signal long_command_active     : std_logic := '0';
    signal swt_wr_substate         : integer range 0 to 2 := 0;
    signal sweep_table_write_wait  : integer range 0 to 3;
    signal swt_rd_substate         : integer range 0 to 2 := 0;
    signal sweep_table_read_wait   : integer range 0 to 3;
    
    signal acc_send_req            : std_logic := '0';
    signal mag_send_req            : std_logic := '0';
    signal gyro_send_req           : std_logic := '0';
    signal pressure_send_req       : std_logic := '0';
    signal T_send_req              : std_logic := '0';
    signal const_volt_send_req     : std_logic := '0';
    signal swt_swp_cnt_send_req    : std_logic := '0';
    signal swt_steps_send_req      : std_logic := '0';
    signal swt_sps_send_req        : std_logic := '0';
    signal swt_skip_send_req       : std_logic := '0';
    signal swt_spp_send_req        : std_logic := '0';
    signal swt_points_send_req     : std_logic := '0';
    signal swt_value_send_req      : std_logic := '0';
    
    constant POSTAMBLE  : std_logic_vector(7 downto 0) := x"0A";
    constant PREAMBLE_1 : std_logic_vector(7 downto 0) := x"B5";
    constant PREAMBLE_2 : std_logic_vector(7 downto 0) := x"43";



    -- TX FSM
    signal uc_tx_state    : uc_tx_state_type;
    signal msg_2send      : byte_array_type := (others => (others => '0'));
    signal start_tx       : std_logic := '0';
    signal tx_byte_index  : integer range 0 to 11 := 0;

    signal constant_bias_voltage_tx  : std_logic_vector(15 downto 0);

    signal acc_tx_flag            : std_logic := '0';
    signal mag_tx_flag            : std_logic := '0';
    signal gyro_tx_flag           : std_logic := '0';
    signal pressure_tx_flag       : std_logic := '0';
    signal T_tx_flag              : std_logic := '0';
    signal const_volt_tx_flag     : std_logic := '0';
    signal swt_swp_cnt_tx_flag    : std_logic := '0';
    signal swt_steps_tx_flag      : std_logic := '0';
    signal swt_sps_tx_flag        : std_logic := '0';
    signal swt_skip_tx_flag       : std_logic := '0';
    signal swt_spp_tx_flag        : std_logic := '0';
    signal swt_points_tx_flag     : std_logic := '0';
    signal sc_bias_data_tx_flag   : std_logic := '0';
    signal swt_value_tx_flag      : std_logic := '0';



    -- PERIODIC TX
    signal old_clk_256Hz   : std_logic;

    signal acc_tx_periodic_flag       : std_logic := '0';
    signal mag_tx_periodic_flag       : std_logic := '0';
    signal gyro_tx_periodic_flag      : std_logic := '0';
    signal pressure_tx_periodic_flag  : std_logic := '0';

    signal acc_period_s     : sec_t := 0;
    signal mag_period_s     : sec_t := 0;
    signal gyro_period_s    : sec_t := 0;
    signal pres_period_s    : sec_t := 0;
    signal acc_cnt_s        : sec_t := 0;
    signal mag_cnt_s        : sec_t := 0;
    signal gyro_cnt_s       : sec_t := 0;
    signal pres_cnt_s       : sec_t := 0;
    signal acc_scale        : std_logic_vector(1 downto 0);
    signal mag_scale        : std_logic_vector(1 downto 0);
    signal gyro_scale       : std_logic_vector(1 downto 0);
    signal pres_scale       : std_logic_vector(1 downto 0);
    signal acc_period_code  : std_logic_vector(7 downto 0);
    signal mag_period_code  : std_logic_vector(7 downto 0);
    signal gyro_period_code : std_logic_vector(7 downto 0);
    signal pres_period_code : std_logic_vector(7 downto 0);
    signal T_2rb            : std_logic_vector(7 downto 0);
    signal HK_ID_2rb        : std_logic_vector(7 downto 0);

    constant T_HK_MIN : integer := 1; -- 256Hz as implemented now


   
   -- seconds counter 
    signal state_seconds : std_logic_vector(19 downto 0);
    signal old_clk_1Hz : std_logic;
    signal old_clk_4Hz : std_logic;



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

        variable v_scale : std_logic_vector(1 downto 0):= (others => '0');
        variable v_val : integer := 0;
        variable tick_1Hz    : boolean := false;
        variable tick_4Hz    : boolean := false;
        variable tick_256Hz  : boolean := false;
        variable acc_tick    : boolean := false;
        variable mag_tick    : boolean := false;
        variable gyro_tick   : boolean := false;
        variable pres_tick   : boolean := false;

    begin
        if reset /= '0' then
       

            led1 <= '0';
            led2 <= '0';

            uc_send <= (others => '0');
            uc_wen <= '0';
            uc_oen <= '0';

            -- always activated for now
            en_sensors <= '1';   
            en_data_saving <= '1';
            -- maybe adc reset to implement in the future
            exp_adc_reset <= '0';
            
            old_clk_1Hz <= '0';
            old_clk_4Hz <= '0';

            state_seconds <= (others => '0');



            -- SCIENCE DATA
            Sweep_enabled       <= '0';
            Bias_enabled        <= '0';
            constant_bias_mode  <= '0';
            sc_bias_new_rise    <= '0';
            old_sc_bias_new       <= '0';

            constant_bias_voltage_0   <= (others => '0');
            constant_bias_voltage_1   <= (others => '0');
            constant_bias_voltage_tx  <= (others => '0');
            constant_bias_probe_id    <= (others => '0');

            sweep_table_probe_id           <= (others => '0');
            sweep_table_activate_sweep     <= '0';
            sweep_table_sweep_cnt          <= (others => '0');
            sweep_table_nof_steps          <= (others => '0');
            sweep_table_sample_skip        <= (others => '0');
            sweep_table_samples_per_point  <= (others => '0');
            sweep_table_points             <= (others => '0');

            st_wdata <= (others => '0');
            st_waddr <= (others => '0');
            st_raddr <= (others => '0');
            st_wen0  <= '0';
            st_wen1  <= '0';
            st_ren0  <= '0';
            st_ren1  <= '0';



            -- PERIODIC
            old_clk_256Hz             <= '0'; -- 1Hz counter



            -- RX FSM
            uc_rx_state              <= RX_IDLE;
            rx_context               <= CTX_PREAMBLE;
            preamble_counter         <= 0;
            command_byte             <= (others => '0');
            current_command          <= (others => '0');
            payload_index            <= 0;
            expected_payload_length  <= 0;
            for i in 0 to 3 loop
                payload_buffer(i)    <= (others => '0');
            end loop;
            long_command_active      <= '0';
            swt_rd_substate          <= 0;
            swt_wr_substate          <= 0;
            sweep_table_write_wait   <= 0;
            sweep_table_read_wait    <= 0;



            -- TX FSM
            uc_tx_state    <= TX_IDLE;
            start_tx       <= '0';
            tx_byte_index  <= 0;
            msg_2send      <= (others => (others => '0'));

            acc_send_req            <= '0';
            mag_send_req            <= '0';
            gyro_send_req           <= '0';
            pressure_send_req       <= '0';
            T_send_req              <= '0';
            const_volt_send_req     <= '0';
            swt_swp_cnt_send_req    <= '0';
            swt_steps_send_req      <= '0';
            swt_sps_send_req        <= '0';
            swt_skip_send_req       <= '0';
            swt_spp_send_req        <= '0';
            swt_points_send_req     <= '0';
            swt_value_send_req      <= '0';

            acc_tx_flag                <= '0';
            mag_tx_flag                <= '0';
            gyro_tx_flag               <= '0';
            pressure_tx_flag           <= '0';
            T_tx_flag                  <= '0';
            const_volt_tx_flag         <= '0';
            sc_bias_data_tx_flag       <= '0';
            swt_swp_cnt_tx_flag        <= '0';
            swt_steps_tx_flag          <= '0';
            swt_sps_tx_flag            <= '0';
            swt_skip_tx_flag           <= '0';
            swt_spp_tx_flag            <= '0';
            swt_points_tx_flag         <= '0';
            swt_value_tx_flag          <= '0';
            acc_tx_periodic_flag       <= '0';
            mag_tx_periodic_flag       <= '0';
            gyro_tx_periodic_flag      <= '0';
            pressure_tx_periodic_flag  <= '0';
            acc_period_s               <= 0;
            mag_period_s               <= 0;
            gyro_period_s              <= 0;
            pres_period_s              <= 0;
            acc_cnt_s                  <= 0;
            mag_cnt_s                  <= 0;
            gyro_cnt_s                 <= 0;
            pres_cnt_s                 <= 0;
            acc_period_code            <= (others => '0');
            mag_period_code            <= (others => '0');
            gyro_period_code           <= (others => '0');
            pres_period_code           <= (others => '0');
            T_2rb                      <= (others => '0');
            HK_ID_2rb                  <= (others => '0');


        elsif rising_edge(clk) then


-- TX FSM --


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
            if (constant_bias_mode = '1') and (sc_bias_new_rise = '1') then
                sc_bias_data_tx_flag <= '1';
            end if;
            if swt_value_send_req = '1' then
                swt_value_tx_flag <= '1';
            end if;


            -- Handle TX flags, building packet to send --
            if uc_tx_state = TX_IDLE and start_tx = '0' then -- TODO: decide wether to use start_tx as a variable for not losing clock cycles

                -- TESTING PACKETS for RESYNC in MUC
                -- ACC
                --  x"00" & PREAMBLE_1 & PREAMBLE_2 &"11111"&"001"& acc_packet
                -- MAG
                -- POSTAMBLE & x"000000" & PREAMBLE_1 & PREAMBLE_2 &"11111"&"001"& mag_packet(63 downto 24)
                -- GYRO
                -- mag_packet(23 downto 0) & POSTAMBLE & (63 downto 0 => '0')
                -- T_tx
                -- (95 downto 8 => '0') & PREAMBLE_1
                -- PRESS
                -- PREAMBLE_2 &"11111"&"001"& pressure_packet & POSTAMBLE & x"00"

                if sc_bias_data_tx_flag = '1' then
                    msg_2send <= vector_2array(PREAMBLE_1 & PREAMBLE_2 & x"09"& sc_bias_data & POSTAMBLE);
                    sc_bias_data_tx_flag <= '0';
                    start_tx <= '1';
                
                elsif const_volt_tx_flag = '1' then
                    msg_2send <= vector_2array(PREAMBLE_1 & PREAMBLE_2 &"00100"&"001"& constant_bias_probe_id & constant_bias_voltage_tx & (39 downto 0 => '0') & POSTAMBLE);
                    const_volt_tx_flag <= '0';
                    start_tx <= '1'; 

                elsif (acc_tx_flag = '1') or (acc_tx_periodic_flag = '1') then
                    msg_2send <= vector_2array(PREAMBLE_1 & PREAMBLE_2 &"11111"&"001"& acc_packet & POSTAMBLE);
                    acc_tx_periodic_flag <= '0';
                    acc_tx_flag <= '0';
                    start_tx <= '1';                    

                elsif (mag_tx_flag = '1') or (mag_tx_periodic_flag = '1') then
                    msg_2send <= vector_2array(PREAMBLE_1 & PREAMBLE_2 &"11111"&"001"& mag_packet & POSTAMBLE);
                    mag_tx_periodic_flag <= '0';
                    mag_tx_flag <= '0';
                    start_tx <= '1'; 

                elsif (gyro_tx_flag = '1') or (gyro_tx_periodic_flag = '1') then
                    msg_2send <= vector_2array(PREAMBLE_1 & PREAMBLE_2 &"11111"&"001"& gyro_packet & POSTAMBLE);
                    gyro_tx_periodic_flag <= '0';
                    gyro_tx_flag <= '0';
                    start_tx <= '1';

                elsif (pressure_tx_flag = '1') or (pressure_tx_periodic_flag = '1') then
                    msg_2send <= vector_2array(PREAMBLE_1 & PREAMBLE_2 &"11111"&"001"& pressure_packet & POSTAMBLE);
                    pressure_tx_periodic_flag <= '0';
                    pressure_tx_flag <= '0';
                    start_tx <= '1';

                elsif (T_tx_flag = '1') then
                    msg_2send <= vector_2array(PREAMBLE_1 & PREAMBLE_2 &"11111"&"001"& HK_ID_2rb & T_2rb & (47 downto 0 => '0') & POSTAMBLE);
                    T_tx_flag <= '0';
                    start_tx <= '1';

                elsif swt_swp_cnt_tx_flag = '1' then
                    msg_2send <= vector_2array(PREAMBLE_1 & PREAMBLE_2 &"01011"&"000"& sweep_table_sweep_cnt(15 downto 8)& sweep_table_sweep_cnt(7 downto 0)&(47 downto 0 => '0') & POSTAMBLE);
                    swt_swp_cnt_tx_flag <= '0';
                    start_tx <= '1';

                elsif swt_steps_tx_flag = '1' then
                    msg_2send <= vector_2array(PREAMBLE_1 & PREAMBLE_2 &"01101"&"000"& sweep_table_nof_steps &(55 downto 0 => '0') & POSTAMBLE);
                    swt_steps_tx_flag <= '0';
                    start_tx <= '1';

                elsif swt_sps_tx_flag = '1' then
                    msg_2send <= vector_2array(PREAMBLE_1 & PREAMBLE_2 &"01111"&"000"& sweep_table_samples_per_step(15 downto 8)& sweep_table_samples_per_step(7 downto 0)&(47 downto 0 => '0') & POSTAMBLE);
                    swt_sps_tx_flag <= '0';
                    start_tx <= '1';

                elsif swt_skip_tx_flag = '1' then
                    msg_2send <= vector_2array(PREAMBLE_1 & PREAMBLE_2 &"10001"&"000"& sweep_table_sample_skip(15 downto 8)& sweep_table_sample_skip(7 downto 0)&(47 downto 0 => '0') & POSTAMBLE);
                    swt_skip_tx_flag <= '0';
                    start_tx <= '1';

                elsif swt_spp_tx_flag = '1' then
                    msg_2send <= vector_2array(PREAMBLE_1 & PREAMBLE_2 &"10011"&"000"& sweep_table_samples_per_point(15 downto 8)& sweep_table_samples_per_point(7 downto 0)&(47 downto 0 => '0') & POSTAMBLE);
                    swt_spp_tx_flag <= '0';
                    start_tx <= '1';

                elsif swt_points_tx_flag = '1' then
                    msg_2send <= vector_2array(PREAMBLE_1 & PREAMBLE_2 &"10101"&"000"& sweep_table_points(15 downto 8)& sweep_table_points(7 downto 0)&(47 downto 0 => '0') & POSTAMBLE);
                    swt_points_tx_flag <= '0';
                    start_tx <= '1';

                elsif swt_value_tx_flag = '1' then
                    msg_2send <= vector_2array(PREAMBLE_1 & PREAMBLE_2 &"10111"&"010"& sweep_table_probe_id & st_raddr & sweep_table_read_value(15 downto 8)& sweep_table_read_value(7 downto 0)&(31 downto 0 => '0') & POSTAMBLE);
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


-- PERIODIC FLAGS --



            -- edge detect on clocks and tick calculation
            old_clk_1Hz   <= clk_1Hz;
            old_clk_4Hz   <= clk_4Hz;
            old_clk_256Hz <= clk_256Hz;
            tick_1Hz   := (clk_1Hz = '1')   and (old_clk_1Hz = '0');
            tick_4Hz   := (clk_4Hz = '1')   and (old_clk_4Hz = '0');
            tick_256Hz := (clk_256Hz = '1') and (old_clk_256Hz = '0');

            old_sc_bias_new <= sc_bias_new;
            sc_bias_new_rise <= '1' when (sc_bias_new = '1' and old_sc_bias_new = '0') else '0';


            -- scale selection for each sensor --
            -- ACC
            if acc_scale = "00" then
                acc_tick := tick_256Hz;
            elsif acc_scale = "01" then
                acc_tick := tick_4Hz;
            elsif acc_scale = "10" or acc_scale = "11" then
                acc_tick := tick_1Hz;
            end if;

            -- MAG
            if mag_scale = "00" then
                mag_tick := tick_256Hz;
            elsif mag_scale = "01" then
                mag_tick := tick_4Hz;
            elsif mag_scale = "10" or mag_scale = "11" then
                mag_tick := tick_1Hz;
            end if;

            -- GYRO
            if gyro_scale = "00" then
                gyro_tick := tick_256Hz;
            elsif gyro_scale = "01" then
                gyro_tick := tick_4Hz;
            elsif gyro_scale = "10" or gyro_scale = "11" then
                gyro_tick := tick_1Hz;
            end if;

            -- PRESSURE
            if pres_scale = "00" then
                pres_tick := tick_256Hz;
            elsif pres_scale = "01" then
                pres_tick := tick_4Hz;
            elsif pres_scale = "10" or pres_scale = "11" then
                pres_tick := tick_1Hz;
            end if;


            -- sensors periodic flags logic
            -- ACC
            if acc_tick then
                if acc_period_s = 0 then
                    acc_cnt_s <= 0;
                else
                    if (acc_cnt_s + 1 = acc_period_s) then
                        acc_cnt_s <= 0;
                        acc_tx_periodic_flag <= '1';
                    else
                        acc_cnt_s <= acc_cnt_s + 1;
                    end if;
                end if;
            end if;

            -- MAG
            if mag_tick then
                if mag_period_s = 0 then
                    mag_cnt_s <= 0;
                else
                    if (mag_cnt_s + 1 = mag_period_s) then
                        mag_cnt_s <= 0;
                        mag_tx_periodic_flag <= '1';
                    else
                        mag_cnt_s <= mag_cnt_s + 1;
                    end if;
                end if;
            end if;

            -- GYRO
            if gyro_tick then
                if gyro_period_s = 0 then
                    gyro_cnt_s <= 0;
                else
                    if (gyro_cnt_s + 1 = gyro_period_s) then
                        gyro_cnt_s <= 0;
                        gyro_tx_periodic_flag <= '1';
                    else
                        gyro_cnt_s <= gyro_cnt_s + 1;
                    end if;
                end if;
            end if;

            -- PRESSURE
            if pres_tick then
                if pres_period_s = 0 then
                    pres_cnt_s <= 0;
                else
                    if (pres_cnt_s + 1 = pres_period_s) then
                        pres_cnt_s <= 0;
                        pressure_tx_periodic_flag <= '1';
                    else
                        pres_cnt_s <= pres_cnt_s + 1;
                    end if;
                end if;
            end if;
        

-- RX FSM --

            case uc_rx_state is

                when RX_IDLE =>   -- TODO: "idle state" not really needed

                    -- strobes --
                    Sweep_enabled              <= '0'; -- set to 1 in command 01010
                    sweep_table_activate_sweep <= '0';  -- set to 1 in command 01010
                    acc_send_req               <= '0';
                    mag_send_req               <= '0';
                    gyro_send_req              <= '0';
                    pressure_send_req          <= '0';
                    T_send_req                 <= '0';
                    const_volt_send_req        <= '0';
                    swt_swp_cnt_send_req       <= '0';
                    swt_steps_send_req         <= '0';
                    swt_sps_send_req           <= '0';
                    swt_skip_send_req          <= '0';
                    swt_spp_send_req           <= '0';
                    swt_points_send_req        <= '0';
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
                            when CTX_COMMAND =>
                                uc_rx_state <= RX_COMMAND;
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
                                rx_context <= CTX_COMMAND;                                
                            end if;
                            preamble_counter <= 0;
                            uc_rx_state <= RX_IDLE;  
                    end case;

                when RX_COMMAND =>
                    current_command <= received_byte(7 downto 3);
                    expected_payload_length <= to_integer(unsigned(received_byte(2 downto 0)));

                    if (received_byte(2 downto 0)) = "000" then
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
                            constant_bias_mode <= '1';
                            Bias_enabled <= '1';
                            C_bias_V0 <= constant_bias_voltage_0;
                            C_bias_V1 <= constant_bias_voltage_1;

                        -- Disable Constant Bias Mode
                        when "00010" => 
                            constant_bias_mode <= '0';
                            Bias_enabled <= '0';

                        -- Activate Sweep mode
                        when "01010" =>  
                            Sweep_enabled <= '1';  
                            sweep_table_activate_sweep <= '1'; 
                            constant_bias_mode <= '0';  -- Disable CB mode 
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

                        -- Readback Constant Bias Voltage
                        when "00100" =>
                            constant_bias_probe_id <= payload_buffer(0);
                            case payload_buffer(0) is
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
                                when x"01" => acc_send_req      <= '1';
                                when x"02" => mag_send_req      <= '1';
                                when x"03" => gyro_send_req     <= '1';
                                when x"04" => pressure_send_req <= '1';
                                when others => 
                            end case;

                        -- Readback HK Period
                        when "11101" =>
                            HK_ID_2rb <= payload_buffer(0);
                            case payload_buffer(0) is
                                when x"01" => T_2rb <= acc_period_code;
                                when x"02" => T_2rb <= mag_period_code;
                                when x"03" => T_2rb <= gyro_period_code;
                                when x"04" => T_2rb <= pres_period_code;
                                when others => 
                            end case; 
                            T_send_req <= '1';


                        -- 2 BYTES PAYLOAD --
                                                       
                        -- Readback Sweep Table
                        when "10111" =>  
                            case swt_rd_substate is

                                when 0 =>
                                    -- payload_buffer(0) is sweep_table_probe_id
                                    -- payload_buffer(1) is sweep_table_step_id

                                    sweep_table_probe_id <= payload_buffer(0);
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
                            sweep_table_samples_per_step(15 downto 8) <= payload_buffer(0);
                            sweep_table_samples_per_step(7 downto 0)  <= payload_buffer(1);
                            
                        -- Set Sweep Skip 
                        when "10000" => 
                            sweep_table_sample_skip(15 downto 8) <= payload_buffer(0);
                            sweep_table_sample_skip(7 downto 0)  <= payload_buffer(1);

                        -- Set Samples per Point
                        when "10010" =>  
                            sweep_table_samples_per_point(15 downto 8) <= payload_buffer(0);
                            sweep_table_samples_per_point(7 downto 0)  <= payload_buffer(1);

                        -- Set Sweep Points
                        when "10100" => 
                            sweep_table_points(15 downto 8) <= payload_buffer(0);
                            sweep_table_points(7 downto 0)  <= payload_buffer(1);

                        -- Set Periodic HK sending
                        when "11110" =>
                            -- payload_buffer(0) = HK ID
                            -- payload_buffer(1) = [7:6]=scale, [5:0]=value

                            v_scale := payload_buffer(1)(7 downto 6);
                            v_val := to_integer(unsigned(payload_buffer(1)(5 downto 0)));

                            case payload_buffer(0) is

                                when x"01" =>  -- ACC
                                    acc_period_code <= payload_buffer(1);
                                    acc_scale       <= v_scale;
                                    acc_period_s    <= 60 * v_val when v_scale = x"11" else v_val;
                                    acc_cnt_s       <= 0;

                                when x"02" =>  -- MAG
                                    mag_period_code <= payload_buffer(1);
                                    mag_scale       <= v_scale;
                                    mag_period_s    <= 60 * v_val when v_scale = x"11" else v_val;
                                    mag_cnt_s       <= 0;

                                when x"03" =>  -- GYRO
                                    gyro_period_code <= payload_buffer(1);
                                    gyro_scale       <= v_scale;
                                    gyro_period_s    <= 60 * v_val when v_scale = x"11" else v_val;
                                    gyro_cnt_s       <= 0;

                                when x"04" =>  -- PRES
                                    pres_period_code <= payload_buffer(1);
                                    pres_scale       <= v_scale;
                                    pres_period_s    <= 60 * v_val when v_scale = x"11" else v_val;
                                    pres_cnt_s       <= 0;

                                when others =>
                            end case;


                        -- 3 BYTES PAYLOAD --

                        -- Set Constant Bias Voltage
                        when "00011" =>  
                            constant_bias_probe_id <= payload_buffer(0);

                            case payload_buffer(0) is
                                when x"00" =>
                                    constant_bias_voltage_0(15 downto 8) <= payload_buffer(1);
                                    constant_bias_voltage_0(7 downto 0)  <= payload_buffer(2);
                                when x"01" =>
                                    constant_bias_voltage_1(15 downto 8) <= payload_buffer(1);
                                    constant_bias_voltage_1(7 downto 0)  <= payload_buffer(2);
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
                                    st_wdata <= payload_buffer(2) & payload_buffer(3);

                                    swt_wr_substate <= 1;

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
        end if;
    end process;



end architecture_General_Controller;