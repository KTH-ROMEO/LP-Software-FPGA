----------------------------------------------------------------------
-- Created by SmartDesign Tue Jan 23 15:37:21 2024
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
-- tiime entity declaration
----------------------------------------------------------------------
entity tiime is
    -- Port list
    port(
        -- Inputs
        clk          : in  std_logic;
        clk_1Hz      : in  std_logic;
        clk_1MHz     : in  std_logic;
        clk_1kHz     : in  std_logic;
        reset        : in  std_logic;
        -- Outputs
        microseconds : out std_logic_vector(23 downto 0);
        milliseconds : out std_logic_vector(23 downto 0);
        seconds      : out std_logic_vector(19 downto 0)
        );
end tiime;
----------------------------------------------------------------------
-- tiime architecture body
----------------------------------------------------------------------
architecture RTL of tiime is
----------------------------------------------------------------------
-- Component declarations
----------------------------------------------------------------------
-- Timekeeper
component Timekeeper
    -- Port list
    port(
        -- Inputs
        clk          : in  std_logic;
        clk_1Hz      : in  std_logic;
        clk_1MHz     : in  std_logic;
        clk_1kHz     : in  std_logic;
        reset        : in  std_logic;
        -- Outputs
        microseconds : out std_logic_vector(23 downto 0);
        milliseconds : out std_logic_vector(23 downto 0);
        seconds      : out std_logic_vector(19 downto 0)
        );
end component;
----------------------------------------------------------------------
-- Signal declarations
----------------------------------------------------------------------
signal microseconds_net_0 : std_logic_vector(23 downto 0);
signal milliseconds_net_0 : std_logic_vector(23 downto 0);
signal seconds_net_0      : std_logic_vector(19 downto 0);
signal microseconds_net_1 : std_logic_vector(23 downto 0);
signal milliseconds_net_1 : std_logic_vector(23 downto 0);
signal seconds_net_1      : std_logic_vector(19 downto 0);

begin
----------------------------------------------------------------------
-- Top level output port assignments
----------------------------------------------------------------------
 microseconds_net_1        <= microseconds_net_0;
 microseconds(23 downto 0) <= microseconds_net_1;
 milliseconds_net_1        <= milliseconds_net_0;
 milliseconds(23 downto 0) <= milliseconds_net_1;
 seconds_net_1             <= seconds_net_0;
 seconds(19 downto 0)      <= seconds_net_1;
----------------------------------------------------------------------
-- Component instances
----------------------------------------------------------------------
-- Timekeeper_0
Timekeeper_0 : Timekeeper
    port map( 
        -- Inputs
        clk          => clk,
        clk_1MHz     => clk_1MHz,
        clk_1kHz     => clk_1kHz,
        clk_1Hz      => clk_1Hz,
        reset        => reset,
        -- Outputs
        microseconds => microseconds_net_0,
        milliseconds => milliseconds_net_0,
        seconds      => seconds_net_0 
        );

end RTL;
