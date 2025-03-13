-- Version: v11.9 SP6 11.9.6.7

library ieee;
use ieee.std_logic_1164.all;
library proasic3;
use proasic3.all;

entity SweepTable is

    port( WD    : in    std_logic_vector(15 downto 0);
          RD    : out   std_logic_vector(15 downto 0);
          WEN   : in    std_logic;
          REN   : in    std_logic;
          WADDR : in    std_logic_vector(7 downto 0);
          RADDR : in    std_logic_vector(7 downto 0);
          RWCLK : in    std_logic;
          RESET : in    std_logic
        );

end SweepTable;

architecture DEF_ARCH of SweepTable is 

  component INV
    port( A : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

  component RAM512X18
    generic (MEMORYFILE:string := "");

    port( RADDR8 : in    std_logic := 'U';
          RADDR7 : in    std_logic := 'U';
          RADDR6 : in    std_logic := 'U';
          RADDR5 : in    std_logic := 'U';
          RADDR4 : in    std_logic := 'U';
          RADDR3 : in    std_logic := 'U';
          RADDR2 : in    std_logic := 'U';
          RADDR1 : in    std_logic := 'U';
          RADDR0 : in    std_logic := 'U';
          WADDR8 : in    std_logic := 'U';
          WADDR7 : in    std_logic := 'U';
          WADDR6 : in    std_logic := 'U';
          WADDR5 : in    std_logic := 'U';
          WADDR4 : in    std_logic := 'U';
          WADDR3 : in    std_logic := 'U';
          WADDR2 : in    std_logic := 'U';
          WADDR1 : in    std_logic := 'U';
          WADDR0 : in    std_logic := 'U';
          WD17   : in    std_logic := 'U';
          WD16   : in    std_logic := 'U';
          WD15   : in    std_logic := 'U';
          WD14   : in    std_logic := 'U';
          WD13   : in    std_logic := 'U';
          WD12   : in    std_logic := 'U';
          WD11   : in    std_logic := 'U';
          WD10   : in    std_logic := 'U';
          WD9    : in    std_logic := 'U';
          WD8    : in    std_logic := 'U';
          WD7    : in    std_logic := 'U';
          WD6    : in    std_logic := 'U';
          WD5    : in    std_logic := 'U';
          WD4    : in    std_logic := 'U';
          WD3    : in    std_logic := 'U';
          WD2    : in    std_logic := 'U';
          WD1    : in    std_logic := 'U';
          WD0    : in    std_logic := 'U';
          RW0    : in    std_logic := 'U';
          RW1    : in    std_logic := 'U';
          WW0    : in    std_logic := 'U';
          WW1    : in    std_logic := 'U';
          PIPE   : in    std_logic := 'U';
          REN    : in    std_logic := 'U';
          WEN    : in    std_logic := 'U';
          RCLK   : in    std_logic := 'U';
          WCLK   : in    std_logic := 'U';
          RESET  : in    std_logic := 'U';
          RD17   : out   std_logic;
          RD16   : out   std_logic;
          RD15   : out   std_logic;
          RD14   : out   std_logic;
          RD13   : out   std_logic;
          RD12   : out   std_logic;
          RD11   : out   std_logic;
          RD10   : out   std_logic;
          RD9    : out   std_logic;
          RD8    : out   std_logic;
          RD7    : out   std_logic;
          RD6    : out   std_logic;
          RD5    : out   std_logic;
          RD4    : out   std_logic;
          RD3    : out   std_logic;
          RD2    : out   std_logic;
          RD1    : out   std_logic;
          RD0    : out   std_logic
        );
  end component;

  component GND
    port(Y : out std_logic); 
  end component;

  component VCC
    port(Y : out std_logic); 
  end component;

    signal WEAP, WEBP, RESETP, \VCC\, \GND\ : std_logic;
    signal GND_power_net1 : std_logic;
    signal VCC_power_net1 : std_logic;

begin 

    \GND\ <= GND_power_net1;
    \VCC\ <= VCC_power_net1;

    RESETBUBBLE : INV
      port map(A => RESET, Y => RESETP);
    
    WEBUBBLEB : INV
      port map(A => REN, Y => WEBP);
    
    WEBUBBLEA : INV
      port map(A => WEN, Y => WEAP);
    
    SweepTable_R0C0 : RAM512X18
      generic map(MEMORYFILE => "SweepTable_R0C0.mem")

      port map(RADDR8 => \GND\, RADDR7 => RADDR(7), RADDR6 => 
        RADDR(6), RADDR5 => RADDR(5), RADDR4 => RADDR(4), RADDR3
         => RADDR(3), RADDR2 => RADDR(2), RADDR1 => RADDR(1), 
        RADDR0 => RADDR(0), WADDR8 => \GND\, WADDR7 => WADDR(7), 
        WADDR6 => WADDR(6), WADDR5 => WADDR(5), WADDR4 => 
        WADDR(4), WADDR3 => WADDR(3), WADDR2 => WADDR(2), WADDR1
         => WADDR(1), WADDR0 => WADDR(0), WD17 => \GND\, WD16 => 
        WD(15), WD15 => WD(14), WD14 => WD(13), WD13 => WD(12), 
        WD12 => WD(11), WD11 => WD(10), WD10 => WD(9), WD9 => 
        WD(8), WD8 => \GND\, WD7 => WD(7), WD6 => WD(6), WD5 => 
        WD(5), WD4 => WD(4), WD3 => WD(3), WD2 => WD(2), WD1 => 
        WD(1), WD0 => WD(0), RW0 => \GND\, RW1 => \VCC\, WW0 => 
        \GND\, WW1 => \VCC\, PIPE => \VCC\, REN => WEBP, WEN => 
        WEAP, RCLK => RWCLK, WCLK => RWCLK, RESET => RESETP, RD17
         => OPEN, RD16 => RD(15), RD15 => RD(14), RD14 => RD(13), 
        RD13 => RD(12), RD12 => RD(11), RD11 => RD(10), RD10 => 
        RD(9), RD9 => RD(8), RD8 => OPEN, RD7 => RD(7), RD6 => 
        RD(6), RD5 => RD(5), RD4 => RD(4), RD3 => RD(3), RD2 => 
        RD(2), RD1 => RD(1), RD0 => RD(0));
    
    GND_power_inst1 : GND
      port map( Y => GND_power_net1);

    VCC_power_inst1 : VCC
      port map( Y => VCC_power_net1);


end DEF_ARCH; 

-- _Disclaimer: Please leave the following comments in the file, they are for internal purposes only._


-- _GEN_File_Contents_

-- Version:11.9.6.7
-- ACTGENU_CALL:1
-- BATCH:T
-- FAM:PA3LC
-- OUTFORMAT:VHDL
-- LPMTYPE:LPM_RAM
-- LPM_HINT:TWO
-- INSERT_PAD:NO
-- INSERT_IOREG:NO
-- GEN_BHV_VHDL_VAL:F
-- GEN_BHV_VERILOG_VAL:F
-- MGNTIMER:F
-- MGNCMPL:T
-- DESDIR:C:/Users/Jesus/Documents/KTH/ROMEO/test_vhdl/Master-Thesis-Code-FPGA/smartgen\SweepTable
-- GEN_BEHV_MODULE:F
-- SMARTGEN_DIE:IS4X4M1
-- SMARTGEN_PACKAGE:vq100
-- AGENIII_IS_SUBPROJECT_LIBERO:T
-- WWIDTH:16
-- WDEPTH:256
-- RWIDTH:16
-- RDEPTH:256
-- CLKS:1
-- CLOCK_PN:RWCLK
-- RESET_PN:RESET
-- RESET_POLARITY:1
-- INIT_RAM:T
-- DEFAULT_WORD:0x0000
-- CASCADE:0
-- WCLK_EDGE:RISE
-- PMODE2:1
-- DATA_IN_PN:WD
-- WADDRESS_PN:WADDR
-- WE_PN:WEN
-- DATA_OUT_PN:RD
-- RADDRESS_PN:RADDR
-- RE_PN:REN
-- WE_POLARITY:1
-- RE_POLARITY:1
-- PTYPE:1

-- _End_Comments_

