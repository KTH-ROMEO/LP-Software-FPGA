-- Version: v11.9 SP6 11.9.6.7

library ieee;
use ieee.std_logic_1164.all;
library proasic3;
use proasic3.all;

entity TableSelect is

    port( Data0_port : in    std_logic;
          Data1_port : in    std_logic;
          Sel0       : in    std_logic;
          Result     : out   std_logic
        );

end TableSelect;

architecture DEF_ARCH of TableSelect is 

  component MX2
    port( A : in    std_logic := 'U';
          B : in    std_logic := 'U';
          S : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;


begin 


    MX2_Result : MX2
      port map(A => Data0_port, B => Data1_port, S => Sel0, Y => 
        Result);
    

end DEF_ARCH; 

-- _Disclaimer: Please leave the following comments in the file, they are for internal purposes only._


-- _GEN_File_Contents_

-- Version:11.9.6.7
-- ACTGENU_CALL:1
-- BATCH:T
-- FAM:PA3LC
-- OUTFORMAT:VHDL
-- LPMTYPE:LPM_MUX
-- LPM_HINT:None
-- INSERT_PAD:NO
-- INSERT_IOREG:NO
-- GEN_BHV_VHDL_VAL:F
-- GEN_BHV_VERILOG_VAL:F
-- MGNTIMER:F
-- MGNCMPL:T
-- DESDIR:C:/Users/Jesus/Documents/KTH/ROMEO/test_vhdl/Master-Thesis-Code-FPGA/smartgen\TableSelect
-- GEN_BEHV_MODULE:F
-- SMARTGEN_DIE:IS4X4M1
-- SMARTGEN_PACKAGE:vq100
-- AGENIII_IS_SUBPROJECT_LIBERO:T
-- WIDTH:1
-- SIZE:2
-- SEL0_FANIN:AUTO
-- SEL0_VAL:6
-- SEL0_POLARITY:1
-- SEL1_FANIN:AUTO
-- SEL1_VAL:6
-- SEL1_POLARITY:2
-- SEL2_FANIN:AUTO
-- SEL2_VAL:6
-- SEL2_POLARITY:2
-- SEL3_FANIN:AUTO
-- SEL3_VAL:6
-- SEL3_POLARITY:2
-- SEL4_FANIN:AUTO
-- SEL4_VAL:6
-- SEL4_POLARITY:2

-- _End_Comments_

