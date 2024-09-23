----------------------------------------------------------------------
-- Created by Microsemi SmartDesign Wed Sep 18 11:11:30 2024
-- Testbench Template
-- This is a basic testbench that instantiates your design with basic 
-- clock and reset pins connected.  If your design has special
-- clock/reset or testbench driver requirements then you should 
-- copy this file and modify it. 
----------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: GBFDG_TestBench.vhd
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

entity GBFDG_TestBench is
end GBFDG_TestBench;

architecture behavioral of GBFDG_TestBench is

    constant SYSCLK_PERIOD : time := 31250 ns; -- 0.032MHZ

    signal SYSCLK : std_logic := '0';
    signal NSYSRESET : std_logic := '0';

    signal samples_per_measurement : std_logic_vector(15 downto 0);
    signal measurement_rdy : std_logic;
    signal fake_measurement: std_logic_vector(15 downto 0);

    signal res : std_logic_vector(15 downto 0);

    component Constant_Bias_Fake_Data_Generator
        -- ports
        port( 
            -- Inputs
            clk_32k : in std_logic;
            samples_per_measurement : in std_logic_vector(15 downto 0);
            reset : in std_logic;

            -- Outputs
            measurement_rdy : out std_logic;
            fake_measurement : out std_logic_vector(15 downto 0)

            -- Inouts

        );
    end component;

begin
    samples_per_measurement <= x"7D00"; -- 16
    process
        variable vhdl_initial : BOOLEAN := TRUE;

    begin
        if ( vhdl_initial ) then
            -- Assert Reset
            NSYSRESET <= '1';
            wait for ( SYSCLK_PERIOD * 2 );
            NSYSRESET <= '0';
            vhdl_initial := FALSE;
        else

            for i in 1 to 10 loop
                wait for (SYSCLK_PERIOD * 1);
                res <= fake_measurement;
            end loop;

        end if;

        
    end process;

    -- Clock Driver
    SYSCLK <= not SYSCLK after (SYSCLK_PERIOD / 1.0 );

    -- Instantiate Unit Under Test:  Constant_Bias_Fake_Data_Generator
    Constant_Bias_Fake_Data_Generator_0 : Constant_Bias_Fake_Data_Generator
        -- port map
        port map( 
            -- Inputs
            clk_32k => SYSCLK,
            samples_per_measurement => samples_per_measurement,
            reset => NSYSRESET,

            -- Outputs
            measurement_rdy =>  measurement_rdy,
            fake_measurement => fake_measurement

            -- Inouts

        );

end behavioral;

