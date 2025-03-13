--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: Sweep test.vhd
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

entity Sweep_test is
end Sweep_test;

architecture behavioral of Sweep_test is

    constant SYSCLK_PERIOD : time := 33 ns; -- 30.303MHZ

    signal SYSCLK : std_logic := '0';
    signal NSYSRESET : std_logic := '0';
    signal mysignal : std_logic := '0';

    component Toplevel
        -- ports
        port( 
            -- Inputs
            FMC_CLK : in std_logic;
            FMC_NOE : in std_logic;
            FMC_NE1 : in std_logic;
            UC_UART_TX : in std_logic;
            FFU_EJECTED : in std_logic;
            TOP_UART_RX : in std_logic;
            CLOCK : in std_logic;
            RESET : in std_logic;
            CU_SYNC : in std_logic;
            EMU_RX : in std_logic;
            AA : in std_logic;
            AB : in std_logic;
            ABSY : in std_logic;
            UC_CONSOLE_EN : in std_logic;
            UC_I2C4_SCL : in std_logic;

            -- Outputs
            FPGA_BUF_INT : out std_logic;
            PRESSURE_SCL : out std_logic;
            UC_UART_RX : out std_logic;
            TOP_UART_TX : out std_logic;
            GYRO_SCL : out std_logic;
            ACCE_SCL : out std_logic;
            LED1 : out std_logic;
            LED2 : out std_logic;
            UC_PWR_EN : out std_logic;
            UC_RESET : out std_logic;
            FRAM_SCL : out std_logic;
            SCIENCE_TX : out std_logic;
            ACS : out std_logic;
            ACLK : out std_logic;
            ACST : out std_logic;
            L1WR : out std_logic;
            L2WR : out std_logic;
            L3WR : out std_logic;
            L4WR : out std_logic;
            LDCS : out std_logic;
            LDSDI : out std_logic;
            LDCLK : out std_logic;
            LA0 : out std_logic;
            LA1 : out std_logic;
            ARST : out std_logic;
            FMC_DA : out std_logic_vector(7 downto 0);

            -- Inouts
            ACCE_SDA : inout std_logic;
            PRESSURE_SDA : inout std_logic;
            GYRO_SDA : inout std_logic;
            FRAM_SDA : inout std_logic;
            UC_I2C4_SDA : inout std_logic

        );
    end component;

begin

    process
        variable vhdl_initial : BOOLEAN := TRUE;

    begin
        if ( vhdl_initial ) then
            -- Assert Reset
            NSYSRESET <= '1';
            mysignal  <= '0';
            wait for ( SYSCLK_PERIOD * 10 );
            
            NSYSRESET <= '0';

            wait for ( SYSCLK_PERIOD * 20 );
            mysignal  <= '1';
  
            wait;
        end if;
    end process;

    -- Clock Driver
    SYSCLK <= not SYSCLK after (SYSCLK_PERIOD / 2.0 );

    -- Instantiate Unit Under Test:  Toplevel
    Toplevel_0 : Toplevel
        -- port map
        port map( 
            -- Inputs
            FMC_CLK => SYSCLK,
            FMC_NOE => '0',
            FMC_NE1 => '0',
            UC_UART_TX => '0',
            FFU_EJECTED => '0',
            TOP_UART_RX => '0',
            CLOCK => SYSCLK,
            RESET => NSYSRESET,
            CU_SYNC => '0',
            EMU_RX => '0',
            AA => mysignal,
            AB => '0',
            ABSY => '0',
            UC_CONSOLE_EN => '0',
            UC_I2C4_SCL => '0',

            -- Outputs
            FPGA_BUF_INT =>  open,
            PRESSURE_SCL =>  open,
            UC_UART_RX =>  open,
            TOP_UART_TX =>  open,
            GYRO_SCL =>  open,
            ACCE_SCL =>  open,
            LED1 =>  open,
            LED2 =>  open,
            UC_PWR_EN =>  open,
            UC_RESET =>  open,
            FRAM_SCL =>  open,
            SCIENCE_TX =>  open,
            ACS =>  open,
            ACLK =>  open,
            ACST =>  open,
            L1WR =>  open,
            L2WR =>  open,
            L3WR =>  open,
            L4WR =>  open,
            LDCS =>  open,
            LDSDI =>  open,
            LDCLK =>  open,
            LA0 =>  open,
            LA1 =>  open,
            ARST =>  open,
            FMC_DA => open,

            -- Inouts
            ACCE_SDA =>  open,
            PRESSURE_SDA =>  open,
            GYRO_SDA =>  open,
            FRAM_SDA =>  open,
            UC_I2C4_SDA =>  open

        );

end behavioral;

