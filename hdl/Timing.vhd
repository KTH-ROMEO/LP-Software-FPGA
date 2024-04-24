--------------------------------------------------------------------------------
-- Company:         KTH - Royal Institute of Technology
--
-- File:            Timing.vhd
-- File history:    <Revision number>: <Date>: <Comments>
--
-- Description:     Generates timing for the system.
--                  clk input should be connected to an external 32.000 MHz oscillator.
--
-- Targeted device: <Family::ProASIC3> <Die::A3P250> <Package::100 VQFP>
-- Author:          Christos Tolis
--
--------------------------------------------------------------------------------
--
-- Outputs: s_clks[24]: 1   Hz
--          s_clks[23]: 2   Hz
--          s_clks[22]: 4   Hz
--          s_clks[21]: 8   Hz
--          s_clks[20]: 16  Hz
--          s_clks[19]: 32  Hz
--          s_clks[18]: 64  Hz
--          s_clks[17]: 128 Hz
--          s_clks[16]: 256 Hz
--          s_clks[15]: 512 Hz
--          s_clks[14]: 1   kHz
--          s_clks[13]: 2   kHz
--          s_clks[12]: 4   kHz
--          s_clks[11]: 8   kHz
--          s_clks[10]: 16  kHz
--          s_clks[9]:  32  kHz
--          s_clks[8]:  64  kHz
--          s_clks[7]:  128 kHz
--          s_clks[6]:  250 kHz
--          s_clks[5]:  500 kHz
--          s_clks[4]:  1   MHz
--          s_clks[3]:  2   MHz
--          s_clks[2]:  4   MHz
--          s_clks[1]:  8   MHz
--          s_clks[0]:  16  MHz

library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity Timing is
port (
	clk : IN  std_logic;
    reset : IN std_logic;
    
    s_clks : OUT std_logic_vector(24 downto 0)    -- Slow clocks
);
end Timing;


architecture architecture_Timing of Timing is
	signal f_time : std_logic_vector(6 downto 0) := (others => '0');
    signal m_count : std_logic_vector(7 downto 0) := (others => '0');
	signal m_time : std_logic_vector(7 downto 0) := (others => '0');
    signal s_count : std_logic_vector(7 downto 0) := (others => '0');
    signal s_time : std_logic_vector(9 downto 0) := (others => '0');

begin

process(clk, reset)
begin
    if reset /= '0' then
        f_time <= (others => '0');
        m_time <= (others => '0');
        s_time <= (others => '0');
        m_count <= (others => '0');
        s_count <= (others => '0');

    elsif rising_edge(clk) then
        f_time <= f_time + 1;
        m_count <= m_count + 1;

        if m_count = 124 then
            m_time <= m_time + 1;
            s_count <= s_count + 1;
            m_count <= (others => '0');
        end if;
   
        if s_count = 250 then
            s_time <= s_time + 1;
            s_count <= (others => '0');
        end if;
    end if;
end process;

s_clks <= s_time & m_time & f_time;

end architecture_Timing;
