----------------------------------------------------------------------
-- Created by SmartDesign Mon Jun 23 18:45:00 2025
-- Version: v11.9 SP6 11.9.6.7
----------------------------------------------------------------------

----------------------------------------------------------------------
-- Libraries
----------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library proasic3;
use proasic3.all;
----------------------------------------------------------------------
-- UART_RX_FSM_tb entity declaration
----------------------------------------------------------------------
entity UART_RX_FSM_tb is
    -- Port list
    port(
        -- Inputs
        clk       : in std_logic;
        reset     : in std_logic;
        uc_recv   : in std_logic_vector(7 downto 0);
        uc_rx_rdy : in std_logic
        );
end UART_RX_FSM_tb;
----------------------------------------------------------------------
-- UART_RX_FSM_tb architecture body
----------------------------------------------------------------------
architecture RTL of UART_RX_FSM_tb is
----------------------------------------------------------------------
-- Component declarations
----------------------------------------------------------------------
-- UART_RX_FSM
component UART_RX_FSM
    -- Port list
    port(
        -- Inputs
        clk       : in std_logic;
        reset     : in std_logic;
        uc_recv   : in std_logic_vector(7 downto 0);
        uc_rx_rdy : in std_logic
        );
end component;

begin
----------------------------------------------------------------------
-- Component instances
----------------------------------------------------------------------
-- UART_RX_FSM_0
UART_RX_FSM_0 : UART_RX_FSM
    port map( 
        -- Inputs
        clk       => clk,
        reset     => reset,
        uc_rx_rdy => uc_rx_rdy,
        uc_recv   => uc_recv 
        );

end RTL;
