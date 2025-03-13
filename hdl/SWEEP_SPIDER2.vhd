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
		RESET           : in  std_logic;
        CLK             : in  std_logic;                    
        CLK_SLOW        : in std_logic;                         -- SampleRate 32kHz       
        SW_ENABLE       : in  std_logic;
        CB_ENABLE       : in  std_logic;
        RD0             : in  std_logic_vector(15 downto 0);    -- Data from Table0
        RD1             : in  std_logic_vector(15 downto 0);    -- Data from Table1
        N_STEPS         : in  std_logic_vector(7 downto 0);
        N_SAMPLES       : in  std_logic_vector(15 downto 0);
        N_SKIP_SAMPLES  : in  std_logic_vector(15 downto 0);

        CBIASV0         : in  std_logic_vector(15 downto 0);    -- Voltage for CBias0
        CBIASV1         : in  std_logic_vector(15 downto 0);    -- Voltage for CBias1

        DAC1            : out  std_logic_vector(15 downto 0);
        DAC2            : out  std_logic_vector(15 downto 0);
        
        SET             : out std_logic; 
        REN0            : out std_logic;                    -- Read enable table 0
        REN1            : out std_logic;                    -- Read enable table 1
        RADDR           : out std_logic_vector(7 downto 0); -- Read address
        ADC_EN          : out std_logic;                    -- ADC only enable when not skipping samples
        SW_END          : out std_logic

);
end SWEEP_SPIDER2;

architecture architecture_SWEEP_SPIDER2 of SWEEP_SPIDER2 is
    signal dac1_int, dac2_int                       : std_logic_vector(15 downto 0); --dac3_int, dac4_int
    signal latch, update, fetch, V_Changed          : std_logic;
    signal sweep_state                              : integer range 0 to 6;
    signal skipped_n                                : std_logic_vector(15 downto 0);
    signal step                                     : std_logic_vector(7 downto 0);
    signal sample_n                                 : std_logic_vector(15 downto 0); -- Amount of samples performed in current step
    signal sweep_end                                : std_logic;
    signal sweep_table_read_wait                    : integer range 0 to 3;  -- Buffer to read from table

---------------------------------------------------------------------

begin
    DAC1 <= dac1_int;
    DAC2 <= dac2_int;
    SET <= update;

--------------------------
-- state machine to set out DACs
--------------------------
	process (CLK, RESET)
	begin
		if RESET = '1' then         -- assync. reset
		    dac1_int <= x"9B1F";    -- reset value of the DAC
            dac2_int <= x"9B1F";    -- reset value of the DAC
            fetch <='0';            -- Voltage value needs to be requested
            latch <= '0';           -- initialize the latch
            update <= '0';          -- Update signal
            sweep_state <= 0;       -- number of sweeps CHANGED
            step <= x"00";          -- Reset step
            REN0 <='0';
            REN1 <='0';
            RADDR <= x"00";
            ADC_EN <='0';
            sweep_table_read_wait <= 0;
            skipped_n <= x"0000";
            sample_n <= x"0000";
            SW_END <= '0';
            V_Changed <= '0';
            
		elsif rising_edge(CLK) then
            -- Block to update the DAC values #update --TODO: Should only be active if SW_ENABLE or CB_ENABLE ='1'
            latch <= CLK_SLOW;
            if (CLK_SLOW = '1') and (latch = '0') then 
                if (SW_ENABLE= '1' or CB_ENABLE= '1') and V_Changed= '1' then
                    update <= '1';
                end if;
                fetch <='0';
                if sweep_end='1' then
                    SW_END <= '1';
                end if;
            else
                update <= '0';
            end if;
            if SW_ENABLE= '1' or CB_ENABLE= '1' then
                if fetch ='0' then
                    if CB_ENABLE= '1' then
                        ADC_EN <= '1';
                        dac1_int <= CBIASV0;
                        dac2_int <= CBIASV1;
                        fetch <= '1';
                    elsif SW_ENABLE='1' then
                        case sweep_state is
                            when 0 => -- Consider to move it to last step and avoid issues
                                -- Check if current sample is last of the step, if not increase sample counter
                                if skipped_n = x"0000" then
                                    ADC_EN <= '0';
                                    sweep_state <= 1;
                                elsif skipped_n = N_SKIP_SAMPLES then
                                    ADC_EN <= '1';
                                    sweep_state <= 3;
                                else
                                    skipped_n <= skipped_n + x"0001";
                                    sweep_state <= 3;
                                end if;

                            when 1 =>
                                RADDR <= step;
                                REN0 <= '1';
                                REN1 <= '1';
                                sweep_state <= 2;
                            when 2 => 
                                -- Wait 4 CLK cycles for data to be read.
                                if sweep_table_read_wait /= 3 then
                                    sweep_table_read_wait <= sweep_table_read_wait + 1;
                                else
                                    sweep_state <= 3;
                                    dac1_int <= RD0;
                                    dac2_int <= RD1;
                                    REN0 <= '0';
                                    REN1 <= '0';
                                end if;
                            when 3=>
                                sweep_table_read_wait <= 0;
                                if skipped_n = x"0000" then
                                    V_Changed <= '1';
                                    skipped_n <= skipped_n + x"0001";
                                    sweep_state <= 4;
                                elsif sample_n = N_SAMPLES then
                                    V_Changed <= '0';
                                    if step = N_STEPS then
                                        step <= (others =>'0');
                                        sweep_state <= 5;
                                    else
                                        step <= step+x"01";
                                        skipped_n <= x"0000";
                                        sweep_state <= 4;
                                    end if;
                                    sample_n <= (others => '0');
                                else 
                                    V_Changed <= '0';
                                    sample_n <= sample_n +x"0001";
                                    sweep_state <= 4;
                                end if;
                                
                            when 4 =>
                                fetch <= '1';
                                sweep_state <= 0;
                            when 5 =>
                                fetch <= '1';
                                sweep_end <= '1';
                            when others =>
                                sweep_table_read_wait <= 0;
                                REN0 <= '0';
                                REN1 <= '0';
                                sweep_state <= 0;
                                fetch <= '0';
                        end case;

                    end if;
                end if;
            else
                ADC_EN <='0';           -- ADC off if the experiment is not running
                step <= x"00";          -- Reset value of step
                dac1_int <= x"9B1F";    -- reset value of the DAC
                dac2_int <= x"9B1F";    -- reset value of the DAC
                --SW_END <= '0';
                sample_n <= x"0000";
                sweep_end <= '0';
            end if;
        end if;
    end process;
    --Comment to see if it does update the test bench


end architecture_SWEEP_SPIDER2;
