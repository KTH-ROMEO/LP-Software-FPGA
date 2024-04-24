----------------------------------------------------------------------
-- Created by SmartDesign Wed Feb 21 17:01:37 2024
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
-- Toplevel entity declaration
----------------------------------------------------------------------
entity Toplevel is
    -- Port list
    port(
        -- Inputs
        AA            : in    std_logic;
        AB            : in    std_logic;
        ABSY          : in    std_logic;
        CLOCK         : in    std_logic;
        CU_SYNC       : in    std_logic;
        EMU_RX        : in    std_logic;
        FFU_EJECTED   : in    std_logic;
        FMC_CLK       : in    std_logic;
        FMC_NE1       : in    std_logic;
        FMC_NOE       : in    std_logic;
        RESET         : in    std_logic;
        TOP_UART_RX   : in    std_logic;
        UC_CONSOLE_EN : in    std_logic;
        UC_I2C4_SCL   : in    std_logic;
        UC_UART_TX    : in    std_logic;
        -- Outputs
        ACCE_SCL      : out   std_logic;
        ACLK          : out   std_logic;
        ACS           : out   std_logic;
        ACST          : out   std_logic;
        ARST          : out   std_logic;
        FMC_DA        : out   std_logic_vector(7 downto 0);
        FPGA_BUF_INT  : out   std_logic;
        FRAM_SCL      : out   std_logic;
        GYRO_SCL      : out   std_logic;
        L1WR          : out   std_logic;
        L2WR          : out   std_logic;
        L3WR          : out   std_logic;
        L4WR          : out   std_logic;
        LA0           : out   std_logic;
        LA1           : out   std_logic;
        LDCLK         : out   std_logic;
        LDCS          : out   std_logic;
        LDSDI         : out   std_logic;
        LED1          : out   std_logic;
        LED2          : out   std_logic;
        PRESSURE_SCL  : out   std_logic;
        SCIENCE_TX    : out   std_logic;
        TOP_UART_TX   : out   std_logic;
        UC_PWR_EN     : out   std_logic;
        UC_RESET      : out   std_logic;
        UC_UART_RX    : out   std_logic;
        -- Inouts
        ACCE_SDA      : inout std_logic;
        FRAM_SDA      : inout std_logic;
        GYRO_SDA      : inout std_logic;
        PRESSURE_SDA  : inout std_logic;
        UC_I2C4_SDA   : inout std_logic
        );
end Toplevel;
----------------------------------------------------------------------
-- Toplevel architecture body
----------------------------------------------------------------------
architecture RTL of Toplevel is
----------------------------------------------------------------------
-- Component declarations
----------------------------------------------------------------------
-- AND2
component AND2
    -- Port list
    port(
        -- Inputs
        A : in  std_logic;
        B : in  std_logic;
        -- Outputs
        Y : out std_logic
        );
end component;
-- CLKINT
component CLKINT
    -- Port list
    port(
        -- Inputs
        A : in  std_logic;
        -- Outputs
        Y : out std_logic
        );
end component;
-- ClockDivs
component ClockDivs
    -- Port list
    port(
        -- Inputs
        clk_32MHz  : in  std_logic;
        reset      : in  std_logic;
        -- Outputs
        clk_16MHz  : out std_logic;
        clk_1Hz    : out std_logic;
        clk_1MHz   : out std_logic;
        clk_1kHz   : out std_logic;
        clk_2MHz   : out std_logic;
        clk_4MHz   : out std_logic;
        clk_4kHz   : out std_logic;
        clk_50Hz   : out std_logic;
        clk_800kHz : out std_logic;
        clk_8MHz   : out std_logic
        );
end component;
-- Communications
component Communications
    -- Port list
    port(
        -- Inputs
        clk           : in  std_logic;
        ext_oen       : in  std_logic;
        ext_send      : in  std_logic_vector(7 downto 0);
        ext_tx        : in  std_logic;
        ext_wen       : in  std_logic;
        reset         : in  std_logic;
        uc_console_en : in  std_logic;
        uc_oen        : in  std_logic;
        uc_send       : in  std_logic_vector(7 downto 0);
        uc_tx         : in  std_logic;
        uc_wen        : in  std_logic;
        unit_id       : in  std_logic_vector(7 downto 0);
        -- Outputs
        ext_recv      : out std_logic_vector(7 downto 0);
        ext_rx        : out std_logic;
        ext_rx_rdy    : out std_logic;
        ext_tx_rdy    : out std_logic;
        uc_recv       : out std_logic_vector(7 downto 0);
        uc_rx         : out std_logic;
        uc_rx_rdy     : out std_logic;
        uc_tx_rdy     : out std_logic
        );
end component;
-- Data_Hub_Packets
component Data_Hub_Packets
    -- Port list
    port(
        -- Inputs
        C1                : in  std_logic_vector(15 downto 0);
        C2                : in  std_logic_vector(15 downto 0);
        C3                : in  std_logic_vector(15 downto 0);
        C4                : in  std_logic_vector(15 downto 0);
        C5                : in  std_logic_vector(15 downto 0);
        C6                : in  std_logic_vector(15 downto 0);
        acc_temp          : in  std_logic_vector(7 downto 0);
        acc_time          : in  std_logic_vector(23 downto 0);
        acc_x             : in  std_logic_vector(11 downto 0);
        acc_y             : in  std_logic_vector(11 downto 0);
        acc_z             : in  std_logic_vector(11 downto 0);
        gyro_temp         : in  std_logic_vector(7 downto 0);
        gyro_time         : in  std_logic_vector(23 downto 0);
        gyro_x            : in  std_logic_vector(15 downto 0);
        gyro_y            : in  std_logic_vector(15 downto 0);
        gyro_z            : in  std_logic_vector(15 downto 0);
        mag_time          : in  std_logic_vector(23 downto 0);
        mag_x             : in  std_logic_vector(11 downto 0);
        mag_y             : in  std_logic_vector(11 downto 0);
        mag_z             : in  std_logic_vector(11 downto 0);
        pressure_raw      : in  std_logic_vector(23 downto 0);
        pressure_temp_raw : in  std_logic_vector(23 downto 0);
        pressure_time     : in  std_logic_vector(23 downto 0);
        status_bits       : in  std_logic_vector(63 downto 0);
        -- Outputs
        acc_packet        : out std_logic_vector(87 downto 0);
        gyro_packet       : out std_logic_vector(87 downto 0);
        mag_packet        : out std_logic_vector(87 downto 0);
        pres_cal1_packet  : out std_logic_vector(87 downto 0);
        pres_cal2_packet  : out std_logic_vector(87 downto 0);
        pressure_packet   : out std_logic_vector(87 downto 0);
        status_packet     : out std_logic_vector(87 downto 0)
        );
end component;
-- Data_Saving
component Data_Saving
    -- Port list
    port(
        -- Inputs
        acc_new_data       : in  std_logic;
        acc_packet_0       : in  std_logic_vector(87 downto 0);
        ch_0_new_data      : in  std_logic;
        ch_0_packet_0      : in  std_logic_vector(87 downto 0);
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
end component;
-- Eject_Signal_Debounce
component Eject_Signal_Debounce
    -- Port list
    port(
        -- Inputs
        clk             : in  std_logic;
        clk_1kHz        : in  std_logic;
        ffu_ejected_in  : in  std_logic;
        reset           : in  std_logic;
        -- Outputs
        ffu_ejected_out : out std_logic
        );
end component;
-- General_Controller
component General_Controller
    -- Port list
    port(
        -- Inputs
        clk                : in  std_logic;
        clk_1Hz            : in  std_logic;
        cu_sync            : in  std_logic;
        ext_recv           : in  std_logic_vector(7 downto 0);
        ext_rx_rdy         : in  std_logic;
        ffu_ejected        : in  std_logic;
        low_pressure       : in  std_logic;
        milliseconds       : in  std_logic_vector(23 downto 0);
        reset              : in  std_logic;
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
-- GS_Readout
component GS_Readout
    -- Port list
    port(
        -- Inputs
        ch0_data    : in  std_logic_vector(11 downto 0);
        ch10_data   : in  std_logic_vector(11 downto 0);
        ch11_data   : in  std_logic_vector(11 downto 0);
        ch1_data    : in  std_logic_vector(11 downto 0);
        ch2_data    : in  std_logic_vector(11 downto 0);
        ch3_data    : in  std_logic_vector(11 downto 0);
        ch4_data    : in  std_logic_vector(11 downto 0);
        ch5_data    : in  std_logic_vector(11 downto 0);
        ch6_data    : in  std_logic_vector(11 downto 0);
        ch7_data    : in  std_logic_vector(11 downto 0);
        ch8_data    : in  std_logic_vector(11 downto 0);
        ch9_data    : in  std_logic_vector(11 downto 0);
        clk         : in  std_logic;
        enable      : in  std_logic;
        gs_id       : in  std_logic_vector(7 downto 0);
        reset       : in  std_logic;
        status_bits : in  std_logic_vector(63 downto 0);
        txrdy       : in  std_logic;
        -- Outputs
        busy        : out std_logic;
        send        : out std_logic_vector(7 downto 0);
        wen         : out std_logic
        );
end component;
-- I2C_PassThrough
component I2C_PassThrough
    -- Port list
    port(
        -- Inputs
        clk   : in    std_logic;
        reset : in    std_logic;
        scl_m : in    std_logic;
        -- Outputs
        scl_s : out   std_logic;
        -- Inouts
        sda_m : inout std_logic;
        sda_s : inout std_logic
        );
end component;
-- Pressure_Signal_Debounce
component Pressure_Signal_Debounce
    -- Port list
    port(
        -- Inputs
        clk_1kHz     : in  std_logic;
        pressure     : in  std_logic_vector(23 downto 0);
        reset        : in  std_logic;
        -- Outputs
        low_pressure : out std_logic
        );
end component;
-- Science
component Science
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
end component;
-- Sensors
component Sensors
    -- Port list
    port(
        -- Inputs
        clk               : in    std_logic;
        clk_1kHz          : in    std_logic;
        en                : in    std_logic;
        i2c_clk           : in    std_logic;
        microseconds      : in    std_logic_vector(23 downto 0);
        reset             : in    std_logic;
        -- Outputs
        C1                : out   std_logic_vector(15 downto 0);
        C2                : out   std_logic_vector(15 downto 0);
        C3                : out   std_logic_vector(15 downto 0);
        C4                : out   std_logic_vector(15 downto 0);
        C5                : out   std_logic_vector(15 downto 0);
        C6                : out   std_logic_vector(15 downto 0);
        acc_new_data      : out   std_logic;
        acc_temp          : out   std_logic_vector(7 downto 0);
        acc_time          : out   std_logic_vector(23 downto 0);
        acc_x             : out   std_logic_vector(11 downto 0);
        acc_y             : out   std_logic_vector(11 downto 0);
        acc_z             : out   std_logic_vector(11 downto 0);
        acce_scl          : out   std_logic;
        gyro_new_data     : out   std_logic;
        gyro_scl          : out   std_logic;
        gyro_temp         : out   std_logic_vector(7 downto 0);
        gyro_time         : out   std_logic_vector(23 downto 0);
        gyro_x            : out   std_logic_vector(15 downto 0);
        gyro_y            : out   std_logic_vector(15 downto 0);
        gyro_z            : out   std_logic_vector(15 downto 0);
        mag_new_data      : out   std_logic;
        mag_time          : out   std_logic_vector(23 downto 0);
        mag_x             : out   std_logic_vector(11 downto 0);
        mag_y             : out   std_logic_vector(11 downto 0);
        mag_z             : out   std_logic_vector(11 downto 0);
        pres_cal_new_data : out   std_logic;
        pressure_new_data : out   std_logic;
        pressure_raw      : out   std_logic_vector(23 downto 0);
        pressure_scl      : out   std_logic;
        pressure_temp_raw : out   std_logic_vector(23 downto 0);
        pressure_time     : out   std_logic_vector(23 downto 0);
        -- Inouts
        acce_sda          : inout std_logic;
        gyro_sda          : inout std_logic;
        pressure_sda      : inout std_logic
        );
end component;
-- Timekeeper
component Timekeeper
    -- Port list
    port(
        -- Inputs
        clk          : in  std_logic;
        clk_1Hz      : in  std_logic;
        clk_1MHz     : in  std_logic;
        clk_1kHz     : in  std_logic;
        reset        : in  std_logic;
        -- Outputs
        microseconds : out std_logic_vector(23 downto 0);
        milliseconds : out std_logic_vector(23 downto 0);
        seconds      : out std_logic_vector(19 downto 0)
        );
end component;
-- Timing
component Timing
    -- Port list
    port(
        -- Inputs
        clk    : in  std_logic;
        reset  : in  std_logic;
        -- Outputs
        s_clks : out std_logic_vector(24 downto 0)
        );
end component;
----------------------------------------------------------------------
-- Signal declarations
----------------------------------------------------------------------
signal ACCE_SCL_net_0                          : std_logic;
signal ACLK_net_0                              : std_logic;
signal ACS_net_0                               : std_logic;
signal ACST_net_0                              : std_logic;
signal AND2_0_Y                                : std_logic;
signal ARST_net_0                              : std_logic;
signal CLKINT_0_Y_0                            : std_logic;
signal CLKINT_1_Y                              : std_logic;
signal CLKINT_2_Y                              : std_logic;
signal ClockDivs_0_clk_800kHz                  : std_logic;
signal Communications_0_ext_recv               : std_logic_vector(7 downto 0);
signal Communications_0_ext_rx_rdy             : std_logic;
signal Communications_0_ext_tx_rdy             : std_logic;
signal Communications_0_uc_recv                : std_logic_vector(7 downto 0);
signal Communications_0_uc_rx_rdy              : std_logic;
signal Communications_0_uc_tx_rdy              : std_logic;
signal Data_Hub_Packets_0_acc_packet           : std_logic_vector(87 downto 0);
signal Data_Hub_Packets_0_gyro_packet          : std_logic_vector(87 downto 0);
signal Data_Hub_Packets_0_mag_packet           : std_logic_vector(87 downto 0);
signal Data_Hub_Packets_0_pres_cal1_packet     : std_logic_vector(87 downto 0);
signal Data_Hub_Packets_0_pres_cal2_packet     : std_logic_vector(87 downto 0);
signal Data_Hub_Packets_0_pressure_packet      : std_logic_vector(87 downto 0);
signal Data_Hub_Packets_0_status_packet        : std_logic_vector(87 downto 0);
signal Eject_Signal_Debounce_0_ffu_ejected_out : std_logic;
signal FMC_DA_net_0                            : std_logic_vector(7 downto 0);
signal FPGA_BUF_INT_net_0                      : std_logic;
signal FRAM_SCL_net_0                          : std_logic;
signal General_Controller_0_en_data_saving     : std_logic;
signal General_Controller_0_en_science_packets : std_logic;
signal General_Controller_0_en_sensors         : std_logic;
signal General_Controller_0_exp_adc_reset      : std_logic;
signal General_Controller_0_ext_oen            : std_logic;
signal General_Controller_0_ffu_id             : std_logic_vector(7 downto 0);
signal General_Controller_0_gs_id              : std_logic_vector(7 downto 0);
signal General_Controller_0_man_gain1          : std_logic_vector(1 downto 0);
signal General_Controller_0_man_gain2          : std_logic_vector(1 downto 0);
signal General_Controller_0_man_gain3          : std_logic_vector(1 downto 0);
signal General_Controller_0_man_gain4          : std_logic_vector(1 downto 0);
signal General_Controller_0_readout_en         : std_logic;
signal General_Controller_0_status_bits        : std_logic_vector(63 downto 0);
signal General_Controller_0_status_new_data    : std_logic;
signal General_Controller_0_sweep_en           : std_logic;
signal General_Controller_0_uc_oen             : std_logic;
signal General_Controller_0_uc_send            : std_logic_vector(7 downto 0);
signal General_Controller_0_uc_wen             : std_logic;
signal General_Controller_0_unit_id            : std_logic_vector(7 downto 0);
signal GS_Readout_0_send                       : std_logic_vector(7 downto 0);
signal GS_Readout_0_wen                        : std_logic;
signal GYRO_SCL_net_0                          : std_logic;
signal L1WR_net_0                              : std_logic;
signal L2WR_net_0                              : std_logic;
signal L3WR_net_0                              : std_logic;
signal L4WR_net_0                              : std_logic;
signal LA0_net_0                               : std_logic;
signal LA1_net_0                               : std_logic;
signal LDCLK_net_0                             : std_logic;
signal LDCS_net_0                              : std_logic;
signal LDSDI_net_0                             : std_logic;
signal LED1_0                                  : std_logic;
signal LED2_net_0                              : std_logic;
signal PRESSURE_SCL_net_0                      : std_logic;
signal Pressure_Signal_Debounce_0_low_pressure : std_logic;
signal Science_0_chan0_data                    : std_logic_vector(11 downto 0);
signal Science_0_chan1_data                    : std_logic_vector(11 downto 0);
signal Science_0_chan2_data                    : std_logic_vector(11 downto 0);
signal Science_0_chan3_data                    : std_logic_vector(11 downto 0);
signal Science_0_chan4_data                    : std_logic_vector(11 downto 0);
signal Science_0_chan5_data                    : std_logic_vector(11 downto 0);
signal Science_0_chan6_data                    : std_logic_vector(11 downto 0);
signal Science_0_chan7_data                    : std_logic_vector(11 downto 0);
signal Science_0_exp_new_data                  : std_logic;
signal Science_0_exp_packet_0                  : std_logic_vector(87 downto 0);
signal Sensors_0_acc_new_data                  : std_logic;
signal Sensors_0_acc_temp                      : std_logic_vector(7 downto 0);
signal Sensors_0_acc_time                      : std_logic_vector(23 downto 0);
signal Sensors_0_acc_x                         : std_logic_vector(11 downto 0);
signal Sensors_0_acc_y                         : std_logic_vector(11 downto 0);
signal Sensors_0_acc_z                         : std_logic_vector(11 downto 0);
signal Sensors_0_C1                            : std_logic_vector(15 downto 0);
signal Sensors_0_C2                            : std_logic_vector(15 downto 0);
signal Sensors_0_C3                            : std_logic_vector(15 downto 0);
signal Sensors_0_C4                            : std_logic_vector(15 downto 0);
signal Sensors_0_C5                            : std_logic_vector(15 downto 0);
signal Sensors_0_C6                            : std_logic_vector(15 downto 0);
signal Sensors_0_gyro_new_data                 : std_logic;
signal Sensors_0_gyro_temp                     : std_logic_vector(7 downto 0);
signal Sensors_0_gyro_time                     : std_logic_vector(23 downto 0);
signal Sensors_0_gyro_x                        : std_logic_vector(15 downto 0);
signal Sensors_0_gyro_y                        : std_logic_vector(15 downto 0);
signal Sensors_0_gyro_z                        : std_logic_vector(15 downto 0);
signal Sensors_0_gyro_z7to4                    : std_logic_vector(7 downto 4);
signal Sensors_0_gyro_z11to8                   : std_logic_vector(11 downto 8);
signal Sensors_0_gyro_z15to12                  : std_logic_vector(15 downto 12);
signal Sensors_0_mag_new_data                  : std_logic;
signal Sensors_0_mag_time                      : std_logic_vector(23 downto 0);
signal Sensors_0_mag_x                         : std_logic_vector(11 downto 0);
signal Sensors_0_mag_y                         : std_logic_vector(11 downto 0);
signal Sensors_0_mag_z                         : std_logic_vector(11 downto 0);
signal Sensors_0_pres_cal_new_data             : std_logic;
signal Sensors_0_pressure_new_data             : std_logic;
signal Sensors_0_pressure_raw                  : std_logic_vector(23 downto 0);
signal Sensors_0_pressure_raw23to12            : std_logic_vector(23 downto 12);
signal Sensors_0_pressure_temp_raw             : std_logic_vector(23 downto 0);
signal Sensors_0_pressure_temp_raw23to12       : std_logic_vector(23 downto 12);
signal Sensors_0_pressure_time                 : std_logic_vector(23 downto 0);
signal Timekeeper_0_microseconds               : std_logic_vector(23 downto 0);
signal Timekeeper_0_milliseconds               : std_logic_vector(23 downto 0);
signal Timing_0_s_clks4to4                     : std_logic_vector(4 to 4);
signal Timing_0_s_clks9to9                     : std_logic_vector(9 to 9);
signal Timing_0_s_clks14to14                   : std_logic_vector(14 to 14);
signal Timing_0_s_clks18to18                   : std_logic_vector(18 to 18);
signal Timing_0_s_clks20to20                   : std_logic_vector(20 to 20);
signal Timing_0_s_clks24to24                   : std_logic_vector(24 to 24);
signal TOP_UART_TX_net_0                       : std_logic;
signal UC_PWR_EN_net_0                         : std_logic;
signal UC_RESET_net_0                          : std_logic;
signal UC_UART_RX_net_0                        : std_logic;
signal FPGA_BUF_INT_net_1                      : std_logic;
signal PRESSURE_SCL_net_1                      : std_logic;
signal UC_UART_RX_net_1                        : std_logic;
signal TOP_UART_TX_net_1                       : std_logic;
signal GYRO_SCL_net_1                          : std_logic;
signal ACCE_SCL_net_1                          : std_logic;
signal LED1_0_net_0                            : std_logic;
signal LED2_net_1                              : std_logic;
signal UC_PWR_EN_net_1                         : std_logic;
signal UC_RESET_net_1                          : std_logic;
signal FRAM_SCL_net_1                          : std_logic;
signal TOP_UART_TX_net_2                       : std_logic;
signal ACS_net_1                               : std_logic;
signal ACLK_net_1                              : std_logic;
signal ACST_net_1                              : std_logic;
signal L1WR_net_1                              : std_logic;
signal L2WR_net_1                              : std_logic;
signal L3WR_net_1                              : std_logic;
signal L4WR_net_1                              : std_logic;
signal LDCS_net_1                              : std_logic;
signal LDSDI_net_1                             : std_logic;
signal LDCLK_net_1                             : std_logic;
signal LA0_net_1                               : std_logic;
signal LA1_net_1                               : std_logic;
signal ARST_net_1                              : std_logic;
signal FMC_DA_net_1                            : std_logic_vector(7 downto 0);
signal gyro_z_slice_0                          : std_logic_vector(3 downto 0);
signal pressure_raw_slice_0                    : std_logic_vector(11 downto 0);
signal pressure_temp_raw_slice_0               : std_logic_vector(11 downto 0);
signal s_clks_slice_0                          : std_logic_vector(0 to 0);
signal s_clks_slice_1                          : std_logic_vector(10 to 10);
signal s_clks_slice_2                          : std_logic_vector(11 to 11);
signal s_clks_slice_3                          : std_logic_vector(12 to 12);
signal s_clks_slice_4                          : std_logic_vector(13 to 13);
signal s_clks_slice_5                          : std_logic_vector(15 to 15);
signal s_clks_slice_6                          : std_logic_vector(16 to 16);
signal s_clks_slice_7                          : std_logic_vector(17 to 17);
signal s_clks_slice_8                          : std_logic_vector(19 to 19);
signal s_clks_slice_9                          : std_logic_vector(1 to 1);
signal s_clks_slice_10                         : std_logic_vector(21 to 21);
signal s_clks_slice_11                         : std_logic_vector(22 to 22);
signal s_clks_slice_12                         : std_logic_vector(23 to 23);
signal s_clks_slice_13                         : std_logic_vector(2 to 2);
signal s_clks_slice_14                         : std_logic_vector(3 to 3);
signal s_clks_slice_15                         : std_logic_vector(5 to 5);
signal s_clks_slice_16                         : std_logic_vector(6 to 6);
signal s_clks_slice_17                         : std_logic_vector(7 to 7);
signal s_clks_slice_18                         : std_logic_vector(8 to 8);
signal ch3_data_net_0                          : std_logic_vector(11 downto 0);
signal s_clks_net_0                            : std_logic_vector(24 downto 0);
----------------------------------------------------------------------
-- TiedOff Signals
----------------------------------------------------------------------
signal GND_net                                 : std_logic;
signal ch_1_packet_0_const_net_0               : std_logic_vector(87 downto 0);
signal ch_2_packet_0_const_net_0               : std_logic_vector(87 downto 0);
signal ch_3_packet_0_const_net_0               : std_logic_vector(87 downto 0);
signal ch_4_packet_const_net_0                 : std_logic_vector(87 downto 0);
signal ch_5_packet_const_net_0                 : std_logic_vector(87 downto 0);
----------------------------------------------------------------------
-- Inverted Signals
----------------------------------------------------------------------
signal FFU_EJECTED_IN_POST_INV0_0              : std_logic;

begin
----------------------------------------------------------------------
-- Constant assignments
----------------------------------------------------------------------
 GND_net                   <= '0';
 ch_1_packet_0_const_net_0 <= B"0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
 ch_2_packet_0_const_net_0 <= B"0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
 ch_3_packet_0_const_net_0 <= B"0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
 ch_4_packet_const_net_0   <= B"0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
 ch_5_packet_const_net_0   <= B"0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
----------------------------------------------------------------------
-- Inversions
----------------------------------------------------------------------
 FFU_EJECTED_IN_POST_INV0_0 <= NOT FFU_EJECTED;
----------------------------------------------------------------------
-- Top level output port assignments
----------------------------------------------------------------------
 FPGA_BUF_INT_net_1 <= FPGA_BUF_INT_net_0;
 FPGA_BUF_INT       <= FPGA_BUF_INT_net_1;
 PRESSURE_SCL_net_1 <= PRESSURE_SCL_net_0;
 PRESSURE_SCL       <= PRESSURE_SCL_net_1;
 UC_UART_RX_net_1   <= UC_UART_RX_net_0;
 UC_UART_RX         <= UC_UART_RX_net_1;
 TOP_UART_TX_net_1  <= TOP_UART_TX_net_0;
 TOP_UART_TX        <= TOP_UART_TX_net_1;
 GYRO_SCL_net_1     <= GYRO_SCL_net_0;
 GYRO_SCL           <= GYRO_SCL_net_1;
 ACCE_SCL_net_1     <= ACCE_SCL_net_0;
 ACCE_SCL           <= ACCE_SCL_net_1;
 LED1_0_net_0       <= LED1_0;
 LED1               <= LED1_0_net_0;
 LED2_net_1         <= LED2_net_0;
 LED2               <= LED2_net_1;
 UC_PWR_EN_net_1    <= UC_PWR_EN_net_0;
 UC_PWR_EN          <= UC_PWR_EN_net_1;
 UC_RESET_net_1     <= UC_RESET_net_0;
 UC_RESET           <= UC_RESET_net_1;
 FRAM_SCL_net_1     <= FRAM_SCL_net_0;
 FRAM_SCL           <= FRAM_SCL_net_1;
 TOP_UART_TX_net_2  <= TOP_UART_TX_net_0;
 SCIENCE_TX         <= TOP_UART_TX_net_2;
 ACS_net_1          <= ACS_net_0;
 ACS                <= ACS_net_1;
 ACLK_net_1         <= ACLK_net_0;
 ACLK               <= ACLK_net_1;
 ACST_net_1         <= ACST_net_0;
 ACST               <= ACST_net_1;
 L1WR_net_1         <= L1WR_net_0;
 L1WR               <= L1WR_net_1;
 L2WR_net_1         <= L2WR_net_0;
 L2WR               <= L2WR_net_1;
 L3WR_net_1         <= L3WR_net_0;
 L3WR               <= L3WR_net_1;
 L4WR_net_1         <= L4WR_net_0;
 L4WR               <= L4WR_net_1;
 LDCS_net_1         <= LDCS_net_0;
 LDCS               <= LDCS_net_1;
 LDSDI_net_1        <= LDSDI_net_0;
 LDSDI              <= LDSDI_net_1;
 LDCLK_net_1        <= LDCLK_net_0;
 LDCLK              <= LDCLK_net_1;
 LA0_net_1          <= LA0_net_0;
 LA0                <= LA0_net_1;
 LA1_net_1          <= LA1_net_0;
 LA1                <= LA1_net_1;
 ARST_net_1         <= ARST_net_0;
 ARST               <= ARST_net_1;
 FMC_DA_net_1       <= FMC_DA_net_0;
 FMC_DA(7 downto 0) <= FMC_DA_net_1;
----------------------------------------------------------------------
-- Slices assignments
----------------------------------------------------------------------
 Sensors_0_gyro_z7to4              <= Sensors_0_gyro_z(7 downto 4);
 Sensors_0_gyro_z11to8             <= Sensors_0_gyro_z(11 downto 8);
 Sensors_0_gyro_z15to12            <= Sensors_0_gyro_z(15 downto 12);
 Sensors_0_pressure_raw23to12      <= Sensors_0_pressure_raw(23 downto 12);
 Sensors_0_pressure_temp_raw23to12 <= Sensors_0_pressure_temp_raw(23 downto 12);
 Timing_0_s_clks4to4(4)            <= s_clks_net_0(4);
 Timing_0_s_clks9to9(9)            <= s_clks_net_0(9);
 Timing_0_s_clks14to14(14)         <= s_clks_net_0(14);
 Timing_0_s_clks18to18(18)         <= s_clks_net_0(18);
 Timing_0_s_clks20to20(20)         <= s_clks_net_0(20);
 Timing_0_s_clks24to24(24)         <= s_clks_net_0(24);
 gyro_z_slice_0                    <= Sensors_0_gyro_z(3 downto 0);
 pressure_raw_slice_0              <= Sensors_0_pressure_raw(11 downto 0);
 pressure_temp_raw_slice_0         <= Sensors_0_pressure_temp_raw(11 downto 0);
 s_clks_slice_0(0)                 <= s_clks_net_0(0);
 s_clks_slice_1(10)                <= s_clks_net_0(10);
 s_clks_slice_2(11)                <= s_clks_net_0(11);
 s_clks_slice_3(12)                <= s_clks_net_0(12);
 s_clks_slice_4(13)                <= s_clks_net_0(13);
 s_clks_slice_5(15)                <= s_clks_net_0(15);
 s_clks_slice_6(16)                <= s_clks_net_0(16);
 s_clks_slice_7(17)                <= s_clks_net_0(17);
 s_clks_slice_8(19)                <= s_clks_net_0(19);
 s_clks_slice_9(1)                 <= s_clks_net_0(1);
 s_clks_slice_10(21)               <= s_clks_net_0(21);
 s_clks_slice_11(22)               <= s_clks_net_0(22);
 s_clks_slice_12(23)               <= s_clks_net_0(23);
 s_clks_slice_13(2)                <= s_clks_net_0(2);
 s_clks_slice_14(3)                <= s_clks_net_0(3);
 s_clks_slice_15(5)                <= s_clks_net_0(5);
 s_clks_slice_16(6)                <= s_clks_net_0(6);
 s_clks_slice_17(7)                <= s_clks_net_0(7);
 s_clks_slice_18(8)                <= s_clks_net_0(8);
----------------------------------------------------------------------
-- Concatenation assignments
----------------------------------------------------------------------
 ch3_data_net_0 <= ( Sensors_0_gyro_z15to12 & Sensors_0_gyro_z11to8 & Sensors_0_gyro_z7to4 );
----------------------------------------------------------------------
-- Component instances
----------------------------------------------------------------------
-- AND2_0
AND2_0 : AND2
    port map( 
        -- Inputs
        A => TOP_UART_RX,
        B => EMU_RX,
        -- Outputs
        Y => AND2_0_Y 
        );
-- CLKINT_0
CLKINT_0 : CLKINT
    port map( 
        -- Inputs
        A => CLOCK,
        -- Outputs
        Y => CLKINT_0_Y_0 
        );
-- CLKINT_1
CLKINT_1 : CLKINT
    port map( 
        -- Inputs
        A => RESET,
        -- Outputs
        Y => CLKINT_1_Y 
        );
-- CLKINT_2
CLKINT_2 : CLKINT
    port map( 
        -- Inputs
        A => FMC_CLK,
        -- Outputs
        Y => CLKINT_2_Y 
        );
-- ClockDivs_0
ClockDivs_0 : ClockDivs
    port map( 
        -- Inputs
        clk_32MHz  => CLKINT_0_Y_0,
        reset      => CLKINT_1_Y,
        -- Outputs
        clk_16MHz  => OPEN,
        clk_8MHz   => OPEN,
        clk_4MHz   => OPEN,
        clk_2MHz   => OPEN,
        clk_1MHz   => OPEN,
        clk_800kHz => ClockDivs_0_clk_800kHz,
        clk_4kHz   => OPEN,
        clk_1kHz   => OPEN,
        clk_50Hz   => OPEN,
        clk_1Hz    => OPEN 
        );
-- Communications_0
Communications_0 : Communications
    port map( 
        -- Inputs
        clk           => CLKINT_0_Y_0,
        reset         => CLKINT_1_Y,
        ext_tx        => AND2_0_Y,
        uc_tx         => UC_UART_TX,
        uc_console_en => UC_CONSOLE_EN,
        uc_oen        => General_Controller_0_uc_oen,
        uc_wen        => General_Controller_0_uc_wen,
        ext_wen       => GS_Readout_0_wen,
        ext_oen       => General_Controller_0_ext_oen,
        uc_send       => General_Controller_0_uc_send,
        ext_send      => GS_Readout_0_send,
        unit_id       => General_Controller_0_unit_id,
        -- Outputs
        uc_rx         => UC_UART_RX_net_0,
        ext_rx        => TOP_UART_TX_net_0,
        uc_tx_rdy     => Communications_0_uc_tx_rdy,
        uc_rx_rdy     => Communications_0_uc_rx_rdy,
        ext_rx_rdy    => Communications_0_ext_rx_rdy,
        ext_tx_rdy    => Communications_0_ext_tx_rdy,
        uc_recv       => Communications_0_uc_recv,
        ext_recv      => Communications_0_ext_recv 
        );
-- Data_Hub_Packets_0
Data_Hub_Packets_0 : Data_Hub_Packets
    port map( 
        -- Inputs
        acc_time          => Sensors_0_acc_time,
        acc_x             => Sensors_0_acc_x,
        acc_y             => Sensors_0_acc_y,
        acc_z             => Sensors_0_acc_z,
        acc_temp          => Sensors_0_acc_temp,
        mag_time          => Sensors_0_mag_time,
        mag_x             => Sensors_0_mag_x,
        mag_y             => Sensors_0_mag_y,
        mag_z             => Sensors_0_mag_z,
        gyro_time         => Sensors_0_gyro_time,
        gyro_x            => Sensors_0_gyro_x,
        gyro_y            => Sensors_0_gyro_y,
        gyro_z            => Sensors_0_gyro_z,
        gyro_temp         => Sensors_0_gyro_temp,
        pressure_time     => Sensors_0_pressure_time,
        pressure_raw      => Sensors_0_pressure_raw,
        pressure_temp_raw => Sensors_0_pressure_temp_raw,
        C1                => Sensors_0_C1,
        C2                => Sensors_0_C2,
        C3                => Sensors_0_C3,
        C4                => Sensors_0_C4,
        C5                => Sensors_0_C5,
        C6                => Sensors_0_C6,
        status_bits       => General_Controller_0_status_bits,
        -- Outputs
        acc_packet        => Data_Hub_Packets_0_acc_packet,
        mag_packet        => Data_Hub_Packets_0_mag_packet,
        gyro_packet       => Data_Hub_Packets_0_gyro_packet,
        pressure_packet   => Data_Hub_Packets_0_pressure_packet,
        pres_cal1_packet  => Data_Hub_Packets_0_pres_cal1_packet,
        pres_cal2_packet  => Data_Hub_Packets_0_pres_cal2_packet,
        status_packet     => Data_Hub_Packets_0_status_packet 
        );
-- Data_Saving_0
Data_Saving_0 : Data_Saving
    port map( 
        -- Inputs
        clk                => CLKINT_0_Y_0,
        reset              => CLKINT_1_Y,
        fmc_clk            => CLKINT_2_Y,
        en                 => General_Controller_0_en_data_saving,
        acc_new_data       => Sensors_0_acc_new_data,
        mag_new_data       => Sensors_0_mag_new_data,
        gyro_new_data      => Sensors_0_gyro_new_data,
        pressure_new_data  => Sensors_0_pressure_new_data,
        pres_cal_new_data  => Sensors_0_pres_cal_new_data,
        status_new_data    => General_Controller_0_status_new_data,
        fmc_noe            => FMC_NOE,
        ch_0_new_data      => Science_0_exp_new_data,
        ch_1_new_data      => GND_net,
        ch_2_new_data      => GND_net,
        ch_3_new_data      => GND_net,
        ch_4_new_data      => GND_net,
        ch_5_new_data      => GND_net,
        sync               => CU_SYNC,
        acc_packet_0       => Data_Hub_Packets_0_acc_packet,
        mag_packet_0       => Data_Hub_Packets_0_mag_packet,
        gyro_packet_0      => Data_Hub_Packets_0_gyro_packet,
        pressure_packet_0  => Data_Hub_Packets_0_pressure_packet,
        status_packet_0    => Data_Hub_Packets_0_status_packet,
        pres_cal1_packet_0 => Data_Hub_Packets_0_pres_cal1_packet,
        pres_cal2_packet_0 => Data_Hub_Packets_0_pres_cal2_packet,
        ch_0_packet_0      => Science_0_exp_packet_0,
        ch_1_packet_0      => ch_1_packet_0_const_net_0,
        ch_2_packet_0      => ch_2_packet_0_const_net_0,
        ch_3_packet_0      => ch_3_packet_0_const_net_0,
        ch_4_packet        => ch_4_packet_const_net_0,
        ch_5_packet        => ch_5_packet_const_net_0,
        -- Outputs
        uC_interrupt       => FPGA_BUF_INT_net_0,
        fmc_da             => FMC_DA_net_0 
        );
-- Eject_Signal_Debounce_0
Eject_Signal_Debounce_0 : Eject_Signal_Debounce
    port map( 
        -- Inputs
        clk             => CLKINT_0_Y_0,
        clk_1kHz        => Timing_0_s_clks14to14(14),
        reset           => CLKINT_1_Y,
        ffu_ejected_in  => FFU_EJECTED_IN_POST_INV0_0,
        -- Outputs
        ffu_ejected_out => Eject_Signal_Debounce_0_ffu_ejected_out 
        );
-- General_Controller_0
General_Controller_0 : General_Controller
    port map( 
        -- Inputs
        clk                => CLKINT_0_Y_0,
        clk_1Hz            => Timing_0_s_clks24to24(24),
        reset              => CLKINT_1_Y,
        status_packet_clk  => Timing_0_s_clks18to18(18),
        ffu_ejected        => Eject_Signal_Debounce_0_ffu_ejected_out,
        low_pressure       => Pressure_Signal_Debounce_0_low_pressure,
        ext_rx_rdy         => Communications_0_ext_rx_rdy,
        uc_tx_rdy          => Communications_0_uc_tx_rdy,
        uc_rx_rdy          => Communications_0_uc_rx_rdy,
        cu_sync            => CU_SYNC,
        milliseconds       => Timekeeper_0_milliseconds,
        ext_recv           => Communications_0_ext_recv,
        uc_recv            => Communications_0_uc_recv,
        -- Outputs
        uc_wen             => General_Controller_0_uc_wen,
        uc_oen             => General_Controller_0_uc_oen,
        ext_oen            => General_Controller_0_ext_oen,
        readout_en         => General_Controller_0_readout_en,
        uc_reset           => UC_RESET_net_0,
        uc_pwr_en          => UC_PWR_EN_net_0,
        en_sensors         => General_Controller_0_en_sensors,
        en_data_saving     => General_Controller_0_en_data_saving,
        led1               => LED1_0,
        led2               => LED2_net_0,
        status_new_data    => General_Controller_0_status_new_data,
        en_science_packets => General_Controller_0_en_science_packets,
        sweep_en           => General_Controller_0_sweep_en,
        exp_adc_reset      => General_Controller_0_exp_adc_reset,
        DAC_zero_value     => OPEN,
        DAC_max_value      => OPEN,
        unit_id            => General_Controller_0_unit_id,
        ffu_id             => General_Controller_0_ffu_id,
        gs_id              => General_Controller_0_gs_id,
        uc_send            => General_Controller_0_uc_send,
        status_bits        => General_Controller_0_status_bits,
        ramp               => OPEN,
        man_gain1          => General_Controller_0_man_gain1,
        man_gain2          => General_Controller_0_man_gain2,
        man_gain3          => General_Controller_0_man_gain3,
        man_gain4          => General_Controller_0_man_gain4 
        );
-- GS_Readout_0
GS_Readout_0 : GS_Readout
    port map( 
        -- Inputs
        clk         => CLKINT_0_Y_0,
        reset       => CLKINT_1_Y,
        enable      => General_Controller_0_readout_en,
        txrdy       => Communications_0_ext_tx_rdy,
        gs_id       => General_Controller_0_gs_id,
        ch0_data    => Sensors_0_pressure_raw23to12,
        ch1_data    => Sensors_0_pressure_temp_raw23to12,
        ch2_data    => Sensors_0_acc_z,
        ch3_data    => ch3_data_net_0,
        ch4_data    => Science_0_chan0_data,
        ch5_data    => Science_0_chan1_data,
        ch6_data    => Science_0_chan2_data,
        ch7_data    => Science_0_chan3_data,
        ch8_data    => Science_0_chan4_data,
        ch9_data    => Science_0_chan5_data,
        ch10_data   => Science_0_chan6_data,
        ch11_data   => Science_0_chan7_data,
        status_bits => General_Controller_0_status_bits,
        -- Outputs
        wen         => GS_Readout_0_wen,
        busy        => OPEN,
        send        => GS_Readout_0_send 
        );
-- I2C_PassThrough_0
I2C_PassThrough_0 : I2C_PassThrough
    port map( 
        -- Inputs
        clk   => CLKINT_0_Y_0,
        reset => CLKINT_1_Y,
        scl_m => UC_I2C4_SCL,
        -- Outputs
        scl_s => FRAM_SCL_net_0,
        -- Inouts
        sda_m => UC_I2C4_SDA,
        sda_s => FRAM_SDA 
        );
-- Pressure_Signal_Debounce_0
Pressure_Signal_Debounce_0 : Pressure_Signal_Debounce
    port map( 
        -- Inputs
        clk_1kHz     => Timing_0_s_clks14to14(14),
        reset        => CLKINT_1_Y,
        pressure     => Sensors_0_pressure_raw,
        -- Outputs
        low_pressure => Pressure_Signal_Debounce_0_low_pressure 
        );
-- Science_0
Science_0 : Science
    port map( 
        -- Inputs
        AA            => AA,
        AB            => AB,
        ABSY          => ABSY,
        clk_32kHz     => Timing_0_s_clks9to9(9),
        clk           => CLKINT_0_Y_0,
        reset         => CLKINT_1_Y,
        sweep_en      => General_Controller_0_sweep_en,
        clk_1kHz      => Timing_0_s_clks14to14(14),
        exp_adc_reset => General_Controller_0_exp_adc_reset,
        clk_16Hz      => Timing_0_s_clks20to20(20),
        en_packets    => General_Controller_0_en_science_packets,
        man_gain1     => General_Controller_0_man_gain1,
        man_gain2     => General_Controller_0_man_gain2,
        man_gain3     => General_Controller_0_man_gain3,
        man_gain4     => General_Controller_0_man_gain4,
        milliseconds  => Timekeeper_0_microseconds,
        FFUID         => General_Controller_0_ffu_id,
        -- Outputs
        ACS           => ACS_net_0,
        ACLK          => ACLK_net_0,
        ACST          => ACST_net_0,
        exp_new_data  => Science_0_exp_new_data,
        LA0           => LA0_net_0,
        LA1           => LA1_net_0,
        L1WR          => L1WR_net_0,
        L2WR          => L2WR_net_0,
        L3WR          => L3WR_net_0,
        L4WR          => L4WR_net_0,
        LDCS          => LDCS_net_0,
        LDSDI         => LDSDI_net_0,
        LDCLK         => LDCLK_net_0,
        ARST          => ARST_net_0,
        exp_packet    => Science_0_exp_packet_0,
        chan1_data    => Science_0_chan1_data,
        chan7_data    => Science_0_chan7_data,
        chan3_data    => Science_0_chan3_data,
        chan0_data    => Science_0_chan0_data,
        chan6_data    => Science_0_chan6_data,
        chan4_data    => Science_0_chan4_data,
        chan2_data    => Science_0_chan2_data,
        chan5_data    => Science_0_chan5_data 
        );
-- Sensors_0
Sensors_0 : Sensors
    port map( 
        -- Inputs
        clk               => CLKINT_0_Y_0,
        reset             => CLKINT_1_Y,
        en                => General_Controller_0_en_sensors,
        clk_1kHz          => Timing_0_s_clks14to14(14),
        i2c_clk           => ClockDivs_0_clk_800kHz,
        microseconds      => Timekeeper_0_microseconds,
        -- Outputs
        acce_scl          => ACCE_SCL_net_0,
        pressure_scl      => PRESSURE_SCL_net_0,
        gyro_scl          => GYRO_SCL_net_0,
        acc_new_data      => Sensors_0_acc_new_data,
        mag_new_data      => Sensors_0_mag_new_data,
        gyro_new_data     => Sensors_0_gyro_new_data,
        pressure_new_data => Sensors_0_pressure_new_data,
        pres_cal_new_data => Sensors_0_pres_cal_new_data,
        acc_x             => Sensors_0_acc_x,
        acc_y             => Sensors_0_acc_y,
        acc_z             => Sensors_0_acc_z,
        acc_temp          => Sensors_0_acc_temp,
        mag_x             => Sensors_0_mag_x,
        mag_y             => Sensors_0_mag_y,
        mag_z             => Sensors_0_mag_z,
        gyro_x            => Sensors_0_gyro_x,
        gyro_y            => Sensors_0_gyro_y,
        gyro_z            => Sensors_0_gyro_z,
        gyro_temp         => Sensors_0_gyro_temp,
        pressure_raw      => Sensors_0_pressure_raw,
        pressure_temp_raw => Sensors_0_pressure_temp_raw,
        C1                => Sensors_0_C1,
        C2                => Sensors_0_C2,
        C3                => Sensors_0_C3,
        C4                => Sensors_0_C4,
        C5                => Sensors_0_C5,
        C6                => Sensors_0_C6,
        pressure_time     => Sensors_0_pressure_time,
        gyro_time         => Sensors_0_gyro_time,
        acc_time          => Sensors_0_acc_time,
        mag_time          => Sensors_0_mag_time,
        -- Inouts
        gyro_sda          => GYRO_SDA,
        acce_sda          => ACCE_SDA,
        pressure_sda      => PRESSURE_SDA 
        );
-- Timekeeper_0
Timekeeper_0 : Timekeeper
    port map( 
        -- Inputs
        clk          => CLKINT_0_Y_0,
        clk_1MHz     => Timing_0_s_clks4to4(4),
        clk_1kHz     => Timing_0_s_clks14to14(14),
        clk_1Hz      => Timing_0_s_clks24to24(24),
        reset        => CLKINT_1_Y,
        -- Outputs
        microseconds => Timekeeper_0_microseconds,
        milliseconds => Timekeeper_0_milliseconds,
        seconds      => OPEN 
        );
-- Timing_0
Timing_0 : Timing
    port map( 
        -- Inputs
        clk    => CLKINT_0_Y_0,
        reset  => CLKINT_1_Y,
        -- Outputs
        s_clks => s_clks_net_0 
        );

end RTL;
