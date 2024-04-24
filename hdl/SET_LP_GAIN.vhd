-- SET_LP_GAIN.vhd


library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_unsigned.all; 
use IEEE.numeric_std.all;


entity SET_LP_GAIN is
	port(
		RESET       : in  std_logic;
        CLK         : in  std_logic;
        G1          : in  std_logic_vector(1 downto 0);
        G2          : in  std_logic_vector(1 downto 0);
        G3          : in  std_logic_vector(1 downto 0);
        G4          : in  std_logic_vector(1 downto 0);

        LA0         : out std_logic;
        LA1         : out std_logic;
        L1WR        : out std_logic;
        L2WR        : out std_logic;
        L3WR        : out std_logic;
        L4WR        : out std_logic
       );

end SET_LP_GAIN;

----------------------------------------------------------------
----------------------------------------------------------------

architecture behavioral of SET_LP_GAIN is
    type state_type is (
            check_G1,
            check_G2,
            check_G3,
            check_G4,
            update_G1,
            update_G2,
            update_G3,
            update_G4
    );

    signal state  : state_type;

    signal old_G1 : std_logic_vector(1 downto 0);
    signal old_G2 : std_logic_vector(1 downto 0);
    signal old_G3 : std_logic_vector(1 downto 0);
    signal old_G4 : std_logic_vector(1 downto 0);




---------------------------------------------------------------------

begin



--------------------------
-- state machine to set out 
--------------------------
	process (CLK, RESET)
	begin
		if RESET = '1' then -- assync. reset
           LA0 <='0';
           LA1 <='0';
           L1WR <= '0';
           L2WR <= '0';
           L3WR <= '0';
           L4WR <= '0';

           old_G1 <= "00";
           old_G2 <= "00";
           old_G3 <= "00";
           old_G4 <= "00";

           state <= check_G1;


		elsif falling_edge(CLK) then
            L1WR <= '1';    -- Default states
            L2WR <= '1';
            L3WR <= '1';
            L4WR <= '1';

			case state is 
				when check_G1 =>
                    old_G1 <= G1;

                    if G1 /= old_G1 then
                        LA0 <= G1(0);
                        LA1 <= G1(1);
                        state <= update_G1;
                    else
                        state <= check_G2;
                    end if;

				when check_G2 =>
                    old_G2 <= G2;

                    if G2 /= old_G2 then
                        LA0 <= G2(0);
                        LA1 <= G2(1);
                        state <= update_G2;
                    else
                        state <= check_G3;
                    end if;

				when check_G3 =>
                    old_G3 <= G3;

                    if G3 /= old_G3 then
                        LA0 <= G3(0);
                        LA1 <= G3(1);
                        state <= update_G3;
                    else
                        state <= check_G4;
                    end if;

				when check_G4 =>
                    old_G4 <= G4;

                    if G4 /= old_G4 then
                        LA0 <= G4(0);
                        LA1 <= G4(1);
                        state <= update_G4;
                    else
                        state <= check_G1;
                    end if;

				when update_G1 =>
                    L1WR <= '0';
                    state <= check_G2;

                when update_G2 =>
                    L2WR <= '0';
                    state <= check_G3;

                when update_G3 =>
                    L3WR <= '0';
                    state <= check_G4;

                when update_G4 =>
                    L4WR <= '0';
                    state <= check_G1;

                when others =>   -- any strange state
                    state <= check_G1;
            end case;
        end if;
    end process;


end behavioral;