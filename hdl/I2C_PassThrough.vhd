--------------------------------------------------------------------------------
-- Company: Royal Institute of Technology
--
-- File: I2C_PassThrough.vhd
-- File history:
--      <Revision number>: <Date>: <Comments>
--      <Revision number>: <Date>: <Comments>
--      <Revision number>: <Date>: <Comments>
--
-- Description: 
-- An attempt to route an I2C bus through the FPGA.
-- Original purpose to connect data hub FRAM to microcontroller.
-- Should work for other stuff as well, provided that clk >> scl.
-- Clock stretching is not implemented, but could probably be implemented in the same way as SDA handling.
--
-- The value of cnt check in states wait_slave and wait_master might need to be adjusted, depending on pullups, parasitic capacitances etc.
--
-- Targeted device: <Family::ProASIC3> <Die::A3P250> <Package::100 VQFP>
-- Author: C. Tolis
--
--------------------------------------------------------------------------------

library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity I2C_PassThrough is
port (
    clk : IN std_logic;
    reset : IN std_logic;

    sda_m : INOUT std_logic;
    sda_s : INOUT std_logic;

    scl_m : IN std_logic;
    scl_s : OUT std_logic
);
end I2C_PassThrough;
architecture architecture_I2C_PassThrough of I2C_PassThrough is
    type i2c_state is (idle, master_pull, slave_pull, wait_master, wait_slave);
    signal state : i2c_state;
    signal cnt : integer range 1 to 20;
begin
    scl_s <= scl_m;
    sda_s <= '0' when state = master_pull else 'Z';
    sda_m <= '0' when state = slave_pull else 'Z';

    process (reset, clk)
    begin
        if reset /= '0' then
            state <= idle;

        elsif rising_edge(clk) then
            case state is
                when idle =>
                    if sda_m = '0' then
                        state <= master_pull;
                    elsif sda_s = '0' then
                        state <= slave_pull;
                    end if;

                when master_pull =>
                    if sda_m = '1' then
                        state <= wait_slave;
                    end if;

                when slave_pull =>
                    if sda_s = '1' then
                        state <= wait_master;
                    end if;
 
                when wait_slave =>
                    if cnt = 20 then
                        cnt <= 1;

                        if sda_s = '1' then
                            state <= idle;
                        else
                            state <= slave_pull;
                        end if;
                    else
                        cnt <= cnt + 1;
                    end if;

                when wait_master =>
                    if cnt = 20 then
                        cnt <= 1;

                        if sda_m = '1' then
                            state <= idle;
                        else
                            state <= master_pull;
                        end if;
                    else
                        cnt <= cnt + 1;
                    end if;

            end case;
        end if;
    end process;
end architecture_I2C_PassThrough;
