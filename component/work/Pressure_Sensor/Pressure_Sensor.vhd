----------------------------------------------------------------------
-- Created by SmartDesign Sun Jan 12 18:53:51 2020
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
-- Pressure_Sensor entity declaration
----------------------------------------------------------------------
entity Pressure_Sensor is
    -- Port list
    port(
        -- Inputs
        clk                  : in    std_logic;
        clk_1kHz             : in    std_logic;
        en                   : in    std_logic;
        i2c_clk              : in    std_logic;
        microseconds         : in    std_logic_vector(23 downto 0);
        reset                : in    std_logic;
        -- Outputs
        C1                   : out   std_logic_vector(15 downto 0);
        C2                   : out   std_logic_vector(15 downto 0);
        C3                   : out   std_logic_vector(15 downto 0);
        C4                   : out   std_logic_vector(15 downto 0);
        C5                   : out   std_logic_vector(15 downto 0);
        C6                   : out   std_logic_vector(15 downto 0);
        calibration_new_data : out   std_logic;
        pressure_new_data    : out   std_logic;
        pressure_raw         : out   std_logic_vector(23 downto 0);
        pressure_time        : out   std_logic_vector(23 downto 0);
        scl                  : out   std_logic;
        temp_raw             : out   std_logic_vector(23 downto 0);
        -- Inouts
        sda                  : inout std_logic
        );
end Pressure_Sensor;
----------------------------------------------------------------------
-- Pressure_Sensor architecture body
----------------------------------------------------------------------
architecture RTL of Pressure_Sensor is
----------------------------------------------------------------------
-- Component declarations
----------------------------------------------------------------------
-- I2C_Master
component I2C_Master
    -- Port list
    port(
        -- Inputs
        address      : in    std_logic_vector(7 downto 0);
        clk          : in    std_logic;
        data_in      : in    std_logic_vector(7 downto 0);
        num_bytes    : in    std_logic_vector(3 downto 0);
        repeat_start : in    std_logic;
        reset        : in    std_logic;
        we           : in    std_logic;
        -- Outputs
        busy         : out   std_logic;
        data_out     : out   std_logic_vector(7 downto 0);
        data_out_rdy : out   std_logic;
        s_ack_error  : out   std_logic;
        scl          : out   std_logic;
        write_done   : out   std_logic;
        -- Inouts
        sda          : inout std_logic
        );
end component;
-- MS5611_01BA03_Interface
component MS5611_01BA03_Interface
    -- Port list
    port(
        -- Inputs
        clk                  : in  std_logic;
        clk_1kHz             : in  std_logic;
        data_in              : in  std_logic_vector(7 downto 0);
        en                   : in  std_logic;
        i2c_busy             : in  std_logic;
        i2c_data_rdy         : in  std_logic;
        i2c_s_ack_error      : in  std_logic;
        i2c_write_done       : in  std_logic;
        microseconds         : in  std_logic_vector(23 downto 0);
        reset                : in  std_logic;
        -- Outputs
        C1                   : out std_logic_vector(15 downto 0);
        C2                   : out std_logic_vector(15 downto 0);
        C3                   : out std_logic_vector(15 downto 0);
        C4                   : out std_logic_vector(15 downto 0);
        C5                   : out std_logic_vector(15 downto 0);
        C6                   : out std_logic_vector(15 downto 0);
        calibration_new_data : out std_logic;
        data_out             : out std_logic_vector(7 downto 0);
        i2c_addr             : out std_logic_vector(7 downto 0);
        i2c_repeat_start     : out std_logic;
        num_bytes            : out std_logic_vector(3 downto 0);
        pressure_new_data    : out std_logic;
        pressure_raw         : out std_logic_vector(23 downto 0);
        pressure_time        : out std_logic_vector(23 downto 0);
        temp_raw             : out std_logic_vector(23 downto 0);
        we                   : out std_logic
        );
end component;
----------------------------------------------------------------------
-- Signal declarations
----------------------------------------------------------------------
signal C1_net_0                                   : std_logic_vector(15 downto 0);
signal C2_net_0                                   : std_logic_vector(15 downto 0);
signal C3_net_0                                   : std_logic_vector(15 downto 0);
signal C4_net_0                                   : std_logic_vector(15 downto 0);
signal C5_net_0                                   : std_logic_vector(15 downto 0);
signal C6_net_0                                   : std_logic_vector(15 downto 0);
signal calibration_new_data_net_0                 : std_logic;
signal I2C_Master_0_busy                          : std_logic;
signal I2C_Master_0_data_out                      : std_logic_vector(7 downto 0);
signal I2C_Master_0_data_out_rdy                  : std_logic;
signal I2C_Master_0_s_ack_error                   : std_logic;
signal I2C_Master_0_write_done                    : std_logic;
signal MS5611_01BA03_Interface_0_data_out         : std_logic_vector(7 downto 0);
signal MS5611_01BA03_Interface_0_i2c_addr         : std_logic_vector(7 downto 0);
signal MS5611_01BA03_Interface_0_i2c_repeat_start : std_logic;
signal MS5611_01BA03_Interface_0_num_bytes        : std_logic_vector(3 downto 0);
signal MS5611_01BA03_Interface_0_we               : std_logic;
signal pressure_new_data_net_0                    : std_logic;
signal pressure_raw_net_0                         : std_logic_vector(23 downto 0);
signal pressure_time_net_0                        : std_logic_vector(23 downto 0);
signal scl_net_0                                  : std_logic;
signal temp_raw_net_0                             : std_logic_vector(23 downto 0);
signal scl_net_1                                  : std_logic;
signal pressure_new_data_net_1                    : std_logic;
signal calibration_new_data_net_1                 : std_logic;
signal pressure_raw_net_1                         : std_logic_vector(23 downto 0);
signal temp_raw_net_1                             : std_logic_vector(23 downto 0);
signal C1_net_1                                   : std_logic_vector(15 downto 0);
signal C2_net_1                                   : std_logic_vector(15 downto 0);
signal C3_net_1                                   : std_logic_vector(15 downto 0);
signal C4_net_1                                   : std_logic_vector(15 downto 0);
signal C5_net_1                                   : std_logic_vector(15 downto 0);
signal C6_net_1                                   : std_logic_vector(15 downto 0);
signal pressure_time_net_1                        : std_logic_vector(23 downto 0);

begin
----------------------------------------------------------------------
-- Top level output port assignments
----------------------------------------------------------------------
 scl_net_1                  <= scl_net_0;
 scl                        <= scl_net_1;
 pressure_new_data_net_1    <= pressure_new_data_net_0;
 pressure_new_data          <= pressure_new_data_net_1;
 calibration_new_data_net_1 <= calibration_new_data_net_0;
 calibration_new_data       <= calibration_new_data_net_1;
 pressure_raw_net_1         <= pressure_raw_net_0;
 pressure_raw(23 downto 0)  <= pressure_raw_net_1;
 temp_raw_net_1             <= temp_raw_net_0;
 temp_raw(23 downto 0)      <= temp_raw_net_1;
 C1_net_1                   <= C1_net_0;
 C1(15 downto 0)            <= C1_net_1;
 C2_net_1                   <= C2_net_0;
 C2(15 downto 0)            <= C2_net_1;
 C3_net_1                   <= C3_net_0;
 C3(15 downto 0)            <= C3_net_1;
 C4_net_1                   <= C4_net_0;
 C4(15 downto 0)            <= C4_net_1;
 C5_net_1                   <= C5_net_0;
 C5(15 downto 0)            <= C5_net_1;
 C6_net_1                   <= C6_net_0;
 C6(15 downto 0)            <= C6_net_1;
 pressure_time_net_1        <= pressure_time_net_0;
 pressure_time(23 downto 0) <= pressure_time_net_1;
----------------------------------------------------------------------
-- Component instances
----------------------------------------------------------------------
-- I2C_Master_0
I2C_Master_0 : I2C_Master
    port map( 
        -- Inputs
        clk          => i2c_clk,
        reset        => reset,
        we           => MS5611_01BA03_Interface_0_we,
        repeat_start => MS5611_01BA03_Interface_0_i2c_repeat_start,
        address      => MS5611_01BA03_Interface_0_i2c_addr,
        data_in      => MS5611_01BA03_Interface_0_data_out,
        num_bytes    => MS5611_01BA03_Interface_0_num_bytes,
        -- Outputs
        busy         => I2C_Master_0_busy,
        data_out_rdy => I2C_Master_0_data_out_rdy,
        write_done   => I2C_Master_0_write_done,
        s_ack_error  => I2C_Master_0_s_ack_error,
        scl          => scl_net_0,
        data_out     => I2C_Master_0_data_out,
        -- Inouts
        sda          => sda 
        );
-- MS5611_01BA03_Interface_0
MS5611_01BA03_Interface_0 : MS5611_01BA03_Interface
    port map( 
        -- Inputs
        clk                  => clk,
        reset                => reset,
        clk_1kHz             => clk_1kHz,
        en                   => en,
        i2c_busy             => I2C_Master_0_busy,
        i2c_data_rdy         => I2C_Master_0_data_out_rdy,
        i2c_write_done       => I2C_Master_0_write_done,
        i2c_s_ack_error      => I2C_Master_0_s_ack_error,
        microseconds         => microseconds,
        data_in              => I2C_Master_0_data_out,
        -- Outputs
        i2c_repeat_start     => MS5611_01BA03_Interface_0_i2c_repeat_start,
        we                   => MS5611_01BA03_Interface_0_we,
        pressure_new_data    => pressure_new_data_net_0,
        calibration_new_data => calibration_new_data_net_0,
        i2c_addr             => MS5611_01BA03_Interface_0_i2c_addr,
        data_out             => MS5611_01BA03_Interface_0_data_out,
        num_bytes            => MS5611_01BA03_Interface_0_num_bytes,
        C1                   => C1_net_0,
        C2                   => C2_net_0,
        C3                   => C3_net_0,
        C4                   => C4_net_0,
        C5                   => C5_net_0,
        C6                   => C6_net_0,
        pressure_time        => pressure_time_net_0,
        pressure_raw         => pressure_raw_net_0,
        temp_raw             => temp_raw_net_0 
        );

end RTL;
