library IEEE;
use IEEE.std_logic_1164.all;

entity uart_rx_fsm is
  port (
    clk   : IN std_logic;
    reset : IN std_logic;
    data_in  : IN std_logic;
    data_out : OUT std_logic
  );
end uart_rx_fsm;

architecture Behavioral of uart_rx_fsm is
begin
  process(clk, reset)
  begin
    if reset = '1' then
      data_out <= '0';
    elsif rising_edge(clk) then
      data_out <= data_in;
    end if;
  end process;
end Behavioral;