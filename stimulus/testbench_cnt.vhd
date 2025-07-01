--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: testbench_cnt.vhd
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

entity testbench_cnt is
end testbench_cnt;

architecture behavioral of testbench_cnt is

    constant SYSCLK_PERIOD : time := 100 ns; -- 10MHZ

    signal SYSCLK : std_logic := '0';
    signal NSYSRESET : std_logic := '0';

    component test_sim
        -- ports
        port( 
            -- Inputs
            reset : in std_logic;
            clk : in std_logic;

            -- Outputs
            cnt : out std_logic_vector(1 downto 0)

            -- Inouts

        );
    end component;

begin

    process
        variable vhdl_initial : BOOLEAN := TRUE;

    begin
        if ( vhdl_initial ) then
            -- Assert Reset
            NSYSRESET <= '1';
            wait for ( SYSCLK_PERIOD * 10 );
            
            NSYSRESET <= '0';
            wait;
        end if;
    end process;

    -- Clock Driver
    SYSCLK <= not SYSCLK after (SYSCLK_PERIOD / 2.0 );

    -- Instantiate Unit Under Test:  test_sim
    test_sim_0 : test_sim
        -- port map
        port map( 
            -- Inputs
            reset => NSYSRESET,
            clk => SYSCLK,

            -- Outputs
            cnt => open

            -- Inouts

        );

end behavioral;

