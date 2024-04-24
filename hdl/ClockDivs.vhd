--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: ClockDivs.vhd
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

entity ClockDivs is
port (
    clk_32MHz, reset : IN std_logic;
    
    clk_16MHz: OUT std_logic;
    clk_8MHz: OUT std_logic;
    clk_4MHz: OUT std_logic;
    clk_2MHz: OUT std_logic;
    clk_1MHz : OUT std_logic;
    clk_800kHz : OUT std_logic;
    clk_4kHz : OUT std_logic;
    clk_1kHz : OUT std_logic;
    clk_50Hz : OUT std_logic;
    clk_1Hz : OUT std_logic
    
);
end ClockDivs;
architecture architecture_ClockDivs of ClockDivs is
    signal div_by2 : std_logic_vector(4 downto 0);
    signal cnt_800kHz : std_logic_vector(4 downto 0);
    signal cnt_4kHz : std_logic_vector(6 downto 0);
    signal cnt_1kHz : std_logic_vector(8 downto 0);
    signal cnt_50Hz : std_logic_vector(5 downto 0);
    signal cnt_1Hz : std_logic_vector(4 downto 0);
begin
    clk_16MHz <= div_by2(0);
    clk_8MHz <= div_by2(1);
    clk_4MHz <= div_by2(2);
    clk_2MHz <= div_by2(3);
    clk_1MHz <= div_by2(4);

    process(clk_32MHz, reset)
    begin
        if reset /= '0' then
            cnt_800kHz <= (others => '0');
            clk_800kHz <= '0';
            div_by2 <= (others => '0');

        elsif rising_edge(clk_32MHz) then
            div_by2 <= div_by2 + 1;

            if cnt_800kHz = 19 then             -- Formula: clk_out = clk_in / ((cnt + 1)*2)
                clk_800kHz <= not clk_800kHz;
                cnt_800kHz <= (others => '0');
            else
                cnt_800kHz <= cnt_800kHz + 1;
            end if;
        end if;
    end process;

    process(clk_800kHz, reset)
    begin
        if reset /= '0' then
            cnt_1kHz <= (others => '0');
            cnt_4kHz <= (others => '0');
            clk_4kHz <= '0';
            clk_1kHz <= '0';
        elsif rising_edge(clk_800kHz) then
            if cnt_1kHz = 399 then             -- Formula: clk_out = clk_in / ((cnt + 1)*2)
                clk_1kHz <= not clk_1kHz;
                cnt_1kHz <= (others => '0');
            else
                cnt_1kHz <= cnt_1kHz + 1;
            end if;

            if cnt_4kHz = 99 then             -- Formula: clk_out = clk_in / ((cnt + 1)*2)
                clk_4kHz <= not clk_4kHz;
                cnt_4kHz <= (others => '0');
            else
                cnt_4kHz <= cnt_4kHz + 1;
            end if;
        end if;
    end process;

    process(clk_1kHz, reset)
    begin
        if reset /= '0' then
            cnt_50Hz <= (others => '0');
            clk_50Hz <= '0';
        elsif rising_edge(clk_1kHz) then
            if cnt_50Hz = 9 then             -- Formula: clk_out = clk_in / ((cnt + 1)*2)
                clk_50Hz <= not clk_50Hz;
                cnt_50Hz <= (others => '0');
            else
                cnt_50Hz <= cnt_50Hz + 1;
            end if;
        end if;
    end process;

    process(clk_50Hz, reset)
    begin
        if reset /= '0' then
        
        elsif rising_edge(clk_50Hz) then
            if cnt_1Hz = 24 then
                clk_1Hz <= not clk_1Hz;
                cnt_1Hz <= (others => '0');
            else
                cnt_1Hz <= cnt_1Hz + 1;
            end if;
        end if;
    end process;
end architecture_ClockDivs;
