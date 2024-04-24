--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: I2C_Master.vhd
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

entity I2C_Master is
port (
    clk : IN std_logic;         -- Twice that of desired SCL
    reset : IN std_logic;

    address : IN std_logic_vector(7 downto 0);
    data_in : IN std_logic_vector(7 downto 0);
    num_bytes : IN std_logic_vector(3 downto 0);
    we : IN std_logic;
    repeat_start : IN std_logic;

    sda : INOUT std_logic;

    busy : OUT std_logic;
    data_out : OUT std_logic_vector(7 downto 0);
    data_out_rdy : OUT std_logic;
    write_done : OUT std_logic;
    s_ack_error : OUT std_logic;
    scl : OUT std_logic
);
end I2C_Master;
architecture architecture_I2C_Master of I2C_Master is
    type state_type is (
        idle,
        start,
        rep_start,
        addr,
        s_ack,
        m_ack,
        writebyte,
        readbyte,
        stop
    );

    signal state : state_type;
    signal next_state : state_type;
    signal bitcnt : integer range -1 to 7;
    signal byte_cnt : std_logic_vector(3 downto 0);

begin
    busy <= '0' when state = idle else '1';

    process (clk, reset)
    begin
        if reset /= '0' then
            state <= idle;
            scl <= '1';
            sda <= 'Z';
            bitcnt <= 7;
            byte_cnt <= x"0";
            write_done <= '0';
            s_ack_error <= '0';

            data_out_rdy <= '0';
            data_out <= (others => '0');

        elsif falling_edge(clk) then
            case state is
                when idle =>
                    sda <= '1';

                    if we = '1' then
                        state <= start;
                    end if;

                when start =>
                    sda <= '0';
                    state <= addr;
                    bitcnt <= 7;
                    byte_cnt <= num_bytes;

                when addr =>
                    if scl = '1' then
                        if bitcnt = 0 then
                            if address(bitcnt) = '0' then
                                next_state <= writebyte;
                            else
                                next_state <= readbyte;
                            end if;
                        end if;
                    elsif scl = '0' then
                        if bitcnt = -1 then
                            state <= s_ack;
                            sda <= 'Z';
                        else
                            sda <= address(bitcnt);
                            bitcnt <= bitcnt - 1;
                        end if;
                    end if;

                when s_ack =>
                    bitcnt <= 7;

                    if scl = '1' then
                        if sda /= '0' then
                            next_state <= stop;
                            s_ack_error <= '1';
                        end if;
                    else
                        write_done <= '0';

                        if next_state = writebyte then
                            if byte_cnt > 0 then
                                state <= next_state;
                                sda <= data_in(7);
                                bitcnt <= 6;
                            else
                                if repeat_start = '1' then
                                    state <= start;
                                    sda <= '1';
                                else
                                    state <= stop;
                                    sda <= '0';
                                end if;
                            end if;
                        elsif next_state = readbyte then
                            if byte_cnt > 0 then
                                state <= next_state;
                                sda <= 'Z';
                            else
                                state <= stop;
                                sda <= '0';
                            end if;
                        else
                            state <= stop;
                            sda <= '0';
                        end if;
                    end if;
                    
                when writebyte =>
                    if scl = '0' then
                        if bitcnt = -1 then
                            write_done <= '1';
                            state <= s_ack;
                            sda <= 'Z';
                            byte_cnt <= byte_cnt - 1;
                        else
                            sda <= data_in(bitcnt);
                            bitcnt <= bitcnt - 1;
                        end if;
                    end if;

                when m_ack =>
                    bitcnt <= 7;

                    if scl = '0' then
                        data_out_rdy <= '0';

                        if byte_cnt > 0 then
                            sda <= 'Z';
                            state <= next_state;
                        else
                            sda <= '0';
                            state <= stop;
                        end if;
                    end if;

                when readbyte =>
                    if scl = '0' then
                        if bitcnt = 0 then
                            state <= m_ack;
                            data_out_rdy <= '1';
                            byte_cnt <= byte_cnt - 1;

                            if byte_cnt > 1 then
                                sda <= '0';
                            else
                                sda <= '1';
                            end if;

                        else
                            sda <= 'Z';
                            bitcnt <= bitcnt - 1;
                        end if;
                    else
                        data_out(bitcnt) <= sda;
                    end if;

                when stop =>
                    if scl = '1' then
                        sda <= '1';
                        s_ack_error <= '0';
                        state <= idle;
                    end if;

                when others =>
                    state <= idle;

            end case;

        elsif rising_edge(clk) then
            if state = idle OR state = start OR state = stop then
                scl <= '1';
            else
                scl <= not scl;
            end if;



        end if;
    end process;
end architecture_I2C_Master;
