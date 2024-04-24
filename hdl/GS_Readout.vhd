--------------------------------------------------------------------------------
-- Company: KTH - Royal Institute of Technology
--
-- File: Status_Readout.vhd
-- File history:
--      <Revision number>: <Date>: <Comments>
--      <Revision number>: <Date>: <Comments>
--      <Revision number>: <Date>: <Comments>
--
-- Description: 
--
-- Readout module that sends information in the format
-- expected by the ground station used in KTH sounding rocket projects.
--
--
-- Targeted device: <Family::ProASIC3> <Die::A3P250> <Package::100 VQFP>
-- Author: C. Tolis
--
--------------------------------------------------------------------------------

library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity GS_Readout is
port (
    clk : IN std_logic;
    reset : IN std_logic;

    enable : IN std_logic;
    gs_id : IN std_logic_vector(7 downto 0);      -- gs_id byte, second character of message.

    ch0_data : IN std_logic_vector(11 downto 0);
    ch1_data : IN std_logic_vector(11 downto 0);
    ch2_data : IN std_logic_vector(11 downto 0);
    ch3_data : IN std_logic_vector(11 downto 0);
    ch4_data : IN std_logic_vector(11 downto 0);
    ch5_data : IN std_logic_vector(11 downto 0);
    ch6_data : IN std_logic_vector(11 downto 0);
    ch7_data : IN std_logic_vector(11 downto 0);
    ch8_data : IN std_logic_vector(11 downto 0);
    ch9_data : IN std_logic_vector(11 downto 0);
    ch10_data : IN std_logic_vector(11 downto 0);
    ch11_data : IN std_logic_vector(11 downto 0);

    txrdy : IN std_logic;

    status_bits : IN std_logic_vector(63 downto 0);

    send : OUT std_logic_vector(7 downto 0);
    wen : OUT std_logic;

    busy : OUT std_logic

);
end GS_Readout;
architecture architecture_GS_Readout of GS_Readout is
    type state_type is (
        state_idle,
        state_send_wait,
        state_send_id,
        state_send_statusbits,
        state_send_adc_1,
        state_send_adc_2,
        state_send_adc_3,
        state_send_postamble
    );

    signal state : state_type;          -- Data rotator state
    signal prevState : state_type;      -- Data rotator previous state
    signal subState : integer range 1 to 17;    -- Data rotator substates

    signal adc_vector_1 : std_logic_vector(63 downto 0);
    signal adc_vector_2 : std_logic_vector(63 downto 0);
    signal adc_vector_3 : std_logic_vector(63 downto 0);

    function halfByteToAscii (                       -- Converts 4 bits to to an ASCII hex character (0-F).
        halfByte : IN std_logic_vector(3 downto 0))
        return std_logic_vector is
        variable asciiByte : std_logic_vector(7 downto 0);
    begin
        case halfByte is
            when x"A" => asciiByte := x"41";
            when x"B" => asciiByte := x"42";
            when x"C" => asciiByte := x"43";
            when x"D" => asciiByte := x"44";
            when x"E" => asciiByte := x"45";
            when x"F" => asciiByte := x"46";
            when others => asciiByte := x"3" & halfByte;
        end case;

        return std_logic_vector(asciiByte);
    end;

    function getHalfByte(
        vector : IN std_logic_vector(63 downto 0);
        part : IN integer range 1 to 16)
        return std_logic_vector is
        variable s_vector : std_logic_vector(63 downto 0);
        variable halfByte : std_logic_vector(3 downto 0);
    begin
        s_vector := std_logic_vector(shift_left(unsigned(vector), 4*(part - 1)));
        
        halfByte := s_vector(63 downto 60);

        return std_logic_vector(halfByte);
    end;
begin
    busy <= '0' when state = state_idle else '1';

    adc_vector_1(63 downto 48) <= x"01AD";
    adc_vector_1(47 downto 36) <= ch0_data;
    adc_vector_1(35 downto 24) <= ch1_data;
    adc_vector_1(23 downto 12) <= ch2_data;
    adc_vector_1(11 downto 0) <= ch3_data;

    adc_vector_2(63 downto 48) <= x"02AD";
    adc_vector_2(47 downto 36) <= ch4_data;
    adc_vector_2(35 downto 24) <= ch5_data;
    adc_vector_2(23 downto 12) <= ch6_data;
    adc_vector_2(11 downto 0) <= ch7_data;

    adc_vector_3(63 downto 48) <= x"03AD";
    adc_vector_3(47 downto 36) <= ch8_data;
    adc_vector_3(35 downto 24) <= ch9_data;
    adc_vector_3(23 downto 12) <= ch10_data;
    adc_vector_3(11 downto 0) <= ch11_data;

    process (clk, reset)
    begin
        if reset /= '0' then
            send <= (others => '0');
            wen <= '0';

            state <= state_idle;
            prevState <= state_idle;
            subState <= 1;

        elsif rising_edge(clk) then
            if state /= state_send_wait then
                prevState <= state;
            end if;

            case state is
                when state_idle =>                  -- Idle state.
                    if enable then
                        subState <= 1;
                        state <= state_send_id;
                    end if;

                when state_send_id =>               -- Sending preamble, contains a # and an ID byte.
                    case subState is
                        when 1 =>   -- Send preamble.
                            if txrdy = '1' then
                                send <= x"23";     -- ASCII value: # - Indicates start of rotator message.
                                state <= state_send_wait;
                            end if;

                        when 2 =>   -- Send identifier.
                            if txrdy then
                                send <= gs_id;       -- Send an identifier so the ground station know what unit is sending.

                                state <= state_send_wait;
                            end if;
        
                        when 3 =>   -- Decide what to do next.
                                subState <= 1;
                                state <= state_send_statusbits;

                        when others => subState <= 1;
                            
                    end case;

                when state_send_wait =>      -- Send the current message and wait until the UART core has sampled the byte.
                    if txrdy = '0' then    -- The core has sampled our sent byte, go back to previous state.
                        wen <= '0';
                        subState <= subState + 1;
                        state <= prevState;
                    else
                        wen <= '1';
                    end if;

                when state_send_statusbits =>         -- Sending 64 status bits, 8 bytes.
                    if subState = 17 then
                        subState <= 1;
                        state <= state_send_adc_1;
                    
                    else         -- There are 16 substates here. Each substate processes and sends 4 bits of the status vector.                    
                        if txrdy then
                            send <= halfByteToAscii(getHalfByte(status_bits, subState));
                            state <= state_send_wait;
                        end if;

                    end if;

                when state_send_adc_1 =>                -- Send first ADC message, "01AD" and first four channels.
                    if subState = 17 then
                        subState <= 1;
                        state <= state_send_adc_2;
                    
                    else         -- There are 16 substates here. Each substate processes and sends 4 bits of the vector.                    
                        if txrdy then
                            send <= halfByteToAscii(getHalfByte(adc_vector_1, subState));
                            state <= state_send_wait;
                        end if;
                    end if;

                when state_send_adc_2 =>                -- Send first ADC message, "02AD" and next four channels.
                    if subState = 17 then
                        subState <= 1;
                        state <= state_send_adc_3;
                    
                    else         -- There are 16 substates here. Each substate processes and sends 4 bits of the vector.                    
                        if txrdy then
                            send <= halfByteToAscii(getHalfByte(adc_vector_2, subState));
                            state <= state_send_wait;
                        end if;

                    end if;

                when state_send_adc_3 =>                -- Send first ADC message, "03AD" and last four channels.
                    if subState = 17 then
                        subState <= 1;
                        state <= state_send_postamble;
                    
                    else         -- There are 16 substates here. Each substate processes and sends 4 bits of the vector.                    
                        if txrdy then
                            send <= halfByteToAscii(getHalfByte(adc_vector_3, subState));
                            state <= state_send_wait;
                        end if;

                    end if;

                when state_send_postamble =>          -- Sending postamble.
                    case subState is
                        when 1 =>   -- Send postamble byte (line break).
                            if txrdy then
                                send <= x"0A";     -- ASCII value: \n - Indicates end of rotator message.
                                state <= state_send_wait;
                            end if;

                        when 2 =>
                            state <= state_idle;

                    end case;

                when others => state <= state_idle;


            end case;
        end if;
    end process;

end architecture_GS_Readout;
