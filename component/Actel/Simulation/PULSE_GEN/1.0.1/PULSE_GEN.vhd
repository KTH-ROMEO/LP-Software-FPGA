library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity PULSE_GEN is
generic(PULSE_START_TIME : integer := 1000 ; PULSE_WIDTH : integer := 10 ; PULSE_TYPE : integer :=  1 );

port( PULSE : out std_logic
	);
end PULSE_GEN;

architecture behavior of PULSE_GEN is
	signal T1_time : time := 1 ns ;
	signal PULSE1 : std_logic := '0' ;
	signal PULSE2 : std_logic := '0' ;
begin
	
	process
	begin
		wait for (T1_time*PULSE_START_TIME) ;
		PULSE1 <= '1';
		wait for (T1_time*PULSE_WIDTH) ;
		PULSE1 <= '0';		
		wait;
	end process;
	
	process
	begin
		wait for (T1_time*PULSE_START_TIME);
		PULSE2 <= '1' ;
		wait for (T1_time*PULSE_WIDTH) ;
		PULSE2 <= '0' ;
	end process;	
	
	PULSE <= PULSE1 when PULSE_TYPE=0 else PULSE2 ;
	
end behavior;