--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: Eject_Signal_Debounce.vhd
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
--use IEEE.std_logic_unsigned.all;

entity Eject_Signal_Debounce is
port (
    clk : IN std_logic;
    clk_1kHz : IN std_logic;
    reset : IN std_logic;

	ffu_ejected_in : IN  std_logic;

    ffu_ejected_out : OUT std_logic
);

end Eject_Signal_Debounce;

architecture architecture_Eject_Signal_Debounce of Eject_Signal_Debounce is

    type state_type is (ejected, debounce_ejected, not_ejected, debounce_not_ejected);
    
    signal state : state_type;

    signal ms_cnt : integer range 1 to 50;
    signal old_1kHz : std_logic;
begin


process(clk, reset)
begin

    if reset /= '0' then
        ffu_ejected_out <= '0';
        state <= not_ejected;
        old_1kHz <= '0';

    elsif rising_edge(clk) then
        old_1kHz <= clk_1kHz;

        if old_1kHz = '0' AND clk_1kHz = '1' then
            case state is
                when not_ejected =>
                    ffu_ejected_out <= '0';
                    
                    if ffu_ejected_in = '1' then
                        state <= debounce_ejected;
                        ms_cnt <= 1;
                    end if;

                when debounce_ejected =>
                    ffu_ejected_out <= '0';

                    if ffu_ejected_in = '0' then
                        state <= not_ejected;
                    end if;

                    if ms_cnt = 50 then
                        state <= ejected;
                    else
                       ms_cnt <= ms_cnt + 1;
                    end if;

                when ejected =>
                    ffu_ejected_out <= '1';

                    if ffu_ejected_in = '0' then
                        state <= debounce_not_ejected;
                        ms_cnt <= 1;
                    end if;

                when debounce_not_ejected =>
                    ffu_ejected_out <= '1';

                    if ffu_ejected_in = '1' then
                        state <= ejected;
                    end if;

                    if ms_cnt = 50 then
                        state <= not_ejected;
                    else
                       ms_cnt <= ms_cnt + 1;
                    end if;

            end case;
        end if;

    end if;

end process;
end architecture_Eject_Signal_Debounce;
