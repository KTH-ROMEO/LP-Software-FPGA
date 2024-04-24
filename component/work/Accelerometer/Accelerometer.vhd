----------------------------------------------------------------------
-- Created by SmartDesign Sun Jan 12 18:53:50 2020
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
-- Accelerometer entity declaration
----------------------------------------------------------------------
entity Accelerometer is
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
end Accelerometer;
----------------------------------------------------------------------
-- Accelerometer architecture body
----------------------------------------------------------------------
architecture RTL of Accelerometer is
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
-- LSM303AGR_I2C_Interface
component LSM303AGR_I2C_Interface
    -- Port list
    port(
        -- Inputs
        clk              : in  std_logic;
        data_in          : in  std_logic_vector(7 downto 0);
        en               : in  std_logic;
        i2c_busy         : in  std_logic;
        i2c_data_rdy     : in  std_logic;
        i2c_s_ack_error  : in  std_logic;
        i2c_write_done   : in  std_logic;
        microseconds     : in  std_logic_vector(23 downto 0);
        reset            : in  std_logic;
        -- Outputs
        acc_new_data     : out std_logic;
        acc_time         : out std_logic_vector(23 downto 0);
        acc_x            : out std_logic_vector(11 downto 0);
        acc_y            : out std_logic_vector(11 downto 0);
        acc_z            : out std_logic_vector(11 downto 0);
        data_out         : out std_logic_vector(7 downto 0);
        i2c_addr         : out std_logic_vector(7 downto 0);
        i2c_repeat_start : out std_logic;
        mag_new_data     : out std_logic;
        mag_time         : out std_logic_vector(23 downto 0);
        mag_x            : out std_logic_vector(11 downto 0);
        mag_y            : out std_logic_vector(11 downto 0);
        mag_z            : out std_logic_vector(11 downto 0);
        num_bytes        : out std_logic_vector(3 downto 0);
        temp             : out std_logic_vector(7 downto 0);
        we               : out std_logic
        );
end component;
----------------------------------------------------------------------
-- Signal declarations
----------------------------------------------------------------------
signal acc_new_data_net_0                         : std_logic;
signal acc_time_net_0                             : std_logic_vector(23 downto 0);
signal acc_x_net_0                                : std_logic_vector(11 downto 0);
signal acc_y_net_0                                : std_logic_vector(11 downto 0);
signal acc_z_net_0                                : std_logic_vector(11 downto 0);
signal I2C_Master_0_busy                          : std_logic;
signal I2C_Master_0_data_out                      : std_logic_vector(7 downto 0);
signal I2C_Master_0_data_out_rdy                  : std_logic;
signal I2C_Master_0_s_ack_error                   : std_logic;
signal I2C_Master_0_write_done                    : std_logic;
signal LSM303AGR_I2C_Interface_0_data_out         : std_logic_vector(7 downto 0);
signal LSM303AGR_I2C_Interface_0_i2c_addr         : std_logic_vector(7 downto 0);
signal LSM303AGR_I2C_Interface_0_i2c_repeat_start : std_logic;
signal LSM303AGR_I2C_Interface_0_num_bytes        : std_logic_vector(3 downto 0);
signal LSM303AGR_I2C_Interface_0_we               : std_logic;
signal mag_new_data_net_0                         : std_logic;
signal mag_time_net_0                             : std_logic_vector(23 downto 0);
signal mag_x_net_0                                : std_logic_vector(11 downto 0);
signal mag_y_net_0                                : std_logic_vector(11 downto 0);
signal mag_z_net_0                                : std_logic_vector(11 downto 0);
signal scl_net_0                                  : std_logic;
signal temp_net_0                                 : std_logic_vector(7 downto 0);
signal scl_net_1                                  : std_logic;
signal acc_new_data_net_1                         : std_logic;
signal mag_new_data_net_1                         : std_logic;
signal acc_x_net_1                                : std_logic_vector(11 downto 0);
signal acc_y_net_1                                : std_logic_vector(11 downto 0);
signal acc_z_net_1                                : std_logic_vector(11 downto 0);
signal temp_net_1                                 : std_logic_vector(7 downto 0);
signal mag_x_net_1                                : std_logic_vector(11 downto 0);
signal mag_y_net_1                                : std_logic_vector(11 downto 0);
signal mag_z_net_1                                : std_logic_vector(11 downto 0);
signal acc_time_net_1                             : std_logic_vector(23 downto 0);
signal mag_time_net_1                             : std_logic_vector(23 downto 0);

begin
----------------------------------------------------------------------
-- Top level output port assignments
----------------------------------------------------------------------
 scl_net_1             <= scl_net_0;
 scl                   <= scl_net_1;
 acc_new_data_net_1    <= acc_new_data_net_0;
 acc_new_data          <= acc_new_data_net_1;
 mag_new_data_net_1    <= mag_new_data_net_0;
 mag_new_data          <= mag_new_data_net_1;
 acc_x_net_1           <= acc_x_net_0;
 acc_x(11 downto 0)    <= acc_x_net_1;
 acc_y_net_1           <= acc_y_net_0;
 acc_y(11 downto 0)    <= acc_y_net_1;
 acc_z_net_1           <= acc_z_net_0;
 acc_z(11 downto 0)    <= acc_z_net_1;
 temp_net_1            <= temp_net_0;
 temp(7 downto 0)      <= temp_net_1;
 mag_x_net_1           <= mag_x_net_0;
 mag_x(11 downto 0)    <= mag_x_net_1;
 mag_y_net_1           <= mag_y_net_0;
 mag_y(11 downto 0)    <= mag_y_net_1;
 mag_z_net_1           <= mag_z_net_0;
 mag_z(11 downto 0)    <= mag_z_net_1;
 acc_time_net_1        <= acc_time_net_0;
 acc_time(23 downto 0) <= acc_time_net_1;
 mag_time_net_1        <= mag_time_net_0;
 mag_time(23 downto 0) <= mag_time_net_1;
----------------------------------------------------------------------
-- Component instances
----------------------------------------------------------------------
-- I2C_Master_0
I2C_Master_0 : I2C_Master
    port map( 
        -- Inputs
        clk          => i2c_clk,
        reset        => reset,
        we           => LSM303AGR_I2C_Interface_0_we,
        repeat_start => LSM303AGR_I2C_Interface_0_i2c_repeat_start,
        address      => LSM303AGR_I2C_Interface_0_i2c_addr,
        data_in      => LSM303AGR_I2C_Interface_0_data_out,
        num_bytes    => LSM303AGR_I2C_Interface_0_num_bytes,
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
-- LSM303AGR_I2C_Interface_0
LSM303AGR_I2C_Interface_0 : LSM303AGR_I2C_Interface
    port map( 
        -- Inputs
        clk              => clk,
        reset            => reset,
        en               => en,
        i2c_busy         => I2C_Master_0_busy,
        i2c_data_rdy     => I2C_Master_0_data_out_rdy,
        i2c_write_done   => I2C_Master_0_write_done,
        i2c_s_ack_error  => I2C_Master_0_s_ack_error,
        microseconds     => microseconds,
        data_in          => I2C_Master_0_data_out,
        -- Outputs
        i2c_repeat_start => LSM303AGR_I2C_Interface_0_i2c_repeat_start,
        we               => LSM303AGR_I2C_Interface_0_we,
        acc_new_data     => acc_new_data_net_0,
        mag_new_data     => mag_new_data_net_0,
        i2c_addr         => LSM303AGR_I2C_Interface_0_i2c_addr,
        data_out         => LSM303AGR_I2C_Interface_0_data_out,
        num_bytes        => LSM303AGR_I2C_Interface_0_num_bytes,
        acc_time         => acc_time_net_0,
        acc_x            => acc_x_net_0,
        acc_y            => acc_y_net_0,
        acc_z            => acc_z_net_0,
        mag_time         => mag_time_net_0,
        mag_x            => mag_x_net_0,
        mag_y            => mag_y_net_0,
        mag_z            => mag_z_net_0,
        temp             => temp_net_0 
        );

end RTL;
