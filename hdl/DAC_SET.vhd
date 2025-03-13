-- DAC_SET.vhd


library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_unsigned.all; 
use IEEE.numeric_std.all;


entity DAC_SET is
	port(
		RESET       : in  std_logic;
        CLK         : in  std_logic;
        DACA        : in  std_logic_vector(15 downto 0);
        DACB        : in  std_logic_vector(15 downto 0);
        --DACC        : in  std_logic_vector(15 downto 0);
        --DACD        : in  std_logic_vector(15 downto 0);
--        ADR         : in  std_logic_vector(1 downto 0);
        SET         : in  std_logic;
        LDCS        : out std_logic;
        LDSDI       : out std_logic;
        LDCLK       : out std_logic;
        state_out   : out std_logic_vector(3 downto 0)
       );

end DAC_SET;

----------------------------------------------------------------
----------------------------------------------------------------

architecture behavioral of DAC_SET is

    signal vector             : std_logic_vector(17 downto 0);
    signal state              : std_logic_vector(4 downto 0);
    signal cnt                : std_logic_vector(4 downto 0);
    signal old_set            : std_logic;
    signal CS, DCLK, sdi_int    : std_logic;
    signal ADR                  : std_logic_vector(1 downto 0);
    signal DAC                  : std_logic_vector(15 downto 0);

---------------------------------------------------------------------

begin
    LDCS <= CS;
    LDCLK <= DCLK;
    state_out <= sdi_int & DAC(2 downto 0);
    LDSDI <= sdi_int;

    DAC <=  DACA when ADR = "00" else
            DACB when ADR = "01";
--------------------------
-- state machine to set out 
--------------------------
	process (CLK, RESET)
	begin
		if RESET = '1' then -- assync. reset
		   vector <= (others => '0');
           cnt <= (others => '0');
           old_set <= '0';
           CS <= '1';
           DCLK <= '0';
           sdi_int <= '0';
           state <= "00001";
           ADR <= "00";

		elsif rising_edge(CLK) then
			case state is 
				when "00001" =>  -- idle state
                    old_set <= SET;
                    DCLK <= '0';
                    CS <= '1';
                    sdi_int <='0';
                    ADR <= "00";
                    if (SET = '1') and (old_set = '0') then 
                        state <= "00010";
                    else
                        state <= "00001";
                    end if;
                    

				when "00010" =>  -- increment the address here.
                    DCLK <= '0';
                    CS <= '1';
                    if cnt = "11111" then 
                        cnt <= (others => '0');
                        vector <= ADR & DAC;
                        ADR <= ADR + 1;
                        state <= "00100";
                    else
                        cnt <= cnt + 1;
                        state <= "00010";
                    end if;

                when "00100" =>  -- set CS low
                    CS <= '0';
                    DCLK <= '0';
                    sdi_int <= vector(17);             
                    state <= "01000";

				when "01000" =>  -- set clock high
                    DCLK <= '1';
                    CS <= '0';
                    cnt <= cnt + 1;
                    vector(17 downto 0) <= vector (16 downto 0) & '0';
                    state <= "10000";

                when "10000" => -- set clock low
                    DCLK <= '0';
                    CS <= '0';
                    sdi_int <= vector(17);
                    if cnt = "10010" then
                        if ADR = "10" then 
                            state <= "00001";       -- this is to return to the idle state when all four DACs have been sent.
                        else
                            state <= "00010";       -- this is to set the next DAC value.
                        end if;
                    else
                       state <= "00100"; 
                    end if;
                when others =>   -- any strange state
                    state <= "00001";
            end case;
        end if;
    end process;


end behavioral;