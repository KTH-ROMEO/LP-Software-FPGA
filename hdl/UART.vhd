--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: UART.vhd
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

entity UART is
port (
    clk : IN std_logic;
    reset : IN std_logic;

    rx : IN std_logic;
    send : IN std_logic_vector(7 downto 0);
    send_wen : IN std_logic;
    recv_oen : IN std_logic;

    tx : OUT std_logic;
    recv : OUT std_logic_vector(7 downto 0);

    test_port : OUT std_logic;

    rx_rdy : OUT std_logic;
    tx_rdy : OUT std_logic;

    transmitting : OUT std_logic
);
end UART;
architecture architecture_UART of UART is
    --constant baud_cnt : integer := 833;     -- Set baud rate here. Value should be (clk / baud_rate).
    constant baud_cnt : integer := 275;
    constant rx_sample_cnt : integer := baud_cnt / 2;

    type tx_state_type is (tx_idle, tx_start, tx_data, tx_stop);
    signal tx_state : tx_state_type;
    signal tx_count : integer range 0 to 7;
    signal tx_byte : std_logic_vector(7 downto 0);
    signal tx_clk_count : integer range 0 to baud_cnt;

    type rx_state_type is (rx_idle, rx_start, rx_data, rx_stop);
    signal rx_state : rx_state_type;
    signal rx_count : integer range 0 to 7;
    signal rx_byte : std_logic_vector(7 downto 0);
    signal rx_clk_count : integer range 0 to baud_cnt;

begin

    transmitting <= '0' when tx_state = tx_idle else '1';

    process(reset, clk)
    begin
        if reset /= '0' then
            tx_rdy <= '0';
            tx <= '1';
            tx_count <= 0;
            tx_clk_count <= 0;
            tx_state <= tx_idle;

        elsif rising_edge(clk) then
            case tx_state is
                when tx_idle =>
                    tx_rdy <= '1';
                    tx <= '1';

                    if send_wen = '1' then
                        tx_byte <= send;
                        tx_state <= tx_start;
                    end if;

                when tx_start =>
                    tx_rdy <= '0';
                    tx <= '0';

                    if tx_clk_count >= baud_cnt then
                        tx_state <= tx_data;
                        tx_count <= 0;
                        tx_clk_count <= 0;
                    else
                        tx_clk_count <= tx_clk_count + 1;
                    end if;

                when tx_data =>
                    tx_rdy <= '0';
                    tx <= tx_byte(tx_count);

                    if tx_clk_count >= baud_cnt then
                        tx_clk_count <= 0;

                        if tx_count = 7 then
                            tx_state <= tx_stop;
                        else
                            tx_count <= tx_count + 1;
                        end if;
                    else
                        tx_clk_count <= tx_clk_count + 1;
                    end if;

                when tx_stop =>
                    tx <= '1';
                    tx_rdy <= '0';

                    if tx_clk_count >= baud_cnt then
                        tx_state <= tx_idle;
                        tx_clk_count <= 0;
                    else
                        tx_clk_count <= tx_clk_count + 1;
                    end if;

                when others => tx_state <= tx_idle;

            end case;
        end if;
    end process;

    process(reset, clk)
    begin
        if reset /= '0' then
            rx_state <= rx_idle;
            rx_rdy <= '0';
            recv <= (others => '0');
            rx_count <= 0;
            rx_byte <= (others => '0');
            rx_clk_count <= 0;
            test_port <= '0';

        elsif rising_edge(clk) then
            test_port <= '0';

            case rx_state is
                when rx_idle =>
                    if recv_oen = '1' then
                        rx_rdy <= '0';
                    end if;

                    if rx = '0' then
                        rx_state <= rx_start;
                    end if;

                when rx_start =>
                    if rx_clk_count >= baud_cnt then
                        rx_state <= rx_data;
                        rx_clk_count <= 0;
                        rx_count <= 0;
                    else
                        rx_clk_count <= rx_clk_count + 1;
                    end if;

                when rx_data =>
                    rx_rdy <= '0';

                    if rx_clk_count = rx_sample_cnt then
                        rx_byte(rx_count) <= rx;
                        rx_clk_count <= rx_clk_count + 1;

                    elsif rx_clk_count >= baud_cnt then
                        rx_clk_count <= 0;

                        if rx_count = 7 then
                            rx_state <= rx_stop;
                        else
                            rx_count <= rx_count + 1;
                        end if;
                    else
                        rx_clk_count <= rx_clk_count + 1;
                    end if;

                when rx_stop =>
                    if rx_clk_count >= rx_sample_cnt then
                        rx_state <= rx_idle;
                        rx_rdy <= '1';
                        recv <= rx_byte;
                        rx_clk_count <= 0;
                    else
                        rx_clk_count <= rx_clk_count + 1;
                    end if;

                when others => rx_state <= rx_idle;
            end case;
        end if;
    end process;
end architecture_UART;
