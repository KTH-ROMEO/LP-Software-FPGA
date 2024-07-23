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

    constant SYSCLK_PERIOD : time := 100 ns; -- 10MHZ

    signal SYSCLK : std_logic := '0';
    signal NSYSRESET : std_logic := '0';
    signal UC_RX_RDY : std_logic := '1';
    signal UC_RECV : std_logic_vector(7 downto 0):= x"B5";
    
    type b_array is array (0 to 15) of std_logic_vector(7 downto 0);
    signal SEND_ARRAY : b_array := (x"B5", x"43", x"AB", x"0B", x"01", x"02", x"03", x"04", x"05", x"06", x"07", x"08", x"09", x"0A", x"0B", x"0A");

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

    component General_Controller
        -- ports
        port( 
            -- Inputs
            clk : in std_logic;
            clk_1Hz : in std_logic;
            reset : in std_logic;
            status_packet_clk : in std_logic;
            milliseconds : in std_logic_vector(23 downto 0);
            ffu_ejected : in std_logic;
            low_pressure : in std_logic;
            ext_rx_rdy : in std_logic;
            ext_recv : in std_logic_vector(7 downto 0);
            uc_recv : in std_logic_vector(7 downto 0);
            uc_tx_rdy : in std_logic;
            uc_rx_rdy : in std_logic;
            cu_sync : in std_logic;

            -- Outputs
            unit_id : out std_logic_vector(7 downto 0);
            ffu_id : out std_logic_vector(7 downto 0);
            gs_id : out std_logic_vector(7 downto 0);
            uc_send : out std_logic_vector(7 downto 0);
            uc_wen : out std_logic;
            uc_oen : out std_logic;
            ext_oen : out std_logic;
            readout_en : out std_logic;
            uc_reset : out std_logic;
            uc_pwr_en : out std_logic;
            en_sensors : out std_logic;
            en_data_saving : out std_logic;
            led1 : out std_logic;
            led2 : out std_logic;
            status_bits : out std_logic_vector(63 downto 0);
            status_new_data : out std_logic;
            en_science_packets : out std_logic;
            sweep_en : out std_logic;
            ramp : out std_logic_vector(3 downto 0);
            exp_adc_reset : out std_logic;
            man_gain1 : out std_logic_vector(1 downto 0);
            man_gain2 : out std_logic_vector(1 downto 0);
            man_gain3 : out std_logic_vector(1 downto 0);
            man_gain4 : out std_logic_vector(1 downto 0);
            DAC_zero_value : out std_logic;
            DAC_max_value : out std_logic

            -- Inouts

        );
    end component;

begin

    process
        variable vhdl_initial : BOOLEAN := TRUE;

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
            for i in SEND_ARRAY'range loop
                wait for (SYSCLK_PERIOD * 2);
                UC_RX_RDY <= '1';                
                UC_RECV <= SEND_ARRAY(i);
                wait for (SYSCLK_PERIOD * 2);
                UC_RX_RDY <= '0';
            end loop;

        end if;
    end process;

    -- Clock Driver
    SYSCLK <= not SYSCLK after (SYSCLK_PERIOD / 2.0 );

    -- Instantiate Unit Under Test:  General_Controller
    General_Controller_0 : General_Controller
        -- port map
        port map( 
            -- Inputs
            clk => SYSCLK,
            clk_1Hz => SYSCLK,
            reset => NSYSRESET,
            status_packet_clk => SYSCLK,
            milliseconds => (others=> '0'),
            ffu_ejected => '0',
            low_pressure => '0',
            ext_rx_rdy => '0',
            ext_recv => (others=> '0'),
            uc_recv => UC_RECV,
            uc_tx_rdy => '0',
            uc_rx_rdy => UC_RX_RDY,
            cu_sync => '0',

            -- Outputs
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

end behavioral;

