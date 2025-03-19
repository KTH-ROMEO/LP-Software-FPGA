--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: ADC_Data_Packer.vhd
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

entity ADC_Data_Packer is
port (
    
    CLK     : IN std_logic;
    RESET   : IN std_logic;
    SW_EN       : IN std_logic;
    CB_EN       : IN std_logic;
    STEP_END    : IN std_logic;
	CHAN0 : IN  std_logic_vector(17 downto 0); 
    CHAN4 : IN  std_logic_vector(17 downto 0);
    exp_new_data    : IN std_logic;
    N_SAMPLES_POINT: IN std_logic_vector(15 downto 0);
    N_POINT_STEP: IN std_logic_vector(15 downto 0);
    N_SKIPPED_SAMPLES: IN std_logic_vector(15 downto 0);   
    --DEBUG:
    --Skipped   : OUT std_logic_vector(15 downto 0);
    --Point_samples   : OUT std_logic_vector(15 downto 0);
    --
    G1          : OUT  std_logic_vector(1 downto 0);
    G2          : OUT  std_logic_vector(1 downto 0);
    SC_packet   : OUT std_logic_vector(63 downto 0);
    new_SC_packet   : OUT std_logic

);
end ADC_Data_Packer;
architecture architecture_ADC_Data_Packer of ADC_Data_Packer is
   -- signal, component etc. declarations
	signal signal_name1 : std_logic; -- example
	signal signal_name2 : std_logic_vector(1 downto 0) ; -- example
    
    signal n_points                     : std_logic_vector(15 downto 0);
    signal n_skipped, n_point_samples   : std_logic_vector(15 downto 0);
    signal point_counter            : std_logic_vector(15 downto 0);
    signal cnt_chan, chan           : std_logic_vector(1 downto 0);
    signal ACC_chan0, ACC_chan4     : std_logic_vector(21 downto 0); -- accumulators for postprocesing the point value
    signal state                    : integer range 0 to 7;
    signal ADC_Data                 : std_logic_vector(17 downto 0);
    --Gain
    signal g1i,g2i                  : std_logic_vector(1 downto 0); --,g3i,g4i
    signal gain                     : std_logic_vector(1 downto 0);
    signal cntup, cnt1up, cnt2up           : std_logic_vector(11 downto 0); --, cnt3up, cnt4up
    signal cntdn, cnt1dn, cnt2dn           : integer range 0 to 255; --,cnt3dn,cnt4dn :

begin
    --Skipped <= n_skipped;
    --Point_samples <= n_point_samples;
    process (CLK, RESET)
    begin
        
        if RESET = '1' then -- assync. reset            
            -- Gain control, can be simplified but it remains as it was until a decision is taken on how to handle gain
            G1 <= "00";     -- these are the gain settings for the gain of the AD8253
            G2 <= "00";     -- "00" is 1, "01" is 10, "10" is 100 and "11" is 1000
            state <= 0;
            n_skipped <= (others => '0');
            n_point_samples <= (others => '0');
            new_SC_packet <= '0';
            point_counter <= (others => '0');
            SC_packet <= (others => '0');
            ACC_chan0 <= (others =>'0');
            ACC_chan4 <= (others =>'0');
            n_points <= (others => '0');

        ---------------------------------------------------------------
        elsif rising_edge(CLK) then
            if SW_EN ='1' or CB_EN='1' then             
                case state is
                    when 0 => -- idle
                        if exp_new_data ='1' then
                            state <= 1;
                        else
                            state <= 0;
                        end if;
                        
                    when 1 =>
                        if n_skipped = N_SKIPPED_SAMPLES then
                            state <= 2;
                        else
                            state <= 0;
                            n_skipped <= n_skipped + x"0001";
                        end if;
                        
                    when 2 =>
                        ACC_chan0 <= ACC_chan0 + CHAN0;
                        ACC_chan4 <= ACC_chan4 + CHAN4;
                        n_point_samples <= n_point_samples + x"0001";
                        state <= 3;
                    when 3 => 
                        if n_point_samples = N_SAMPLES_POINT then
                            SC_packet <= point_counter & G1 & ACC_chan0 & G2 & ACC_chan4;      -- Using Channel 0 & 4 (connected to test points in prototype board, but will be connected to LP in final design)
                            n_point_samples <=x"0000";
                            n_points <= n_points + x"0001";
                            point_counter <= point_counter+1;      
                            ACC_chan0 <= (others =>'0');
                            ACC_chan4 <= (others =>'0');
                            new_SC_packet <='1';
                            state <= 4;
                            --ACC_chan5 <= (others =>'0'); --ACC_chan1 <= (others =>'0');
                        else
                            state <= 0;
                        end if;
                    when 4 =>
                        -- Gain update after point recorded
                        G1 <= g1i;
                        G2 <= g2i;
                        -----------------------------------
                        if n_points = N_POINT_STEP then
                            n_points <= x"0000";
                            state <= 5;
                        else
                            state <= 0;
                        end if;
                        new_SC_packet <='0';
                    when 5 =>
                        if STEP_END = '1' or CB_EN='1' then
                            -- Gain update at the end of the step
                            G1 <= g1i;
                            G2 <= g2i;
                            n_skipped <= (others => '0');
                            state <= 0;
                        end if;

                    when others =>
                        state <= 0;
                end case;
            else
                point_counter <= (others => '0');
                state <= 0;
                new_SC_packet <='0';
                n_point_samples <= (others => '0');
                n_skipped <= (others => '0');
                ACC_chan0 <= (others =>'0');
                ACC_chan4 <= (others =>'0');
                n_points <= (others => '0');
            end if;
        end if;
    end process;

    process (CLK, RESET)--, CNV)
    begin
        if RESET = '1' then -- assync. reset
            
            -- Gain control, can be simplified but it remains as it was until a decision is taken on how to handle gain
            g1i <= "00";     -- these are the gain settings for the gain of the AD8253
            g2i <= "00";     -- "00" is 1, "01" is 10, "10" is 100 and "11" is 1000
            cnt1dn <= 0;
            cnt1up <= (others => '0');
            cnt2dn <= 0;
            cnt2up <= (others => '0');

        ---------------------------------------------------------------
        elsif rising_edge(CLK) then -- Gain control and packet assembly, condition met once each channel is read (4 times every sample)
            if exp_new_data = '1' then 
                
                --  GAIN CONTROL FOR CHANNEL 0
                if (CHAN0(17 downto 12) = "00" & x"7") or (CHAN0(17 downto 12) = "00" & x"8") then
                    if (cnt1up(3) = '1') then  cnt1up <= (others => '0');
                        if G1 /= "11" then g1i <= G1 + "1";
                        end if;
                    else cnt1up <= cnt1up + 1;
                    end if;
                else cnt1up <= (others => '0');
                end if;

                if (CHAN0(17 downto 15) = "100") or (CHAN0(17 downto 15) = "011") then 
                    if (cnt1dn = 8) then cnt1dn <= 0;
                        if G1 /= "00" then g1i <= G1 - "1";                                 
                        end if;
                    else cnt1dn <= cnt1dn + 1;                                    
                    end if;                                
                else cnt1dn <= 0;
                end if;
                --  GAIN CONTROL FOR CHANNEL 4
                if (CHAN4(17 downto 12) = "00" & x"7") or (CHAN4(17 downto 12) = "00" & x"8") then
                    if (cnt2up(3) = '1') then  cnt2up <= (others => '0');
                        if G2 /= "11" then g2i <= G2 + "1";
                        end if;
                    else cnt2up <= cnt2up + 1;
                    end if;
                else cnt2up <= (others => '0');
                end if;

                if (CHAN4(17 downto 15) = "100") or (CHAN4(17 downto 15) = "011") then 
                    if (cnt2dn = 8) then cnt2dn <= 0;
                        if G2 /= "00" then g2i <= G2 - "1";                                 
                        end if;
                    else cnt2dn <= cnt2dn + 1;                                    
                    end if;                                
                else cnt2dn <= 0;
                end if;

                ------------------------- done with gain control dealing --------------------------------

            end if;
        end if;
    end process;

   -- architecture body
end architecture_ADC_Data_Packer;
