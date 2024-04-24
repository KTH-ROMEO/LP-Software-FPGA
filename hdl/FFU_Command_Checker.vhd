--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: FFU_Command_Checker.vhd
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

entity FFU_Command_Checker is
port (
    clk : IN std_logic;         -- Drive with system clock.
    reset : IN std_logic;

    byte_in : IN std_logic_vector(7 downto 0);
    rmu_rxrdy : IN std_logic;

    command_oen : IN std_logic;

    identifier : IN std_logic_vector(7 downto 0);

    rmu_oen : OUT std_logic;
    command_out : OUT std_logic_vector(7 downto 0);
    command_rdy : OUT std_logic

);
end FFU_Command_Checker;
architecture architecture_FFU_Command_Checker of FFU_Command_Checker is
	signal state : integer range 1 to 4;
    signal command : std_logic_vector(7 downto 0);

begin

process (clk, reset)
begin
    if reset /= '0' then
        rmu_oen <= '0';
        command_out <= (others => '0');
        command_rdy <= '0';
        command <= (others => '0');
        state <= 1;

    elsif rising_edge(clk) then
        rmu_oen <= '0';

        case state is
            when 1 =>               -- First state: receive identifier from Ground Station.
                if rmu_rxrdy = '1' then
                    rmu_oen <= '1';

                    -- The x"20" is convenient when debugging but VERY DANGEROUS for flight if there are multiple
                    -- units on the same UART line.
                    if byte_in = identifier then --OR byte_in = x"20" then
                        state <= 2;
                    end if;
                end if;

            when 2 =>
                if rmu_rxrdy = '0' then      -- Proceed to next state when byte has been read.
                    state <= 3;
                end if;

            when 3 =>
                if rmu_rxrdy = '1' then          -- Next byte is the command.
                    rmu_oen <= '1';
                    command_out <= byte_in;
                    command_rdy <= '1';
                    state <= 4;
                end if;

            when 4 =>
                if command_oen = '1' then         -- Command has been read.
                    command_rdy <= '0';
                    state <= 1;
                end if;
                

        end case;
    end if;

end process;
end architecture_FFU_Command_Checker;
