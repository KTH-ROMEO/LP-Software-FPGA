--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: Timekeeper.vhd
--
-- Description:
-- Timekeeper with 7-byte timestamp packet.
--
-- Timestamp packet format:
--
--   timestamp_packet[55:52] = timestamp_flags
--   timestamp_packet[51:20] = seconds32
--   timestamp_packet[19:0]  = usec_in_sec
--
-- Byte layout:
--
--   B0[7:4] = timestamp_flags
--   B0[3:0] = seconds32[31:28]
--   B1      = seconds32[27:20]
--   B2      = seconds32[19:12]
--   B3      = seconds32[11:4]
--   B4[7:4] = seconds32[3:0]
--   B4[3:0] = usec_in_sec[19:16]
--   B5      = usec_in_sec[15:8]
--   B6      = usec_in_sec[7:0]
--
-- timestamp_flags:
--   flags[3] = timestamp_valid
--   flags[2] = reserved
--   flags[1] = reserved
--   flags[0] = reserved
--
--------------------------------------------------------------------------------

library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Timekeeper is
port (
    clk       : IN std_logic;
    clk_1MHz  : IN std_logic;
    clk_1kHz  : IN std_logic;
    clk_1Hz   : IN std_logic;
    reset     : IN std_logic;

    microseconds     : OUT std_logic_vector(23 downto 0);
    milliseconds     : OUT std_logic_vector(23 downto 0);
    seconds          : OUT std_logic_vector(19 downto 0);

    timestamp_packet : OUT std_logic_vector(55 downto 0)
);
end Timekeeper;

architecture architecture_Timekeeper of Timekeeper is

    signal old_1MHz : std_logic := '0';
    signal old_1kHz : std_logic := '0';
    signal old_1Hz  : std_logic := '0';

    signal microseconds_i : unsigned(23 downto 0) := (others => '0');
    signal milliseconds_i : unsigned(23 downto 0) := (others => '0');
    signal seconds_i      : unsigned(19 downto 0) := (others => '0');

    -- Extra upper bits used to extend the original 20-bit seconds counter
    -- into a 32-bit seconds counter.
    signal seconds_high_i : unsigned(11 downto 0) := (others => '0');

    -- Microseconds inside the current second: 0 to 999999.
    signal usec_in_sec_i  : unsigned(19 downto 0) := (others => '0');

    signal timestamp_valid : std_logic := '0';
    signal timestamp_flags : std_logic_vector(3 downto 0) := (others => '0');
    signal seconds32       : std_logic_vector(31 downto 0) := (others => '0');

    constant USEC_IN_SEC_MAX : unsigned(19 downto 0) := to_unsigned(999999, 20);
    constant SECONDS_LOW_MAX : unsigned(19 downto 0) := (others => '1');

begin

    microseconds <= std_logic_vector(microseconds_i);
    milliseconds <= std_logic_vector(milliseconds_i);
    seconds      <= std_logic_vector(seconds_i);

    timestamp_flags <= timestamp_valid & "000";

    seconds32 <= std_logic_vector(seconds_high_i) & std_logic_vector(seconds_i);

    timestamp_packet <=
        seconds32 &
        std_logic_vector(usec_in_sec_i) &
        timestamp_flags;

    process(clk, reset)
    begin
        if reset /= '0' then
            old_1MHz <= '0';
            old_1kHz <= '0';
            old_1Hz  <= '0';

            microseconds_i <= (others => '0');
            milliseconds_i <= (others => '0');
            seconds_i      <= (others => '0');
            seconds_high_i <= (others => '0');
            usec_in_sec_i  <= (others => '0');

            timestamp_valid <= '0';

        elsif rising_edge(clk) then

            -- Once the design is out of reset and clocked, the relative timestamp
            -- is considered valid.
            timestamp_valid <= '1';

            old_1MHz <= clk_1MHz;
            old_1kHz <= clk_1kHz;
            old_1Hz  <= clk_1Hz;

            if old_1MHz = '0' and clk_1MHz = '1' then
                microseconds_i <= microseconds_i + 1;

                if usec_in_sec_i = USEC_IN_SEC_MAX then
                    usec_in_sec_i <= (others => '0');
                else
                    usec_in_sec_i <= usec_in_sec_i + 1;
                end if;
            end if;

            if old_1kHz = '0' and clk_1kHz = '1' then
                milliseconds_i <= milliseconds_i + 1;
            end if;

            if old_1Hz = '0' and clk_1Hz = '1' then
                if seconds_i = SECONDS_LOW_MAX then
                    seconds_i      <= (others => '0');
                    seconds_high_i <= seconds_high_i + 1;
                else
                    seconds_i <= seconds_i + 1;
                end if;
            end if;

        end if;
    end process;

end architecture_Timekeeper;