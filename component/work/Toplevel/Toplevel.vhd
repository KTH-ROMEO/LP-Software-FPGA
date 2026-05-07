----------------------------------------------------------------------
-- Created by SmartDesign Thu May 07 18:39:00 2026
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
        AA           : in    std_logic;
        AB           : in    std_logic;
        ABSY         : in    std_logic;
        CLOCK        : in    std_logic;
        CU_SYNC      : in    std_logic;
        FFU_EJECTED  : in    std_logic;
        FMC_CLK      : in    std_logic;
        FMC_NOE      : in    std_logic;
        RESET        : in    std_logic;
        UC_I2C4_SCL  : in    std_logic;
        UC_UART_TX   : in    std_logic;
        -- Outputs
        ACCE_SCL     : out   std_logic;
        ACLK         : out   std_logic;
        ACS          : out   std_logic;
        ACST         : out   std_logic;
        ARST         : out   std_logic;
        DPIN_19      : out   std_logic;
        DPIN_22      : out   std_logic;
        DPIN_59      : out   std_logic;
        DPIN_69      : out   std_logic;
        DPIN_70      : out   std_logic;
        DPIN_71      : out   std_logic;
        DPIN_96      : out   std_logic;
        FMC_DA       : out   std_logic_vector(7 downto 0);
        FPGA_BUF_INT : out   std_logic;
        GYRO_SCL     : out   std_logic;
        L1WR         : out   std_logic;
        L2WR         : out   std_logic;
        LA0          : out   std_logic;
        LA1          : out   std_logic;
        LDCLK        : out   std_logic;
        LDCS         : out   std_logic;
        LDSDI        : out   std_logic;
        LED1         : out   std_logic;
        LED2         : out   std_logic;
        MAX_SCL      : out   std_logic;
        PRESSURE_SCL : out   std_logic;
        UC_UART_RX   : out   std_logic;
        -- Inouts
        ACCE_SDA     : inout std_logic;
        FRAM_SDA     : inout std_logic;
        FRSTDATA     : inout std_logic;
        GYRO_SDA     : inout std_logic;
        MAX_SDA      : inout std_logic;
        PRESSURE_SDA : inout std_logic;
        UC_I2C4_SDA  : inout std_logic
        );
end Toplevel;
----------------------------------------------------------------------
-- Toplevel architecture body
----------------------------------------------------------------------
architecture RTL of Toplevel is
----------------------------------------------------------------------
-- Component declarations
----------------------------------------------------------------------
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
        clk       : in  std_logic;
        reset     : in  std_logic;
        rx        : in  std_logic;
        uc_oen    : in  std_logic;
        uc_send   : in  std_logic_vector(7 downto 0);
        uc_wen    : in  std_logic;
        -- Outputs
        tx        : out std_logic;
        uc_recv   : out std_logic_vector(7 downto 0);
        uc_rx_rdy : out std_logic;
        uc_tx_rdy : out std_logic
        );
end component;
-- Data_Hub_Packets
component Data_Hub_Packets
    -- Port list
    port(
        -- Inputs
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
        -- Outputs
        acc_packet        : out std_logic_vector(63 downto 0);
        gyro_packet       : out std_logic_vector(63 downto 0);
        mag_packet        : out std_logic_vector(63 downto 0);
        pressure_packet   : out std_logic_vector(63 downto 0)
        );
end component;
-- Data_Saving
component Data_Saving
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
        sync          : in  std_logic;
        -- Outputs
        fmc_da        : out std_logic_vector(7 downto 0);
        uC_interrupt  : out std_logic
        );
end component;
-- Dummy_Pins
component Dummy_Pins
    -- Port list
    port(
        -- Inputs
        RESET    : in    std_logic;
        -- Outputs
        MAX_SCL  : out   std_logic;
        p13      : out   std_logic;
        p15      : out   std_logic;
        p16      : out   std_logic;
        p19      : out   std_logic;
        p22      : out   std_logic;
        p59      : out   std_logic;
        p69      : out   std_logic;
        p70      : out   std_logic;
        p71      : out   std_logic;
        p96      : out   std_logic;
        -- Inouts
        FRSTDATA : inout std_logic;
        MAX_SDA  : inout std_logic
        );
end component;
-- General_Controller
component General_Controller
    -- Port list
    port(
        -- Inputs
        acc_packet            : in  std_logic_vector(63 downto 0);
        clk                   : in  std_logic;
        clk_1Hz               : in  std_logic;
        clk_256Hz             : in  std_logic;
        clk_4Hz               : in  std_logic;
        gyro_packet           : in  std_logic_vector(63 downto 0);
        mag_packet            : in  std_logic_vector(63 downto 0);
        pressure_packet       : in  std_logic_vector(63 downto 0);
        reset                 : in  std_logic;
        sc_data               : in  std_logic_vector(63 downto 0);
        sc_new                : in  std_logic;
        swt_rdata0            : in  std_logic_vector(15 downto 0);
        swt_rdata1            : in  std_logic_vector(15 downto 0);
        uc_recv               : in  std_logic_vector(7 downto 0);
        uc_rx_rdy             : in  std_logic;
        uc_tx_rdy             : in  std_logic;
        -- Outputs
        Bias_enabled          : out std_logic;
        C_bias_V0             : out std_logic_vector(15 downto 0);
        C_bias_V1             : out std_logic_vector(15 downto 0);
        Sweep_enabled         : out std_logic;
        led1                  : out std_logic;
        led2                  : out std_logic;
        swt_nof_steps         : out std_logic_vector(7 downto 0);
        swt_points_per_step   : out std_logic_vector(15 downto 0);
        swt_raddr             : out std_logic_vector(7 downto 0);
        swt_ren               : out std_logic;
        swt_sample_skip       : out std_logic_vector(15 downto 0);
        swt_samples_per_point : out std_logic_vector(15 downto 0);
        swt_samples_per_step  : out std_logic_vector(15 downto 0);
        swt_waddr             : out std_logic_vector(7 downto 0);
        swt_wdata             : out std_logic_vector(15 downto 0);
        swt_wen0              : out std_logic;
        swt_wen1              : out std_logic;
        uc_oen                : out std_logic;
        uc_send               : out std_logic_vector(7 downto 0);
        uc_wen                : out std_logic
        );
end component;
-- Science
component Science
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
        exp_adc_reset           : in  std_logic;
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
        REN                     : out std_logic;
        SC_packet               : out std_logic_vector(63 downto 0);
        SW_END                  : out std_logic;
        new_SC_packet           : out std_logic
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
-- TableSelect
component TableSelect
    -- Port list
    port(
        -- Inputs
        GCRADDR : in  std_logic_vector(7 downto 0);
        GCREN   : in  std_logic;
        ScRADDR : in  std_logic_vector(7 downto 0);
        ScREN   : in  std_logic;
        -- Outputs
        RADDR   : out std_logic_vector(7 downto 0);
        REN     : out std_logic
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
signal ACCE_SCL_net_0                             : std_logic;
signal ACLK_net_0                                 : std_logic;
signal ACS_net_0                                  : std_logic;
signal ACST_net_0                                 : std_logic;
signal ARST_net_0                                 : std_logic;
signal CLKINT_0_Y_0                               : std_logic;
signal CLKINT_1_Y                                 : std_logic;
signal CLKINT_2_Y                                 : std_logic;
signal ClockDivs_0_clk_800kHz                     : std_logic;
signal Communications_0_uc_recv                   : std_logic_vector(7 downto 0);
signal Communications_0_uc_rx_rdy                 : std_logic;
signal Communications_0_uc_tx_rdy                 : std_logic;
signal Data_Hub_Packets_0_acc_packet_1            : std_logic_vector(63 downto 0);
signal Data_Hub_Packets_0_gyro_packet_0           : std_logic_vector(63 downto 0);
signal Data_Hub_Packets_0_mag_packet_1            : std_logic_vector(63 downto 0);
signal Data_Hub_Packets_0_pressure_packet_0       : std_logic_vector(63 downto 0);
signal DPIN_19_net_0                              : std_logic;
signal DPIN_22_net_0                              : std_logic;
signal DPIN_59_net_0                              : std_logic;
signal DPIN_69_net_0                              : std_logic;
signal DPIN_70_net_0                              : std_logic;
signal DPIN_71_net_0                              : std_logic;
signal DPIN_96_net_0                              : std_logic;
signal FMC_DA_0                                   : std_logic_vector(7 downto 0);
signal FPGA_BUF_INT_net_0                         : std_logic;
signal General_Controller_0_Bias_enabled          : std_logic;
signal General_Controller_0_C_bias_V0             : std_logic_vector(15 downto 0);
signal General_Controller_0_C_bias_V1             : std_logic_vector(15 downto 0);
signal General_Controller_0_Sweep_enabled         : std_logic;
signal General_Controller_0_swt_nof_steps         : std_logic_vector(7 downto 0);
signal General_Controller_0_swt_points_per_step   : std_logic_vector(15 downto 0);
signal General_Controller_0_swt_raddr             : std_logic_vector(7 downto 0);
signal General_Controller_0_swt_ren               : std_logic;
signal General_Controller_0_swt_sample_skip       : std_logic_vector(15 downto 0);
signal General_Controller_0_swt_samples_per_point : std_logic_vector(15 downto 0);
signal General_Controller_0_swt_samples_per_step  : std_logic_vector(15 downto 0);
signal General_Controller_0_swt_waddr             : std_logic_vector(7 downto 0);
signal General_Controller_0_swt_wdata             : std_logic_vector(15 downto 0);
signal General_Controller_0_swt_wen0              : std_logic;
signal General_Controller_0_swt_wen1              : std_logic;
signal General_Controller_0_uc_oen                : std_logic;
signal General_Controller_0_uc_send               : std_logic_vector(7 downto 0);
signal General_Controller_0_uc_wen                : std_logic;
signal GYRO_SCL_net_0                             : std_logic;
signal L1WR_net_0                                 : std_logic;
signal L2WR_net_0                                 : std_logic;
signal LA0_net_0                                  : std_logic;
signal LA1_net_0                                  : std_logic;
signal LDCLK_net_0                                : std_logic;
signal LDCS_net_0                                 : std_logic;
signal LDSDI_net_0                                : std_logic;
signal LED1_0                                     : std_logic;
signal LED2_net_0                                 : std_logic;
signal MAX_SCL_net_0                              : std_logic;
signal PRESSURE_SCL_net_0                         : std_logic;
signal Science_0_new_SC_packet                    : std_logic;
signal Science_0_RADDR                            : std_logic_vector(7 downto 0);
signal Science_0_REN                              : std_logic;
signal Science_0_SC_packet                        : std_logic_vector(63 downto 0);
signal Sensors_0_acc_temp                         : std_logic_vector(7 downto 0);
signal Sensors_0_acc_time                         : std_logic_vector(23 downto 0);
signal Sensors_0_acc_x                            : std_logic_vector(11 downto 0);
signal Sensors_0_acc_y                            : std_logic_vector(11 downto 0);
signal Sensors_0_acc_z                            : std_logic_vector(11 downto 0);
signal Sensors_0_gyro_temp                        : std_logic_vector(7 downto 0);
signal Sensors_0_gyro_time                        : std_logic_vector(23 downto 0);
signal Sensors_0_gyro_x                           : std_logic_vector(15 downto 0);
signal Sensors_0_gyro_y                           : std_logic_vector(15 downto 0);
signal Sensors_0_gyro_z                           : std_logic_vector(15 downto 0);
signal Sensors_0_gyro_z7to4                       : std_logic_vector(7 downto 4);
signal Sensors_0_gyro_z11to8                      : std_logic_vector(11 downto 8);
signal Sensors_0_gyro_z15to12                     : std_logic_vector(15 downto 12);
signal Sensors_0_mag_time                         : std_logic_vector(23 downto 0);
signal Sensors_0_mag_x                            : std_logic_vector(11 downto 0);
signal Sensors_0_mag_y                            : std_logic_vector(11 downto 0);
signal Sensors_0_mag_z                            : std_logic_vector(11 downto 0);
signal Sensors_0_pressure_raw                     : std_logic_vector(23 downto 0);
signal Sensors_0_pressure_raw23to12               : std_logic_vector(23 downto 12);
signal Sensors_0_pressure_temp_raw                : std_logic_vector(23 downto 0);
signal Sensors_0_pressure_temp_raw23to12          : std_logic_vector(23 downto 12);
signal Sensors_0_pressure_time                    : std_logic_vector(23 downto 0);
signal SweepTable_0_RD                            : std_logic_vector(15 downto 0);
signal SweepTable_1_RD                            : std_logic_vector(15 downto 0);
signal TableSelect_0_RADDR                        : std_logic_vector(7 downto 0);
signal TableSelect_0_REN                          : std_logic;
signal Timekeeper_0_microseconds                  : std_logic_vector(23 downto 0);
signal Timekeeper_0_milliseconds                  : std_logic_vector(23 downto 0);
signal Timing_0_s_clks4to4                        : std_logic_vector(4 to 4);
signal Timing_0_s_clks9to9                        : std_logic_vector(9 to 9);
signal Timing_0_s_clks14to14                      : std_logic_vector(14 to 14);
signal Timing_0_s_clks16to16                      : std_logic_vector(16 to 16);
signal Timing_0_s_clks18to18                      : std_logic_vector(18 to 18);
signal Timing_0_s_clks20to20                      : std_logic_vector(20 to 20);
signal Timing_0_s_clks22to22                      : std_logic_vector(22 to 22);
signal Timing_0_s_clks24to24                      : std_logic_vector(24 to 24);
signal UC_UART_RX_net_0                           : std_logic;
signal FPGA_BUF_INT_net_1                         : std_logic;
signal PRESSURE_SCL_net_1                         : std_logic;
signal UC_UART_RX_net_1                           : std_logic;
signal GYRO_SCL_net_1                             : std_logic;
signal ACCE_SCL_net_1                             : std_logic;
signal LED1_0_net_0                               : std_logic;
signal LED2_net_1                                 : std_logic;
signal ACS_net_1                                  : std_logic;
signal ACLK_net_1                                 : std_logic;
signal ACST_net_1                                 : std_logic;
signal L1WR_net_1                                 : std_logic;
signal L2WR_net_1                                 : std_logic;
signal LDCS_net_1                                 : std_logic;
signal LDSDI_net_1                                : std_logic;
signal LDCLK_net_1                                : std_logic;
signal LA0_net_1                                  : std_logic;
signal LA1_net_1                                  : std_logic;
signal ARST_net_1                                 : std_logic;
signal DPIN_19_net_1                              : std_logic;
signal DPIN_22_net_1                              : std_logic;
signal MAX_SCL_net_1                              : std_logic;
signal DPIN_59_net_1                              : std_logic;
signal DPIN_69_net_1                              : std_logic;
signal DPIN_70_net_1                              : std_logic;
signal DPIN_71_net_1                              : std_logic;
signal DPIN_96_net_1                              : std_logic;
signal FMC_DA_0_net_0                             : std_logic_vector(7 downto 0);
signal gyro_z_slice_0                             : std_logic_vector(3 downto 0);
signal pressure_raw_slice_0                       : std_logic_vector(11 downto 0);
signal pressure_temp_raw_slice_0                  : std_logic_vector(11 downto 0);
signal s_clks_slice_0                             : std_logic_vector(0 to 0);
signal s_clks_slice_1                             : std_logic_vector(10 to 10);
signal s_clks_slice_2                             : std_logic_vector(11 to 11);
signal s_clks_slice_3                             : std_logic_vector(12 to 12);
signal s_clks_slice_4                             : std_logic_vector(13 to 13);
signal s_clks_slice_5                             : std_logic_vector(15 to 15);
signal s_clks_slice_6                             : std_logic_vector(17 to 17);
signal s_clks_slice_7                             : std_logic_vector(19 to 19);
signal s_clks_slice_8                             : std_logic_vector(1 to 1);
signal s_clks_slice_9                             : std_logic_vector(21 to 21);
signal s_clks_slice_10                            : std_logic_vector(23 to 23);
signal s_clks_slice_11                            : std_logic_vector(2 to 2);
signal s_clks_slice_12                            : std_logic_vector(3 to 3);
signal s_clks_slice_13                            : std_logic_vector(5 to 5);
signal s_clks_slice_14                            : std_logic_vector(6 to 6);
signal s_clks_slice_15                            : std_logic_vector(7 to 7);
signal s_clks_slice_16                            : std_logic_vector(8 to 8);
signal s_clks_net_0                               : std_logic_vector(24 downto 0);
----------------------------------------------------------------------
-- TiedOff Signals
----------------------------------------------------------------------
signal VCC_net                                    : std_logic;
signal GND_net                                    : std_logic;
----------------------------------------------------------------------
-- Inverted Signals
----------------------------------------------------------------------
signal FFU_EJECTED_IN_POST_INV0_0                 : std_logic;

begin
----------------------------------------------------------------------
-- Constant assignments
----------------------------------------------------------------------
 VCC_net <= '1';
 GND_net <= '0';
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
 GYRO_SCL_net_1     <= GYRO_SCL_net_0;
 GYRO_SCL           <= GYRO_SCL_net_1;
 ACCE_SCL_net_1     <= ACCE_SCL_net_0;
 ACCE_SCL           <= ACCE_SCL_net_1;
 LED1_0_net_0       <= LED1_0;
 LED1               <= LED1_0_net_0;
 LED2_net_1         <= LED2_net_0;
 LED2               <= LED2_net_1;
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
 DPIN_19_net_1      <= DPIN_19_net_0;
 DPIN_19            <= DPIN_19_net_1;
 DPIN_22_net_1      <= DPIN_22_net_0;
 DPIN_22            <= DPIN_22_net_1;
 MAX_SCL_net_1      <= MAX_SCL_net_0;
 MAX_SCL            <= MAX_SCL_net_1;
 DPIN_59_net_1      <= DPIN_59_net_0;
 DPIN_59            <= DPIN_59_net_1;
 DPIN_69_net_1      <= DPIN_69_net_0;
 DPIN_69            <= DPIN_69_net_1;
 DPIN_70_net_1      <= DPIN_70_net_0;
 DPIN_70            <= DPIN_70_net_1;
 DPIN_71_net_1      <= DPIN_71_net_0;
 DPIN_71            <= DPIN_71_net_1;
 DPIN_96_net_1      <= DPIN_96_net_0;
 DPIN_96            <= DPIN_96_net_1;
 FMC_DA_0_net_0     <= FMC_DA_0;
 FMC_DA(7 downto 0) <= FMC_DA_0_net_0;
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
 Timing_0_s_clks16to16(16)         <= s_clks_net_0(16);
 Timing_0_s_clks18to18(18)         <= s_clks_net_0(18);
 Timing_0_s_clks20to20(20)         <= s_clks_net_0(20);
 Timing_0_s_clks22to22(22)         <= s_clks_net_0(22);
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
 s_clks_slice_6(17)                <= s_clks_net_0(17);
 s_clks_slice_7(19)                <= s_clks_net_0(19);
 s_clks_slice_8(1)                 <= s_clks_net_0(1);
 s_clks_slice_9(21)                <= s_clks_net_0(21);
 s_clks_slice_10(23)               <= s_clks_net_0(23);
 s_clks_slice_11(2)                <= s_clks_net_0(2);
 s_clks_slice_12(3)                <= s_clks_net_0(3);
 s_clks_slice_13(5)                <= s_clks_net_0(5);
 s_clks_slice_14(6)                <= s_clks_net_0(6);
 s_clks_slice_15(7)                <= s_clks_net_0(7);
 s_clks_slice_16(8)                <= s_clks_net_0(8);
----------------------------------------------------------------------
-- Component instances
----------------------------------------------------------------------
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
        clk       => CLKINT_0_Y_0,
        reset     => CLKINT_1_Y,
        uc_oen    => General_Controller_0_uc_oen,
        uc_wen    => General_Controller_0_uc_wen,
        rx        => UC_UART_TX,
        uc_send   => General_Controller_0_uc_send,
        -- Outputs
        uc_tx_rdy => Communications_0_uc_tx_rdy,
        uc_rx_rdy => Communications_0_uc_rx_rdy,
        tx        => UC_UART_RX_net_0,
        uc_recv   => Communications_0_uc_recv 
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
        -- Outputs
        acc_packet        => Data_Hub_Packets_0_acc_packet_1,
        mag_packet        => Data_Hub_Packets_0_mag_packet_1,
        gyro_packet       => Data_Hub_Packets_0_gyro_packet_0,
        pressure_packet   => Data_Hub_Packets_0_pressure_packet_0 
        );
-- Data_Saving_0
Data_Saving_0 : Data_Saving
    port map( 
        -- Inputs
        clk           => CLKINT_0_Y_0,
        reset         => CLKINT_1_Y,
        ch_0_new_data => Science_0_new_SC_packet,
        sync          => CU_SYNC,
        fmc_noe       => FMC_NOE,
        fmc_clk       => CLKINT_2_Y,
        en            => VCC_net,
        exp_SC_packet => Science_0_SC_packet,
        -- Outputs
        uC_interrupt  => FPGA_BUF_INT_net_0,
        fmc_da        => FMC_DA_0 
        );
-- Dummy_Pins_0
Dummy_Pins_0 : Dummy_Pins
    port map( 
        -- Inputs
        RESET    => CLKINT_1_Y,
        -- Outputs
        p13      => OPEN,
        p15      => OPEN,
        p16      => OPEN,
        p19      => DPIN_19_net_0,
        p22      => DPIN_22_net_0,
        MAX_SCL  => MAX_SCL_net_0,
        p59      => DPIN_59_net_0,
        p69      => DPIN_69_net_0,
        p70      => DPIN_70_net_0,
        p71      => DPIN_71_net_0,
        p96      => DPIN_96_net_0,
        -- Inouts
        MAX_SDA  => MAX_SDA,
        FRSTDATA => FRSTDATA 
        );
-- General_Controller_0
General_Controller_0 : General_Controller
    port map( 
        -- Inputs
        clk                   => CLKINT_0_Y_0,
        clk_1Hz               => Timing_0_s_clks24to24(24),
        clk_4Hz               => Timing_0_s_clks22to22(22),
        clk_256Hz             => Timing_0_s_clks16to16(16),
        reset                 => CLKINT_1_Y,
        uc_recv               => Communications_0_uc_recv,
        uc_tx_rdy             => Communications_0_uc_tx_rdy,
        uc_rx_rdy             => Communications_0_uc_rx_rdy,
        swt_rdata0            => SweepTable_0_RD,
        swt_rdata1            => SweepTable_1_RD,
        acc_packet            => Data_Hub_Packets_0_acc_packet_1,
        mag_packet            => Data_Hub_Packets_0_mag_packet_1,
        gyro_packet           => Data_Hub_Packets_0_gyro_packet_0,
        pressure_packet       => Data_Hub_Packets_0_pressure_packet_0,
        sc_new                => Science_0_new_SC_packet,
        sc_data               => Science_0_SC_packet,
        -- Outputs
        swt_wdata             => General_Controller_0_swt_wdata,
        swt_waddr             => General_Controller_0_swt_waddr,
        swt_raddr             => General_Controller_0_swt_raddr,
        swt_wen0              => General_Controller_0_swt_wen0,
        swt_wen1              => General_Controller_0_swt_wen1,
        swt_ren               => General_Controller_0_swt_ren,
        uc_send               => General_Controller_0_uc_send,
        uc_wen                => General_Controller_0_uc_wen,
        uc_oen                => General_Controller_0_uc_oen,
        led1                  => LED1_0,
        led2                  => LED2_net_0,
        C_bias_V0             => General_Controller_0_C_bias_V0,
        C_bias_V1             => General_Controller_0_C_bias_V1,
        Bias_enabled          => General_Controller_0_Bias_enabled,
        Sweep_enabled         => General_Controller_0_Sweep_enabled,
        swt_nof_steps         => General_Controller_0_swt_nof_steps,
        swt_samples_per_step  => General_Controller_0_swt_samples_per_step,
        swt_samples_per_point => General_Controller_0_swt_samples_per_point,
        swt_sample_skip       => General_Controller_0_swt_sample_skip,
        swt_points_per_step   => General_Controller_0_swt_points_per_step 
        );
-- Science_0
Science_0 : Science
    port map( 
        -- Inputs
        AA                      => AA,
        AB                      => AB,
        ABSY                    => ABSY,
        clk_32kHz               => Timing_0_s_clks9to9(9),
        clk                     => CLKINT_0_Y_0,
        reset                   => CLKINT_1_Y,
        exp_adc_reset           => GND_net,
        clk_16Hz                => Timing_0_s_clks20to20(20),
        Bias_enabled            => General_Controller_0_Bias_enabled,
        Sweep_enabled           => General_Controller_0_Sweep_enabled,
        Sweep_no_steps          => General_Controller_0_swt_nof_steps,
        Sweep_skipped_samples   => General_Controller_0_swt_sample_skip,
        Sweep_Samples           => General_Controller_0_swt_samples_per_step,
        C_bias_V1               => General_Controller_0_C_bias_V1,
        C_bias_V0               => General_Controller_0_C_bias_V0,
        RData0                  => SweepTable_0_RD,
        RData1                  => SweepTable_1_RD,
        Sweep_samples_per_point => General_Controller_0_swt_samples_per_point,
        Sweep_points_per_step   => General_Controller_0_swt_points_per_step,
        -- Outputs
        ACS                     => ACS_net_0,
        ACLK                    => ACLK_net_0,
        ACST                    => ACST_net_0,
        LA0                     => LA0_net_0,
        LA1                     => LA1_net_0,
        L1WR                    => L1WR_net_0,
        L2WR                    => L2WR_net_0,
        L3WR                    => OPEN,
        L4WR                    => OPEN,
        LDCS                    => LDCS_net_0,
        LDSDI                   => LDSDI_net_0,
        LDCLK                   => LDCLK_net_0,
        ARST                    => ARST_net_0,
        REN                     => Science_0_REN,
        new_SC_packet           => Science_0_new_SC_packet,
        SW_END                  => OPEN,
        RADDR                   => Science_0_RADDR,
        SC_packet               => Science_0_SC_packet 
        );
-- Sensors_0
Sensors_0 : Sensors
    port map( 
        -- Inputs
        clk               => CLKINT_0_Y_0,
        reset             => CLKINT_1_Y,
        en                => VCC_net,
        clk_1kHz          => Timing_0_s_clks14to14(14),
        i2c_clk           => ClockDivs_0_clk_800kHz,
        microseconds      => Timekeeper_0_microseconds,
        -- Outputs
        acce_scl          => ACCE_SCL_net_0,
        pressure_scl      => PRESSURE_SCL_net_0,
        gyro_scl          => GYRO_SCL_net_0,
        acc_new_data      => OPEN,
        mag_new_data      => OPEN,
        gyro_new_data     => OPEN,
        pressure_new_data => OPEN,
        pres_cal_new_data => OPEN,
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
        C1                => OPEN,
        C2                => OPEN,
        C3                => OPEN,
        C4                => OPEN,
        C5                => OPEN,
        C6                => OPEN,
        pressure_time     => Sensors_0_pressure_time,
        gyro_time         => Sensors_0_gyro_time,
        acc_time          => Sensors_0_acc_time,
        mag_time          => Sensors_0_mag_time,
        -- Inouts
        gyro_sda          => GYRO_SDA,
        acce_sda          => ACCE_SDA,
        pressure_sda      => PRESSURE_SDA 
        );
-- SweepTable_0
SweepTable_0 : SweepTable
    port map( 
        -- Inputs
        WEN   => General_Controller_0_swt_wen0,
        REN   => TableSelect_0_REN,
        RWCLK => CLKINT_0_Y_0,
        RESET => CLKINT_1_Y,
        WD    => General_Controller_0_swt_wdata,
        WADDR => General_Controller_0_swt_waddr,
        RADDR => TableSelect_0_RADDR,
        -- Outputs
        RD    => SweepTable_0_RD 
        );
-- SweepTable_1
SweepTable_1 : SweepTable
    port map( 
        -- Inputs
        WEN   => General_Controller_0_swt_wen1,
        REN   => TableSelect_0_REN,
        RWCLK => CLKINT_0_Y_0,
        RESET => CLKINT_1_Y,
        WD    => General_Controller_0_swt_wdata,
        WADDR => General_Controller_0_swt_waddr,
        RADDR => TableSelect_0_RADDR,
        -- Outputs
        RD    => SweepTable_1_RD 
        );
-- TableSelect_0
TableSelect_0 : TableSelect
    port map( 
        -- Inputs
        GCREN   => General_Controller_0_swt_ren,
        GCRADDR => General_Controller_0_swt_raddr,
        ScREN   => Science_0_REN,
        ScRADDR => Science_0_RADDR,
        -- Outputs
        REN     => TableSelect_0_REN,
        RADDR   => TableSelect_0_RADDR 
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
