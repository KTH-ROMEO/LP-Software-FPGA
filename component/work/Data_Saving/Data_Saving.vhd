----------------------------------------------------------------------
-- Created by SmartDesign Tue Mar 11 18:06:40 2025
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
        acc_new_data       : in  std_logic;
        acc_packet_0       : in  std_logic_vector(87 downto 0);
        ch_0_new_data      : in  std_logic;
        ch_1_new_data      : in  std_logic;
        ch_1_packet_0      : in  std_logic_vector(87 downto 0);
        ch_2_new_data      : in  std_logic;
        ch_2_packet_0      : in  std_logic_vector(87 downto 0);
        ch_3_new_data      : in  std_logic;
        ch_3_packet_0      : in  std_logic_vector(87 downto 0);
        ch_4_new_data      : in  std_logic;
        ch_4_packet        : in  std_logic_vector(87 downto 0);
        ch_5_new_data      : in  std_logic;
        ch_5_packet        : in  std_logic_vector(87 downto 0);
        clk                : in  std_logic;
        en                 : in  std_logic;
        exp_SC_packet      : in  std_logic_vector(63 downto 0);
        fmc_clk            : in  std_logic;
        fmc_noe            : in  std_logic;
        gyro_new_data      : in  std_logic;
        gyro_packet_0      : in  std_logic_vector(87 downto 0);
        mag_new_data       : in  std_logic;
        mag_packet_0       : in  std_logic_vector(87 downto 0);
        pres_cal1_packet_0 : in  std_logic_vector(87 downto 0);
        pres_cal2_packet_0 : in  std_logic_vector(87 downto 0);
        pres_cal_new_data  : in  std_logic;
        pressure_new_data  : in  std_logic;
        pressure_packet_0  : in  std_logic_vector(87 downto 0);
        reset              : in  std_logic;
        status_new_data    : in  std_logic;
        status_packet_0    : in  std_logic_vector(87 downto 0);
        sync               : in  std_logic;
        -- Outputs
        fmc_da             : out std_logic_vector(7 downto 0);
        uC_interrupt       : out std_logic
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
        acc_new_data      : in  std_logic;
        acc_packet        : in  std_logic_vector(87 downto 0);
        ch_0_new_data     : in  std_logic;
        ch_0_packet       : in  std_logic_vector(63 downto 0);
        ch_1_new_data     : in  std_logic;
        ch_1_packet       : in  std_logic_vector(87 downto 0);
        ch_2_new_data     : in  std_logic;
        ch_2_packet       : in  std_logic_vector(87 downto 0);
        ch_3_new_data     : in  std_logic;
        ch_3_packet       : in  std_logic_vector(87 downto 0);
        ch_4_new_data     : in  std_logic;
        ch_4_packet       : in  std_logic_vector(87 downto 0);
        ch_5_new_data     : in  std_logic;
        ch_5_packet       : in  std_logic_vector(87 downto 0);
        clk               : in  std_logic;
        en                : in  std_logic;
        gyro_new_data     : in  std_logic;
        gyro_packet       : in  std_logic_vector(87 downto 0);
        mag_new_data      : in  std_logic;
        mag_packet        : in  std_logic_vector(87 downto 0);
        pres_cal1_packet  : in  std_logic_vector(87 downto 0);
        pres_cal2_packet  : in  std_logic_vector(87 downto 0);
        pres_cal_new_data : in  std_logic;
        pressure_new_data : in  std_logic;
        pressure_packet   : in  std_logic_vector(87 downto 0);
        reset             : in  std_logic;
        status_new_data   : in  std_logic;
        status_packet     : in  std_logic_vector(87 downto 0);
        sync              : in  std_logic;
        -- Outputs
        data_out          : out std_logic_vector(31 downto 0);
        we                : out std_logic
        );
end component;
----------------------------------------------------------------------
-- Signal declarations
----------------------------------------------------------------------
signal fmc_da_net_0              : std_logic_vector(7 downto 0);
signal FPGA_Buffer_0_afull       : std_logic;
signal Packet_Saver_0_data_out_0 : std_logic_vector(31 downto 0);
signal Packet_Saver_0_we         : std_logic;
signal uC_interrupt_net_0        : std_logic;
signal uC_interrupt_net_1        : std_logic;
signal fmc_da_net_1              : std_logic_vector(7 downto 0);

begin
----------------------------------------------------------------------
-- Top level output port assignments
----------------------------------------------------------------------
 uC_interrupt_net_1 <= uC_interrupt_net_0;
 uC_interrupt       <= uC_interrupt_net_1;
 fmc_da_net_1       <= fmc_da_net_0;
 fmc_da(7 downto 0) <= fmc_da_net_1;
----------------------------------------------------------------------
-- Component instances
----------------------------------------------------------------------
-- FPGA_Buffer_0
FPGA_Buffer_0 : FPGA_Buffer
    port map( 
        -- Inputs
        we       => Packet_Saver_0_we,
        re       => fmc_noe,
        w_clk    => clk,
        r_clk    => fmc_clk,
        reset    => reset,
        data_in  => Packet_Saver_0_data_out_0,
        -- Outputs
        full     => OPEN,
        empty    => OPEN,
        afull    => FPGA_Buffer_0_afull,
        data_out => fmc_da_net_0 
        );
-- Interrupt_Generator_0
Interrupt_Generator_0 : Interrupt_Generator
    port map( 
        -- Inputs
        clk          => clk,
        reset        => reset,
        afull        => FPGA_Buffer_0_afull,
        -- Outputs
        uC_interrupt => uC_interrupt_net_0 
        );
-- Packet_Saver_0
Packet_Saver_0 : Packet_Saver
    port map( 
        -- Inputs
        clk               => clk,
        reset             => reset,
        en                => en,
        sync              => sync,
        acc_new_data      => acc_new_data,
        mag_new_data      => mag_new_data,
        gyro_new_data     => gyro_new_data,
        pressure_new_data => pressure_new_data,
        status_new_data   => status_new_data,
        pres_cal_new_data => pres_cal_new_data,
        ch_0_new_data     => ch_0_new_data,
        ch_1_new_data     => ch_1_new_data,
        ch_2_new_data     => ch_2_new_data,
        ch_3_new_data     => ch_3_new_data,
        ch_4_new_data     => ch_4_new_data,
        ch_5_new_data     => ch_5_new_data,
        acc_packet        => acc_packet_0,
        mag_packet        => mag_packet_0,
        gyro_packet       => gyro_packet_0,
        pressure_packet   => pressure_packet_0,
        status_packet     => status_packet_0,
        pres_cal1_packet  => pres_cal1_packet_0,
        pres_cal2_packet  => pres_cal2_packet_0,
        ch_0_packet       => exp_SC_packet,
        ch_1_packet       => ch_1_packet_0,
        ch_2_packet       => ch_2_packet_0,
        ch_3_packet       => ch_3_packet_0,
        ch_4_packet       => ch_4_packet,
        ch_5_packet       => ch_5_packet,
        -- Outputs
        we                => Packet_Saver_0_we,
        data_out          => Packet_Saver_0_data_out_0 
        );

end RTL;
