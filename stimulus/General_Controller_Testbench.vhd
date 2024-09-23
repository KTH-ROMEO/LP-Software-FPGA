----------------------------------------------------------------------
-- Created by Microsemi SmartDesign Fri Jul 19 16:10:47 2024
-- Testbench Template
-- This is a basic testbench that instantiates your design with basic 
-- clock and reset pins connected.  If your design has special
-- clock/reset or testbench driver requirements then you should 
-- copy this file and modify it. 
----------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: General_Controller_Testbench.vhd
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


library ieee;
use ieee.std_logic_1164.all;

entity General_Controller_Testbench is
end General_Controller_Testbench;

architecture behavioral of General_Controller_Testbench is

    constant SYSCLK_PERIOD : time := 31.25 ns; -- 32MHZ

    constant SYSCLK_PERIOD32 : time := 31250 ns; -- 32kHZ
    
    signal SYSCLK : std_logic := '0';
    signal SYSCLK32 : std_logic := '0';
    signal NSYSRESET : std_logic := '0';
    signal UC_RX_RDY : std_logic := '0';
    signal UC_TX_RDY : std_logic := '0';
    signal UC_RECV : std_logic_vector(7 downto 0):= (others => '0');
    


    type CB_array is array (0 to 13) of std_logic_vector(7 downto 0);
    signal SEND_CB_ARRAY : CB_array := (x"B5", x"43", x"CB", x"01", x"CD", x"AB", x"0A", x"B5", x"43", x"CB", x"00", x"FD", x"CE", x"0A");

    type AA_array is array (0 to 3) of std_logic_vector(7 downto 0);
    signal SEND_AA_ARRAY : AA_array := (x"B5", x"43", x"AA", x"0A");

    type A0_array is array (0 to 3) of std_logic_vector(7 downto 0);
    signal SEND_A0_ARRAY : AA_array := (x"B5", x"43", x"A0", x"0A");

    type CA_array is array (0 to 3) of std_logic_vector(7 downto 0);
    signal SEND_CA_ARRAY : CA_array := (x"B5", x"43", x"CA", x"0A");

    type C0_array is array (0 to 3) of std_logic_vector(7 downto 0);
    signal SEND_C0_ARRAY : CA_array := (x"B5", x"43", x"C0", x"0A");

    type AC_array is array (0 to 4) of std_logic_vector(7 downto 0);
    signal SEND_AC_ARRAY : AC_array := (x"b5", x"43", x"ac", x"bc", x"0a");

    type AD_array is array (0 to 5) of std_logic_vector(7 downto 0);
    signal SEND_AD_ARRAY : AD_array := (x"b5", x"43", x"ad", x"10", x"00", x"0a");


    type CC_array is array (0 to 4) of std_logic_vector(7 downto 0);
    signal SEND_CC_ARRAY : CC_array := (x"b5", x"43", x"CC", x"01", x"0A");

    type AB_array is array (0 to 7) of std_logic_vector(7 downto 0);
    signal SEND_AB_ARRAY : AB_array := (x"b5", x"43", x"ab", x"00", x"1a", x"ec", x"2a", x"0a");

    type A1_array is array (0 to 5) of std_logic_vector(7 downto 0);
    signal READBACK_A1_ARRAY: A1_array := (x"b5", x"43", x"a1", x"00", x"1a", x"0a");

    signal unit_id : std_logic_vector(7 downto 0);
    signal ffu_id : std_logic_vector(7 downto 0);
    signal gs_id : std_logic_vector(7 downto 0);
    signal uc_send : std_logic_vector(7 downto 0);
    signal uc_wen : std_logic;
    signal uc_oen : std_logic;
    signal ext_oen : std_logic;
    signal readout_en : std_logic;
    signal uc_reset : std_logic;
    signal uc_pwr_en : std_logic;
    signal en_sensors : std_logic;
    signal en_data_saving : std_logic;
    signal led1 : std_logic;
    signal led2 : std_logic;
    signal status_bits : std_logic_vector(63 downto 0);
    signal status_new_data : std_logic;
    signal en_science_packets : std_logic;
    signal sweep_en : std_logic;
    signal ramp : std_logic_vector(3 downto 0);
    signal exp_adc_reset : std_logic;
    signal man_gain1 : std_logic_vector(1 downto 0);
    signal man_gain2 : std_logic_vector(1 downto 0);
    signal man_gain3 : std_logic_vector(1 downto 0);
    signal man_gain4 : std_logic_vector(1 downto 0);
    signal DAC_zero_value : std_logic;
    signal DAC_max_value : std_logic;

    signal st_rdata0  : std_logic_vector(15 downto 0);
    signal st_rdata1  : std_logic_vector(15 downto 0);

    signal st_wdata : std_logic_vector(15 downto 0);
    signal st_waddr : std_logic_vector(7 downto 0);
    signal st_raddr : std_logic_vector(7 downto 0);
    signal st_wen0  : std_logic;
    signal st_wen1  : std_logic;
    signal st_ren0  : std_logic;
    signal st_ren1  : std_logic;

    --signal fake_msr : std_logic_vector(15 downto 0);
    --signal fake_msr_rdy : std_logic;
    --signal smp_per_msr : std_logic_vector(15 downto 0);

component General_Controller
    -- Port list
    port(
        -- Inputs
        clk                : in  std_logic;
        clk_1Hz            : in  std_logic;
        clk_32k            : in  std_logic;
        cu_sync            : in  std_logic;
        ext_recv           : in  std_logic_vector(7 downto 0);
        ext_rx_rdy         : in  std_logic;

        --fake_msr           : in  std_logic_vector(15 downto 0);
        --fake_msr_rdy       : in  std_logic;
        
        ffu_ejected        : in  std_logic;
        low_pressure       : in  std_logic;
        milliseconds       : in  std_logic_vector(23 downto 0);
        reset              : in  std_logic;
        st_rdata0          : in  std_logic_vector(15 downto 0);
        st_rdata1          : in  std_logic_vector(15 downto 0);
        status_packet_clk  : in  std_logic;
        uc_recv            : in  std_logic_vector(7 downto 0);
        uc_rx_rdy          : in  std_logic;
        uc_tx_rdy          : in  std_logic;
        -- Outputs
        DAC_max_value      : out std_logic;
        DAC_zero_value     : out std_logic;
        en_data_saving     : out std_logic;
        en_science_packets : out std_logic;
        en_sensors         : out std_logic;
        exp_adc_reset      : out std_logic;
        ext_oen            : out std_logic;
        ffu_id             : out std_logic_vector(7 downto 0);
        gs_id              : out std_logic_vector(7 downto 0);
        led1               : out std_logic;
        led2               : out std_logic;
        man_gain1          : out std_logic_vector(1 downto 0);
        man_gain2          : out std_logic_vector(1 downto 0);
        man_gain3          : out std_logic_vector(1 downto 0);
        man_gain4          : out std_logic_vector(1 downto 0);
        ramp               : out std_logic_vector(3 downto 0);
        readout_en         : out std_logic;
        
        --smp_per_msr        : out std_logic_vector(15 downto 0);
        
        st_raddr           : out std_logic_vector(7 downto 0);
        st_ren0            : out std_logic;
        st_ren1            : out std_logic;
        st_waddr           : out std_logic_vector(7 downto 0);
        st_wdata           : out std_logic_vector(15 downto 0);
        st_wen0            : out std_logic;
        st_wen1            : out std_logic;
        status_bits        : out std_logic_vector(63 downto 0);
        status_new_data    : out std_logic;
        sweep_en           : out std_logic;
        uc_oen             : out std_logic;
        uc_pwr_en          : out std_logic;
        uc_reset           : out std_logic;
        uc_send            : out std_logic_vector(7 downto 0);
        uc_wen             : out std_logic;
        unit_id            : out std_logic_vector(7 downto 0)
        );
end component;

    component SweepTable
        -- Port list
        port(
            -- Inputs
            RADDR : in  std_logic_vector(7 downto 0);
            REN   : in  std_logic;
            RESET : in  std_logic;
            RWCLK : in  std_logic;
            WADDR : in  std_logic_vector(7 downto 0);
            WD    : in  std_logic_vector(15 downto 0);
            WEN   : in  std_logic;
            -- Outputs
            RD    : out std_logic_vector(15 downto 0)
        );
    end component;

-- Constant_Bias_Fake_Data_Generator
--component Constant_Bias_Fake_Data_Generator
    -- Port list
--    port(
        -- Inputs
--       clk_32k                 : in  std_logic;
--        reset                   : in  std_logic;
--        samples_per_measurement : in  std_logic_vector(15 downto 0);
        -- Outputs
--        fake_measurement        : out std_logic_vector(15 downto 0);
--        measurement_rdy         : out std_logic
--        );
--end component;

begin

    process
        variable vhdl_initial : BOOLEAN := TRUE;
        variable send_cmd_sent : BOOLEAN := FALSE;

    begin
        if ( vhdl_initial ) then
            -- Assert Reset
            NSYSRESET <= '0';
            wait for ( SYSCLK_PERIOD * 10 );
            
            NSYSRESET <= '1';
            wait for ( SYSCLK_PERIOD * 10 );
            NSYSRESET <= '0';
            vhdl_initial := FALSE;
        else
            if ( not send_cmd_sent ) then


            wait for (SYSCLK_PERIOD * 2000);


            for i in SEND_AD_ARRAY'range loop
                wait for (SYSCLK_PERIOD * 1000);
                UC_RX_RDY <= '1';
                UC_RECV <= SEND_AD_ARRAY(i);
                wait for (SYSCLK_PERIOD * 1000);
                UC_RX_RDY <= '0';
            end loop;


            wait for (SYSCLK_PERIOD * 5000);


            for i in SEND_CA_ARRAY'range loop
                wait for (SYSCLK_PERIOD * 1000);
                UC_RX_RDY <= '1';
                UC_RECV <= SEND_CA_ARRAY(i);
                wait for (SYSCLK_PERIOD * 1000);
                UC_RX_RDY <= '0';
            end loop;
            send_cmd_sent := TRUE;
            end if;

            wait for (SYSCLK_PERIOD * 5000);
--
            for i in 1 to 100 loop
                wait for (SYSCLK_PERIOD * 1000);
                UC_TX_RDY <= '1';                
                
                wait for (SYSCLK_PERIOD * 1000);
                UC_TX_RDY <= '0';
            end loop;

        end if;
    end process;

    -- Clock Driver
    SYSCLK <= not SYSCLK after (SYSCLK_PERIOD / 1.0 );
    SYSCLK32 <= not SYSCLK32 after (SYSCLK_PERIOD32 / 1);

    -- Instantiate Unit Under Test:  General_Controller
    General_Controller_0 : General_Controller
        -- port map
        port map( 
            -- Inputs
            clk => SYSCLK,
            clk_1Hz => SYSCLK,
            clk_32k => SYSCLK32,
            reset => NSYSRESET,
            status_packet_clk => SYSCLK,
            milliseconds => (others=> '0'),
            ffu_ejected => '0',
            low_pressure => '0',
            ext_rx_rdy => '0',
            ext_recv => (others=> '0'),
            uc_recv => UC_RECV,
            uc_tx_rdy => UC_TX_RDY,
            uc_rx_rdy => UC_RX_RDY,
            cu_sync => '0',

            st_rdata0 => st_rdata0,
            st_rdata1 => st_rdata1,

            --fake_msr => fake_msr,
            --fake_msr_rdy => fake_msr_rdy,


            -- Outputs

            --smp_per_msr => smp_per_msr,

            st_wdata => st_wdata,
            st_waddr => st_waddr,
            st_raddr => st_raddr,
            st_wen0  => st_wen0,
            st_wen1  => st_wen1,
            st_ren0  => st_ren0,
            st_ren1  => st_ren1,

            unit_id => unit_id ,
            ffu_id => ffu_id ,
            gs_id => gs_id ,
            uc_send => uc_send ,
            uc_wen =>  uc_wen ,
            uc_oen =>  uc_oen ,
            ext_oen =>  ext_oen ,
            readout_en =>  readout_en ,
            uc_reset =>  uc_reset ,
            uc_pwr_en =>  uc_pwr_en ,
            en_sensors =>  en_sensors ,
            en_data_saving =>  en_data_saving ,
            led1 =>  led1 ,
            led2 =>  led2 ,
            status_bits => status_bits ,
            status_new_data =>  status_new_data ,
            en_science_packets =>  en_science_packets ,
            sweep_en =>  sweep_en ,
            ramp => ramp ,
            exp_adc_reset =>  exp_adc_reset ,
            man_gain1 => man_gain1 ,
            man_gain2 => man_gain2 ,
            man_gain3 => man_gain3 ,
            man_gain4 => man_gain4 ,
            DAC_zero_value =>  DAC_zero_value ,
            DAC_max_value =>  DAC_max_value 

            -- Inouts

        );


-- Constant_Bias_Fake_Data_Generator_0
--Constant_Bias_Fake_Data_Generator_0 : Constant_Bias_Fake_Data_Generator
--    port map( 
        -- Inputs
--        clk_32k                 => SYSCLK32,
--        samples_per_measurement => smp_per_msr,
--        reset                   => NSYSRESET,
        -- Outputs
--        measurement_rdy         => fake_msr_rdy,
--        fake_measurement        => fake_msr
--        );


    -- SweepTable_0
    SweepTable_0 : SweepTable
        port map( 
            -- Inputs
            WD    => st_wdata,
            WEN   => st_wen0,
            REN   => st_ren0,
            WADDR => st_waddr,
            RADDR => st_raddr,
            RWCLK => SYSCLK,
            RESET => NSYSRESET,
            -- Outputs
            RD    =>  st_rdata0 
       );
    -- SweepTable_1
    SweepTable_1 : SweepTable
        port map( 
            -- Inputs
            WD    => st_wdata,
            WEN   => st_wen1,
            REN   => st_ren1,
            WADDR => st_waddr,
            RADDR => st_raddr,
            RWCLK => SYSCLK,
            RESET => NSYSRESET,
            -- Outputs
            RD    => st_rdata1 
        );


end behavioral;

