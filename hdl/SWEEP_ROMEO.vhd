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
        N_SAMPLES_SW    : in  std_logic_vector(15 downto 0);
        N_SAMPLES_CB    : in  std_logic_vector(15 downto 0);
        CBIASV0         : in  std_logic_vector(15 downto 0);    -- Voltage for CBias0
        CBIASV1         : in  std_logic_vector(15 downto 0);    -- Voltage for CBias1

        REN             : out std_logic;                    -- Read enable
        RADDR           : out std_logic_vector(7 downto 0); -- Read address
        SET             : out std_logic; 
        DAC1            : out  std_logic_vector(15 downto 0);
        DAC2            : out  std_logic_vector(15 downto 0);
        STEP_END        : out std_logic;                    -- ADC only enable when not skipping samples
        --samp       : out  std_logic_vector(15 downto 0); --DEBUG
        SWEEP_ACTIVE    : out std_logic;
        SW_END          : out std_logic


);
end SWEEP_ROMEO;

architecture architecture_SWEEP_ROMEO of SWEEP_ROMEO is

    type sweep_state_type is (
            Check_step_start,
            Request_step_Voltage,
            Read_step_Voltage,
            Increase_sample_count,
            Check_end_step,
            Wait_step,
            End_Sweep
        );

    signal dac1_int, dac2_int                       : std_logic_vector(15 downto 0); --dac3_int, dac4_int
    signal update, update_DAC, Wait_until_next_step                     : std_logic;
    signal step                                     : std_logic_vector(7 downto 0);
    signal sample_n, N_SAMPLES                      : std_logic_vector(15 downto 0); -- Amount of samples performed in current step
    signal sweep_end, SW_active                     : std_logic;
    signal sweep_table_read_wait                    : integer range 0 to 3;  -- Buffer to read from table
    signal sweep_state    : sweep_state_type := Check_step_start;
---------------------------------------------------------------------

begin
    DAC1 <= dac1_int;
    DAC2 <= dac2_int;
    SET <= update_DAC;
    SWEEP_ACTIVE <=SW_active;
    --samp <= sample_n;

--------------------------
-- state machine to set out DACs
--------------------------
	process (CLK, RESET)
	begin
		if RESET = '1' then         -- assync. reset
		    dac1_int <= x"9B1F";    -- reset value of the DAC
            dac2_int <= x"9B1F";    -- reset value of the DAC
            Wait_until_next_step <='0';            -- Voltage value needs to be requested
            update <= '0';           -- initialize the latch
            update_DAC <= '0';          -- update_DAC signal
            sweep_state <= Check_step_start;       -- Sweep state machine
            step <= x"00";          -- Reset step
            REN <='0';
            RADDR <= x"00";
            sweep_table_read_wait <= 0;
            sample_n <= x"0000";
            SW_active<= '0';
            STEP_END <= '0';
            SW_END <= '0';
            
		elsif rising_edge(CLK) then
            -- Block to update_DAC the DAC values #update_DAC --TODO: Should only be active if SW_active or CB_ENABLE ='1'
            update <= CLK_SLOW;
            if SW_ENABLE='1' then
                SW_active <= '1';
                N_SAMPLES <= N_SAMPLES_SW;
            else
                N_SAMPLES <= N_SAMPLES_CB;
            end if;
            if (CLK_SLOW = '1') and (update = '0') then 
                Wait_until_next_step <='0';
                if sweep_end='1' then
                    SW_active <='0';
                    SW_END <= '1';
                end if;
            end if;
            if SW_active= '1' or CB_ENABLE= '1' then
                if Wait_until_next_step ='0' then
                    if CB_ENABLE= '1' then
                        sweep_state <= Check_step_start;
                        dac1_int <= CBIASV0;
                        dac2_int <= CBIASV1;
                        update_DAC <= '1';
                        Wait_until_next_step <= '1';
                    elsif SW_active='1' then
                        case sweep_state is
                            when Check_step_start => 
                                if sample_n = x"0000" then
                                    sweep_state <= Request_step_Voltage;
                                    STEP_END <='1';
                                else
                                    sweep_state <= Increase_sample_count;
                                end if;
                            when Request_step_Voltage =>
                                RADDR <= step;
                                REN <= '1';
                                STEP_END <='0';
                              sweep_state <= Read_step_Voltage;
                            when Read_step_Voltage => 
                                -- Wait 4 CLK cycles for data to be read.
                                if sweep_table_read_wait /= 3 then
                                    sweep_table_read_wait <= sweep_table_read_wait + 1;
                                else
                                    sweep_state <= Increase_sample_count;
                                    dac1_int <= RD0;
                                    dac2_int <= RD1;
                                    REN <= '0';
                                end if;
                            when Increase_sample_count=>
                                sweep_table_read_wait <= 0;
                                if sample_n = x"0000" then
                                    -- Request DAC update_DAC only at the begining of the step
                                    update_DAC <= '1';
                                else 
                                    update_DAC <= '0';
                                end if;
                                sample_n <= sample_n +1;
                                sweep_state <= Check_end_step;
                            when Check_end_step =>
                                if sample_n = N_SAMPLES then
                                    if step = N_STEPS then
                                        -- Case: last step of the sweep, End Sweep 
                                        step <= (others =>'0');
                                        sweep_state <= End_Sweep;
                                    else
                                        step <= step+1;
                                        sweep_state <= Wait_step;
                                    end if;
                                    sample_n <= (others => '0');
                                else
                                    sweep_state <= Wait_step;
                                end if;
                            when Wait_step =>
                                Wait_until_next_step <= '1';
                                update_DAC <= '0';
                                sweep_state <= Check_step_start;
                            when End_Sweep =>
                                Wait_until_next_step <= '1';
                                sweep_end <= '1';
                            when others =>
                                sweep_table_read_wait <= 0;
                                REN <= '0';
                                STEP_END <='0';
                                sweep_state <= Check_step_start;
                                Wait_until_next_step <= '0';
                                sample_n <= (others => '0');
                                step <= (others => '0');
                                update <= '0';
                                update_DAC <= '0';
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
                update_DAC <= '0';
                Wait_until_next_step <= '0';
                REN <= '0';
                RADDR <= x"00";
                sweep_state <= Check_step_start;
            end if;
        end if;
    end process;


end architecture_SWEEP_ROMEO;
