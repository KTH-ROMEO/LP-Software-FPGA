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
        --ARST        : out std_logic;


        RST         : in std_logic;    -- manual reset
        CNV         : in std_logic;    -- single conversion

--      also we save the DAC settings
--      here is the input

        DACA        : in std_logic_vector(15 downto 0);
        DACB        : in std_logic_vector(15 downto 0);
        DACC        : in std_logic_vector(15 downto 0);
        DACD        : in std_logic_vector(15 downto 0);

        man_gain1 : IN std_logic_vector(1 downto 0);
        man_gain2 : IN std_logic_vector(1 downto 0);
        man_gain3 : IN std_logic_vector(1 downto 0);
        man_gain4 : IN std_logic_vector(1 downto 0);

        milliseconds : IN std_logic_vector(23 downto 0);
        exp_packet : OUT std_logic_vector(87 downto 0);
        exp_new_data : out std_logic;
        en_packets : IN std_logic;

        chan0_data   : OUT std_logic_vector(11 downto 0);
        chan1_data   : OUT std_logic_vector(11 downto 0);
        chan2_data   : OUT std_logic_vector(11 downto 0);
        chan3_data   : OUT std_logic_vector(11 downto 0);
        chan4_data   : OUT std_logic_vector(11 downto 0);
        chan5_data   : OUT std_logic_vector(11 downto 0);
        chan6_data   : OUT std_logic_vector(11 downto 0);
        chan7_data   : OUT std_logic_vector(11 downto 0);


        --ADCDATA     : out  std_logic_vector(7 downto 0);
        --ADCWE       : out  std_logic;


        --SAVE_ADC_DATA : in std_logic;
        --HK_SEND     : out std_logic;

        G1          : out  std_logic_vector(1 downto 0);
        G2          : out  std_logic_vector(1 downto 0);
        G3          : out  std_logic_vector(1 downto 0);
        G4          : out  std_logic_vector(1 downto 0);

        SYNC        : in std_logic     -- the SYNC signal from the magnetometer.

        --NEWDATA     : out  std_logic

       );

end ADC_READ;

----------------------------------------------------------------
----------------------------------------------------------------

architecture behavioral of ADC_READ is

    signal data_a, data_b     : std_logic_vector(17 downto 0);
    --signal da,db              : std_logic_vector(17 downto 0);
    signal state, state_out   : std_logic_vector(7 downto 0);
    signal counter            : std_logic_vector(8 downto 0);
    signal cnt                : std_logic_vector(7 downto 0);
    signal cnt_chan, chan     : std_logic_vector(1 downto 0);
    signal old_cnv            : std_logic;
    signal CS, DCLK, sdi_int  : std_logic;
    signal newflag            : std_logic;
    signal DAC                : std_logic_vector(15 downto 0);

    signal g1i,g2i,g3i,g4i : std_logic_vector(1 downto 0);
    signal gain    : std_logic_vector(1 downto 0);
    signal cnt1up, cnt2up, cnt3up, cnt4up   : std_logic_vector(11 downto 0);
    signal cnt1dn,cnt2dn,cnt3dn,cnt4dn : integer range 0 to 255;

---------------------------------------------------------------------

begin
    ACS <= CS;


--------------------------
-- state machine to set out 
--------------------------
	process (CLK, RESET)--, CNV)
	begin
		if RESET = '1' then -- assync. reset
		   data_a <= (others => '0');
		   data_b <= (others => '0');
           ACST <= '1';                 -- Start conversion
           cnt <= (others => '0');
           old_cnv <= '0';
           CS <= '1';
           ACLK <= '1';
           state <= "00000001";
           --ARST <= '0';
           --NEWDATA <= '0';
           counter <= (others => '0');
           cnt_chan <= "00";
           newflag <= '0';
           chan <= "00";

		elsif rising_edge(CLK) then
			case state is 
				when "00000001" =>  -- idle state
                    old_cnv <= CNV;
                    cnt <= (others => '0');
                    CS <= '1';
                    ACST <= '1';
                    ACLK <= '1';
                    --ARST <= '0';
                    --NEWDATA <= '0';
                    newflag <= '0';
                    counter <= (others => '0');
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
                    if counter(8 downto 5)="0110" then   -- wait for 22 us (good up to oversampling x4)  -reducing for 32 kHz sampling
                       state <= "00010000";
                       --NEWDATA <= '1';
                    else 
                       state <= "00000100";
                       counter <= counter + 1;                       
                    end if;
         

                when "00010000" => -- set chip select low
                    CS <= '0';
                    --NEWDATA <= '0';
                    state <= "00100000";

                when "00100000" => -- set clock low, latch the data in 
                    newflag <= '0';
                    ACLK <= '0';
                    data_a <= data_a(16 downto 0) & AB; -- Lines are flipped on schematics
                    data_b <= data_b(16 downto 0) & AA; -- Lines are flipped on schematics
                    state <= "01000000";
                    cnt <= cnt + 1;

                when "01000000" => -- set clock high, return it if is time.
                    ACLK <= '1';

                    if cnt=x"12" then 
                       cnt <= x"00";

                       if cnt_chan = "11" then 
                            state <= "00000001"; 
                       else 
                            state <= "00100000";
                            cnt_chan <= cnt_chan + 1;
                       end if;

                       newflag <= '1';
                       chan <= cnt_chan;
                    else 
                       state <= "00100000";
                    end if;

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
           --ADCDATA <= (others => '0');
           --ADCWE   <= '0';
           state_out <= "00000001";
           --da <= (others => '0');
           --db <= (others => '0');

           exp_new_data <= '0';
           chan0_data <= (others => '0');
           chan1_data <= (others => '0');
           chan2_data <= (others => '0');
           chan3_data <= (others => '0');
           chan4_data <= (others => '0');
           chan5_data <= (others => '0');
           chan6_data <= (others => '0');
           chan7_data <= (others => '0');

           --HK_SEND <= '0';

           g1i <= "00";     -- these are the gain settings for the gain of the AD8253
           g2i <= "00";     -- "00" is 1, "01" is 10, "10" is 100 and "11" is 1000
           g3i <= "00";     -- and automatic gain selection is to be implemented.
           g4i <= "00";

            cnt1dn <= 0;
            cnt1up <= (others => '0');
           

		elsif rising_edge(CLK) then
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
                            end case;
                        else
                            cnt1dn <= cnt1dn + 1;                                    
                        end if;                                
                    else
                        cnt1dn <= 0;
                    end if;

                end if;

--
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
                            end case;
                        else
                            cnt2dn <= cnt2dn + 1;                                    
                        end if;                                
                    else
                        cnt2dn <= 0;
                    end if;

                end if;

--
                --  adding here gain control, 
                if chan = "10" then -- dealing with channel 3 only.
                    if  (data_b(17 downto 12) = "00" & x"7") or
                        (data_b(17 downto 12) = "00" & x"8") then
                        if (cnt3up(4) = '1') then 
                            cnt3up <= (others => '0');
                            CASE g3i is
                                when "00"=>
                                    g3i <= "01";
                                when "01"=>
                                    g3i <= "10";
                                --when "10"=>
                                    --g3i <= "11";                                            
                            end case;
                        else
                            cnt3up <= cnt3up + 1;                                    
                        end if;
                    else
                        cnt3up <= (others => '0');
                    end if;

                    if (data_b(17 downto 15) = "100") or (data_b(17 downto 15) = "011") then 
                        if (cnt3dn = 8) then 
                            cnt3dn <= 0;
                            CASE g3i is
                                when "01"=>
                                    g3i <= "00";
                                when "10"=>
                                    g3i <= "01";
                                --when "11"=>
                                    --g3i <= "10";                                            
                            end case;
                        else
                            cnt3dn <= cnt3dn + 1;                                    
                        end if;                                
                    else
                        cnt3dn <= 0;
                    end if;

                end if;

--
                --  adding here gain control,
                if chan = "11" then -- dealing with channel 0 only.
                    if  (data_b(17 downto 12) = "00" & x"7") or
                        (data_b(17 downto 12) = "00" & x"8") then
                        if (cnt4up(4) = '1') then 
                            cnt4up <= (others => '0');
                            CASE g4i is
                                when "00"=>
                                    g4i <= "01";
                                when "01"=>
                                    g4i <= "10";
                                --when "10"=>
                                    --g4i <= "11";                                            
                            end case;
                        else
                            cnt4up <= cnt4up + 1;                                    
                        end if;
                    else
                        cnt4up <= (others => '0');
                    end if;

                    if (data_b(17 downto 15) = "100") or (data_b(17 downto 15) = "011") then 
                        if (cnt4dn = 8) then 
                            cnt4dn <= 0;
                            CASE g4i is
                                when "01"=>
                                    g4i <= "00";
                                when "10"=>
                                    g4i <= "01";
                                --when "11"=>
                                    --g4i <= "10";                                            
                            end case;
                        else
                            cnt4dn <= cnt4dn + 1;                                    
                        end if;                                
                    else
                        cnt4dn <= 0;
                    end if;

                end if;
----------------------------------------- done with gain control dealing --------------------------------

                exp_packet <= x"45" & milliseconds & chan & gain & data_a & data_b & DAC;

                case chan is
                    when "00" => chan0_data <= data_a(17 downto 6); chan4_data <= data_b(17 downto 6);
                    when "01" => chan1_data <= data_a(17 downto 6); chan5_data <= data_b(17 downto 6);
                    when "10" => chan2_data <= data_a(17 downto 6); chan6_data <= data_b(17 downto 6);
                    when "11" => chan3_data <= data_a(17 downto 6); chan7_data <= data_b(17 downto 6);
                end case;

                if en_packets = '1' then
                    exp_new_data <= '1';
                end if;

            else
                exp_new_data <= '0';
            end if;
        end if;
    end process;

DAC <=  DACA when chan = "00" else
        DACB when chan = "01" else
        DACC when chan = "10" else
        DACD;

gain <= g1i  when chan = "00" else
        g2i  when chan = "01" else
        g3i  when chan = "10" else
        g4i;

G1 <= g1i;
G2 <= g2i;
G3 <= g3i;
G4 <= g4i;

end behavioral;