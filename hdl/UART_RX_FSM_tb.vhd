----------------------------------------------------------------------
-- Created by Microsemi SmartDesign Mon Jun 23 18:47:15 2025
-- Testbench Template
-- This is a basic testbench that instantiates your design with basic 
-- clock and reset pins connected.  If your design has special
-- clock/reset or testbench driver requirements then you should 
-- copy this file and modify it. 
----------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: UART_RX_FSM_tb.vhd
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


library ieee;
use ieee.std_logic_1164.all;

entity UART_RX_FSM_tb is
end UART_RX_FSM_tb;

architecture behavioral of UART_RX_FSM_tb is

    constant SYSCLK_PERIOD : time := 100 ns; -- 10MHZ

    signal SYSCLK : std_logic := '0';
    signal NSYSRESET : std_logic := '0';

    component UART_RX_FSM
        -- ports
        port( 
            -- Inputs
            clk : in std_logic;
            reset : in std_logic;
            uc_rx_rdy : in std_logic;
            uc_recv : in std_logic_vector(7 downto 0)

            -- Outputs

            -- Inouts

        );
    end component;

begin

    process
        variable vhdl_initial : BOOLEAN := TRUE;

    begin
        if ( vhdl_initial ) then
            -- Assert Reset
            NSYSRESET <= '0';
            wait for ( SYSCLK_PERIOD * 10 );
            
            NSYSRESET <= '1';
            wait;
        end if;
    end process;

    -- Clock Driver
    SYSCLK <= not SYSCLK after (SYSCLK_PERIOD / 2.0 );

    -- Instantiate Unit Under Test:  UART_RX_FSM
    UART_RX_FSM_0 : UART_RX_FSM
        -- port map
        port map( 
            -- Inputs
            clk => SYSCLK,
            reset => NSYSRESET,
            uc_rx_rdy => '0',
            uc_recv => (others=> '0')

            -- Outputs

            -- Inouts

        );

end behavioral;

