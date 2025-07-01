library IEEE;
use IEEE.std_logic_1164.all;

entity uart_rx_fsm_tb is
end uart_rx_fsm_tb;

architecture behavior of uart_rx_fsm_tb is

  -- Signals to drive DUT
  signal clk    : std_logic := '0';
  signal reset  : std_logic := '0';
  signal data_in  : std_logic := '0';
  signal data_out : std_logic;

  constant clk_period : time := 10 ns;

begin

  -- Instantiate DUT directly by entity
  uut: entity work.uart_rx_fsm
  port map (
    clk => clk,
    reset => reset,
    data_in => data_in,
    data_out => data_out
  );

  -- Clock generation
  clk_process : process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;

  -- Stimulus process
  stim_proc: process
  begin
    reset <= '1';
    wait for 20 ns;
    reset <= '0';
    wait for 20 ns;

    data_in <= '1';
    wait for 20 ns;
    data_in <= '0';
    wait for 20 ns;
    data_in <= '1';
    wait for 40 ns;

    wait;
  end process;

end behavior;