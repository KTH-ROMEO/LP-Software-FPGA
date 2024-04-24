-- ADC_RESET.vhd


library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_unsigned.all; 
use IEEE.numeric_std.all;


entity ADC_RESET is
	port(
		RESET       : in  std_logic;
        CLK         : in  std_logic;
        PWRANEN     : in  std_logic;
        ADCRESET    : out std_logic
       );

end ADC_RESET;

----------------------------------------------------------------
----------------------------------------------------------------

architecture behavioral of ADC_RESET is

    signal state              : std_logic_vector(3 downto 0);
    signal old_enable          : std_logic;

---------------------------------------------------------------------

begin

--------------------------
-- state machine to set out 
--------------------------
	process (CLK, RESET)
	begin
		if RESET = '1' then -- assync. reset
		   ADCRESET <= '0';
           old_enable <= '0';

		elsif rising_edge(CLK) then
    		case state is 
				when "0001" =>  -- idle state
                    ADCRESET <= '0';
                    old_enable <= PWRANEN;
                    if (PWRANEN = '1' AND old_enable='0') then 
                        state <= "0010";
                    else 
                        state <= "0001";
                    end if;
                when "0010" =>  -- wait a bit until resetting the power...
                    ADCRESET <= '0';
                    state <= "0100";

				when "0100" =>  -- set reset high for a while 
                    ADCRESET <= '1';
                    state <= "0001";

                when others =>   -- any strange state
                    state <= "0001";
            end case;
        end if;
    end process;


end behavioral;