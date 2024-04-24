--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: Pressure_Signal_Debounce.vhd
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

entity Pressure_Signal_Debounce is
port (
    clk_1kHz : IN std_logic;
    reset : IN std_logic;

    pressure : IN std_logic_vector(23 downto 0);
    
    low_pressure : OUT std_logic
);
end Pressure_Signal_Debounce;

architecture architecture_Pressure_Signal_Debounce of Pressure_Signal_Debounce is
    type state_type is (state_high, state_low_debounce, state_low, state_high_debounce);

    signal state : state_type;

    signal ms_cnt : integer range 1 to 1000;

    constant threshold : integer := 5750000;
begin

process (clk_1kHz, reset)
begin
    if reset /= '0' then
        state <= state_high;
        low_pressure <= '0';

    elsif rising_edge(clk_1kHz) then

        case state is
            when state_high =>
                low_pressure <= '0';

                if pressure < threshold AND pressure /= 0 then
                    state <= state_low_debounce;
                    ms_cnt <= 1;
                end if;

            when state_low_debounce =>
                low_pressure <= '0';

                if pressure > threshold then
                    state <= state_high;
                end if;

                if ms_cnt = 1000 then
                    state <= state_low;
                else
                    ms_cnt <= ms_cnt + 1;
                end if;

            when state_low =>
                low_pressure <= '1';

                if pressure > threshold then
                    state <= state_high_debounce;
                    ms_cnt <= 1;
                end if;

            when state_high_debounce =>
                low_pressure <= '1';

                if pressure < threshold then
                    state <= state_low;
                end if;

                if ms_cnt = 1000 then
                    state <= state_high;
                else
                    ms_cnt <= ms_cnt + 1;
                end if;
        end case;
    end if;

end process;
end architecture_Pressure_Signal_Debounce;
