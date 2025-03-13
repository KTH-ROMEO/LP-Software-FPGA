----------------------------------------------------------------------
-- Created by SmartDesign Wed Mar 12 16:54:09 2025
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
-- Science entity declaration
----------------------------------------------------------------------
entity Science is
    -- Port list
    port(
        -- Inputs
        AA                      : in  std_logic;
        AB                      : in  std_logic;
        ABSY                    : in  std_logic;
        Bias_enabled            : in  std_logic;
        C_bias_V0               : in  std_logic_vector(15 downto 0);
        C_bias_V1               : in  std_logic_vector(15 downto 0);
        RData0                  : in  std_logic_vector(15 downto 0);
        RData1                  : in  std_logic_vector(15 downto 0);
        Sweep_Samples           : in  std_logic_vector(15 downto 0);
        Sweep_enabled           : in  std_logic;
        Sweep_no_steps          : in  std_logic_vector(7 downto 0);
        Sweep_points_per_step   : in  std_logic_vector(15 downto 0);
        Sweep_samples_per_point : in  std_logic_vector(15 downto 0);
        Sweep_skipped_samples   : in  std_logic_vector(15 downto 0);
        clk                     : in  std_logic;
        clk_16Hz                : in  std_logic;
        clk_32kHz               : in  std_logic;
        en_packets              : in  std_logic;
        exp_adc_reset           : in  std_logic;
        milliseconds            : in  std_logic_vector(23 downto 0);
        reset                   : in  std_logic;
        -- Outputs
        ACLK                    : out std_logic;
        ACS                     : out std_logic;
        ACST                    : out std_logic;
        ARST                    : out std_logic;
        L1WR                    : out std_logic;
        L2WR                    : out std_logic;
        L3WR                    : out std_logic;
        L4WR                    : out std_logic;
        LA0                     : out std_logic;
        LA1                     : out std_logic;
        LDCLK                   : out std_logic;
        LDCS                    : out std_logic;
        LDSDI                   : out std_logic;
        RADDR                   : out std_logic_vector(7 downto 0);
        RE0                     : out std_logic;
        REN1                    : out std_logic;
        exp_SC_packet           : out std_logic_vector(63 downto 0);
        exp_Test_packet         : out std_logic_vector(63 downto 0);
        exp_new_data            : out std_logic
        );
end Science;
----------------------------------------------------------------------
-- Science architecture body
----------------------------------------------------------------------
architecture RTL of Science is
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
-- ADC_RESET
component ADC_RESET
    -- Port list
    port(
        -- Inputs
        CLK      : in  std_logic;
        PWRANEN  : in  std_logic;
        RESET    : in  std_logic;
        -- Outputs
        ADCRESET : out std_logic
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
-- SET_LP_GAIN
component SET_LP_GAIN
    -- Port list
    port(
        -- Inputs
        CLK   : in  std_logic;
        G1    : in  std_logic_vector(1 downto 0);
        G2    : in  std_logic_vector(1 downto 0);
        G3    : in  std_logic_vector(1 downto 0);
        G4    : in  std_logic_vector(1 downto 0);
        RESET : in  std_logic;
        -- Outputs
        L1WR  : out std_logic;
        L2WR  : out std_logic;
        L3WR  : out std_logic;
        L4WR  : out std_logic;
        LA0   : out std_logic;
        LA1   : out std_logic
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
----------------------------------------------------------------------
-- Signal declarations
----------------------------------------------------------------------
signal ACLK_net_0             : std_logic;
signal ACS_net_0              : std_logic;
signal ACST_net_0             : std_logic;
signal ADC_READ_0_G1          : std_logic_vector(1 downto 0);
signal ADC_READ_0_G2          : std_logic_vector(1 downto 0);
signal ARST_net_0             : std_logic;
signal exp_new_data_net_0     : std_logic;
signal exp_SC_packet_0        : std_logic_vector(63 downto 0);
signal exp_Test_packet_net_0  : std_logic_vector(63 downto 0);
signal L1WR_net_0             : std_logic;
signal L2WR_net_0             : std_logic;
signal L3WR_net_0             : std_logic;
signal L4WR_net_0             : std_logic;
signal LA0_net_0              : std_logic;
signal LA1_net_0              : std_logic;
signal LDCLK_net_0            : std_logic;
signal LDCS_net_0             : std_logic;
signal LDSDI_net_0            : std_logic;
signal RADDR_net_0            : std_logic_vector(7 downto 0);
signal RE0_net_0              : std_logic;
signal REN1_net_0             : std_logic;
signal SWEEP_SPIDER2_0_ADC_EN : std_logic;
signal SWEEP_SPIDER2_0_DAC1   : std_logic_vector(15 downto 0);
signal SWEEP_SPIDER2_0_DAC2   : std_logic_vector(15 downto 0);
signal SWEEP_SPIDER2_0_SET    : std_logic;
signal ACS_net_1              : std_logic;
signal ACLK_net_1             : std_logic;
signal ACST_net_1             : std_logic;
signal exp_new_data_net_1     : std_logic;
signal LA0_net_1              : std_logic;
signal LA1_net_1              : std_logic;
signal L1WR_net_1             : std_logic;
signal L2WR_net_1             : std_logic;
signal L3WR_net_1             : std_logic;
signal L4WR_net_1             : std_logic;
signal LDCS_net_1             : std_logic;
signal LDSDI_net_1            : std_logic;
signal LDCLK_net_1            : std_logic;
signal ARST_net_1             : std_logic;
signal RE0_net_1              : std_logic;
signal REN1_net_1             : std_logic;
signal RADDR_net_1            : std_logic_vector(7 downto 0);
signal exp_SC_packet_0_net_0  : std_logic_vector(63 downto 0);
signal exp_Test_packet_net_1  : std_logic_vector(63 downto 0);
----------------------------------------------------------------------
-- TiedOff Signals
----------------------------------------------------------------------
signal G3_const_net_0         : std_logic_vector(1 downto 0);
signal G4_const_net_0         : std_logic_vector(1 downto 0);

begin
----------------------------------------------------------------------
-- Constant assignments
----------------------------------------------------------------------
 G3_const_net_0 <= B"00";
 G4_const_net_0 <= B"00";
----------------------------------------------------------------------
-- Top level output port assignments
----------------------------------------------------------------------
 ACS_net_1                    <= ACS_net_0;
 ACS                          <= ACS_net_1;
 ACLK_net_1                   <= ACLK_net_0;
 ACLK                         <= ACLK_net_1;
 ACST_net_1                   <= ACST_net_0;
 ACST                         <= ACST_net_1;
 exp_new_data_net_1           <= exp_new_data_net_0;
 exp_new_data                 <= exp_new_data_net_1;
 LA0_net_1                    <= LA0_net_0;
 LA0                          <= LA0_net_1;
 LA1_net_1                    <= LA1_net_0;
 LA1                          <= LA1_net_1;
 L1WR_net_1                   <= L1WR_net_0;
 L1WR                         <= L1WR_net_1;
 L2WR_net_1                   <= L2WR_net_0;
 L2WR                         <= L2WR_net_1;
 L3WR_net_1                   <= L3WR_net_0;
 L3WR                         <= L3WR_net_1;
 L4WR_net_1                   <= L4WR_net_0;
 L4WR                         <= L4WR_net_1;
 LDCS_net_1                   <= LDCS_net_0;
 LDCS                         <= LDCS_net_1;
 LDSDI_net_1                  <= LDSDI_net_0;
 LDSDI                        <= LDSDI_net_1;
 LDCLK_net_1                  <= LDCLK_net_0;
 LDCLK                        <= LDCLK_net_1;
 ARST_net_1                   <= ARST_net_0;
 ARST                         <= ARST_net_1;
 RE0_net_1                    <= RE0_net_0;
 RE0                          <= RE0_net_1;
 REN1_net_1                   <= REN1_net_0;
 REN1                         <= REN1_net_1;
 RADDR_net_1                  <= RADDR_net_0;
 RADDR(7 downto 0)            <= RADDR_net_1;
 exp_SC_packet_0_net_0        <= exp_SC_packet_0;
 exp_SC_packet(63 downto 0)   <= exp_SC_packet_0_net_0;
 exp_Test_packet_net_1        <= exp_Test_packet_net_0;
 exp_Test_packet(63 downto 0) <= exp_Test_packet_net_1;
----------------------------------------------------------------------
-- Component instances
----------------------------------------------------------------------
-- ADC_READ_0
ADC_READ_0 : ADC_READ
    port map( 
        -- Inputs
        RESET           => reset,
        CLK             => clk,
        AA              => AA,
        AB              => AB,
        ABSY            => ABSY,
        CNV             => clk_32kHz,
        ADC_EN          => SWEEP_SPIDER2_0_ADC_EN,
        SW_EN           => Sweep_enabled,
        CB_EN           => Bias_enabled,
        N_SAMPLES_POINT => Sweep_samples_per_point,
        N_POINT_STEP    => Sweep_points_per_step,
        milliseconds    => milliseconds,
        en_packets      => en_packets,
        -- Outputs
        ACS             => ACS_net_0,
        ACLK            => ACLK_net_0,
        ACST            => ACST_net_0,
        exp_SC_packet   => exp_SC_packet_0,
        exp_Test_packet => exp_Test_packet_net_0,
        exp_new_data    => exp_new_data_net_0,
        G1              => ADC_READ_0_G1,
        G2              => ADC_READ_0_G2 
        );
-- ADC_RESET_0
ADC_RESET_0 : ADC_RESET
    port map( 
        -- Inputs
        RESET    => reset,
        CLK      => clk_16Hz,
        PWRANEN  => exp_adc_reset,
        -- Outputs
        ADCRESET => ARST_net_0 
        );
-- DAC_SET_0
DAC_SET_0 : DAC_SET
    port map( 
        -- Inputs
        RESET     => reset,
        CLK       => clk,
        SET       => SWEEP_SPIDER2_0_SET,
        DACA      => SWEEP_SPIDER2_0_DAC1,
        DACB      => SWEEP_SPIDER2_0_DAC2,
        -- Outputs
        LDCS      => LDCS_net_0,
        LDSDI     => LDSDI_net_0,
        LDCLK     => LDCLK_net_0,
        state_out => OPEN 
        );
-- SET_LP_GAIN_0
SET_LP_GAIN_0 : SET_LP_GAIN
    port map( 
        -- Inputs
        RESET => reset,
        CLK   => clk,
        G1    => ADC_READ_0_G1,
        G2    => ADC_READ_0_G2,
        G3    => G3_const_net_0,
        G4    => G4_const_net_0,
        -- Outputs
        LA0   => LA0_net_0,
        LA1   => LA1_net_0,
        L1WR  => L1WR_net_0,
        L2WR  => L2WR_net_0,
        L3WR  => L3WR_net_0,
        L4WR  => L4WR_net_0 
        );
-- SWEEP_SPIDER2_0
SWEEP_SPIDER2_0 : SWEEP_SPIDER2
    port map( 
        -- Inputs
        RESET          => reset,
        CLK            => clk,
        CLK_SLOW       => clk_32kHz,
        SW_ENABLE      => Sweep_enabled,
        CB_ENABLE      => Bias_enabled,
        RD0            => RData0,
        RD1            => RData1,
        N_STEPS        => Sweep_no_steps,
        N_SAMPLES      => Sweep_Samples,
        N_SKIP_SAMPLES => Sweep_skipped_samples,
        CBIASV0        => C_bias_V0,
        CBIASV1        => C_bias_V1,
        -- Outputs
        SET            => SWEEP_SPIDER2_0_SET,
        REN0           => RE0_net_0,
        REN1           => REN1_net_0,
        ADC_EN         => SWEEP_SPIDER2_0_ADC_EN,
        SW_END         => OPEN,
        DAC1           => SWEEP_SPIDER2_0_DAC1,
        DAC2           => SWEEP_SPIDER2_0_DAC2,
        RADDR          => RADDR_net_0 
        );

end RTL;
