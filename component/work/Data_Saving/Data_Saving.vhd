----------------------------------------------------------------------
-- Created by SmartDesign Sun Mar 23 23:24:42 2025
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
-- Data_Saving entity declaration
----------------------------------------------------------------------
entity Data_Saving is
    -- Port list
    port(
        -- Inputs
        ch_0_new_data : in  std_logic;
        clk           : in  std_logic;
        en            : in  std_logic;
        exp_SC_packet : in  std_logic_vector(63 downto 0);
        fmc_clk       : in  std_logic;
        fmc_noe       : in  std_logic;
        reset         : in  std_logic;
        -- Outputs
        fmc_da        : out std_logic_vector(7 downto 0);
        led2          : out std_logic;
        uC_interrupt  : out std_logic
        );
end Data_Saving;
----------------------------------------------------------------------
-- Data_Saving architecture body
----------------------------------------------------------------------
architecture RTL of Data_Saving is
----------------------------------------------------------------------
-- Component declarations
----------------------------------------------------------------------
-- FPGA_Buffer
component FPGA_Buffer
    -- Port list
    port(
        -- Inputs
        data_in  : in  std_logic_vector(31 downto 0);
        r_clk    : in  std_logic;
        re       : in  std_logic;
        reset    : in  std_logic;
        w_clk    : in  std_logic;
        we       : in  std_logic;
        -- Outputs
        afull    : out std_logic;
        data_out : out std_logic_vector(7 downto 0);
        empty    : out std_logic;
        full     : out std_logic
        );
end component;
-- Interrupt_Generator
component Interrupt_Generator
    -- Port list
    port(
        -- Inputs
        afull        : in  std_logic;
        clk          : in  std_logic;
        reset        : in  std_logic;
        -- Outputs
        uC_interrupt : out std_logic
        );
end component;
-- Packet_Saver
component Packet_Saver
    -- Port list
    port(
        -- Inputs
        ch_0_new_data : in  std_logic;
        ch_0_packet   : in  std_logic_vector(63 downto 0);
        clk           : in  std_logic;
        en            : in  std_logic;
        reset         : in  std_logic;
        -- Outputs
        data_out      : out std_logic_vector(31 downto 0);
        we            : out std_logic
        );
end component;
----------------------------------------------------------------------
-- Signal declarations
----------------------------------------------------------------------
signal fmc_da_net_0              : std_logic_vector(7 downto 0);
signal led2_net_0                : std_logic;
signal led2_0                    : std_logic;
signal Packet_Saver_0_data_out_0 : std_logic_vector(31 downto 0);
signal uC_interrupt_net_0        : std_logic;
signal uC_interrupt_net_1        : std_logic;
signal fmc_da_net_1              : std_logic_vector(7 downto 0);
signal led2_0_net_0              : std_logic;

begin
----------------------------------------------------------------------
-- Top level output port assignments
----------------------------------------------------------------------
 uC_interrupt_net_1 <= uC_interrupt_net_0;
 uC_interrupt       <= uC_interrupt_net_1;
 fmc_da_net_1       <= fmc_da_net_0;
 fmc_da(7 downto 0) <= fmc_da_net_1;
 led2_0_net_0       <= led2_0;
 led2               <= led2_0_net_0;
----------------------------------------------------------------------
-- Component instances
----------------------------------------------------------------------
-- FPGA_Buffer_0
FPGA_Buffer_0 : FPGA_Buffer
    port map( 
        -- Inputs
        data_in  => Packet_Saver_0_data_out_0,
        we       => led2_net_0,
        re       => fmc_noe,
        w_clk    => clk,
        r_clk    => fmc_clk,
        reset    => reset,
        -- Outputs
        data_out => fmc_da_net_0,
        full     => OPEN,
        empty    => OPEN,
        afull    => led2_0 
        );
-- Interrupt_Generator_0
Interrupt_Generator_0 : Interrupt_Generator
    port map( 
        -- Inputs
        clk          => clk,
        reset        => reset,
        afull        => led2_0,
        -- Outputs
        uC_interrupt => uC_interrupt_net_0 
        );
-- Packet_Saver_0
Packet_Saver_0 : Packet_Saver
    port map( 
        -- Inputs
        clk           => clk,
        reset         => reset,
        en            => en,
        ch_0_packet   => exp_SC_packet,
        ch_0_new_data => ch_0_new_data,
        -- Outputs
        data_out      => Packet_Saver_0_data_out_0,
        we            => led2_net_0 
        );

end RTL;
