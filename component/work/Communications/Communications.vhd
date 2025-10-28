----------------------------------------------------------------------
-- Created by SmartDesign Tue Oct 28 16:57:14 2025
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
-- Communications entity declaration
----------------------------------------------------------------------
entity Communications is
    -- Port list
    port(
        -- Inputs
        clk       : in  std_logic;
        reset     : in  std_logic;
        rx        : in  std_logic;
        uc_oen    : in  std_logic;
        uc_send   : in  std_logic_vector(7 downto 0);
        uc_wen    : in  std_logic;
        -- Outputs
        tx        : out std_logic;
        uc_recv   : out std_logic_vector(7 downto 0);
        uc_rx_rdy : out std_logic;
        uc_tx_rdy : out std_logic
        );
end Communications;
----------------------------------------------------------------------
-- Communications architecture body
----------------------------------------------------------------------
architecture RTL of Communications is
----------------------------------------------------------------------
-- Component declarations
----------------------------------------------------------------------
-- UART
component UART
    -- Port list
    port(
        -- Inputs
        clk          : in  std_logic;
        recv_oen     : in  std_logic;
        reset        : in  std_logic;
        rx           : in  std_logic;
        send         : in  std_logic_vector(7 downto 0);
        send_wen     : in  std_logic;
        -- Outputs
        recv         : out std_logic_vector(7 downto 0);
        rx_rdy       : out std_logic;
        test_port    : out std_logic;
        transmitting : out std_logic;
        tx           : out std_logic;
        tx_rdy       : out std_logic
        );
end component;
----------------------------------------------------------------------
-- Signal declarations
----------------------------------------------------------------------
signal tx_net_0        : std_logic;
signal uc_recv_net_0   : std_logic_vector(7 downto 0);
signal uc_rx_rdy_net_0 : std_logic;
signal uc_tx_rdy_net_0 : std_logic;
signal uc_tx_rdy_net_1 : std_logic;
signal uc_rx_rdy_net_1 : std_logic;
signal uc_recv_net_1   : std_logic_vector(7 downto 0);
signal tx_net_1        : std_logic;

begin
----------------------------------------------------------------------
-- Top level output port assignments
----------------------------------------------------------------------
 uc_tx_rdy_net_1     <= uc_tx_rdy_net_0;
 uc_tx_rdy           <= uc_tx_rdy_net_1;
 uc_rx_rdy_net_1     <= uc_rx_rdy_net_0;
 uc_rx_rdy           <= uc_rx_rdy_net_1;
 uc_recv_net_1       <= uc_recv_net_0;
 uc_recv(7 downto 0) <= uc_recv_net_1;
 tx_net_1            <= tx_net_0;
 tx                  <= tx_net_1;
----------------------------------------------------------------------
-- Component instances
----------------------------------------------------------------------
-- UART_1
UART_1 : UART
    port map( 
        -- Inputs
        clk          => clk,
        reset        => reset,
        rx           => rx,
        send_wen     => uc_wen,
        recv_oen     => uc_oen,
        send         => uc_send,
        -- Outputs
        tx           => tx_net_0,
        test_port    => OPEN,
        rx_rdy       => uc_rx_rdy_net_0,
        tx_rdy       => uc_tx_rdy_net_0,
        transmitting => OPEN,
        recv         => uc_recv_net_0 
        );

end RTL;
