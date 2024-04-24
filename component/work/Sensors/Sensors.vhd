----------------------------------------------------------------------
-- Created by SmartDesign Sun Jan 12 19:03:13 2020
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
-- Sensors entity declaration
----------------------------------------------------------------------
entity Sensors is
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
end Sensors;
----------------------------------------------------------------------
-- Sensors architecture body
----------------------------------------------------------------------
architecture RTL of Sensors is
----------------------------------------------------------------------
-- Component declarations
----------------------------------------------------------------------
-- Accelerometer
component Accelerometer
    -- Port list
    port(
        -- Inputs
        clk          : in    std_logic;
        en           : in    std_logic;
        i2c_clk      : in    std_logic;
        microseconds : in    std_logic_vector(23 downto 0);
        reset        : in    std_logic;
        -- Outputs
        acc_new_data : out   std_logic;
        acc_time     : out   std_logic_vector(23 downto 0);
        acc_x        : out   std_logic_vector(11 downto 0);
        acc_y        : out   std_logic_vector(11 downto 0);
        acc_z        : out   std_logic_vector(11 downto 0);
        mag_new_data : out   std_logic;
        mag_time     : out   std_logic_vector(23 downto 0);
        mag_x        : out   std_logic_vector(11 downto 0);
        mag_y        : out   std_logic_vector(11 downto 0);
        mag_z        : out   std_logic_vector(11 downto 0);
        scl          : out   std_logic;
        temp         : out   std_logic_vector(7 downto 0);
        -- Inouts
        sda          : inout std_logic
        );
end component;
-- Gyro
component Gyro
    -- Port list
    port(
        -- Inputs
        clk           : in    std_logic;
        en            : in    std_logic;
        i2c_clk       : in    std_logic;
        microseconds  : in    std_logic_vector(23 downto 0);
        reset         : in    std_logic;
        -- Outputs
        gyro_new_data : out   std_logic;
        gyro_time     : out   std_logic_vector(23 downto 0);
        gyro_x        : out   std_logic_vector(15 downto 0);
        gyro_y        : out   std_logic_vector(15 downto 0);
        gyro_z        : out   std_logic_vector(15 downto 0);
        scl           : out   std_logic;
        temp          : out   std_logic_vector(7 downto 0);
        -- Inouts
        sda           : inout std_logic
        );
end component;
-- Pressure_Sensor
component Pressure_Sensor
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
end component;
----------------------------------------------------------------------
-- Signal declarations
----------------------------------------------------------------------
signal acc_new_data_net_0      : std_logic;
signal acc_temp_net_0          : std_logic_vector(7 downto 0);
signal acc_time_net_0          : std_logic_vector(23 downto 0);
signal acc_x_net_0             : std_logic_vector(11 downto 0);
signal acc_y_net_0             : std_logic_vector(11 downto 0);
signal acc_z_net_0             : std_logic_vector(11 downto 0);
signal acce_scl_net_0          : std_logic;
signal C1_net_0                : std_logic_vector(15 downto 0);
signal C2_net_0                : std_logic_vector(15 downto 0);
signal C3_net_0                : std_logic_vector(15 downto 0);
signal C4_net_0                : std_logic_vector(15 downto 0);
signal C5_net_0                : std_logic_vector(15 downto 0);
signal C6_net_0                : std_logic_vector(15 downto 0);
signal gyro_new_data_net_0     : std_logic;
signal gyro_scl_net_0          : std_logic;
signal gyro_temp_net_0         : std_logic_vector(7 downto 0);
signal gyro_time_net_0         : std_logic_vector(23 downto 0);
signal gyro_x_net_0            : std_logic_vector(15 downto 0);
signal gyro_y_net_0            : std_logic_vector(15 downto 0);
signal gyro_z_net_0            : std_logic_vector(15 downto 0);
signal mag_new_data_net_0      : std_logic;
signal mag_time_net_0          : std_logic_vector(23 downto 0);
signal mag_x_net_0             : std_logic_vector(11 downto 0);
signal mag_y_net_0             : std_logic_vector(11 downto 0);
signal mag_z_net_0             : std_logic_vector(11 downto 0);
signal pres_cal_new_data_net_0 : std_logic;
signal pressure_new_data_net_0 : std_logic;
signal pressure_raw_net_0      : std_logic_vector(23 downto 0);
signal pressure_scl_net_0      : std_logic;
signal pressure_temp_raw_net_0 : std_logic_vector(23 downto 0);
signal pressure_time_net_0     : std_logic_vector(23 downto 0);
signal acce_scl_net_1          : std_logic;
signal pressure_scl_net_1      : std_logic;
signal gyro_scl_net_1          : std_logic;
signal acc_new_data_net_1      : std_logic;
signal mag_new_data_net_1      : std_logic;
signal gyro_new_data_net_1     : std_logic;
signal pressure_new_data_net_1 : std_logic;
signal pres_cal_new_data_net_1 : std_logic;
signal acc_x_net_1             : std_logic_vector(11 downto 0);
signal acc_y_net_1             : std_logic_vector(11 downto 0);
signal acc_z_net_1             : std_logic_vector(11 downto 0);
signal acc_temp_net_1          : std_logic_vector(7 downto 0);
signal mag_x_net_1             : std_logic_vector(11 downto 0);
signal mag_y_net_1             : std_logic_vector(11 downto 0);
signal mag_z_net_1             : std_logic_vector(11 downto 0);
signal gyro_x_net_1            : std_logic_vector(15 downto 0);
signal gyro_y_net_1            : std_logic_vector(15 downto 0);
signal gyro_z_net_1            : std_logic_vector(15 downto 0);
signal gyro_temp_net_1         : std_logic_vector(7 downto 0);
signal pressure_raw_net_1      : std_logic_vector(23 downto 0);
signal pressure_temp_raw_net_1 : std_logic_vector(23 downto 0);
signal C1_net_1                : std_logic_vector(15 downto 0);
signal C2_net_1                : std_logic_vector(15 downto 0);
signal C3_net_1                : std_logic_vector(15 downto 0);
signal C4_net_1                : std_logic_vector(15 downto 0);
signal C5_net_1                : std_logic_vector(15 downto 0);
signal C6_net_1                : std_logic_vector(15 downto 0);
signal pressure_time_net_1     : std_logic_vector(23 downto 0);
signal gyro_time_net_1         : std_logic_vector(23 downto 0);
signal acc_time_net_1          : std_logic_vector(23 downto 0);
signal mag_time_net_1          : std_logic_vector(23 downto 0);

begin
----------------------------------------------------------------------
-- Top level output port assignments
----------------------------------------------------------------------
 acce_scl_net_1                 <= acce_scl_net_0;
 acce_scl                       <= acce_scl_net_1;
 pressure_scl_net_1             <= pressure_scl_net_0;
 pressure_scl                   <= pressure_scl_net_1;
 gyro_scl_net_1                 <= gyro_scl_net_0;
 gyro_scl                       <= gyro_scl_net_1;
 acc_new_data_net_1             <= acc_new_data_net_0;
 acc_new_data                   <= acc_new_data_net_1;
 mag_new_data_net_1             <= mag_new_data_net_0;
 mag_new_data                   <= mag_new_data_net_1;
 gyro_new_data_net_1            <= gyro_new_data_net_0;
 gyro_new_data                  <= gyro_new_data_net_1;
 pressure_new_data_net_1        <= pressure_new_data_net_0;
 pressure_new_data              <= pressure_new_data_net_1;
 pres_cal_new_data_net_1        <= pres_cal_new_data_net_0;
 pres_cal_new_data              <= pres_cal_new_data_net_1;
 acc_x_net_1                    <= acc_x_net_0;
 acc_x(11 downto 0)             <= acc_x_net_1;
 acc_y_net_1                    <= acc_y_net_0;
 acc_y(11 downto 0)             <= acc_y_net_1;
 acc_z_net_1                    <= acc_z_net_0;
 acc_z(11 downto 0)             <= acc_z_net_1;
 acc_temp_net_1                 <= acc_temp_net_0;
 acc_temp(7 downto 0)           <= acc_temp_net_1;
 mag_x_net_1                    <= mag_x_net_0;
 mag_x(11 downto 0)             <= mag_x_net_1;
 mag_y_net_1                    <= mag_y_net_0;
 mag_y(11 downto 0)             <= mag_y_net_1;
 mag_z_net_1                    <= mag_z_net_0;
 mag_z(11 downto 0)             <= mag_z_net_1;
 gyro_x_net_1                   <= gyro_x_net_0;
 gyro_x(15 downto 0)            <= gyro_x_net_1;
 gyro_y_net_1                   <= gyro_y_net_0;
 gyro_y(15 downto 0)            <= gyro_y_net_1;
 gyro_z_net_1                   <= gyro_z_net_0;
 gyro_z(15 downto 0)            <= gyro_z_net_1;
 gyro_temp_net_1                <= gyro_temp_net_0;
 gyro_temp(7 downto 0)          <= gyro_temp_net_1;
 pressure_raw_net_1             <= pressure_raw_net_0;
 pressure_raw(23 downto 0)      <= pressure_raw_net_1;
 pressure_temp_raw_net_1        <= pressure_temp_raw_net_0;
 pressure_temp_raw(23 downto 0) <= pressure_temp_raw_net_1;
 C1_net_1                       <= C1_net_0;
 C1(15 downto 0)                <= C1_net_1;
 C2_net_1                       <= C2_net_0;
 C2(15 downto 0)                <= C2_net_1;
 C3_net_1                       <= C3_net_0;
 C3(15 downto 0)                <= C3_net_1;
 C4_net_1                       <= C4_net_0;
 C4(15 downto 0)                <= C4_net_1;
 C5_net_1                       <= C5_net_0;
 C5(15 downto 0)                <= C5_net_1;
 C6_net_1                       <= C6_net_0;
 C6(15 downto 0)                <= C6_net_1;
 pressure_time_net_1            <= pressure_time_net_0;
 pressure_time(23 downto 0)     <= pressure_time_net_1;
 gyro_time_net_1                <= gyro_time_net_0;
 gyro_time(23 downto 0)         <= gyro_time_net_1;
 acc_time_net_1                 <= acc_time_net_0;
 acc_time(23 downto 0)          <= acc_time_net_1;
 mag_time_net_1                 <= mag_time_net_0;
 mag_time(23 downto 0)          <= mag_time_net_1;
----------------------------------------------------------------------
-- Component instances
----------------------------------------------------------------------
-- Accelerometer_0
Accelerometer_0 : Accelerometer
    port map( 
        -- Inputs
        clk          => clk,
        i2c_clk      => i2c_clk,
        reset        => reset,
        en           => en,
        microseconds => microseconds,
        -- Outputs
        scl          => acce_scl_net_0,
        acc_new_data => acc_new_data_net_0,
        mag_new_data => mag_new_data_net_0,
        acc_x        => acc_x_net_0,
        acc_y        => acc_y_net_0,
        acc_z        => acc_z_net_0,
        temp         => acc_temp_net_0,
        mag_x        => mag_x_net_0,
        mag_y        => mag_y_net_0,
        mag_z        => mag_z_net_0,
        acc_time     => acc_time_net_0,
        mag_time     => mag_time_net_0,
        -- Inouts
        sda          => acce_sda 
        );
-- Gyro_0
Gyro_0 : Gyro
    port map( 
        -- Inputs
        clk           => clk,
        i2c_clk       => i2c_clk,
        reset         => reset,
        en            => en,
        microseconds  => microseconds,
        -- Outputs
        scl           => gyro_scl_net_0,
        gyro_new_data => gyro_new_data_net_0,
        gyro_x        => gyro_x_net_0,
        gyro_y        => gyro_y_net_0,
        gyro_z        => gyro_z_net_0,
        temp          => gyro_temp_net_0,
        gyro_time     => gyro_time_net_0,
        -- Inouts
        sda           => gyro_sda 
        );
-- Pressure_Sensor_0
Pressure_Sensor_0 : Pressure_Sensor
    port map( 
        -- Inputs
        clk                  => clk,
        i2c_clk              => i2c_clk,
        clk_1kHz             => clk_1kHz,
        reset                => reset,
        en                   => en,
        microseconds         => microseconds,
        -- Outputs
        scl                  => pressure_scl_net_0,
        pressure_new_data    => pressure_new_data_net_0,
        calibration_new_data => pres_cal_new_data_net_0,
        pressure_raw         => pressure_raw_net_0,
        temp_raw             => pressure_temp_raw_net_0,
        C1                   => C1_net_0,
        C2                   => C2_net_0,
        C3                   => C3_net_0,
        C4                   => C4_net_0,
        C5                   => C5_net_0,
        C6                   => C6_net_0,
        pressure_time        => pressure_time_net_0,
        -- Inouts
        sda                  => pressure_sda 
        );

end RTL;
