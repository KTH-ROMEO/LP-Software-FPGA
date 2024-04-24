--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: SWEEP_SPIDER2.vhd
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

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use IEEE.numeric_std.all;


entity SWEEP_SPIDER2 is
port (
		RESET       : in  std_logic;
        CLK         : in  std_logic;                    
        CLK_SLOW    : in std_logic;                     -- here the clock should probably be M_time(17)       
        ACTIVATE    : in  std_logic;
        FFUID       : in  std_logic_vector(7 downto 0);
        DAC1        : out  std_logic_vector(15 downto 0);
        DAC2        : out  std_logic_vector(15 downto 0);
        DAC3        : out  std_logic_vector(15 downto 0);
        DAC4        : out  std_logic_vector(15 downto 0);

        SET         : out std_logic
);
end SWEEP_SPIDER2;

architecture architecture_SWEEP_SPIDER2 of SWEEP_SPIDER2 is
    signal dac1_int, dac2_int, dac3_int, dac4_int   : std_logic_vector(15 downto 0);
    signal latch, update                            : std_logic;
    signal cnt                                      : std_logic_vector(1 downto 0);
    signal counter                                  : std_logic_vector(15 downto 0);
    signal ud_counter                               : std_logic_vector(15 downto 0);
    signal up_flag                                  : std_logic;

---------------------------------------------------------------------

begin
    DAC1 <= dac1_int;
    DAC2 <= dac2_int;
    DAC3 <= dac3_int;
    DAC4 <= dac4_int;
    SET <= update;

--------------------------
-- state machine to set out DACs
--------------------------
	process (CLK, RESET)
	begin
		if RESET = '1' then -- assync. reset
		    dac1_int <= x"9B1F";   -- reset value of the DAC
            dac2_int <= x"9B1F";   -- reset value of the DAC
            dac3_int <= x"9B1F";   -- reset value of the DAC
            dac4_int <= x"9B1F";   -- reset value of the DAC
           latch <= '0';
           update <= '0';
           cnt <= "00";
            up_flag <='1';
            ud_counter <= x"4000";  -- starting value of the up/down ramp
           counter <= x"9800";   -- starting value of the Sweep/ramp
            
		elsif rising_edge(CLK) then
            latch <= CLK_SLOW;
            if (CLK_SLOW = '1') and (latch = '0') then 
                update <= '1';
            else
                update <= '0';
            end if;

            if update = '1' then            
                if (ACTIVATE = '1') then

--                  This is counter upward (ramp) for all sweeps!
                    if counter = x"F800" then       -- Maximum value of all sweeps, ca 3V
                        if ((FFUID=x"07") or (FFUID=x"08")) then 
                            counter <= x"9800";         -- Minimum value of the sweep for FFU # 7 and 8, ca 0V
                        else
                            counter <= x"4000";         -- Minimum value of the sweep for all other FFUs
                        end if;
                        cnt <= cnt + 1;
                    else
                        if ((FFUID=x"07") or (FFUID=x"08")) then 
                            counter <= counter + x"0200";         -- Minimum value of the sweep for FFU # 7 and 8, ca 0V
                        else
                            counter <= counter + x"0400";         -- Minimum value of the sweep for all other FFUs
                        end if;
                    end if;

--                  This is counter up/down for sweep on probe 1 for FFUs #3 and #4
                    if ud_counter = x"F800" then       -- Maximum value of the sweep
                            up_flag <= '0';                           
                            ud_counter <= ud_counter - x"0200";  -- Increase voltage by 66 mV
                    elsif (ud_counter = x"4000") then       -- Maximum value of the sweep
                            up_flag <= '1';                            
                            ud_counter <= ud_counter + x"0200";  -- Increase voltage by 66 mV
                    else
                        if up_flag = '1' then
                            ud_counter <= ud_counter + x"0200";  -- Increase voltage by 66 mV
                        else
                            ud_counter <= ud_counter - x"0200";  -- Increase voltage by 66 mV
                        end if;
                    end if;


--          Here we do special treatment for FFUID 3 and 4
                    if (FFUID = x"03") or (FFUID = x"04") then
                       dac1_int <= ud_counter;            -- Probe 1 is sweeping up/down
                       dac2_int <= x"C853";            -- 1.5 V
                       dac3_int <= x"D764";            -- 2.0 V
                       dac4_int <= x"F587";            -- 3.0 V
--          Here we do special treatment for FFUID 2
                    elsif (FFUID = x"02") then
                       dac1_int <= x"C853";            -- 1.5 V
                       dac2_int <= x"D764";            -- 2.0 V
                       dac3_int <= x"E676";            -- 2.5 V
                       dac4_int <= x"F587";            -- 3.0 V
                    else

--              This section for rotating sweep on different probes
--                  Setting value for DAC1
                        if cnt="00" then 
                            dac1_int <= counter;
                        else
                            if (FFUID = x"01") then
                                dac1_int <= x"40B6";        -- -3V      -- this is default value for FFU#1    
                            else
                                dac1_int <= x"C853";        -- +1.5V
                            end if;
                        end if;

    --                  Setting value for DAC2
                        if cnt="01" then 
                            dac2_int <= counter;
                        else
                            if (FFUID = x"01") then
                                dac2_int <= x"7CFC";        -- -1V    
                            else
                                dac2_int <= x"D764";        -- +2.0V
                            end if; 
                        end if;

    --                  Setting value for DAC3
                        if cnt="10" then 
                            dac3_int <= counter;
                        else
                            if (FFUID = x"01") then
                                dac3_int <= x"B942";          -- +1.0V
                            else
                                dac3_int <= x"E676";          -- +2.5V 
                            end if;           
                        end if;

    --                  Setting value for DAC4
                        if cnt="11" then 
                            dac4_int <= counter;
                        else
                            dac4_int <= x"F587";            --  +3.0V
                        end if;
                    end if;
                else
  		           dac1_int <= x"9B1F";   -- reset value of the DAC
                   dac2_int <= x"9B1F";   -- reset value of the DAC
                   dac3_int <= x"9B1F";   -- reset value of the DAC
                   dac4_int <= x"9B1F";   -- reset value of the DAC
                end if;
            end if;
        end if;
    end process;


end architecture_SWEEP_SPIDER2;
