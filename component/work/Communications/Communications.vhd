----------------------------------------------------------------------
-- Created by SmartDesign Wed Oct 23 21:08:56 2019
-- Version: v11.9 SP3 11.9.3.5
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
        clk           : in  std_logic;
        ext_oen       : in  std_logic;
        ext_send      : in  std_logic_vector(7 downto 0);
        ext_tx        : in  std_logic;
        ext_wen       : in  std_logic;
        reset         : in  std_logic;
        uc_console_en : in  std_logic;
        uc_oen        : in  std_logic;
        uc_send       : in  std_logic_vector(7 downto 0);
        uc_tx         : in  std_logic;
        uc_wen        : in  std_logic;
        unit_id       : in  std_logic_vector(7 downto 0);
        -- Outputs
        ext_recv      : out std_logic_vector(7 downto 0);
        ext_rx        : out std_logic;
        ext_rx_rdy    : out std_logic;
        ext_tx_rdy    : out std_logic;
        uc_recv       : out std_logic_vector(7 downto 0);
        uc_rx         : out std_logic;
        uc_rx_rdy     : out std_logic;
        uc_tx_rdy     : out std_logic
        );
end Communications;
----------------------------------------------------------------------
-- Communications architecture body
----------------------------------------------------------------------
architecture RTL of Communications is
----------------------------------------------------------------------
-- Component declarations
----------------------------------------------------------------------
-- FFU_Command_Checker
component FFU_Command_Checker
    -- Port list
    port(
        -- Inputs
        byte_in     : in  std_logic_vector(7 downto 0);
        clk         : in  std_logic;
        command_oen : in  std_logic;
        identifier  : in  std_logic_vector(7 downto 0);
        reset       : in  std_logic;
        rmu_rxrdy   : in  std_logic;
        -- Outputs
        command_out : out std_logic_vector(7 downto 0);
        command_rdy : out std_logic;
        rmu_oen     : out std_logic
        );
end component;
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
-- UART_Ext2uC_Switch
component UART_Ext2uC_Switch
    -- Port list
    port(
        -- Inputs
        en       : in  std_logic;
        ext_tx   : in  std_logic;
        fpga2ext : in  std_logic;
        fpga2uc  : in  std_logic;
        uc_tx    : in  std_logic;
        -- Outputs
        ext2fpga : out std_logic;
        ext_rx   : out std_logic;
        uc2fpga  : out std_logic;
        uc_rx    : out std_logic
        );
end component;
----------------------------------------------------------------------
-- Signal declarations
----------------------------------------------------------------------
signal ext_recv_net_0                : std_logic_vector(7 downto 0);
signal ext_rx_net_0                  : std_logic;
signal ext_rx_rdy_net_0              : std_logic;
signal ext_tx_rdy_net_0              : std_logic;
signal FFU_Command_Checker_0_rmu_oen : std_logic;
signal UART_0_recv                   : std_logic_vector(7 downto 0);
signal UART_0_rx_rdy                 : std_logic;
signal UART_0_tx                     : std_logic;
signal UART_1_tx                     : std_logic;
signal UART_Ext2uC_Switch_0_ext2fpga : std_logic;
signal UART_Ext2uC_Switch_0_uc2fpga  : std_logic;
signal uc_recv_net_0                 : std_logic_vector(7 downto 0);
signal uc_rx_net_0                   : std_logic;
signal uc_rx_rdy_net_0               : std_logic;
signal uc_tx_rdy_net_0               : std_logic;
signal uc_rx_net_1                   : std_logic;
signal ext_rx_net_1                  : std_logic;
signal uc_recv_net_1                 : std_logic_vector(7 downto 0);
signal uc_tx_rdy_net_1               : std_logic;
signal uc_rx_rdy_net_1               : std_logic;
signal ext_rx_rdy_net_1              : std_logic;
signal ext_recv_net_1                : std_logic_vector(7 downto 0);
signal ext_tx_rdy_net_1              : std_logic;

begin
----------------------------------------------------------------------
-- Top level output port assignments
----------------------------------------------------------------------
 uc_rx_net_1          <= uc_rx_net_0;
 uc_rx                <= uc_rx_net_1;
 ext_rx_net_1         <= ext_rx_net_0;
 ext_rx               <= ext_rx_net_1;
 uc_recv_net_1        <= uc_recv_net_0;
 uc_recv(7 downto 0)  <= uc_recv_net_1;
 uc_tx_rdy_net_1      <= uc_tx_rdy_net_0;
 uc_tx_rdy            <= uc_tx_rdy_net_1;
 uc_rx_rdy_net_1      <= uc_rx_rdy_net_0;
 uc_rx_rdy            <= uc_rx_rdy_net_1;
 ext_rx_rdy_net_1     <= ext_rx_rdy_net_0;
 ext_rx_rdy           <= ext_rx_rdy_net_1;
 ext_recv_net_1       <= ext_recv_net_0;
 ext_recv(7 downto 0) <= ext_recv_net_1;
 ext_tx_rdy_net_1     <= ext_tx_rdy_net_0;
 ext_tx_rdy           <= ext_tx_rdy_net_1;
----------------------------------------------------------------------
-- Component instances
----------------------------------------------------------------------
-- FFU_Command_Checker_0
FFU_Command_Checker_0 : FFU_Command_Checker
    port map( 
        -- Inputs
        clk         => clk,
        reset       => reset,
        byte_in     => UART_0_recv,
        rmu_rxrdy   => UART_0_rx_rdy,
        command_oen => ext_oen,
        identifier  => unit_id,
        -- Outputs
        rmu_oen     => FFU_Command_Checker_0_rmu_oen,
        command_out => ext_recv_net_0,
        command_rdy => ext_rx_rdy_net_0 
        );
-- UART_0
UART_0 : UART
    port map( 
        -- Inputs
        clk          => clk,
        reset        => reset,
        rx           => UART_Ext2uC_Switch_0_ext2fpga,
        send         => ext_send,
        send_wen     => ext_wen,
        recv_oen     => FFU_Command_Checker_0_rmu_oen,
        -- Outputs
        tx           => UART_0_tx,
        recv         => UART_0_recv,
        test_port    => OPEN,
        rx_rdy       => UART_0_rx_rdy,
        tx_rdy       => ext_tx_rdy_net_0,
        transmitting => OPEN 
        );
-- UART_1
UART_1 : UART
    port map( 
        -- Inputs
        clk          => clk,
        reset        => reset,
        rx           => UART_Ext2uC_Switch_0_uc2fpga,
        send         => uc_send,
        send_wen     => uc_wen,
        recv_oen     => uc_oen,
        -- Outputs
        tx           => UART_1_tx,
        recv         => uc_recv_net_0,
        test_port    => OPEN,
        rx_rdy       => uc_rx_rdy_net_0,
        tx_rdy       => uc_tx_rdy_net_0,
        transmitting => OPEN 
        );
-- UART_Ext2uC_Switch_0
UART_Ext2uC_Switch_0 : UART_Ext2uC_Switch
    port map( 
        -- Inputs
        en       => uc_console_en,
        fpga2ext => UART_0_tx,
        fpga2uc  => UART_1_tx,
        ext_tx   => ext_tx,
        uc_tx    => uc_tx,
        -- Outputs
        ext2fpga => UART_Ext2uC_Switch_0_ext2fpga,
        uc2fpga  => UART_Ext2uC_Switch_0_uc2fpga,
        ext_rx   => ext_rx_net_0,
        uc_rx    => uc_rx_net_0 
        );

end RTL;
