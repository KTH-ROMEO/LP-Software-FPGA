-- ADC_READ.vhd

--
--
-- reading AD7608
--
--

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_unsigned.all; 
use IEEE.numeric_std.all;

entity ADC_READ is
	port(
		RESET       : in  std_logic;
        CLK         : in  std_logic;
        AA          : in  std_logic;
        AB          : in  std_logic;
        ABSY        : in  std_logic;
        ACS         : out std_logic;
        ACLK        : out std_logic;
        ACST        : out std_logic;
        CNV         : in std_logic;    -- SlowClock
        ADC_EN      : in std_logic;
        SW_EN       : IN std_logic;
        CB_EN       : IN std_logic;

        ------------------------------------------------
        --Ports for Sweep steps
        -- TODO:    Rewrite how the samples are taken, it should not be dependand on which step the DAC is, but it only should read when the DAC is active, and continue until its not
        N_SAMPLES_POINT         : IN std_logic_vector(15 downto 0);
        N_POINT_STEP            : IN std_logic_vector(15 downto 0);


        milliseconds    : IN std_logic_vector(23 downto 0);
        exp_SC_packet   : OUT std_logic_vector(63 downto 0);
        exp_Test_packet : OUT std_logic_vector(63 downto 0);
        exp_new_data    : OUT std_logic;
        en_packets      : IN std_logic;

        --chan0_data   : OUT std_logic_vector(11 downto 0);
        --chan1_data   : OUT std_logic_vector(11 downto 0);
        --chan2_data   : OUT std_logic_vector(11 downto 0);
        --chan3_data   : OUT std_logic_vector(11 downto 0);
        --chan4_data   : OUT std_logic_vector(11 downto 0);
        --chan5_data   : OUT std_logic_vector(11 downto 0);
        --chan6_data   : OUT std_logic_vector(11 downto 0);
        --chan7_data   : OUT std_logic_vector(11 downto 0);
        --ENDPOINTSTEP:OUT std_logic; --Debug port 
        G1          : OUT  std_logic_vector(1 downto 0);
        G2          : OUT  std_logic_vector(1 downto 0)
       );

end ADC_READ;
----------------------------------------------------------------

architecture behavioral of ADC_READ is

    signal data_a, data_b           : std_logic_vector(17 downto 0);
    signal state                    : std_logic_vector(7 downto 0);
    signal cnt                      : std_logic_vector(7 downto 0);
    signal cnt_chan, chan           : std_logic_vector(1 downto 0);
    signal old_cnv, end_point_step  : std_logic;
    signal CS, DCLK, sdi_int        : std_logic;
    signal newflag                  : std_logic;
    --signal DAC                    : std_logic_vector(15 downto 0);
    signal n_points                 : std_logic_vector(15 downto 0);
    signal n_point_samples          : std_logic_vector(15 downto 0);
    signal point_counter            : std_logic_vector(15 downto 0);

    signal g1i,g2i                  : std_logic_vector(1 downto 0); --,g3i,g4i
    signal gain                     : std_logic_vector(1 downto 0);
    signal cnt1up, cnt2up           : std_logic_vector(11 downto 0); --, cnt3up, cnt4up
    signal cnt1dn, cnt2dn           : integer range 0 to 255; --,cnt3dn,cnt4dn :
    signal ACC_chan0, ACC_chan1, ACC_chan4, ACC_chan5   : std_logic_vector(21 downto 0); -- accumulators for averaging the point value
    ---------------------------------------------------------------------

begin
    ACS <= CS;
    --ENDPOINTSTEP <=end_point_step; debug
    --------------------------
    -- state machine to set out 
    --------------------------
	process (CLK, RESET)--, CNV)
	begin
		if RESET = '1' then -- assync. reset
		   data_a <= (others => '0');   -- Serial A data
		   data_b <= (others => '0');   -- Serial B data
           ACST <= '1';                 -- Start conversion
           cnt <= (others => '0');      -- Bit counter for serial
           old_cnv <= '0';              -- 32kHz latch
           CS <= '1';
           ACLK <= '1';
           state <= "00000001";
           cnt_chan <= "00";
           newflag <= '0';
           chan <= "00";
           point_counter <= (others => '0');
           end_point_step <='0';
           n_points   <=x"0001";        -- Current step (Always starts at step 1)
           n_point_samples <=x"0000";   -- Number of samples in current point
           ACC_chan0 <= (others =>'0');
           ACC_chan1 <= (others =>'0');
           ACC_chan4 <= (others =>'0');
           ACC_chan5 <= (others =>'0');
           exp_SC_packet <= (others =>'0');
           --g1i <= "00";     -- these are the gain settings for the gain of the AD8253
           --g2i <= "00";     -- "00" is 1, "01" is 10, "10" is 100 and "11" is 1000

		elsif rising_edge(CLK) then
            if SW_EN ='0' and CB_EN='0' then 
                point_counter <= (others => '0');
            end if;
			case state is 
				when "00000001" =>  -- idle state
                    old_cnv <= CNV;
                    cnt <= (others => '0');
                    CS <= '1';
                    ACST <= '1';
                    ACLK <= '1';
                    newflag <= '0';
                    cnt_chan <= "00";

                    if (CNV = '1') and (old_cnv = '0') then 
                        state <= "00000010";
                    else 
                        state <= "00000001";
                    end if;
                    
                when "00000010" =>  -- set convsta low
                    ACST <= '0';
                    state <= "00000100";

				when "00000100" =>  -- set convsta high
                    ACST <= '1';
                    if ABSY /='1' then -- counter(8 downto 5)="0110" then  -- wait for 22 us (good up to oversampling x4)  -reducing for 32 kHz sampling #Old condition, changed to use the busy pin instead
                       state <= "00001000";
                    else                          
                       state <= "00000100";       
                    --   counter <= counter + 1;    #Old condition, changed to use the busy pin instead                      
                    end if;
         
                when "00001000" => -- set chip select low
                    CS <= '0';
                    state <= "00010000";

                when "00010000" => -- set clock low, latch the serial data in 
                    newflag <= '0';
                    ACLK <= '0';
                    data_a <= data_a(16 downto 0) & AB; -- Lines are flipped on schematics
                    data_b <= data_b(16 downto 0) & AA; -- Lines are flipped on schematics
                    state <= "00100000";
                    cnt <= cnt + 1;

                when "00100000" => -- set clock high, return it if is time.
                    ACLK <= '1';

                    if cnt=x"12" then 
                       cnt <= x"00";

                        if cnt_chan = "01" then  -- It was reading the 4 channels in each line, maybe not required for ROMEO, will depend on final PCB layout
                            if ADC_EN='1' then
                                n_point_samples <= n_point_samples + 1;
                            else
                                n_point_samples <=x"0000";  
                            end if;
                            cnt_chan <= "00";
                            state <= "01000000"; 
                        else 
                            state <= "00010000";
                            cnt_chan <= "01";
                        end if;
                        case cnt_chan is -- Adding channel values to accumulator for point processing
                            when "00" => ACC_chan0 <= ACC_chan0 + data_a; ACC_chan4 <= ACC_chan4 + data_b;
                            when "01" => ACC_chan1 <= ACC_chan1 + data_a; ACC_chan5 <= ACC_chan5 + data_b;
                            when others =>
                        end case;
                        chan <= cnt_chan; -- 
                    else 
                       state <= "00010000";
                    end if;
                
                when "01000000" => -- Check if n_point_samples = N_SAMPLES_POINT
                    if ADC_EN='1' then
                        if end_point_step = '0' then
                            if n_point_samples = N_SAMPLES_POINT then -- check if point is complete
                                newflag <= '1';  --Trigers Gain update and Packet Gen
                                exp_SC_packet <= point_counter & g1i & ACC_chan0 & g2i & ACC_chan4;      -- Using Channel 0 & 4 (connected to test points in prototype board, but will be connected to LP in final design)
                                exp_Test_packet <= point_counter & g1i & ACC_chan0 & g2i & ACC_chan4;    -- Using Channel 1 & 5 (connected to ADC points in prototype board, but will be grounded in final design, use for testing)
                                n_point_samples <=x"0000";
                                point_counter <= point_counter+1;                                
                                -- check if step is complete if it is in Sweep Mode
                                if n_points=N_POINT_STEP and SW_EN='1' then
                                    end_point_step <= '1';
                                    n_points <=x"0001";
                                    n_point_samples <=x"0000";
                                else
                                    n_points <= n_points + 1;
                                end if;
                            else
                            end if;
                        end if;
                    else
                        end_point_step <= '0';
                    end if;
                    state <= "00000001";
                when others =>   -- any strange state
                    state <= "00000001";
            end case;
        end if;
    end process;
    --------------------------
    -- state machine to send out the data to memory 
    --------------------------
	process (CLK, RESET)--, CNV)
	begin
		if RESET = '1' then -- assync. reset
            exp_new_data <= '0';
            --chan0_data <= (others => '0');
            --chan1_data <= (others => '0');
            --chan2_data <= (others => '0');
            --chan3_data <= (others => '0');
            --chan4_data <= (others => '0');
            --chan5_data <= (others => '0');
            --chan6_data <= (others => '0');
            --chan7_data <= (others => '0');

            -- Gain control, can be simplified but it remains as it was until a decision is taken on how to handle gain
            g1i <= "00";     -- these are the gain settings for the gain of the AD8253
            g2i <= "00";     -- "00" is 1, "01" is 10, "10" is 100 and "11" is 1000
            cnt1dn <= 0;
            cnt1up <= (others => '0');
            cnt2dn <= 0;
            cnt2up <= (others => '0');

        ---------------------------------------------------------------
		elsif rising_edge(CLK) then -- Gain control and packet assembly, condition met once each channel is read (4 times every sample)
            if newflag = '1' then 
                --  adding here gain control, 
                if chan = "00" then -- dealing with channel 0 only.
                    if (data_b(17 downto 12) = "00" & x"7") or
                        (data_b(17 downto 12) = "00" & x"8") then
                        if (cnt1up(4) = '1') then 
                            cnt1up <= (others => '0');
                            CASE g1i is
                                when "00"=>
                                    g1i <= "01";
                                when "01"=>
                                    g1i <= "10";
                                --when "10"=>
                                    --g1i <= "11";
                                when others =>                                            
                            end case;
                        else
                            cnt1up <= cnt1up + 1;                                    
                        end if;
                    else
                        cnt1up <= (others => '0');
                    end if;

                    if (data_b(17 downto 15) = "100") or (data_b(17 downto 15) = "011") then 
                        if (cnt1dn = 8) then 
                            cnt1dn <= 0;
                            CASE g1i is
                                when "01"=>
                                    g1i <= "00";
                                when "10"=>
                                    g1i <= "01";
                                --when "11"=>
                                    --g1i <= "10";
                                when others =>                                            
                            end case;
                        else
                            cnt1dn <= cnt1dn + 1;                                    
                        end if;                                
                    else
                        cnt1dn <= 0;
                    end if;

                end if;
                --  adding here gain control, 
                if chan = "01" then -- dealing with channel 1 only.
                    if  (data_b(17 downto 12) = "00" & x"7") or
                        (data_b(17 downto 12) = "00" & x"8") then
                        if (cnt2up(4) = '1') then 
                            cnt2up <= (others => '0');
                            CASE g2i is
                                when "00"=>
                                    g2i <= "01";
                                when "01"=>
                                    g2i <= "10";
                                --when "10"=>
                                    --g2i <= "11";       
                                when others =>                                     
                            end case;
                        else
                            cnt2up <= cnt2up + 1;                                    
                        end if;
                    else
                        cnt2up <= (others => '0');
                    end if;

                    if (data_b(17 downto 15) = "100") or (data_b(17 downto 15) = "011") then 
                        if (cnt2dn = 8) then 
                            cnt2dn <= 0;
                            CASE g2i is
                                when "01"=>
                                    g2i <= "00";
                                when "10"=>
                                    g2i <= "01";
                                --when "11"=>
                                    --g2i <= "10";     
                                when others =>
                            end case;
                        else
                            cnt2dn <= cnt2dn + 1;                                    
                        end if;                                
                    else
                        cnt2dn <= 0;
                    end if;

                end if;
                ------------------------- done with gain control dealing --------------------------------
                
                -- TODO: Once decided the channels used, trim the exp packet to only have CHAN, (gain if automatic,) one set of Data (a or b), (and the DAC current?)
                --exp_SC_packet <= x"45" & milliseconds & chan & gain & data_a & data_b & DAC; -- For SD card storage
                
                --case chan is -- ChanX_data used for UART 
                    --when "00" => chan0_data <= data_a(17 downto 6); chan4_data <= data_b(17 downto 6);
                    --when "01" => chan1_data <= data_a(17 downto 6); chan5_data <= data_b(17 downto 6);
                    --when "10" => chan2_data <= data_a(17 downto 6); chan6_data <= data_b(17 downto 6);
                    --when "11" => chan3_data <= data_a(17 downto 6); chan7_data <= data_b(17 downto 6);
                --end case;

                if en_packets = '1' then
                    exp_new_data <= '1';
                end if;

            else
                exp_new_data <= '0';
            end if;
        end if;
    end process;

--DAC <=  DACA when chan = "00" else
        --DACB when chan = "01";-- else
        --DACC when chan = "10" else
        --DACD;

gain <= g1i  when chan = "00" else
        g2i  when chan = "01";-- else
        --g3i  when chan = "10" else
        --g4i;

G1 <= g1i;
G2 <= g2i;
--G3 <= g3i;
--G4 <= g4i;

end behavioral;