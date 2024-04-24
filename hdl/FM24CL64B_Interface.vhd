--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: FM24CL64B_Interface.vhd
-- File history:
--      <Revision number>: <Date>: <Comments>
--      <Revision number>: <Date>: <Comments>
--      <Revision number>: <Date>: <Comments>


--
-- Description: 
--
-- <Description here>
--
-- Targeted device: <Family::ProASIC3> <Die::A3P250> <Package::100 VQFP>
-- Author: <Name>
--
--------------------------------------------------------------------------------

library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity FM24CL64B_Interface is
port (
    clk : IN std_logic;
    reset : IN std_logic;

    fram_address : IN std_logic_vector(12 downto 0);
    data_in : IN std_logic_vector(7 downto 0);
    re : IN std_logic;
    we : IN std_logic;

    i2c_data : IN std_logic_vector(7 downto 0);
    i2c_data_ready: IN std_logic;
    i2c_write_ready : IN std_logic;
    i2c_ready : IN std_logic;
    i2c_ack_error : IN std_logic;

    i2c_address : OUT std_logic_vector(7 downto 0);
    i2c_command : OUT std_logic_vector(7 downto 0);
    i2c_writedata : OUT std_logic_vector(7 downto 0);
    i2c_readbytes : OUT std_logic_vector(7 downto 0);
    i2c_writebytes : OUT std_logic_vector(7 downto 0);
    i2c_go : OUT std_logic;
    i2c_repeatstart : OUT std_logic;

    data_out : OUT std_logic_vector(7 downto 0);
    data_out_rdy : OUT std_logic;
    ready : OUT std_logic

);
end FM24CL64B_Interface;

architecture architecture_FM24CL64B_Interface of FM24CL64B_Interface is
    type state_type is (
        state_idle,
        state_write,
        state_read
    );

    signal state : state_type;

    signal s_fram_address : std_logic_vector(12 downto 0);
    signal s_data_in : std_logic_vector(7 downto 0);

    signal stateCounter : integer range 1 to 16;

    constant address_r : std_logic_vector(7 downto 0) := "10100001";
    constant address_w : std_logic_vector(7 downto 0) := "10100000";

begin

process(clk, reset)
begin
    if reset /= '0' then
        i2c_go <= '0';
        i2c_repeatstart <= '0';
        ready <= '0';
        data_out_rdy <= '0';

        state <= state_idle;
        stateCounter <= 1;

    elsif falling_edge(clk) then
        i2c_go <= '0';

        if i2c_ack_error then
            state <= state_idle;
        end if;

        case state is
            when state_idle =>
                ready <= '1';

                if we = '1' then
                    s_fram_address <= fram_address;
                    s_data_in <= data_in;

                    state <= state_write;
                elsif re = '1' then
                    data_out_rdy <= '0';

                    s_fram_address <= fram_address;

                    state <= state_read;
                end if;

            when state_write =>
                ready <= '0';

                case stateCounter is
                   when 1 =>
                        if i2c_ready then
                            i2c_address <= address_w;
                            i2c_writebytes <= x"02";
                            i2c_command <= "000" & s_fram_address(12 downto 8);
                            i2c_writedata <= s_fram_address(7 downto 0);
                            i2c_go <= '1';

                            stateCounter <= 2;
                        end if;
                    when 2 =>
                        if i2c_write_ready then
                            stateCounter <= 3;
                        end if;

                    when 3 =>
                        if i2c_write_ready = '0' then
                            i2c_writedata <= s_data_in;
                            stateCounter <= 4;
                        end if;

                    when 4 =>
                        if i2c_write_ready then
                            stateCounter <= 1;
                            state <= state_idle;
                        end if;
                            
                end case;

            when state_read =>
                ready <= '0';

                case stateCounter is
                   when 1 =>
                        if i2c_ready then
                            i2c_address <= address_w;
                            i2c_writebytes <= x"01";
                            i2c_command <= "000" & s_fram_address(12 downto 8);
                            i2c_writedata <= s_fram_address(7 downto 0);
                            i2c_go <= '1';

                            stateCounter <= 2;
                        end if;
                    when 2 =>
                        if i2c_write_ready then
                            stateCounter <= 3;
                        end if;

                    when 3 =>
                        if i2c_ready then
                            i2c_address <= address_r;
                            i2c_readbytes <= x"01";
                            i2c_go <= '1';
                        elsif i2c_data_ready then
                            stateCounter <= 4;
                        end if;
 
                    when 4 =>
                            data_out <= i2c_data;
                            data_out_rdy <= '1';
                            stateCounter <= 1;
                            state <= state_idle;


                end case;

        end case;

    end if;
end process;
end architecture_FM24CL64B_Interface;
