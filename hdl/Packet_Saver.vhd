-- 

library IEEE;
use IEEE.std_logic_1164.all;

entity Packet_Saver is
port (
    clk, reset, en : IN std_logic;
    ch_0_packet : IN std_logic_vector(63 downto 0);
    ch_0_new_data : IN std_logic;
    data_out : OUT std_logic_vector(31 downto 0);
    we : OUT std_logic
);
end Packet_Saver;

architecture architecture_Packet_Saver of Packet_Saver is
    type state_type is (idle, sending);
    signal state : state_type := idle;
    signal word_cnt : integer range 1 to 2 := 1;
    signal old_ch_0_new_data : std_logic := '0';
begin

    process (clk, reset)
    begin
        if reset /= '0' then
            state <= idle;
            word_cnt <= 1;
            data_out <= (others => '0');
            we <= '0';
            old_ch_0_new_data <= '0';

        elsif falling_edge(clk) then
            -- Store the previous state of ch_0_new_data
            old_ch_0_new_data <= ch_0_new_data;

            if en = '1' then
                case state is
                    when idle =>
                        we <= '0';
                        if ch_0_new_data = '1' and old_ch_0_new_data = '0' then -- Detect rising edge
                            state <= sending;
                            word_cnt <= 1;
                        end if;

                    when sending =>
                        we <= '1'; -- Assert write enable
                        -- if word_cnt = 1 then
                        --     data_out <= ch_0_packet(63 downto 32);
                        --     word_cnt <= 2;
                        -- else
                        --     data_out <= ch_0_packet(31 downto 0);
                        --     state <= idle; -- Done sending, go back to idle
                        -- end if;
                        
                        if word_cnt = 1 then
                            -- Byte-swap upper 32 bits
                            data_out(31 downto 24) <= ch_0_packet(39 downto 32);
                            data_out(23 downto 16) <= ch_0_packet(47 downto 40);
                            data_out(15 downto 8)  <= ch_0_packet(55 downto 48);
                            data_out(7 downto 0)   <= ch_0_packet(63 downto 56);
                            word_cnt <= 2;
                        else
                            -- Byte-swap lower 32 bits
                            data_out(31 downto 24) <= ch_0_packet(7 downto 0);
                            data_out(23 downto 16) <= ch_0_packet(15 downto 8);
                            data_out(15 downto 8)  <= ch_0_packet(23 downto 16);
                            data_out(7 downto 0)   <= ch_0_packet(31 downto 24);
                            state <= idle;
                        end if;

                end case;
            end if;
        end if;
    end process;
end architecture_Packet_Saver;
