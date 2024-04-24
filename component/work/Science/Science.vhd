----------------------------------------------------------------------
-- Created by SmartDesign Thu Jan 23 14:30:01 2020
-- Version: v11.9 SP3 11.9.3.5
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
        AA            : in  std_logic;
        AB            : in  std_logic;
        ABSY          : in  std_logic;
        FFUID         : in  std_logic_vector(7 downto 0);
        clk           : in  std_logic;
        clk_16Hz      : in  std_logic;
        clk_1kHz      : in  std_logic;
        clk_32kHz     : in  std_logic;
        en_packets    : in  std_logic;
        exp_adc_reset : in  std_logic;
        man_gain1     : in  std_logic_vector(1 downto 0);
        man_gain2     : in  std_logic_vector(1 downto 0);
        man_gain3     : in  std_logic_vector(1 downto 0);
        man_gain4     : in  std_logic_vector(1 downto 0);
        milliseconds  : in  std_logic_vector(23 downto 0);
        reset         : in  std_logic;
        sweep_en      : in  std_logic;
        -- Outputs
        ACLK          : out std_logic;
        ACS           : out std_logic;
        ACST          : out std_logic;
        ARST          : out std_logic;
        L1WR          : out std_logic;
        L2WR          : out std_logic;
        L3WR          : out std_logic;
        L4WR          : out std_logic;
        LA0           : out std_logic;
        LA1           : out std_logic;
        LDCLK         : out std_logic;
        LDCS          : out std_logic;
        LDSDI         : out std_logic;
        chan0_data    : out std_logic_vector(11 downto 0);
        chan1_data    : out std_logic_vector(11 downto 0);
        chan2_data    : out std_logic_vector(11 downto 0);
        chan3_data    : out std_logic_vector(11 downto 0);
        chan4_data    : out std_logic_vector(11 downto 0);
        chan5_data    : out std_logic_vector(11 downto 0);
        chan6_data    : out std_logic_vector(11 downto 0);
        chan7_data    : out std_logic_vector(11 downto 0);
        exp_new_data  : out std_logic;
        exp_packet    : out std_logic_vector(87 downto 0)
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
        AA           : in  std_logic;
        AB           : in  std_logic;
        ABSY         : in  std_logic;
        CLK          : in  std_logic;
        CNV          : in  std_logic;
        DACA         : in  std_logic_vector(15 downto 0);
        DACB         : in  std_logic_vector(15 downto 0);
        DACC         : in  std_logic_vector(15 downto 0);
        DACD         : in  std_logic_vector(15 downto 0);
        RESET        : in  std_logic;
        RST          : in  std_logic;
        SYNC         : in  std_logic;
        en_packets   : in  std_logic;
        man_gain1    : in  std_logic_vector(1 downto 0);
        man_gain2    : in  std_logic_vector(1 downto 0);
        man_gain3    : in  std_logic_vector(1 downto 0);
        man_gain4    : in  std_logic_vector(1 downto 0);
        milliseconds : in  std_logic_vector(23 downto 0);
        -- Outputs
        ACLK         : out std_logic;
        ACS          : out std_logic;
        ACST         : out std_logic;
        G1           : out std_logic_vector(1 downto 0);
        G2           : out std_logic_vector(1 downto 0);
        G3           : out std_logic_vector(1 downto 0);
        G4           : out std_logic_vector(1 downto 0);
        chan0_data   : out std_logic_vector(11 downto 0);
        chan1_data   : out std_logic_vector(11 downto 0);
        chan2_data   : out std_logic_vector(11 downto 0);
        chan3_data   : out std_logic_vector(11 downto 0);
        chan4_data   : out std_logic_vector(11 downto 0);
        chan5_data   : out std_logic_vector(11 downto 0);
        chan6_data   : out std_logic_vector(11 downto 0);
        chan7_data   : out std_logic_vector(11 downto 0);
        exp_new_data : out std_logic;
        exp_packet   : out std_logic_vector(87 downto 0)
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
        DACC      : in  std_logic_vector(15 downto 0);
        DACD      : in  std_logic_vector(15 downto 0);
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
        ACTIVATE : in  std_logic;
        CLK      : in  std_logic;
        CLK_SLOW : in  std_logic;
        FFUID    : in  std_logic_vector(7 downto 0);
        RESET    : in  std_logic;
        -- Outputs
        DAC1     : out std_logic_vector(15 downto 0);
        DAC2     : out std_logic_vector(15 downto 0);
        DAC3     : out std_logic_vector(15 downto 0);
        DAC4     : out std_logic_vector(15 downto 0);
        SET      : out std_logic
        );
end component;
----------------------------------------------------------------------
-- Signal declarations
----------------------------------------------------------------------
signal ACLK_net_0           : std_logic;
signal ACS_net_0            : std_logic;
signal ACST_net_0           : std_logic;
signal ADC_READ_0_G1        : std_logic_vector(1 downto 0);
signal ADC_READ_0_G2        : std_logic_vector(1 downto 0);
signal ADC_READ_0_G3        : std_logic_vector(1 downto 0);
signal ADC_READ_0_G4        : std_logic_vector(1 downto 0);
signal ARST_net_0           : std_logic;
signal chan0_data_net_0     : std_logic_vector(11 downto 0);
signal chan1_data_net_0     : std_logic_vector(11 downto 0);
signal chan2_data_net_0     : std_logic_vector(11 downto 0);
signal chan3_data_net_0     : std_logic_vector(11 downto 0);
signal chan4_data_net_0     : std_logic_vector(11 downto 0);
signal chan5_data_net_0     : std_logic_vector(11 downto 0);
signal chan6_data_net_0     : std_logic_vector(11 downto 0);
signal chan7_data_net_0     : std_logic_vector(11 downto 0);
signal exp_new_data_net_0   : std_logic;
signal exp_packet_0         : std_logic_vector(87 downto 0);
signal L1WR_net_0           : std_logic;
signal L2WR_net_0           : std_logic;
signal L3WR_net_0           : std_logic;
signal L4WR_net_0           : std_logic;
signal LA0_net_0            : std_logic;
signal LA1_net_0            : std_logic;
signal LDCLK_net_0          : std_logic;
signal LDCS_net_0           : std_logic;
signal LDSDI_net_0          : std_logic;
signal SWEEP_SPIDER2_0_DAC1 : std_logic_vector(15 downto 0);
signal SWEEP_SPIDER2_0_DAC2 : std_logic_vector(15 downto 0);
signal SWEEP_SPIDER2_0_DAC3 : std_logic_vector(15 downto 0);
signal SWEEP_SPIDER2_0_DAC4 : std_logic_vector(15 downto 0);
signal SWEEP_SPIDER2_0_SET  : std_logic;
signal ACS_net_1            : std_logic;
signal ACLK_net_1           : std_logic;
signal ACST_net_1           : std_logic;
signal exp_new_data_net_1   : std_logic;
signal LA0_net_1            : std_logic;
signal LA1_net_1            : std_logic;
signal L1WR_net_1           : std_logic;
signal L2WR_net_1           : std_logic;
signal L3WR_net_1           : std_logic;
signal L4WR_net_1           : std_logic;
signal LDCS_net_1           : std_logic;
signal LDSDI_net_1          : std_logic;
signal LDCLK_net_1          : std_logic;
signal ARST_net_1           : std_logic;
signal exp_packet_0_net_0   : std_logic_vector(87 downto 0);
signal chan1_data_net_1     : std_logic_vector(11 downto 0);
signal chan7_data_net_1     : std_logic_vector(11 downto 0);
signal chan3_data_net_1     : std_logic_vector(11 downto 0);
signal chan0_data_net_1     : std_logic_vector(11 downto 0);
signal chan6_data_net_1     : std_logic_vector(11 downto 0);
signal chan4_data_net_1     : std_logic_vector(11 downto 0);
signal chan2_data_net_1     : std_logic_vector(11 downto 0);
signal chan5_data_net_1     : std_logic_vector(11 downto 0);
----------------------------------------------------------------------
-- TiedOff Signals
----------------------------------------------------------------------
signal GND_net              : std_logic;

begin
----------------------------------------------------------------------
-- Constant assignments
----------------------------------------------------------------------
 GND_net <= '0';
----------------------------------------------------------------------
-- Top level output port assignments
----------------------------------------------------------------------
 ACS_net_1               <= ACS_net_0;
 ACS                     <= ACS_net_1;
 ACLK_net_1              <= ACLK_net_0;
 ACLK                    <= ACLK_net_1;
 ACST_net_1              <= ACST_net_0;
 ACST                    <= ACST_net_1;
 exp_new_data_net_1      <= exp_new_data_net_0;
 exp_new_data            <= exp_new_data_net_1;
 LA0_net_1               <= LA0_net_0;
 LA0                     <= LA0_net_1;
 LA1_net_1               <= LA1_net_0;
 LA1                     <= LA1_net_1;
 L1WR_net_1              <= L1WR_net_0;
 L1WR                    <= L1WR_net_1;
 L2WR_net_1              <= L2WR_net_0;
 L2WR                    <= L2WR_net_1;
 L3WR_net_1              <= L3WR_net_0;
 L3WR                    <= L3WR_net_1;
 L4WR_net_1              <= L4WR_net_0;
 L4WR                    <= L4WR_net_1;
 LDCS_net_1              <= LDCS_net_0;
 LDCS                    <= LDCS_net_1;
 LDSDI_net_1             <= LDSDI_net_0;
 LDSDI                   <= LDSDI_net_1;
 LDCLK_net_1             <= LDCLK_net_0;
 LDCLK                   <= LDCLK_net_1;
 ARST_net_1              <= ARST_net_0;
 ARST                    <= ARST_net_1;
 exp_packet_0_net_0      <= exp_packet_0;
 exp_packet(87 downto 0) <= exp_packet_0_net_0;
 chan1_data_net_1        <= chan1_data_net_0;
 chan1_data(11 downto 0) <= chan1_data_net_1;
 chan7_data_net_1        <= chan7_data_net_0;
 chan7_data(11 downto 0) <= chan7_data_net_1;
 chan3_data_net_1        <= chan3_data_net_0;
 chan3_data(11 downto 0) <= chan3_data_net_1;
 chan0_data_net_1        <= chan0_data_net_0;
 chan0_data(11 downto 0) <= chan0_data_net_1;
 chan6_data_net_1        <= chan6_data_net_0;
 chan6_data(11 downto 0) <= chan6_data_net_1;
 chan4_data_net_1        <= chan4_data_net_0;
 chan4_data(11 downto 0) <= chan4_data_net_1;
 chan2_data_net_1        <= chan2_data_net_0;
 chan2_data(11 downto 0) <= chan2_data_net_1;
 chan5_data_net_1        <= chan5_data_net_0;
 chan5_data(11 downto 0) <= chan5_data_net_1;
----------------------------------------------------------------------
-- Component instances
----------------------------------------------------------------------
-- ADC_READ_0
ADC_READ_0 : ADC_READ
    port map( 
        -- Inputs
        RESET        => reset,
        CLK          => clk,
        AA           => AA,
        AB           => AB,
        ABSY         => ABSY,
        RST          => GND_net,
        CNV          => clk_32kHz,
        en_packets   => en_packets,
        SYNC         => GND_net,
        DACA         => SWEEP_SPIDER2_0_DAC1,
        DACB         => SWEEP_SPIDER2_0_DAC2,
        DACC         => SWEEP_SPIDER2_0_DAC3,
        DACD         => SWEEP_SPIDER2_0_DAC4,
        man_gain1    => man_gain1,
        man_gain2    => man_gain2,
        man_gain3    => man_gain3,
        man_gain4    => man_gain4,
        milliseconds => milliseconds,
        -- Outputs
        ACS          => ACS_net_0,
        ACLK         => ACLK_net_0,
        ACST         => ACST_net_0,
        exp_new_data => exp_new_data_net_0,
        exp_packet   => exp_packet_0,
        chan0_data   => chan0_data_net_0,
        chan1_data   => chan1_data_net_0,
        chan2_data   => chan2_data_net_0,
        chan3_data   => chan3_data_net_0,
        chan4_data   => chan4_data_net_0,
        chan5_data   => chan5_data_net_0,
        chan6_data   => chan6_data_net_0,
        chan7_data   => chan7_data_net_0,
        G1           => ADC_READ_0_G1,
        G2           => ADC_READ_0_G2,
        G3           => ADC_READ_0_G3,
        G4           => ADC_READ_0_G4 
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
        DACC      => SWEEP_SPIDER2_0_DAC3,
        DACD      => SWEEP_SPIDER2_0_DAC4,
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
        G3    => ADC_READ_0_G3,
        G4    => ADC_READ_0_G4,
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
        RESET    => reset,
        CLK      => clk,
        CLK_SLOW => clk_1kHz,
        ACTIVATE => sweep_en,
        FFUID    => FFUID,
        -- Outputs
        DAC1     => SWEEP_SPIDER2_0_DAC1,
        DAC2     => SWEEP_SPIDER2_0_DAC2,
        DAC3     => SWEEP_SPIDER2_0_DAC3,
        DAC4     => SWEEP_SPIDER2_0_DAC4,
        SET      => SWEEP_SPIDER2_0_SET 
        );

end RTL;
