----------------------------------------------------------------------
-- Created by SmartDesign Fri Oct 23 14:44:40 2026
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
-- Sensors entity declaration
----------------------------------------------------------------------
entity Sensors is
    -- Port list
    port(
        -- Inputs
        clk           : in    std_logic;
        en            : in    std_logic;
        i2c_clk       : in    std_logic;
        microseconds  : in    std_logic_vector(23 downto 0);
        reset         : in    std_logic;
        -- Outputs
        acc_new_data  : out   std_logic;
        acc_temp      : out   std_logic_vector(7 downto 0);
        acc_time      : out   std_logic_vector(23 downto 0);
        acc_x         : out   std_logic_vector(11 downto 0);
        acc_y         : out   std_logic_vector(11 downto 0);
        acc_z         : out   std_logic_vector(11 downto 0);
        acce_scl      : out   std_logic;
        gyro_new_data : out   std_logic;
        gyro_scl      : out   std_logic;
        gyro_temp     : out   std_logic_vector(7 downto 0);
        gyro_time     : out   std_logic_vector(23 downto 0);
        gyro_x        : out   std_logic_vector(15 downto 0);
        gyro_y        : out   std_logic_vector(15 downto 0);
        gyro_z        : out   std_logic_vector(15 downto 0);
        mag_new_data  : out   std_logic;
        mag_time      : out   std_logic_vector(23 downto 0);
        mag_x         : out   std_logic_vector(11 downto 0);
        mag_y         : out   std_logic_vector(11 downto 0);
        mag_z         : out   std_logic_vector(11 downto 0);
        -- Inouts
        acce_sda      : inout std_logic;
        gyro_sda      : inout std_logic
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
----------------------------------------------------------------------
-- Signal declarations
----------------------------------------------------------------------
signal acc_new_data_net_0  : std_logic;
signal acc_temp_net_0      : std_logic_vector(7 downto 0);
signal acc_time_net_0      : std_logic_vector(23 downto 0);
signal acc_x_net_0         : std_logic_vector(11 downto 0);
signal acc_y_net_0         : std_logic_vector(11 downto 0);
signal acc_z_net_0         : std_logic_vector(11 downto 0);
signal acce_scl_net_0      : std_logic;
signal gyro_new_data_net_0 : std_logic;
signal gyro_scl_net_0      : std_logic;
signal gyro_temp_net_0     : std_logic_vector(7 downto 0);
signal gyro_time_net_0     : std_logic_vector(23 downto 0);
signal gyro_x_net_0        : std_logic_vector(15 downto 0);
signal gyro_y_net_0        : std_logic_vector(15 downto 0);
signal gyro_z_net_0        : std_logic_vector(15 downto 0);
signal mag_new_data_net_0  : std_logic;
signal mag_time_net_0      : std_logic_vector(23 downto 0);
signal mag_x_net_0         : std_logic_vector(11 downto 0);
signal mag_y_net_0         : std_logic_vector(11 downto 0);
signal mag_z_net_0         : std_logic_vector(11 downto 0);
signal acce_scl_net_1      : std_logic;
signal gyro_scl_net_1      : std_logic;
signal acc_new_data_net_1  : std_logic;
signal mag_new_data_net_1  : std_logic;
signal gyro_new_data_net_1 : std_logic;
signal acc_x_net_1         : std_logic_vector(11 downto 0);
signal acc_y_net_1         : std_logic_vector(11 downto 0);
signal acc_z_net_1         : std_logic_vector(11 downto 0);
signal acc_temp_net_1      : std_logic_vector(7 downto 0);
signal mag_x_net_1         : std_logic_vector(11 downto 0);
signal mag_y_net_1         : std_logic_vector(11 downto 0);
signal mag_z_net_1         : std_logic_vector(11 downto 0);
signal gyro_x_net_1        : std_logic_vector(15 downto 0);
signal gyro_y_net_1        : std_logic_vector(15 downto 0);
signal gyro_z_net_1        : std_logic_vector(15 downto 0);
signal gyro_temp_net_1     : std_logic_vector(7 downto 0);
signal gyro_time_net_1     : std_logic_vector(23 downto 0);
signal acc_time_net_1      : std_logic_vector(23 downto 0);
signal mag_time_net_1      : std_logic_vector(23 downto 0);

begin
----------------------------------------------------------------------
-- Top level output port assignments
----------------------------------------------------------------------
 acce_scl_net_1         <= acce_scl_net_0;
 acce_scl               <= acce_scl_net_1;
 gyro_scl_net_1         <= gyro_scl_net_0;
 gyro_scl               <= gyro_scl_net_1;
 acc_new_data_net_1     <= acc_new_data_net_0;
 acc_new_data           <= acc_new_data_net_1;
 mag_new_data_net_1     <= mag_new_data_net_0;
 mag_new_data           <= mag_new_data_net_1;
 gyro_new_data_net_1    <= gyro_new_data_net_0;
 gyro_new_data          <= gyro_new_data_net_1;
 acc_x_net_1            <= acc_x_net_0;
 acc_x(11 downto 0)     <= acc_x_net_1;
 acc_y_net_1            <= acc_y_net_0;
 acc_y(11 downto 0)     <= acc_y_net_1;
 acc_z_net_1            <= acc_z_net_0;
 acc_z(11 downto 0)     <= acc_z_net_1;
 acc_temp_net_1         <= acc_temp_net_0;
 acc_temp(7 downto 0)   <= acc_temp_net_1;
 mag_x_net_1            <= mag_x_net_0;
 mag_x(11 downto 0)     <= mag_x_net_1;
 mag_y_net_1            <= mag_y_net_0;
 mag_y(11 downto 0)     <= mag_y_net_1;
 mag_z_net_1            <= mag_z_net_0;
 mag_z(11 downto 0)     <= mag_z_net_1;
 gyro_x_net_1           <= gyro_x_net_0;
 gyro_x(15 downto 0)    <= gyro_x_net_1;
 gyro_y_net_1           <= gyro_y_net_0;
 gyro_y(15 downto 0)    <= gyro_y_net_1;
 gyro_z_net_1           <= gyro_z_net_0;
 gyro_z(15 downto 0)    <= gyro_z_net_1;
 gyro_temp_net_1        <= gyro_temp_net_0;
 gyro_temp(7 downto 0)  <= gyro_temp_net_1;
 gyro_time_net_1        <= gyro_time_net_0;
 gyro_time(23 downto 0) <= gyro_time_net_1;
 acc_time_net_1         <= acc_time_net_0;
 acc_time(23 downto 0)  <= acc_time_net_1;
 mag_time_net_1         <= mag_time_net_0;
 mag_time(23 downto 0)  <= mag_time_net_1;
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

end RTL;
