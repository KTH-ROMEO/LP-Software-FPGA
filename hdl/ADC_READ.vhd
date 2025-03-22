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
        ------------------------------------------------
        --ADC inputs
        AA          : in  std_logic;
        AB          : in  std_logic;
        ABSY        : in  std_logic;
        CNV         : in std_logic;    -- Conversion ADC (Slow Clock)
        ------------------------------------------------
        --ADC output
        ACS         : out std_logic;
        ACLK        : out std_logic;
        ACST        : out std_logic;

        DATA_c0                : OUT std_logic_vector(17 downto 0);
        --DATA_c1                : OUT std_logic_vector(17 downto 0);
        --DATA_c2                : OUT std_logic_vector(17 downto 0);
        --DATA_c3                : OUT std_logic_vector(17 downto 0);
        DATA_c4                : OUT std_logic_vector(17 downto 0);
        --DATA_c5                : OUT std_logic_vector(17 downto 0);
        --DATA_c6                : OUT std_logic_vector(17 downto 0);
        --DATA_c7                : OUT std_logic_vector(17 downto 0);
        
        exp_new_data    : OUT std_logic        
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

    ---------------------------------------------------------------------

begin
    ACS <= CS;
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
           chan <= "00";
           end_point_step <='0';
           DATA_c0 <= (others => '0');
           DATA_c4 <= (others => '0');
           exp_new_data <= '0';

		elsif rising_edge(CLK) then
            
			case state is 
				when "00000001" =>  -- idle state
                    old_cnv <= CNV;
                    exp_new_data <= '0';
                    cnt <= (others => '0');
                    CS <= '1';
                    ACST <= '1';
                    ACLK <= '1';
                    cnt_chan <= "00";

                    if (CNV = '0') and (old_cnv = '1') then 
                        state <= "00000010";
                    else 
                        state <= "00000001";
                    end if;
                    
                when "00000010" =>  -- set convsta low
                    ACST <= '0';
                    state <= "00000100";

				when "00000100" =>  -- set convsta high
                    ACST <= '1';
                    if ABSY /='1' then -- counter(8 downto 5)="0110" then  -- wait for 22 us (good up to oversampling x4)  -reducing for 32 kHz sampling #(Old condition, changed to use the busy pin instead)
                       state <= "00001000";
                    else                          
                       state <= "00000100";       
                    --   counter <= counter + 1;    #Old condition, changed to use the busy pin instead                      
                    end if;
         
                when "00001000" => -- set chip select low
                    CS <= '0';
                    state <= "00010000";

                when "00010000" => -- set clock low, latch the serial data in 
                    exp_new_data <= '0';
                    ACLK <= '0';
                    -- DEBUG to generate fake ADC values
                    -- data_a <= "000111001000010001";
                    -- data_b <= "011010010000100010"; 
                    data_a <= "111111111111111111";
                    data_b <= "111111111111111111"; 
                    ---------------------------------------
                    -- data_a <= data_a(16 downto 0) & AB; -- Lines are flipped on schematics
                    -- data_b <= data_b(16 downto 0) & AA; -- Lines are flipped on schematics
                    state <= "00100000";
                    cnt <= cnt + 1;

                when "00100000" => -- set clock high, return it if is time.
                    ACLK <= '1';
                    if cnt=x"12" then 
                        cnt <= x"00";
                        case cnt_chan is 
                            when "00" => DATA_c0 <= data_a; DATA_c4 <= data_b; exp_new_data <='1';  --exp_new_data updated here to save time if only chan0 and chan4 (cnt_chan=00) require to be read
                            --when "01" => DATA_c1 <= data_a; DATA_c5 <= data_b;
                            --when "10" => DATA_c2 <= data_a; DATA_c6 <= data_b;
                            --when "11" => DATA_c3 <= data_a; DATA_c7 <= data_b;
                            when others =>
                        end case;
                        data_a <= (others => '0'); 
                        data_b <= (others => '0');
                        
                        if cnt_chan = "11" then  -- Reading all 4 (8) channels
                            --exp_new_data <='1'; (moved to previous case statement to save time)
                            cnt_chan <= "00";
                            state <= "00000001"; 
                        else 
                            state <= "00010000";
                            cnt_chan <= cnt_chan+1;
                        end if;
                        chan <= cnt_chan; 
                    else 
                       state <= "00010000";
                    end if;
                    
                when others =>   -- any strange state
                    state <= "00000001";
            end case;
        end if;
    end process;


end behavioral;