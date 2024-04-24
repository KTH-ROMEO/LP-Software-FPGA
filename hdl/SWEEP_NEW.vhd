--------------------------------------------------------------------------------

-- SWEEP.vhd

--
--  this module defines the sweep of the Langmuir probe.
--
--  

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use IEEE.numeric_std.all;


entity SWEEP_NEW is
	port(
		RESET       : in  std_logic;
        CLK         : in  std_logic;                    
        CLK_SLOW    : in std_logic;                     -- here the clock should probably be M_time(17)       
        ACTIVATE    : in  std_logic;
        zero_value  : IN std_logic;
        max_value   : IN std_logic;
        RAMP        : in  std_logic_vector(3 downto 0); -- this is a slow ramp of the DAC, one bit commands one DAC
        DAC1        : out  std_logic_vector(15 downto 0);
        DAC2        : out  std_logic_vector(15 downto 0);
        DAC3        : out  std_logic_vector(15 downto 0);
        DAC4        : out  std_logic_vector(15 downto 0);

        SET         : out std_logic
        
       );

end SWEEP_NEW;

----------------------------------------------------------------
----------------------------------------------------------------

architecture behavioral of SWEEP_NEW is

    signal dac1_int, dac2_int, dac3_int, dac4_int   : std_logic_vector(15 downto 0);
    signal latch, update                            : std_logic;
    signal flag2, flag3, flag4                      : std_logic;

    signal cnt                                      : std_logic_vector(1 downto 0);
    signal counter                                  : std_logic_vector(15 downto 0);

---------------------------------------------------------------------

begin
    DAC1 <= dac1_int;
    DAC2 <= dac2_int;
    DAC3 <= dac3_int;
    DAC4 <= dac4_int;
    SET <= update;

--------------------------
-- state machine to set out DAC1
--------------------------
	process (CLK, RESET)
	begin
		if RESET = '1' then -- assync. reset
		   --dac1_int <= x"9B27";         -- this will be 0V 
            dac1_int <= x"0000";
           latch <= '0';
           update <= '0';
           cnt <= "00";
           counter <= x"62AA";   -- -1.875 V
            
		elsif rising_edge(CLK) then
            latch <= CLK_SLOW;
            if (CLK_SLOW = '1') and (latch = '0') then 
                update <= '1';
            else
                update <= '0';
            end if;

            if update = '1' then            
                if (ACTIVATE = '1') then
                    if counter >= x"D39B" then    -- +1.875 V
                        counter <= x"62AA";   -- -1.875 V
                        cnt <= cnt + 1;
                    else
                        --counter <= counter + 1;
                        counter <= counter + 2048;  -- Increase voltage by 301 (approx 0.010376 V)
                    end if;
                    case cnt is
                        when "00" =>
                            dac1_int <= counter;
                        when "01" =>
                            dac1_int <= x"ADF6"; -- +0.625 V
                        when "10" =>
                            dac1_int <= x"C0C8"; -- +1.25 V
                        when "11" =>
                            dac1_int <= x"D39B"; -- +1.875V
                    end case;
                elsif (RAMP(0) = '1') then
                    dac1_int <= dac1_int + 2048;
                else
                    --dac1_int <= x"9B27";         -- this will be 0V
                    if max_value = '1' then
                        dac1_int <= x"FFFF";
                    elsif zero_value = '1' then
                        dac1_int <= x"99E3";
                    else
                        dac1_int <= x"0000";
                    end if;
                end if;
            end if;
        end if;
    end process;


--------------------------
-- state machine to set out DAC2
--------------------------
	process (CLK, RESET)
	begin
		if RESET = '1' then -- assync. reset
		   dac2_int <= x"9B27";         -- this will be 0V
           flag2 <= '0';

		elsif rising_edge(CLK) then
            if update = '1' then
                if (ACTIVATE = '1') then
                    case cnt is
                        when "01" =>
                            dac2_int <= counter;
                        when "10" =>
                            dac2_int <= x"ADF6"; -- +0.625 V
                        when "11" =>
                            dac2_int <= x"C0C8"; -- +1.25 V
                        when "00" =>
                            dac2_int <= x"D39B"; -- +1.875V
                    end case;                
                elsif (RAMP(1) = '1') then
                    dac2_int <= dac2_int + 2048;
                else
                    if max_value = '1' then
                        dac2_int <= x"FFFF";
                    elsif zero_value = '1' then
                        dac2_int <= x"9A97";
                    else
                        dac2_int <= x"0000";
                    end if;
                end if;
            end if;
        end if;
    end process;


--------------------------
-- state machine to set out DAC3 -- long sweep
--------------------------
	process (CLK, RESET)
	begin
		if RESET = '1' then -- assync. reset
		   dac3_int <= x"9B27";         -- this will be 0V
           flag3 <= '0';
		elsif rising_edge(CLK) then
            if update = '1' then
                if (ACTIVATE = '1') then
                    case cnt is
                        when "10" =>
                            dac3_int <= counter;
                        when "11" =>
                            dac3_int <= x"ADF6"; -- +0.625 V
                        when "00" =>
                            dac3_int <= x"C0C8"; -- +1.25 V
                        when "01" =>
                            dac3_int <= x"D39B"; -- +1.875V
                    end case;
                    
                elsif (RAMP(2) = '1') then
                    dac3_int <= dac3_int + 2048;
                else
                    if max_value = '1' then
                        dac3_int <= x"FFFF";
                    elsif zero_value = '1' then
                        dac3_int <= x"9A54";
                    else
                        dac3_int <= x"0000";
                    end if;
                end if;
            end if;
        end if;
    end process;

    
--------------------------
-- state machine to set out DAC4 -- same as DAC2
--------------------------
	process (CLK, RESET)
	begin
		if RESET = '1' then -- assync. reset
		   dac4_int <= x"9B27";         -- this will be 0V
           flag4 <= '0';
		elsif rising_edge(CLK) then
            if update = '1' then
                if (ACTIVATE = '1') then
                    case cnt is
                        when "11" =>
                            dac4_int <= counter;
                        when "00" =>
                            dac4_int <= x"ADF6"; -- +0.625 V
                        when "01" =>
                            dac4_int <= x"C0C8"; -- +1.25 V
                        when "10" =>
                            dac4_int <= x"D39B"; -- +1.875V
                    end case;
                elsif (RAMP(3) = '1') then
                    dac4_int <= dac4_int + 2048;
                else
                    if max_value = '1' then
                        dac4_int <= x"FFFF";
                    elsif zero_value = '1' then
                        dac4_int <= x"9B3E";
                    else
                        dac4_int <= x"0000";
                    end if;
                end if;
            end if;
        end if;
    end process;
end behavioral;
