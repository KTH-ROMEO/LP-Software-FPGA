----------------------------------------------------------------------
-- Created by SmartDesign Wed Mar 12 18:02:41 2025
-- Version: v11.9 SP6 11.9.6.7
----------------------------------------------------------------------

----------------------------------------------------------------------
-- Libraries
----------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library proasic3;
use proasic3.all;
----------------------------------------------------------------------
-- RomeoSweep_Test entity declaration
----------------------------------------------------------------------
entity RomeoSweep_Test is
    -- Port list
    port(
        -- Outputs
        ACLK          : out std_logic;
        ACS           : out std_logic;
        ACST          : out std_logic;
        LDCLK         : out std_logic;
        LDCS          : out std_logic;
        LDSDI         : out std_logic;
        SET           : out std_logic;
        exp_SC_packet : out std_logic_vector(63 downto 0);
        exp_new_data  : out std_logic
        );
end RomeoSweep_Test;
----------------------------------------------------------------------
-- RomeoSweep_Test architecture body
----------------------------------------------------------------------
architecture RTL of RomeoSweep_Test is
----------------------------------------------------------------------
-- Component declarations
----------------------------------------------------------------------
-- ADC_READ
component ADC_READ
    -- Port list
    port(
        -- Inputs
        AA              : in  std_logic;
        AB              : in  std_logic;
        ABSY            : in  std_logic;
        ADC_EN          : in  std_logic;
        CB_EN           : in  std_logic;
        CLK             : in  std_logic;
        CNV             : in  std_logic;
        N_POINT_STEP    : in  std_logic_vector(15 downto 0);
        N_SAMPLES_POINT : in  std_logic_vector(15 downto 0);
        RESET           : in  std_logic;
        SW_EN           : in  std_logic;
        en_packets      : in  std_logic;
        milliseconds    : in  std_logic_vector(23 downto 0);
        -- Outputs
        ACLK            : out std_logic;
        ACS             : out std_logic;
        ACST            : out std_logic;
        G1              : out std_logic_vector(1 downto 0);
        G2              : out std_logic_vector(1 downto 0);
        exp_SC_packet   : out std_logic_vector(63 downto 0);
        exp_Test_packet : out std_logic_vector(63 downto 0);
        exp_new_data    : out std_logic
        );
end component;
-- CLK_GEN   -   Actel:Simulation:CLK_GEN:1.0.1
component CLK_GEN
    generic( 
        CLK_PERIOD : integer := 100 ;
        DUTY_CYCLE : integer := 50 
        );
    -- Port list
    port(
        -- Outputs
        CLK : out std_logic
        );
end component;
-- DAC_SET
component DAC_SET
    -- Port list
    port(
        -- Inputs
        CLK       : in  std_logic;
        DACA      : in  std_logic_vector(15 downto 0);
        DACB      : in  std_logic_vector(15 downto 0);
        RESET     : in  std_logic;
        SET       : in  std_logic;
        -- Outputs
        LDCLK     : out std_logic;
        LDCS      : out std_logic;
        LDSDI     : out std_logic;
        state_out : out std_logic_vector(3 downto 0)
        );
end component;
-- RESET_GEN   -   Actel:Simulation:RESET_GEN:1.0.1
component RESET_GEN
    generic( 
        DELAY       : integer := 10 ;
        LOGIC_LEVEL : integer := 1 
        );
    -- Port list
    port(
        -- Outputs
        RESET : out std_logic
        );
end component;
-- SWEEP_SPIDER2
component SWEEP_SPIDER2
    -- Port list
    port(
        -- Inputs
        CBIASV0        : in  std_logic_vector(15 downto 0);
        CBIASV1        : in  std_logic_vector(15 downto 0);
        CB_ENABLE      : in  std_logic;
        CLK            : in  std_logic;
        CLK_SLOW       : in  std_logic;
        N_SAMPLES      : in  std_logic_vector(15 downto 0);
        N_SKIP_SAMPLES : in  std_logic_vector(15 downto 0);
        N_STEPS        : in  std_logic_vector(7 downto 0);
        RD0            : in  std_logic_vector(15 downto 0);
        RD1            : in  std_logic_vector(15 downto 0);
        RESET          : in  std_logic;
        SW_ENABLE      : in  std_logic;
        -- Outputs
        ADC_EN         : out std_logic;
        DAC1           : out std_logic_vector(15 downto 0);
        DAC2           : out std_logic_vector(15 downto 0);
        RADDR          : out std_logic_vector(7 downto 0);
        REN0           : out std_logic;
        REN1           : out std_logic;
        SET            : out std_logic;
        SW_END         : out std_logic
        );
end component;
-- SweepTable
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
----------------------------------------------------------------------
-- Signal declarations
----------------------------------------------------------------------
signal ACLK_net_0             : std_logic;
signal ACS_net_0              : std_logic;
signal ACST_net_0             : std_logic;
signal CLK_GEN_0_CLK          : std_logic;
signal CLK_GEN_1_CLK          : std_logic;
signal DAC2                   : std_logic_vector(15 downto 0);
signal exp_new_data_net_0     : std_logic;
signal exp_SC_packet_net_0    : std_logic_vector(63 downto 0);
signal LDCLK_net_0            : std_logic;
signal LDCS_net_0             : std_logic;
signal LDSDI_net_0            : std_logic;
signal RESET_GEN_0_RESET      : std_logic;
signal SET_net_0              : std_logic;
signal SWEEP_SPIDER2_0_ADC_EN : std_logic;
signal SWEEP_SPIDER2_0_DAC1   : std_logic_vector(15 downto 0);
signal SWEEP_SPIDER2_0_RADDR  : std_logic_vector(7 downto 0);
signal SWEEP_SPIDER2_0_REN0   : std_logic;
signal SWEEP_SPIDER2_0_REN1   : std_logic;
signal SWEEP_SPIDER2_0_SW_END : std_logic;
signal SweepTable_0_RD        : std_logic_vector(15 downto 0);
signal SweepTable_1_RD        : std_logic_vector(15 downto 0);
signal LDCS_net_1             : std_logic;
signal LDSDI_net_1            : std_logic;
signal LDCLK_net_1            : std_logic;
signal ACS_net_1              : std_logic;
signal ACLK_net_1             : std_logic;
signal ACST_net_1             : std_logic;
signal exp_new_data_net_1     : std_logic;
signal SET_net_1              : std_logic;
signal exp_SC_packet_net_1    : std_logic_vector(63 downto 0);
----------------------------------------------------------------------
-- TiedOff Signals
----------------------------------------------------------------------
signal VCC_net                : std_logic;
signal GND_net                : std_logic;
signal N_SAMPLES_POINT_const_net_0: std_logic_vector(15 downto 0);
signal N_POINT_STEP_const_net_0: std_logic_vector(15 downto 0);
signal milliseconds_const_net_0: std_logic_vector(23 downto 0);
signal N_STEPS_const_net_0    : std_logic_vector(7 downto 0);
signal N_SAMPLES_const_net_0  : std_logic_vector(15 downto 0);
signal N_SKIP_SAMPLES_const_net_0: std_logic_vector(15 downto 0);
signal CBIASV0_const_net_0    : std_logic_vector(15 downto 0);
signal CBIASV1_const_net_0    : std_logic_vector(15 downto 0);
signal WD_const_net_0         : std_logic_vector(15 downto 0);
signal WADDR_const_net_0      : std_logic_vector(7 downto 0);
signal WD_const_net_1         : std_logic_vector(15 downto 0);
signal WADDR_const_net_1      : std_logic_vector(7 downto 0);
----------------------------------------------------------------------
-- Inverted Signals
----------------------------------------------------------------------
signal SW_END_OUT_PRE_INV0_0  : std_logic;

begin
----------------------------------------------------------------------
-- Constant assignments
----------------------------------------------------------------------
 VCC_net                     <= '1';
 GND_net                     <= '0';
 N_SAMPLES_POINT_const_net_0 <= B"0000000000000011";
 N_POINT_STEP_const_net_0    <= B"0000000000000010";
 milliseconds_const_net_0    <= B"000000000000000000000000";
 N_STEPS_const_net_0         <= B"00000100";
 N_SAMPLES_const_net_0       <= B"0000000000001011";
 N_SKIP_SAMPLES_const_net_0  <= B"0000000000000100";
 CBIASV0_const_net_0         <= B"0000000010101010";
 CBIASV1_const_net_0         <= B"0000000000001010";
 WD_const_net_0              <= B"0000000000000000";
 WADDR_const_net_0           <= B"00000000";
 WD_const_net_1              <= B"0000000000000000";
 WADDR_const_net_1           <= B"00000000";
----------------------------------------------------------------------
-- Inversions
----------------------------------------------------------------------
 SWEEP_SPIDER2_0_SW_END <= NOT SW_END_OUT_PRE_INV0_0;
----------------------------------------------------------------------
-- Top level output port assignments
----------------------------------------------------------------------
 LDCS_net_1                 <= LDCS_net_0;
 LDCS                       <= LDCS_net_1;
 LDSDI_net_1                <= LDSDI_net_0;
 LDSDI                      <= LDSDI_net_1;
 LDCLK_net_1                <= LDCLK_net_0;
 LDCLK                      <= LDCLK_net_1;
 ACS_net_1                  <= ACS_net_0;
 ACS                        <= ACS_net_1;
 ACLK_net_1                 <= ACLK_net_0;
 ACLK                       <= ACLK_net_1;
 ACST_net_1                 <= ACST_net_0;
 ACST                       <= ACST_net_1;
 exp_new_data_net_1         <= exp_new_data_net_0;
 exp_new_data               <= exp_new_data_net_1;
 SET_net_1                  <= SET_net_0;
 SET                        <= SET_net_1;
 exp_SC_packet_net_1        <= exp_SC_packet_net_0;
 exp_SC_packet(63 downto 0) <= exp_SC_packet_net_1;
----------------------------------------------------------------------
-- Component instances
----------------------------------------------------------------------
-- ADC_READ_0
ADC_READ_0 : ADC_READ
    port map( 
        -- Inputs
        RESET           => RESET_GEN_0_RESET,
        CLK             => CLK_GEN_0_CLK,
        AA              => VCC_net,
        AB              => VCC_net,
        ABSY            => GND_net,
        CNV             => CLK_GEN_1_CLK,
        ADC_EN          => SWEEP_SPIDER2_0_ADC_EN,
        SW_EN           => SWEEP_SPIDER2_0_SW_END,
        CB_EN           => GND_net,
        N_SAMPLES_POINT => N_SAMPLES_POINT_const_net_0,
        N_POINT_STEP    => N_POINT_STEP_const_net_0,
        milliseconds    => milliseconds_const_net_0,
        en_packets      => VCC_net,
        -- Outputs
        ACS             => ACS_net_0,
        ACLK            => ACLK_net_0,
        ACST            => ACST_net_0,
        exp_SC_packet   => exp_SC_packet_net_0,
        exp_Test_packet => OPEN,
        exp_new_data    => exp_new_data_net_0,
        G1              => OPEN,
        G2              => OPEN 
        );
-- CLK_GEN_0   -   Actel:Simulation:CLK_GEN:1.0.1
CLK_GEN_0 : CLK_GEN
    generic map( 
        CLK_PERIOD => ( 100 ),
        DUTY_CYCLE => ( 50 )
        )
    port map( 
        -- Outputs
        CLK => CLK_GEN_0_CLK 
        );
-- CLK_GEN_1   -   Actel:Simulation:CLK_GEN:1.0.1
CLK_GEN_1 : CLK_GEN
    generic map( 
        CLK_PERIOD => ( 50000 ),
        DUTY_CYCLE => ( 50 )
        )
    port map( 
        -- Outputs
        CLK => CLK_GEN_1_CLK 
        );
-- DAC_SET_0
DAC_SET_0 : DAC_SET
    port map( 
        -- Inputs
        RESET     => RESET_GEN_0_RESET,
        CLK       => CLK_GEN_0_CLK,
        SET       => SET_net_0,
        DACA      => SWEEP_SPIDER2_0_DAC1,
        DACB      => DAC2,
        -- Outputs
        LDCS      => LDCS_net_0,
        LDSDI     => LDSDI_net_0,
        LDCLK     => LDCLK_net_0,
        state_out => OPEN 
        );
-- RESET_GEN_0   -   Actel:Simulation:RESET_GEN:1.0.1
RESET_GEN_0 : RESET_GEN
    generic map( 
        DELAY       => ( 10 ),
        LOGIC_LEVEL => ( 1 )
        )
    port map( 
        -- Outputs
        RESET => RESET_GEN_0_RESET 
        );
-- SWEEP_SPIDER2_0
SWEEP_SPIDER2_0 : SWEEP_SPIDER2
    port map( 
        -- Inputs
        RESET          => RESET_GEN_0_RESET,
        CLK            => CLK_GEN_0_CLK,
        CLK_SLOW       => CLK_GEN_1_CLK,
        SW_ENABLE      => SWEEP_SPIDER2_0_SW_END,
        CB_ENABLE      => GND_net,
        RD0            => SweepTable_0_RD,
        RD1            => SweepTable_1_RD,
        N_STEPS        => N_STEPS_const_net_0,
        N_SAMPLES      => N_SAMPLES_const_net_0,
        N_SKIP_SAMPLES => N_SKIP_SAMPLES_const_net_0,
        CBIASV0        => CBIASV0_const_net_0,
        CBIASV1        => CBIASV1_const_net_0,
        -- Outputs
        SET            => SET_net_0,
        REN0           => SWEEP_SPIDER2_0_REN0,
        REN1           => SWEEP_SPIDER2_0_REN1,
        ADC_EN         => SWEEP_SPIDER2_0_ADC_EN,
        SW_END         => SW_END_OUT_PRE_INV0_0,
        DAC1           => SWEEP_SPIDER2_0_DAC1,
        DAC2           => DAC2,
        RADDR          => SWEEP_SPIDER2_0_RADDR 
        );
-- SweepTable_0
SweepTable_0 : SweepTable
    port map( 
        -- Inputs
        WEN   => GND_net,
        REN   => SWEEP_SPIDER2_0_REN0,
        RWCLK => CLK_GEN_0_CLK,
        RESET => RESET_GEN_0_RESET,
        WD    => WD_const_net_0,
        WADDR => WADDR_const_net_0,
        RADDR => SWEEP_SPIDER2_0_RADDR,
        -- Outputs
        RD    => SweepTable_0_RD 
        );
-- SweepTable_1
SweepTable_1 : SweepTable
    port map( 
        -- Inputs
        WEN   => GND_net,
        REN   => SWEEP_SPIDER2_0_REN1,
        RWCLK => CLK_GEN_0_CLK,
        RESET => RESET_GEN_0_RESET,
        WD    => WD_const_net_1,
        WADDR => WADDR_const_net_1,
        RADDR => SWEEP_SPIDER2_0_RADDR,
        -- Outputs
        RD    => SweepTable_1_RD 
        );

end RTL;
