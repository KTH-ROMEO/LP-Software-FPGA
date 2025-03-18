--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: SWEEP_ROMEO.vhd
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


entity SWEEP_ROMEO is
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
        CBIASV0         : in  std_logic_vector(15 downto 0);    -- Voltage for CBias0
        CBIASV1         : in  std_logic_vector(15 downto 0);    -- Voltage for CBias1

        REN             : out std_logic;                    -- Read enable
        RADDR           : out std_logic_vector(7 downto 0); -- Read address
        SET             : out std_logic; 
        DAC1            : out  std_logic_vector(15 downto 0);
        DAC2            : out  std_logic_vector(15 downto 0);
        STEP_END        : out std_logic;                    -- ADC only enable when not skipping samples
        --samp       : out  std_logic_vector(15 downto 0); --DEBUG
        SW_END          : out std_logic


);
end SWEEP_ROMEO;

architecture architecture_SWEEP_ROMEO of SWEEP_ROMEO is
    signal dac1_int, dac2_int                       : std_logic_vector(15 downto 0); --dac3_int, dac4_int
    signal latch, update, fetch                     : std_logic;
    signal sweep_state                              : integer range 0 to 6;
    signal step                                     : std_logic_vector(7 downto 0);
    signal sample_n                                 : std_logic_vector(15 downto 0); -- Amount of samples performed in current step
    signal sweep_end                                : std_logic;
    signal sweep_table_read_wait                    : integer range 0 to 3;  -- Buffer to read from table
---------------------------------------------------------------------

begin
    DAC1 <= dac1_int;
    DAC2 <= dac2_int;
    SET <= update;
    --samp <= sample_n;

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
            REN <='0';
            RADDR <= x"00";
            sweep_table_read_wait <= 0;
            sample_n <= x"0000";
            STEP_END <= '0';
            SW_END <= '0';
            
		elsif rising_edge(CLK) then
            -- Block to update the DAC values #update --TODO: Should only be active if SW_ENABLE or CB_ENABLE ='1'
            latch <= CLK_SLOW;
            if (CLK_SLOW = '1') and (latch = '0') then 
                fetch <='0';
                if sweep_end='1' then
                    SW_END <= '1';
                end if;
            end if;
            if SW_ENABLE= '1' or CB_ENABLE= '1' then
                if fetch ='0' then
                    if CB_ENABLE= '1' then
                        sweep_state <= 0;
                        dac1_int <= CBIASV0;
                        dac2_int <= CBIASV1;
                        update <= '1';
                        fetch <= '1';
                    elsif SW_ENABLE='1' then
                        case sweep_state is
                            when 0 => 
                                if sample_n = x"0000" then
                                    sweep_state <= 1;
                                    STEP_END <='1';
                                else
                                    sweep_state <= 3;
                                end if;
                            when 1 =>
                                RADDR <= step;
                                REN <= '1';
                                STEP_END <='0';
                                sweep_state <= 2;
                            when 2 => 
                                -- Wait 4 CLK cycles for data to be read.
                                if sweep_table_read_wait /= 3 then
                                    sweep_table_read_wait <= sweep_table_read_wait + 1;
                                else
                                    sweep_state <= 3;
                                    dac1_int <= RD0;
                                    dac2_int <= RD1;
                                    REN <= '0';
                                end if;
                            when 3=>
                                sweep_table_read_wait <= 0;
                                if sample_n = x"0000" then
                                    update <= '1';
                                else 
                                    update <= '0';
                                end if;
                                sample_n <= sample_n +x"0001";
                                sweep_state <= 4;
                            when 4 =>
                                if sample_n = N_SAMPLES then
                                    if step = N_STEPS then
                                        step <= (others =>'0');
                                        sweep_state <= 6;
                                    else
                                        step <= step+x"01";
                                        sweep_state <= 5;
                                    end if;
                                    sample_n <= (others => '0');
                                else
                                    sweep_state <= 5;
                                end if;
                            when 5 =>
                                fetch <= '1';
                                update <= '0';
                                sweep_state <= 0;
                            when 6 =>
                                fetch <= '1';
                                sweep_end <= '1';
                            when others =>
                                sweep_table_read_wait <= 0;
                                REN <= '0';
                                STEP_END <='0';
                                sweep_state <= 0;
                                fetch <= '0';
                                sample_n <= (others => '0');
                                step <= (others => '0');
                                update <= '0';
                        end case;

                    end if;
                end if;
            else
                step <= x"00";          -- Reset value of step
                dac1_int <= x"9B1F";    -- reset value of the DAC
                dac2_int <= x"9B1F";    -- reset value of the DAC
                SW_END <= '0';          -- This line needs to be commented if the component is tested in the Test bench
                sample_n <= x"0000";
                sweep_end <= '0';
                update <= '0';
                fetch <= '0';
                REN <= '0';
                RADDR <= x"00";
                sweep_state <= 0;
            end if;
        end if;
    end process;


end architecture_SWEEP_ROMEO;
