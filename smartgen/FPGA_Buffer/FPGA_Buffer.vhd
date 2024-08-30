-- Version: v11.9 SP6 11.9.6.7

library ieee;
use ieee.std_logic_1164.all;
library proasic3;
use proasic3.all;

entity FPGA_Buffer is

    port( data_in  : in    std_logic_vector(31 downto 0);
          data_out : out   std_logic_vector(7 downto 0);
          we       : in    std_logic;
          re       : in    std_logic;
          w_clk    : in    std_logic;
          r_clk    : in    std_logic;
          full     : out   std_logic;
          empty    : out   std_logic;
          reset    : in    std_logic;
          afull    : out   std_logic
        );

end FPGA_Buffer;

architecture DEF_ARCH of FPGA_Buffer is 

  component XNOR3
    port( A : in    std_logic := 'U';
          B : in    std_logic := 'U';
          C : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

  component INV
    port( A : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

  component DFN1C0
    port( D   : in    std_logic := 'U';
          CLK : in    std_logic := 'U';
          CLR : in    std_logic := 'U';
          Q   : out   std_logic
        );
  end component;

  component AND2
    port( A : in    std_logic := 'U';
          B : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

  component AND3
    port( A : in    std_logic := 'U';
          B : in    std_logic := 'U';
          C : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

  component XNOR2
    port( A : in    std_logic := 'U';
          B : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

  component AO1
    port( A : in    std_logic := 'U';
          B : in    std_logic := 'U';
          C : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

  component XOR2
    port( A : in    std_logic := 'U';
          B : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

  component BUFF
    port( A : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

  component AO1C
    port( A : in    std_logic := 'U';
          B : in    std_logic := 'U';
          C : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

  component XOR3
    port( A : in    std_logic := 'U';
          B : in    std_logic := 'U';
          C : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

  component NOR3A
    port( A : in    std_logic := 'U';
          B : in    std_logic := 'U';
          C : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

  component OR2
    port( A : in    std_logic := 'U';
          B : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

  component RAM4K9
    generic (MEMORYFILE:string := "");

    port( ADDRA11 : in    std_logic := 'U';
          ADDRA10 : in    std_logic := 'U';
          ADDRA9  : in    std_logic := 'U';
          ADDRA8  : in    std_logic := 'U';
          ADDRA7  : in    std_logic := 'U';
          ADDRA6  : in    std_logic := 'U';
          ADDRA5  : in    std_logic := 'U';
          ADDRA4  : in    std_logic := 'U';
          ADDRA3  : in    std_logic := 'U';
          ADDRA2  : in    std_logic := 'U';
          ADDRA1  : in    std_logic := 'U';
          ADDRA0  : in    std_logic := 'U';
          ADDRB11 : in    std_logic := 'U';
          ADDRB10 : in    std_logic := 'U';
          ADDRB9  : in    std_logic := 'U';
          ADDRB8  : in    std_logic := 'U';
          ADDRB7  : in    std_logic := 'U';
          ADDRB6  : in    std_logic := 'U';
          ADDRB5  : in    std_logic := 'U';
          ADDRB4  : in    std_logic := 'U';
          ADDRB3  : in    std_logic := 'U';
          ADDRB2  : in    std_logic := 'U';
          ADDRB1  : in    std_logic := 'U';
          ADDRB0  : in    std_logic := 'U';
          DINA8   : in    std_logic := 'U';
          DINA7   : in    std_logic := 'U';
          DINA6   : in    std_logic := 'U';
          DINA5   : in    std_logic := 'U';
          DINA4   : in    std_logic := 'U';
          DINA3   : in    std_logic := 'U';
          DINA2   : in    std_logic := 'U';
          DINA1   : in    std_logic := 'U';
          DINA0   : in    std_logic := 'U';
          DINB8   : in    std_logic := 'U';
          DINB7   : in    std_logic := 'U';
          DINB6   : in    std_logic := 'U';
          DINB5   : in    std_logic := 'U';
          DINB4   : in    std_logic := 'U';
          DINB3   : in    std_logic := 'U';
          DINB2   : in    std_logic := 'U';
          DINB1   : in    std_logic := 'U';
          DINB0   : in    std_logic := 'U';
          WIDTHA0 : in    std_logic := 'U';
          WIDTHA1 : in    std_logic := 'U';
          WIDTHB0 : in    std_logic := 'U';
          WIDTHB1 : in    std_logic := 'U';
          PIPEA   : in    std_logic := 'U';
          PIPEB   : in    std_logic := 'U';
          WMODEA  : in    std_logic := 'U';
          WMODEB  : in    std_logic := 'U';
          BLKA    : in    std_logic := 'U';
          BLKB    : in    std_logic := 'U';
          WENA    : in    std_logic := 'U';
          WENB    : in    std_logic := 'U';
          CLKA    : in    std_logic := 'U';
          CLKB    : in    std_logic := 'U';
          RESET   : in    std_logic := 'U';
          DOUTA8  : out   std_logic;
          DOUTA7  : out   std_logic;
          DOUTA6  : out   std_logic;
          DOUTA5  : out   std_logic;
          DOUTA4  : out   std_logic;
          DOUTA3  : out   std_logic;
          DOUTA2  : out   std_logic;
          DOUTA1  : out   std_logic;
          DOUTA0  : out   std_logic;
          DOUTB8  : out   std_logic;
          DOUTB7  : out   std_logic;
          DOUTB6  : out   std_logic;
          DOUTB5  : out   std_logic;
          DOUTB4  : out   std_logic;
          DOUTB3  : out   std_logic;
          DOUTB2  : out   std_logic;
          DOUTB1  : out   std_logic;
          DOUTB0  : out   std_logic
        );
  end component;

  component DFN1E1C0
    port( D   : in    std_logic := 'U';
          CLK : in    std_logic := 'U';
          CLR : in    std_logic := 'U';
          E   : in    std_logic := 'U';
          Q   : out   std_logic
        );
  end component;

  component OR2A
    port( A : in    std_logic := 'U';
          B : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

  component NAND3A
    port( A : in    std_logic := 'U';
          B : in    std_logic := 'U';
          C : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

  component OR3
    port( A : in    std_logic := 'U';
          B : in    std_logic := 'U';
          C : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

  component NAND2
    port( A : in    std_logic := 'U';
          B : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

  component AND2A
    port( A : in    std_logic := 'U';
          B : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

  component AOI1
    port( A : in    std_logic := 'U';
          B : in    std_logic := 'U';
          C : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

  component DFN1P0
    port( D   : in    std_logic := 'U';
          CLK : in    std_logic := 'U';
          PRE : in    std_logic := 'U';
          Q   : out   std_logic
        );
  end component;

  component NOR2A
    port( A : in    std_logic := 'U';
          B : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

  component GND
    port(Y : out std_logic); 
  end component;

  component VCC
    port(Y : out std_logic); 
  end component;

    signal \full\, \empty\, RESET_POLA, READ_RESET_P, 
        WRITE_RESET_P, \MEM_RADDR[0]\, \MEM_RADDR[1]\, 
        \MEM_RADDR[2]\, \MEM_RADDR[3]\, \MEM_RADDR[4]\, 
        \MEM_RADDR[5]\, \MEM_RADDR[6]\, \MEM_RADDR[7]\, 
        \MEM_RADDR[8]\, \MEM_RADDR[9]\, \MEM_RADDR[10]\, 
        \RBINNXTSHIFT[0]\, \RBINNXTSHIFT[1]\, \RBINNXTSHIFT[2]\, 
        \RBINNXTSHIFT[3]\, \RBINNXTSHIFT[4]\, \RBINNXTSHIFT[5]\, 
        \RBINNXTSHIFT[6]\, \RBINNXTSHIFT[7]\, \RBINNXTSHIFT[8]\, 
        \RBINNXTSHIFT[9]\, \RBINNXTSHIFT[10]\, \WBINSYNC[0]\, 
        \WBINSYNC[1]\, \WBINSYNC[2]\, \WBINSYNC[3]\, 
        \WBINSYNC[4]\, \WBINSYNC[5]\, \WBINSYNC[6]\, 
        \WBINSYNC[7]\, READDOMAIN_WMSB, \MEM_WADDR[0]\, 
        \MEM_WADDR[1]\, \MEM_WADDR[2]\, \MEM_WADDR[3]\, 
        \MEM_WADDR[4]\, \MEM_WADDR[5]\, \MEM_WADDR[6]\, 
        \MEM_WADDR[7]\, \MEM_WADDR[8]\, \WBINNXTSHIFT[0]\, 
        \WBINNXTSHIFT[1]\, \WBINNXTSHIFT[2]\, \WBINNXTSHIFT[3]\, 
        \WBINNXTSHIFT[4]\, \WBINNXTSHIFT[5]\, \WBINNXTSHIFT[6]\, 
        \WBINNXTSHIFT[7]\, \WBINNXTSHIFT[8]\, \RBINSYNC[0]\, 
        \RBINSYNC[1]\, \RBINSYNC[2]\, \RBINSYNC[3]\, 
        \RBINSYNC[4]\, \RBINSYNC[5]\, \RBINSYNC[6]\, 
        \RBINSYNC[7]\, \RBINSYNC[8]\, \RBINSYNC[9]\, 
        \RBINSYNC[10]\, FULLINT, MEMORYWE, MEMWENEG, \WDIFF[0]\, 
        \WDIFF[1]\, \WDIFF[2]\, \WDIFF[3]\, \WDIFF[4]\, 
        \WDIFF[5]\, \WDIFF[6]\, \WDIFF[7]\, \WDIFF[8]\, 
        \AFVALCONST[0]\, \AFVALCONST[1]\, \WGRY[0]\, \WGRY[1]\, 
        \WGRY[2]\, \WGRY[3]\, \WGRY[4]\, \WGRY[5]\, \WGRY[6]\, 
        \WGRY[7]\, \WGRY[8]\, \RGRYSYNC[0]\, \RGRYSYNC[1]\, 
        \RGRYSYNC[2]\, \RGRYSYNC[3]\, \RGRYSYNC[4]\, 
        \RGRYSYNC[5]\, \RGRYSYNC[6]\, \RGRYSYNC[7]\, 
        \RGRYSYNC[8]\, \RGRYSYNC[9]\, \RGRYSYNC[10]\, EMPTYINT, 
        MEMORYRE, MEMRENEG, DVLDI, DVLDX, \RGRY[0]\, \RGRY[1]\, 
        \RGRY[2]\, \RGRY[3]\, \RGRY[4]\, \RGRY[5]\, \RGRY[6]\, 
        \RGRY[7]\, \RGRY[8]\, \RGRY[9]\, \RGRY[10]\, 
        \WGRYSYNC[0]\, \WGRYSYNC[1]\, \WGRYSYNC[2]\, 
        \WGRYSYNC[3]\, \WGRYSYNC[4]\, \WGRYSYNC[5]\, 
        \WGRYSYNC[6]\, \WGRYSYNC[7]\, \WGRYSYNC[8]\, \QXI[0]\, 
        \QXI[1]\, \QXI[2]\, \QXI[3]\, \QXI[4]\, \QXI[5]\, 
        \QXI[6]\, \QXI[7]\, DFN1C0_10_Q, DFN1C0_8_Q, DFN1C0_9_Q, 
        DFN1C0_20_Q, DFN1C0_4_Q, DFN1C0_18_Q, DFN1C0_15_Q, 
        DFN1C0_7_Q, DFN1C0_17_Q, XNOR3_0_Y, XNOR3_5_Y, XNOR3_20_Y, 
        XNOR3_6_Y, XNOR3_16_Y, XNOR3_22_Y, XOR3_1_Y, XNOR3_2_Y, 
        XNOR3_24_Y, XNOR3_18_Y, XNOR3_4_Y, XNOR3_10_Y, XOR3_2_Y, 
        XNOR3_1_Y, XNOR3_21_Y, XOR3_3_Y, XNOR3_12_Y, XNOR3_23_Y, 
        XOR3_4_Y, XNOR3_7_Y, XOR2_11_Y, XOR2_20_Y, XOR2_41_Y, 
        XOR2_43_Y, XOR2_63_Y, XOR2_69_Y, XOR2_56_Y, XOR2_16_Y, 
        XOR2_55_Y, XOR2_30_Y, XOR2_66_Y, AND2_34_Y, AND2_15_Y, 
        AND2_45_Y, AND2_3_Y, AND2_13_Y, AND2_1_Y, AND2_30_Y, 
        AND2_20_Y, AND2_32_Y, AND2_23_Y, XOR2_57_Y, XOR2_3_Y, 
        XOR2_6_Y, XOR2_1_Y, XOR2_7_Y, XOR2_22_Y, XOR2_52_Y, 
        XOR2_2_Y, XOR2_13_Y, XOR2_64_Y, XOR2_50_Y, AND2_7_Y, 
        AO1_32_Y, AND2_19_Y, AO1_10_Y, AND2_17_Y, AO1_38_Y, 
        AND2_51_Y, AO1_34_Y, AND2_18_Y, AND2_31_Y, AO1_9_Y, 
        AND2_47_Y, AND2_41_Y, AND2_57_Y, AND2_2_Y, AND2_54_Y, 
        AND2_0_Y, AND2_66_Y, AND2_36_Y, AO1_15_Y, AND2_68_Y, 
        AND2_61_Y, AO1_17_Y, AO1_36_Y, AO1_18_Y, AO1_5_Y, AO1_0_Y, 
        AO1_19_Y, AO1_35_Y, AO1_26_Y, AO1_22_Y, XOR2_70_Y, 
        XOR2_35_Y, XOR2_33_Y, XOR2_51_Y, XOR2_71_Y, XOR2_19_Y, 
        XOR2_67_Y, XOR2_62_Y, XOR2_72_Y, XOR2_5_Y, NAND2_1_Y, 
        XOR2_29_Y, XOR2_25_Y, XOR2_15_Y, XOR2_54_Y, XOR2_47_Y, 
        XOR2_26_Y, XOR2_37_Y, XOR2_44_Y, XOR2_46_Y, AND2_44_Y, 
        AND2_8_Y, AND2_4_Y, AND2_48_Y, AND2_9_Y, AND2_50_Y, 
        AND2_12_Y, AND2_55_Y, XOR2_34_Y, XOR2_28_Y, XOR2_14_Y, 
        XOR2_65_Y, XOR2_61_Y, XOR2_58_Y, XOR2_0_Y, XOR2_48_Y, 
        XOR2_17_Y, AND2_65_Y, AO1_24_Y, AND2_58_Y, AO1_6_Y, 
        AND2_16_Y, AO1_7_Y, AND2_10_Y, AND2_53_Y, AO1_37_Y, 
        AND2_52_Y, AND2_56_Y, AND2_43_Y, AND2_5_Y, AND2_11_Y, 
        AND2_26_Y, AO1_11_Y, AND2_22_Y, AND2_24_Y, AO1_1_Y, 
        AO1_30_Y, AO1_20_Y, AO1_8_Y, AO1_25_Y, AO1_16_Y, AO1_27_Y, 
        XOR2_60_Y, XOR2_23_Y, XOR2_49_Y, XOR2_10_Y, XOR2_68_Y, 
        XOR2_73_Y, XOR2_39_Y, XOR2_59_Y, XNOR3_11_Y, XNOR3_3_Y, 
        XNOR3_25_Y, XNOR3_8_Y, XNOR3_17_Y, XNOR3_15_Y, XNOR3_9_Y, 
        XNOR3_19_Y, XNOR3_13_Y, XOR3_0_Y, XNOR3_14_Y, XOR3_5_Y, 
        DFN1C0_21_Q, DFN1C0_0_Q, DFN1C0_5_Q, DFN1C0_14_Q, 
        DFN1C0_3_Q, DFN1C0_11_Q, DFN1C0_16_Q, DFN1C0_13_Q, 
        DFN1C0_19_Q, DFN1C0_1_Q, DFN1C0_6_Q, 
        \RAM4K9_QXI[1]_DOUTA0\, \RAM4K9_QXI[1]_DOUTA1\, 
        \RAM4K9_QXI[3]_DOUTA0\, \RAM4K9_QXI[3]_DOUTA1\, 
        \RAM4K9_QXI[5]_DOUTA0\, \RAM4K9_QXI[5]_DOUTA1\, 
        \RAM4K9_QXI[7]_DOUTA0\, \RAM4K9_QXI[7]_DOUTA1\, 
        \RAM4K9_QXI[1]_DOUTA2\, \RAM4K9_QXI[1]_DOUTA3\, 
        \RAM4K9_QXI[3]_DOUTA2\, \RAM4K9_QXI[3]_DOUTA3\, 
        \RAM4K9_QXI[5]_DOUTA2\, \RAM4K9_QXI[5]_DOUTA3\, 
        \RAM4K9_QXI[7]_DOUTA2\, \RAM4K9_QXI[7]_DOUTA3\, 
        \RAM4K9_QXI[1]_DOUTA4\, \RAM4K9_QXI[1]_DOUTA5\, 
        \RAM4K9_QXI[3]_DOUTA4\, \RAM4K9_QXI[3]_DOUTA5\, 
        \RAM4K9_QXI[5]_DOUTA4\, \RAM4K9_QXI[5]_DOUTA5\, 
        \RAM4K9_QXI[7]_DOUTA4\, \RAM4K9_QXI[7]_DOUTA5\, 
        \RAM4K9_QXI[1]_DOUTA6\, \RAM4K9_QXI[1]_DOUTA7\, 
        \RAM4K9_QXI[3]_DOUTA6\, \RAM4K9_QXI[3]_DOUTA7\, 
        \RAM4K9_QXI[5]_DOUTA6\, \RAM4K9_QXI[5]_DOUTA7\, 
        \RAM4K9_QXI[7]_DOUTA6\, \RAM4K9_QXI[7]_DOUTA7\, AND3_7_Y, 
        XNOR2_19_Y, XNOR2_8_Y, XNOR2_4_Y, XNOR2_10_Y, XNOR2_11_Y, 
        XNOR2_20_Y, XNOR2_7_Y, XNOR2_15_Y, XNOR2_17_Y, AND3_6_Y, 
        AND2_63_Y, AND3_5_Y, DFN1C0_12_Q, NOR2A_0_Y, INV_2_Y, 
        INV_8_Y, INV_4_Y, INV_1_Y, INV_0_Y, INV_6_Y, INV_7_Y, 
        INV_3_Y, INV_5_Y, AND2_46_Y, AND2_40_Y, AND2_6_Y, 
        AND2_69_Y, AND2_25_Y, AND2_64_Y, AND2_67_Y, AND2_21_Y, 
        AND2_14_Y, AND2_62_Y, XOR2_8_Y, XOR2_9_Y, XOR2_4_Y, 
        XOR2_45_Y, XOR2_18_Y, XOR2_36_Y, XOR2_31_Y, XOR2_74_Y, 
        AND2_42_Y, AO1_4_Y, AND2_27_Y, AO1_3_Y, AND2_59_Y, 
        AO1_13_Y, AND2_37_Y, AND2_33_Y, AO1_23_Y, AND2_60_Y, 
        AO1_33_Y, AND2_35_Y, AND2_49_Y, AND2_39_Y, AND2_29_Y, 
        AND2_38_Y, OR3_0_Y, AO1_14_Y, AO1_28_Y, AO1_31_Y, 
        AO1_12_Y, AO1_2_Y, AO1_29_Y, XOR2_12_Y, XOR2_32_Y, 
        XOR2_21_Y, XOR2_24_Y, XOR2_53_Y, XOR2_38_Y, XOR2_42_Y, 
        XOR2_27_Y, AND2A_0_Y, DFN1C0_2_Q, AND3_1_Y, XOR2_40_Y, 
        XNOR2_1_Y, XNOR2_14_Y, XNOR2_18_Y, XNOR2_16_Y, XNOR2_0_Y, 
        XNOR2_3_Y, XNOR2_12_Y, XNOR2_5_Y, AND3_3_Y, AND2_28_Y, 
        AND3_2_Y, NAND2_0_Y, AOI1_0_Y, OR2_0_Y, AND3_0_Y, 
        NAND3A_4_Y, AO1_21_Y, AND3_4_Y, NAND3A_3_Y, NAND3A_5_Y, 
        OR2A_4_Y, AO1C_0_Y, NOR3A_2_Y, OR2A_3_Y, NAND3A_2_Y, 
        OR2A_1_Y, AO1C_1_Y, NOR3A_1_Y, OR2A_5_Y, NAND3A_1_Y, 
        XNOR2_22_Y, XNOR2_21_Y, XNOR2_6_Y, OR2A_0_Y, AO1C_2_Y, 
        NOR3A_0_Y, OR2A_2_Y, NAND3A_0_Y, XNOR2_9_Y, XNOR2_2_Y, 
        XNOR2_13_Y, \VCC\, \GND\ : std_logic;
    signal GND_power_net1 : std_logic;
    signal VCC_power_net1 : std_logic;

begin 

    full <= \full\;
    empty <= \empty\;
    \AFVALCONST[1]\ <= GND_power_net1;
    \GND\ <= GND_power_net1;
    \VCC\ <= VCC_power_net1;
    \AFVALCONST[0]\ <= VCC_power_net1;

    XNOR3_14 : XNOR3
      port map(A => \WGRYSYNC[5]\, B => \WGRYSYNC[4]\, C => 
        \WGRYSYNC[3]\, Y => XNOR3_14_Y);
    
    INV_0 : INV
      port map(A => \RBINSYNC[7]\, Y => INV_0_Y);
    
    XNOR3_5 : XNOR3
      port map(A => \RGRYSYNC[10]\, B => \RGRYSYNC[9]\, C => 
        \RGRYSYNC[8]\, Y => XNOR3_5_Y);
    
    \DFN1C0_RGRYSYNC[4]\ : DFN1C0
      port map(D => DFN1C0_3_Q, CLK => w_clk, CLR => 
        WRITE_RESET_P, Q => \RGRYSYNC[4]\);
    
    AND2_2 : AND2
      port map(A => AND2_41_Y, B => AND2_18_Y, Y => AND2_2_Y);
    
    AND3_6 : AND3
      port map(A => XNOR2_8_Y, B => XNOR2_4_Y, C => XNOR2_10_Y, Y
         => AND3_6_Y);
    
    AND2_20 : AND2
      port map(A => \MEM_RADDR[8]\, B => \GND\, Y => AND2_20_Y);
    
    XNOR2_13 : XNOR2
      port map(A => \AFVALCONST[1]\, B => \WDIFF[8]\, Y => 
        XNOR2_13_Y);
    
    AO1_11 : AO1
      port map(A => XOR2_17_Y, B => AO1_27_Y, C => AND2_55_Y, Y
         => AO1_11_Y);
    
    AND2_11 : AND2
      port map(A => AND2_53_Y, B => XOR2_61_Y, Y => AND2_11_Y);
    
    \XOR2_WBINNXTSHIFT[2]\ : XOR2
      port map(A => XOR2_23_Y, B => AO1_1_Y, Y => 
        \WBINNXTSHIFT[2]\);
    
    XNOR3_25 : XNOR3
      port map(A => \WGRYSYNC[5]\, B => \WGRYSYNC[4]\, C => 
        \WGRYSYNC[3]\, Y => XNOR3_25_Y);
    
    AND2_22 : AND2
      port map(A => AND2_56_Y, B => XOR2_17_Y, Y => AND2_22_Y);
    
    \DFN1C0_RGRY[9]\ : DFN1C0
      port map(D => XOR2_30_Y, CLK => r_clk, CLR => READ_RESET_P, 
        Q => \RGRY[9]\);
    
    DFN1C0_full : DFN1C0
      port map(D => FULLINT, CLK => w_clk, CLR => WRITE_RESET_P, 
        Q => \full\);
    
    XNOR2_9 : XNOR2
      port map(A => \AFVALCONST[1]\, B => \WDIFF[6]\, Y => 
        XNOR2_9_Y);
    
    DFN1C0_17 : DFN1C0
      port map(D => \WGRY[8]\, CLK => r_clk, CLR => READ_RESET_P, 
        Q => DFN1C0_17_Q);
    
    XOR2_19 : XOR2
      port map(A => \MEM_RADDR[6]\, B => \GND\, Y => XOR2_19_Y);
    
    AND2_44 : AND2
      port map(A => \MEM_WADDR[1]\, B => \GND\, Y => AND2_44_Y);
    
    AO1_31 : AO1
      port map(A => AND2_27_Y, B => AO1_14_Y, C => AO1_4_Y, Y => 
        AO1_31_Y);
    
    XOR2_23 : XOR2
      port map(A => \MEM_WADDR[2]\, B => \GND\, Y => XOR2_23_Y);
    
    XOR2_1 : XOR2
      port map(A => \MEM_RADDR[3]\, B => \GND\, Y => XOR2_1_Y);
    
    XNOR3_13 : XNOR3
      port map(A => \WGRYSYNC[5]\, B => \WGRYSYNC[4]\, C => 
        \WGRYSYNC[3]\, Y => XNOR3_13_Y);
    
    \XNOR2_WBINSYNC[5]\ : XNOR2
      port map(A => \WGRYSYNC[5]\, B => XNOR3_11_Y, Y => 
        \WBINSYNC[5]\);
    
    \DFN1C0_RGRYSYNC[3]\ : DFN1C0
      port map(D => DFN1C0_14_Q, CLK => w_clk, CLR => 
        WRITE_RESET_P, Q => \RGRYSYNC[3]\);
    
    INV_1 : INV
      port map(A => \RBINSYNC[6]\, Y => INV_1_Y);
    
    XOR2_47 : XOR2
      port map(A => \WBINNXTSHIFT[4]\, B => \WBINNXTSHIFT[5]\, Y
         => XOR2_47_Y);
    
    XOR2_38 : XOR2
      port map(A => \WBINNXTSHIFT[6]\, B => INV_6_Y, Y => 
        XOR2_38_Y);
    
    BUFF_READDOMAIN_WMSB : BUFF
      port map(A => \WGRYSYNC[8]\, Y => READDOMAIN_WMSB);
    
    \XOR2_RBINNXTSHIFT[0]\ : XOR2
      port map(A => \MEM_RADDR[0]\, B => MEMORYRE, Y => 
        \RBINNXTSHIFT[0]\);
    
    AO1C_1 : AO1C
      port map(A => \AFVALCONST[1]\, B => \WDIFF[4]\, C => 
        \AFVALCONST[1]\, Y => AO1C_1_Y);
    
    AO1_7 : AO1
      port map(A => XOR2_48_Y, B => AND2_50_Y, C => AND2_12_Y, Y
         => AO1_7_Y);
    
    DFN1C0_9 : DFN1C0
      port map(D => \WGRY[2]\, CLK => r_clk, CLR => READ_RESET_P, 
        Q => DFN1C0_9_Q);
    
    \DFN1C0_WGRY[6]\ : DFN1C0
      port map(D => XOR2_37_Y, CLK => w_clk, CLR => WRITE_RESET_P, 
        Q => \WGRY[6]\);
    
    AND2_18 : AND2
      port map(A => XOR2_13_Y, B => XOR2_64_Y, Y => AND2_18_Y);
    
    AND2_15 : AND2
      port map(A => \MEM_RADDR[2]\, B => \GND\, Y => AND2_15_Y);
    
    INV_7 : INV
      port map(A => \RBINSYNC[9]\, Y => INV_7_Y);
    
    AO1_25 : AO1
      port map(A => AND2_16_Y, B => AO1_20_Y, C => AO1_6_Y, Y => 
        AO1_25_Y);
    
    DFN1C0_WRITE_RESET_P : DFN1C0
      port map(D => DFN1C0_12_Q, CLK => w_clk, CLR => RESET_POLA, 
        Q => WRITE_RESET_P);
    
    XOR2_45 : XOR2
      port map(A => \WBINNXTSHIFT[4]\, B => INV_1_Y, Y => 
        XOR2_45_Y);
    
    \DFN1C0_RGRYSYNC[7]\ : DFN1C0
      port map(D => DFN1C0_13_Q, CLK => w_clk, CLR => 
        WRITE_RESET_P, Q => \RGRYSYNC[7]\);
    
    \XOR2_RBINNXTSHIFT[9]\ : XOR2
      port map(A => XOR2_72_Y, B => AO1_26_Y, Y => 
        \RBINNXTSHIFT[9]\);
    
    DFN1C0_11 : DFN1C0
      port map(D => \RGRY[5]\, CLK => w_clk, CLR => WRITE_RESET_P, 
        Q => DFN1C0_11_Q);
    
    DFN1C0_0 : DFN1C0
      port map(D => \RGRY[1]\, CLK => w_clk, CLR => WRITE_RESET_P, 
        Q => DFN1C0_0_Q);
    
    AND2_1 : AND2
      port map(A => \MEM_RADDR[6]\, B => \GND\, Y => AND2_1_Y);
    
    \DFN1C0_MEM_WADDR[0]\ : DFN1C0
      port map(D => \WBINNXTSHIFT[0]\, CLK => w_clk, CLR => 
        WRITE_RESET_P, Q => \MEM_WADDR[0]\);
    
    \XNOR3_RBINSYNC[6]\ : XNOR3
      port map(A => \RGRYSYNC[7]\, B => \RGRYSYNC[6]\, C => 
        XNOR3_6_Y, Y => \RBINSYNC[6]\);
    
    XNOR2_21 : XNOR2
      port map(A => \WDIFF[4]\, B => \AFVALCONST[1]\, Y => 
        XNOR2_21_Y);
    
    AND2_49 : AND2
      port map(A => AND2_33_Y, B => AND2_59_Y, Y => AND2_49_Y);
    
    \DFN1C0_MEM_WADDR[3]\ : DFN1C0
      port map(D => \WBINNXTSHIFT[3]\, CLK => w_clk, CLR => 
        WRITE_RESET_P, Q => \MEM_WADDR[3]\);
    
    \DFN1C0_MEM_RADDR[1]\ : DFN1C0
      port map(D => \RBINNXTSHIFT[1]\, CLK => r_clk, CLR => 
        READ_RESET_P, Q => \MEM_RADDR[1]\);
    
    AO1_8 : AO1
      port map(A => XOR2_61_Y, B => AO1_20_Y, C => AND2_48_Y, Y
         => AO1_8_Y);
    
    DFN1C0_20 : DFN1C0
      port map(D => \WGRY[3]\, CLK => r_clk, CLR => READ_RESET_P, 
        Q => DFN1C0_20_Q);
    
    AND2_10 : AND2
      port map(A => XOR2_0_Y, B => XOR2_48_Y, Y => AND2_10_Y);
    
    \DFN1C0_RGRYSYNC[6]\ : DFN1C0
      port map(D => DFN1C0_16_Q, CLK => w_clk, CLR => 
        WRITE_RESET_P, Q => \RGRYSYNC[6]\);
    
    XOR2_20 : XOR2
      port map(A => \RBINNXTSHIFT[1]\, B => \RBINNXTSHIFT[2]\, Y
         => XOR2_20_Y);
    
    AND2_7 : AND2
      port map(A => XOR2_57_Y, B => XOR2_3_Y, Y => AND2_7_Y);
    
    XOR2_63 : XOR2
      port map(A => \RBINNXTSHIFT[4]\, B => \RBINNXTSHIFT[5]\, Y
         => XOR2_63_Y);
    
    \XOR3_RBINSYNC[8]\ : XOR3
      port map(A => \RGRYSYNC[10]\, B => \RGRYSYNC[9]\, C => 
        \RGRYSYNC[8]\, Y => \RBINSYNC[8]\);
    
    AND2_12 : AND2
      port map(A => \MEM_WADDR[7]\, B => \GND\, Y => AND2_12_Y);
    
    \DFN1C0_WGRY[5]\ : DFN1C0
      port map(D => XOR2_26_Y, CLK => w_clk, CLR => WRITE_RESET_P, 
        Q => \WGRY[5]\);
    
    XOR2_52 : XOR2
      port map(A => \MEM_RADDR[6]\, B => \GND\, Y => XOR2_52_Y);
    
    \XNOR3_WBINSYNC[4]\ : XNOR3
      port map(A => \WGRYSYNC[5]\, B => \WGRYSYNC[4]\, C => 
        XNOR3_3_Y, Y => \WBINSYNC[4]\);
    
    AND2_61 : AND2
      port map(A => \MEM_RADDR[0]\, B => MEMORYRE, Y => AND2_61_Y);
    
    \DFN1C0_MEM_WADDR[4]\ : DFN1C0
      port map(D => \WBINNXTSHIFT[4]\, CLK => w_clk, CLR => 
        WRITE_RESET_P, Q => \MEM_WADDR[4]\);
    
    \XOR2_WBINNXTSHIFT[0]\ : XOR2
      port map(A => \MEM_WADDR[0]\, B => MEMORYWE, Y => 
        \WBINNXTSHIFT[0]\);
    
    AO1_15 : AO1
      port map(A => XOR2_50_Y, B => AO1_22_Y, C => AND2_23_Y, Y
         => AO1_15_Y);
    
    \DFN1C0_WGRY[7]\ : DFN1C0
      port map(D => XOR2_44_Y, CLK => w_clk, CLR => WRITE_RESET_P, 
        Q => \WGRY[7]\);
    
    \XOR2_RBINSYNC[9]\ : XOR2
      port map(A => \RGRYSYNC[10]\, B => \RGRYSYNC[9]\, Y => 
        \RBINSYNC[9]\);
    
    DFN1C0_READ_RESET_P : DFN1C0
      port map(D => DFN1C0_2_Q, CLK => r_clk, CLR => RESET_POLA, 
        Q => READ_RESET_P);
    
    AND2_EMPTYINT : AND2
      port map(A => AND3_7_Y, B => XNOR2_19_Y, Y => EMPTYINT);
    
    XOR2_24 : XOR2
      port map(A => \WBINNXTSHIFT[4]\, B => INV_1_Y, Y => 
        XOR2_24_Y);
    
    AND2_57 : AND2
      port map(A => AND2_31_Y, B => AND2_17_Y, Y => AND2_57_Y);
    
    XNOR3_20 : XNOR3
      port map(A => \RGRYSYNC[4]\, B => \RGRYSYNC[3]\, C => 
        XNOR3_5_Y, Y => XNOR3_20_Y);
    
    XOR2_21 : XOR2
      port map(A => \WBINNXTSHIFT[3]\, B => INV_4_Y, Y => 
        XOR2_21_Y);
    
    NOR3A_2 : NOR3A
      port map(A => OR2A_4_Y, B => AO1C_0_Y, C => \WDIFF[0]\, Y
         => NOR3A_2_Y);
    
    AO1_35 : AO1
      port map(A => AND2_47_Y, B => AO1_18_Y, C => AO1_9_Y, Y => 
        AO1_35_Y);
    
    \XOR2_WDIFF[5]\ : XOR2
      port map(A => XOR2_53_Y, B => AO1_31_Y, Y => \WDIFF[5]\);
    
    AND2_46 : AND2
      port map(A => \WBINNXTSHIFT[1]\, B => INV_2_Y, Y => 
        AND2_46_Y);
    
    \XOR2_RBINNXTSHIFT[8]\ : XOR2
      port map(A => XOR2_62_Y, B => AO1_35_Y, Y => 
        \RBINNXTSHIFT[8]\);
    
    XNOR3_9 : XNOR3
      port map(A => \WGRYSYNC[8]\, B => \WGRYSYNC[7]\, C => 
        \WGRYSYNC[6]\, Y => XNOR3_9_Y);
    
    XNOR3_8 : XNOR3
      port map(A => \WGRYSYNC[2]\, B => \WGRYSYNC[1]\, C => 
        \WGRYSYNC[0]\, Y => XNOR3_8_Y);
    
    XOR2_16 : XOR2
      port map(A => \RBINNXTSHIFT[7]\, B => \RBINNXTSHIFT[8]\, Y
         => XOR2_16_Y);
    
    DFN1C0_4 : DFN1C0
      port map(D => \WGRY[4]\, CLK => r_clk, CLR => READ_RESET_P, 
        Q => DFN1C0_4_Q);
    
    XOR2_60 : XOR2
      port map(A => \MEM_WADDR[1]\, B => \GND\, Y => XOR2_60_Y);
    
    DFN1C0_14 : DFN1C0
      port map(D => \RGRY[3]\, CLK => w_clk, CLR => WRITE_RESET_P, 
        Q => DFN1C0_14_Q);
    
    AND2_68 : AND2
      port map(A => AND2_2_Y, B => XOR2_50_Y, Y => AND2_68_Y);
    
    AND2_65 : AND2
      port map(A => XOR2_34_Y, B => XOR2_28_Y, Y => AND2_65_Y);
    
    AND2_43 : AND2
      port map(A => AND2_53_Y, B => AND2_16_Y, Y => AND2_43_Y);
    
    AO1_24 : AO1
      port map(A => XOR2_65_Y, B => AND2_8_Y, C => AND2_4_Y, Y
         => AO1_24_Y);
    
    AND3_3 : AND3
      port map(A => XNOR2_1_Y, B => XNOR2_14_Y, C => XNOR2_18_Y, 
        Y => AND3_3_Y);
    
    INV_5 : INV
      port map(A => NOR2A_0_Y, Y => INV_5_Y);
    
    OR2_0 : OR2
      port map(A => AOI1_0_Y, B => \full\, Y => OR2_0_Y);
    
    MEMWEBUBBLE : INV
      port map(A => MEMORYWE, Y => MEMWENEG);
    
    AND2_6 : AND2
      port map(A => INV_2_Y, B => INV_5_Y, Y => AND2_6_Y);
    
    XOR2_64 : XOR2
      port map(A => \MEM_RADDR[9]\, B => \GND\, Y => XOR2_64_Y);
    
    AND3_0 : AND3
      port map(A => XNOR2_9_Y, B => XNOR2_2_Y, C => XNOR2_13_Y, Y
         => AND3_0_Y);
    
    \RAM4K9_QXI[1]\ : RAM4K9
      port map(ADDRA11 => \GND\, ADDRA10 => \GND\, ADDRA9 => 
        \GND\, ADDRA8 => \GND\, ADDRA7 => \MEM_WADDR[7]\, ADDRA6
         => \MEM_WADDR[6]\, ADDRA5 => \MEM_WADDR[5]\, ADDRA4 => 
        \MEM_WADDR[4]\, ADDRA3 => \MEM_WADDR[3]\, ADDRA2 => 
        \MEM_WADDR[2]\, ADDRA1 => \MEM_WADDR[1]\, ADDRA0 => 
        \MEM_WADDR[0]\, ADDRB11 => \GND\, ADDRB10 => \GND\, 
        ADDRB9 => \MEM_RADDR[9]\, ADDRB8 => \MEM_RADDR[8]\, 
        ADDRB7 => \MEM_RADDR[7]\, ADDRB6 => \MEM_RADDR[6]\, 
        ADDRB5 => \MEM_RADDR[5]\, ADDRB4 => \MEM_RADDR[4]\, 
        ADDRB3 => \MEM_RADDR[3]\, ADDRB2 => \MEM_RADDR[2]\, 
        ADDRB1 => \MEM_RADDR[1]\, ADDRB0 => \MEM_RADDR[0]\, DINA8
         => \GND\, DINA7 => data_in(25), DINA6 => data_in(24), 
        DINA5 => data_in(17), DINA4 => data_in(16), DINA3 => 
        data_in(9), DINA2 => data_in(8), DINA1 => data_in(1), 
        DINA0 => data_in(0), DINB8 => \GND\, DINB7 => \GND\, 
        DINB6 => \GND\, DINB5 => \GND\, DINB4 => \GND\, DINB3 => 
        \GND\, DINB2 => \GND\, DINB1 => \GND\, DINB0 => \GND\, 
        WIDTHA0 => \VCC\, WIDTHA1 => \VCC\, WIDTHB0 => \VCC\, 
        WIDTHB1 => \GND\, PIPEA => \GND\, PIPEB => \GND\, WMODEA
         => \GND\, WMODEB => \GND\, BLKA => MEMWENEG, BLKB => 
        MEMRENEG, WENA => \GND\, WENB => \VCC\, CLKA => w_clk, 
        CLKB => r_clk, RESET => WRITE_RESET_P, DOUTA8 => OPEN, 
        DOUTA7 => \RAM4K9_QXI[1]_DOUTA7\, DOUTA6 => 
        \RAM4K9_QXI[1]_DOUTA6\, DOUTA5 => \RAM4K9_QXI[1]_DOUTA5\, 
        DOUTA4 => \RAM4K9_QXI[1]_DOUTA4\, DOUTA3 => 
        \RAM4K9_QXI[1]_DOUTA3\, DOUTA2 => \RAM4K9_QXI[1]_DOUTA2\, 
        DOUTA1 => \RAM4K9_QXI[1]_DOUTA1\, DOUTA0 => 
        \RAM4K9_QXI[1]_DOUTA0\, DOUTB8 => OPEN, DOUTB7 => OPEN, 
        DOUTB6 => OPEN, DOUTB5 => OPEN, DOUTB4 => OPEN, DOUTB3
         => OPEN, DOUTB2 => OPEN, DOUTB1 => \QXI[1]\, DOUTB0 => 
        \QXI[0]\);
    
    \DFN1C0_MEM_RADDR[2]\ : DFN1C0
      port map(D => \RBINNXTSHIFT[2]\, CLK => r_clk, CLR => 
        READ_RESET_P, Q => \MEM_RADDR[2]\);
    
    AND2_60 : AND2
      port map(A => AND2_59_Y, B => AND2_37_Y, Y => AND2_60_Y);
    
    \DFN1E1C0_data_out[0]\ : DFN1E1C0
      port map(D => \QXI[0]\, CLK => r_clk, CLR => READ_RESET_P, 
        E => DVLDI, Q => data_out(0));
    
    XOR2_61 : XOR2
      port map(A => \MEM_WADDR[4]\, B => \GND\, Y => XOR2_61_Y);
    
    OR2A_4 : OR2A
      port map(A => \WDIFF[2]\, B => \AFVALCONST[1]\, Y => 
        OR2A_4_Y);
    
    XOR2_57 : XOR2
      port map(A => \MEM_RADDR[0]\, B => MEMORYRE, Y => XOR2_57_Y);
    
    \XNOR3_WBINSYNC[2]\ : XNOR3
      port map(A => \WGRYSYNC[2]\, B => XOR3_5_Y, C => XNOR3_14_Y, 
        Y => \WBINSYNC[2]\);
    
    \DFN1C0_RGRY[2]\ : DFN1C0
      port map(D => XOR2_41_Y, CLK => r_clk, CLR => READ_RESET_P, 
        Q => \RGRY[2]\);
    
    AND2_62 : AND2
      port map(A => \WBINNXTSHIFT[8]\, B => INV_3_Y, Y => 
        AND2_62_Y);
    
    XOR2_33 : XOR2
      port map(A => \MEM_RADDR[3]\, B => \GND\, Y => XOR2_33_Y);
    
    INV_3 : INV
      port map(A => \RBINSYNC[10]\, Y => INV_3_Y);
    
    XNOR2_2 : XNOR2
      port map(A => \AFVALCONST[0]\, B => \WDIFF[7]\, Y => 
        XNOR2_2_Y);
    
    \XOR2_WBINNXTSHIFT[8]\ : XOR2
      port map(A => XOR2_59_Y, B => AO1_27_Y, Y => 
        \WBINNXTSHIFT[8]\);
    
    XNOR2_19 : XNOR2
      port map(A => \RBINNXTSHIFT[10]\, B => READDOMAIN_WMSB, Y
         => XNOR2_19_Y);
    
    XOR2_49 : XOR2
      port map(A => \MEM_WADDR[3]\, B => \GND\, Y => XOR2_49_Y);
    
    AO1_14 : AO1
      port map(A => XOR2_9_Y, B => OR3_0_Y, C => AND2_69_Y, Y => 
        AO1_14_Y);
    
    XOR2_4 : XOR2
      port map(A => \WBINNXTSHIFT[3]\, B => INV_4_Y, Y => 
        XOR2_4_Y);
    
    \XOR2_WDIFF[0]\ : XOR2
      port map(A => \WBINNXTSHIFT[0]\, B => \RBINSYNC[2]\, Y => 
        \WDIFF[0]\);
    
    AND3_1 : AND3
      port map(A => AND2_28_Y, B => AND3_3_Y, C => AND3_2_Y, Y
         => AND3_1_Y);
    
    \DFN1E1C0_data_out[7]\ : DFN1E1C0
      port map(D => \QXI[7]\, CLK => r_clk, CLR => READ_RESET_P, 
        E => DVLDI, Q => data_out(7));
    
    XOR2_55 : XOR2
      port map(A => \RBINNXTSHIFT[8]\, B => \RBINNXTSHIFT[9]\, Y
         => XOR2_55_Y);
    
    AND2_24 : AND2
      port map(A => \MEM_WADDR[0]\, B => MEMORYWE, Y => AND2_24_Y);
    
    \DFN1E1C0_data_out[5]\ : DFN1E1C0
      port map(D => \QXI[5]\, CLK => r_clk, CLR => READ_RESET_P, 
        E => DVLDI, Q => data_out(5));
    
    XOR2_72 : XOR2
      port map(A => \MEM_RADDR[9]\, B => \GND\, Y => XOR2_72_Y);
    
    XNOR2_0 : XNOR2
      port map(A => \RBINSYNC[6]\, B => \WBINNXTSHIFT[4]\, Y => 
        XNOR2_0_Y);
    
    OR2A_3 : OR2A
      port map(A => \AFVALCONST[1]\, B => \WDIFF[2]\, Y => 
        OR2A_3_Y);
    
    AND2_31 : AND2
      port map(A => AND2_7_Y, B => AND2_19_Y, Y => AND2_31_Y);
    
    DFN1C0_15 : DFN1C0
      port map(D => \WGRY[6]\, CLK => r_clk, CLR => READ_RESET_P, 
        Q => DFN1C0_15_Q);
    
    AO1_34 : AO1
      port map(A => XOR2_64_Y, B => AND2_20_Y, C => AND2_32_Y, Y
         => AO1_34_Y);
    
    DFN1C0_12 : DFN1C0
      port map(D => \VCC\, CLK => w_clk, CLR => RESET_POLA, Q => 
        DFN1C0_12_Q);
    
    XNOR3_19 : XNOR3
      port map(A => \WGRYSYNC[2]\, B => \WGRYSYNC[1]\, C => 
        XNOR3_9_Y, Y => XNOR3_19_Y);
    
    XOR2_18 : XOR2
      port map(A => \WBINNXTSHIFT[5]\, B => INV_0_Y, Y => 
        XOR2_18_Y);
    
    \XOR2_RBINNXTSHIFT[4]\ : XOR2
      port map(A => XOR2_51_Y, B => AO1_18_Y, Y => 
        \RBINNXTSHIFT[4]\);
    
    XNOR3_22 : XNOR3
      port map(A => \RGRYSYNC[7]\, B => \RGRYSYNC[6]\, C => 
        \RGRYSYNC[5]\, Y => XNOR3_22_Y);
    
    \DFN1C0_MEM_WADDR[8]\ : DFN1C0
      port map(D => \WBINNXTSHIFT[8]\, CLK => w_clk, CLR => 
        WRITE_RESET_P, Q => \MEM_WADDR[8]\);
    
    \DFN1C0_RGRY[1]\ : DFN1C0
      port map(D => XOR2_20_Y, CLK => r_clk, CLR => READ_RESET_P, 
        Q => \RGRY[1]\);
    
    \DFN1C0_RGRYSYNC[5]\ : DFN1C0
      port map(D => DFN1C0_11_Q, CLK => w_clk, CLR => 
        WRITE_RESET_P, Q => \RGRYSYNC[5]\);
    
    \DFN1C0_WGRY[3]\ : DFN1C0
      port map(D => XOR2_54_Y, CLK => w_clk, CLR => WRITE_RESET_P, 
        Q => \WGRY[3]\);
    
    XOR2_8 : XOR2
      port map(A => \WBINNXTSHIFT[1]\, B => INV_2_Y, Y => 
        XOR2_8_Y);
    
    NAND3A_0 : NAND3A
      port map(A => \WDIFF[7]\, B => \AFVALCONST[0]\, C => 
        OR2A_0_Y, Y => NAND3A_0_Y);
    
    XOR2_30 : XOR2
      port map(A => \RBINNXTSHIFT[9]\, B => \RBINNXTSHIFT[10]\, Y
         => XOR2_30_Y);
    
    \XOR2_RBINNXTSHIFT[6]\ : XOR2
      port map(A => XOR2_19_Y, B => AO1_0_Y, Y => 
        \RBINNXTSHIFT[6]\);
    
    OR2A_2 : OR2A
      port map(A => \AFVALCONST[1]\, B => \WDIFF[8]\, Y => 
        OR2A_2_Y);
    
    AND2_38 : AND2
      port map(A => AND2_49_Y, B => XOR2_31_Y, Y => AND2_38_Y);
    
    AND2_35 : AND2
      port map(A => AND2_33_Y, B => AND2_60_Y, Y => AND2_35_Y);
    
    MEMREBUBBLE : INV
      port map(A => MEMORYRE, Y => MEMRENEG);
    
    \DFN1C0_MEM_WADDR[7]\ : DFN1C0
      port map(D => \WBINNXTSHIFT[7]\, CLK => w_clk, CLR => 
        WRITE_RESET_P, Q => \MEM_WADDR[7]\);
    
    AND2_29 : AND2
      port map(A => AND2_33_Y, B => XOR2_18_Y, Y => AND2_29_Y);
    
    \DFN1C0_MEM_RADDR[4]\ : DFN1C0
      port map(D => \RBINNXTSHIFT[4]\, CLK => r_clk, CLR => 
        READ_RESET_P, Q => \MEM_RADDR[4]\);
    
    XNOR3_7 : XNOR3
      port map(A => \RGRYSYNC[1]\, B => \RGRYSYNC[0]\, C => 
        XOR3_4_Y, Y => XNOR3_7_Y);
    
    XOR2_34 : XOR2
      port map(A => \MEM_WADDR[0]\, B => MEMORYWE, Y => XOR2_34_Y);
    
    XOR2_31 : XOR2
      port map(A => \WBINNXTSHIFT[7]\, B => INV_7_Y, Y => 
        XOR2_31_Y);
    
    AND2_3 : AND2
      port map(A => \MEM_RADDR[4]\, B => \GND\, Y => AND2_3_Y);
    
    AND2_30 : AND2
      port map(A => \MEM_RADDR[7]\, B => \GND\, Y => AND2_30_Y);
    
    \XOR2_WBINNXTSHIFT[4]\ : XOR2
      port map(A => XOR2_10_Y, B => AO1_20_Y, Y => 
        \WBINNXTSHIFT[4]\);
    
    XNOR2_6 : XNOR2
      port map(A => \WDIFF[5]\, B => \AFVALCONST[1]\, Y => 
        XNOR2_6_Y);
    
    RESETBUBBLE : INV
      port map(A => reset, Y => RESET_POLA);
    
    AND2_14 : AND2
      port map(A => \WBINNXTSHIFT[7]\, B => INV_7_Y, Y => 
        AND2_14_Y);
    
    INV_4 : INV
      port map(A => \RBINSYNC[5]\, Y => INV_4_Y);
    
    AND2_32 : AND2
      port map(A => \MEM_RADDR[9]\, B => \GND\, Y => AND2_32_Y);
    
    OR2A_1 : OR2A
      port map(A => \WDIFF[5]\, B => \AFVALCONST[1]\, Y => 
        OR2A_1_Y);
    
    \XOR2_WBINNXTSHIFT[6]\ : XOR2
      port map(A => XOR2_73_Y, B => AO1_25_Y, Y => 
        \WBINNXTSHIFT[6]\);
    
    \DFN1C0_MEM_RADDR[5]\ : DFN1C0
      port map(D => \RBINNXTSHIFT[5]\, CLK => r_clk, CLR => 
        READ_RESET_P, Q => \MEM_RADDR[5]\);
    
    NAND3A_2 : NAND3A
      port map(A => \WDIFF[1]\, B => \AFVALCONST[1]\, C => 
        OR2A_4_Y, Y => NAND3A_2_Y);
    
    XOR3_4 : XOR3
      port map(A => \RGRYSYNC[10]\, B => \RGRYSYNC[9]\, C => 
        \RGRYSYNC[8]\, Y => XOR3_4_Y);
    
    XOR2_46 : XOR2
      port map(A => \WBINNXTSHIFT[8]\, B => \GND\, Y => XOR2_46_Y);
    
    XNOR2_11 : XNOR2
      port map(A => \RBINNXTSHIFT[5]\, B => \WBINSYNC[3]\, Y => 
        XNOR2_11_Y);
    
    AO1_2 : AO1
      port map(A => AND2_59_Y, B => AO1_31_Y, C => AO1_3_Y, Y => 
        AO1_2_Y);
    
    \DFN1C0_MEM_RADDR[8]\ : DFN1C0
      port map(D => \RBINNXTSHIFT[8]\, CLK => r_clk, CLR => 
        READ_RESET_P, Q => \MEM_RADDR[8]\);
    
    \DFN1C0_WGRY[0]\ : DFN1C0
      port map(D => XOR2_29_Y, CLK => w_clk, CLR => WRITE_RESET_P, 
        Q => \WGRY[0]\);
    
    \BUFF_RBINSYNC[10]\ : BUFF
      port map(A => \RGRYSYNC[10]\, Y => \RBINSYNC[10]\);
    
    AND2_26 : AND2
      port map(A => AND2_43_Y, B => XOR2_0_Y, Y => AND2_26_Y);
    
    \RAM4K9_QXI[7]\ : RAM4K9
      port map(ADDRA11 => \GND\, ADDRA10 => \GND\, ADDRA9 => 
        \GND\, ADDRA8 => \GND\, ADDRA7 => \MEM_WADDR[7]\, ADDRA6
         => \MEM_WADDR[6]\, ADDRA5 => \MEM_WADDR[5]\, ADDRA4 => 
        \MEM_WADDR[4]\, ADDRA3 => \MEM_WADDR[3]\, ADDRA2 => 
        \MEM_WADDR[2]\, ADDRA1 => \MEM_WADDR[1]\, ADDRA0 => 
        \MEM_WADDR[0]\, ADDRB11 => \GND\, ADDRB10 => \GND\, 
        ADDRB9 => \MEM_RADDR[9]\, ADDRB8 => \MEM_RADDR[8]\, 
        ADDRB7 => \MEM_RADDR[7]\, ADDRB6 => \MEM_RADDR[6]\, 
        ADDRB5 => \MEM_RADDR[5]\, ADDRB4 => \MEM_RADDR[4]\, 
        ADDRB3 => \MEM_RADDR[3]\, ADDRB2 => \MEM_RADDR[2]\, 
        ADDRB1 => \MEM_RADDR[1]\, ADDRB0 => \MEM_RADDR[0]\, DINA8
         => \GND\, DINA7 => data_in(31), DINA6 => data_in(30), 
        DINA5 => data_in(23), DINA4 => data_in(22), DINA3 => 
        data_in(15), DINA2 => data_in(14), DINA1 => data_in(7), 
        DINA0 => data_in(6), DINB8 => \GND\, DINB7 => \GND\, 
        DINB6 => \GND\, DINB5 => \GND\, DINB4 => \GND\, DINB3 => 
        \GND\, DINB2 => \GND\, DINB1 => \GND\, DINB0 => \GND\, 
        WIDTHA0 => \VCC\, WIDTHA1 => \VCC\, WIDTHB0 => \VCC\, 
        WIDTHB1 => \GND\, PIPEA => \GND\, PIPEB => \GND\, WMODEA
         => \GND\, WMODEB => \GND\, BLKA => MEMWENEG, BLKB => 
        MEMRENEG, WENA => \GND\, WENB => \VCC\, CLKA => w_clk, 
        CLKB => r_clk, RESET => WRITE_RESET_P, DOUTA8 => OPEN, 
        DOUTA7 => \RAM4K9_QXI[7]_DOUTA7\, DOUTA6 => 
        \RAM4K9_QXI[7]_DOUTA6\, DOUTA5 => \RAM4K9_QXI[7]_DOUTA5\, 
        DOUTA4 => \RAM4K9_QXI[7]_DOUTA4\, DOUTA3 => 
        \RAM4K9_QXI[7]_DOUTA3\, DOUTA2 => \RAM4K9_QXI[7]_DOUTA2\, 
        DOUTA1 => \RAM4K9_QXI[7]_DOUTA1\, DOUTA0 => 
        \RAM4K9_QXI[7]_DOUTA0\, DOUTB8 => OPEN, DOUTB7 => OPEN, 
        DOUTB6 => OPEN, DOUTB5 => OPEN, DOUTB4 => OPEN, DOUTB3
         => OPEN, DOUTB2 => OPEN, DOUTB1 => \QXI[7]\, DOUTB0 => 
        \QXI[6]\);
    
    XOR2_9 : XOR2
      port map(A => \WBINNXTSHIFT[2]\, B => INV_8_Y, Y => 
        XOR2_9_Y);
    
    AND3_5 : AND3
      port map(A => XNOR2_11_Y, B => XNOR2_20_Y, C => XNOR2_7_Y, 
        Y => AND3_5_Y);
    
    \XOR2_WDIFF[2]\ : XOR2
      port map(A => XOR2_32_Y, B => OR3_0_Y, Y => \WDIFF[2]\);
    
    XOR2_59 : XOR2
      port map(A => \MEM_WADDR[8]\, B => \GND\, Y => XOR2_59_Y);
    
    AND2_23 : AND2
      port map(A => \MEM_RADDR[10]\, B => \GND\, Y => AND2_23_Y);
    
    XNOR2_4 : XNOR2
      port map(A => \RBINNXTSHIFT[3]\, B => \WBINSYNC[1]\, Y => 
        XNOR2_4_Y);
    
    \DFN1C0_WGRYSYNC[1]\ : DFN1C0
      port map(D => DFN1C0_8_Q, CLK => r_clk, CLR => READ_RESET_P, 
        Q => \WGRYSYNC[1]\);
    
    \DFN1C0_RGRY[8]\ : DFN1C0
      port map(D => XOR2_55_Y, CLK => r_clk, CLR => READ_RESET_P, 
        Q => \RGRY[8]\);
    
    XOR2_5 : XOR2
      port map(A => \MEM_RADDR[10]\, B => \GND\, Y => XOR2_5_Y);
    
    XNOR2_20 : XNOR2
      port map(A => \RBINNXTSHIFT[6]\, B => \WBINSYNC[4]\, Y => 
        XNOR2_20_Y);
    
    DFN1C0_16 : DFN1C0
      port map(D => \RGRY[6]\, CLK => w_clk, CLR => WRITE_RESET_P, 
        Q => DFN1C0_16_Q);
    
    XNOR3_11 : XNOR3
      port map(A => \WGRYSYNC[8]\, B => \WGRYSYNC[7]\, C => 
        \WGRYSYNC[6]\, Y => XNOR3_11_Y);
    
    AO1_28 : AO1
      port map(A => XOR2_4_Y, B => AO1_14_Y, C => AND2_25_Y, Y
         => AO1_28_Y);
    
    AND2_19 : AND2
      port map(A => XOR2_6_Y, B => XOR2_1_Y, Y => AND2_19_Y);
    
    DFN1C0_6 : DFN1C0
      port map(D => \RGRY[10]\, CLK => w_clk, CLR => 
        WRITE_RESET_P, Q => DFN1C0_6_Q);
    
    \DFN1C0_MEM_RADDR[6]\ : DFN1C0
      port map(D => \RBINNXTSHIFT[6]\, CLK => r_clk, CLR => 
        READ_RESET_P, Q => \MEM_RADDR[6]\);
    
    XOR2_22 : XOR2
      port map(A => \MEM_RADDR[5]\, B => \GND\, Y => XOR2_22_Y);
    
    AO1_1 : AO1
      port map(A => XOR2_28_Y, B => AND2_24_Y, C => AND2_44_Y, Y
         => AO1_1_Y);
    
    \XOR2_WBINSYNC[7]\ : XOR2
      port map(A => \WGRYSYNC[8]\, B => \WGRYSYNC[7]\, Y => 
        \WBINSYNC[7]\);
    
    DFN1C0_10 : DFN1C0
      port map(D => \WGRY[0]\, CLK => r_clk, CLR => READ_RESET_P, 
        Q => DFN1C0_10_Q);
    
    XOR2_13 : XOR2
      port map(A => \MEM_RADDR[8]\, B => \GND\, Y => XOR2_13_Y);
    
    \DFN1C0_WGRYSYNC[2]\ : DFN1C0
      port map(D => DFN1C0_9_Q, CLK => r_clk, CLR => READ_RESET_P, 
        Q => \WGRYSYNC[2]\);
    
    INV_6 : INV
      port map(A => \RBINSYNC[8]\, Y => INV_6_Y);
    
    \DFN1C0_WGRYSYNC[0]\ : DFN1C0
      port map(D => DFN1C0_10_Q, CLK => r_clk, CLR => 
        READ_RESET_P, Q => \WGRYSYNC[0]\);
    
    XNOR2_18 : XNOR2
      port map(A => \RBINSYNC[4]\, B => \WBINNXTSHIFT[2]\, Y => 
        XNOR2_18_Y);
    
    AND2_51 : AND2
      port map(A => XOR2_52_Y, B => XOR2_2_Y, Y => AND2_51_Y);
    
    \DFN1E1C0_data_out[3]\ : DFN1E1C0
      port map(D => \QXI[3]\, CLK => r_clk, CLR => READ_RESET_P, 
        E => DVLDI, Q => data_out(3));
    
    AO1_3 : AO1
      port map(A => XOR2_36_Y, B => AND2_67_Y, C => AND2_21_Y, Y
         => AO1_3_Y);
    
    AND2_64 : AND2
      port map(A => \WBINNXTSHIFT[4]\, B => INV_1_Y, Y => 
        AND2_64_Y);
    
    AND2_47 : AND2
      port map(A => AND2_17_Y, B => AND2_51_Y, Y => AND2_47_Y);
    
    AO1_18 : AO1
      port map(A => AND2_19_Y, B => AO1_17_Y, C => AO1_32_Y, Y
         => AO1_18_Y);
    
    XOR2_48 : XOR2
      port map(A => \MEM_WADDR[7]\, B => \GND\, Y => XOR2_48_Y);
    
    \XOR2_RBINNXTSHIFT[3]\ : XOR2
      port map(A => XOR2_33_Y, B => AO1_36_Y, Y => 
        \RBINNXTSHIFT[3]\);
    
    DFN1C0_3 : DFN1C0
      port map(D => \RGRY[4]\, CLK => w_clk, CLR => WRITE_RESET_P, 
        Q => DFN1C0_3_Q);
    
    AO1C_0 : AO1C
      port map(A => \AFVALCONST[1]\, B => \WDIFF[1]\, C => 
        \AFVALCONST[0]\, Y => AO1C_0_Y);
    
    \DFN1C0_MEM_RADDR[7]\ : DFN1C0
      port map(D => \RBINNXTSHIFT[7]\, CLK => r_clk, CLR => 
        READ_RESET_P, Q => \MEM_RADDR[7]\);
    
    XNOR3_18 : XNOR3
      port map(A => \RGRYSYNC[10]\, B => \RGRYSYNC[9]\, C => 
        \RGRYSYNC[8]\, Y => XNOR3_18_Y);
    
    AND2_16 : AND2
      port map(A => XOR2_61_Y, B => XOR2_58_Y, Y => AND2_16_Y);
    
    XNOR3_24 : XNOR3
      port map(A => \RGRYSYNC[4]\, B => \RGRYSYNC[3]\, C => 
        \RGRYSYNC[2]\, Y => XNOR3_24_Y);
    
    \XOR2_WDIFF[3]\ : XOR2
      port map(A => XOR2_21_Y, B => AO1_14_Y, Y => \WDIFF[3]\);
    
    AO1_38 : AO1
      port map(A => XOR2_2_Y, B => AND2_1_Y, C => AND2_30_Y, Y
         => AO1_38_Y);
    
    OR2A_5 : OR2A
      port map(A => \AFVALCONST[1]\, B => \WDIFF[5]\, Y => 
        OR2A_5_Y);
    
    \XNOR3_WBINSYNC[0]\ : XNOR3
      port map(A => XNOR3_17_Y, B => XNOR3_25_Y, C => XNOR3_8_Y, 
        Y => \WBINSYNC[0]\);
    
    XOR2_62 : XOR2
      port map(A => \MEM_RADDR[8]\, B => \GND\, Y => XOR2_62_Y);
    
    AND2_13 : AND2
      port map(A => \MEM_RADDR[5]\, B => \GND\, Y => AND2_13_Y);
    
    DFN1C0_18 : DFN1C0
      port map(D => \WGRY[5]\, CLK => r_clk, CLR => READ_RESET_P, 
        Q => DFN1C0_18_Q);
    
    XOR2_10 : XOR2
      port map(A => \MEM_WADDR[4]\, B => \GND\, Y => XOR2_10_Y);
    
    XNOR2_1 : XNOR2
      port map(A => \RBINSYNC[2]\, B => \WBINNXTSHIFT[0]\, Y => 
        XNOR2_1_Y);
    
    AND2_58 : AND2
      port map(A => XOR2_14_Y, B => XOR2_65_Y, Y => AND2_58_Y);
    
    AND2_55 : AND2
      port map(A => \MEM_WADDR[8]\, B => \GND\, Y => AND2_55_Y);
    
    INV_8 : INV
      port map(A => \RBINSYNC[4]\, Y => INV_8_Y);
    
    XNOR3_6 : XNOR3
      port map(A => \RGRYSYNC[10]\, B => \RGRYSYNC[9]\, C => 
        \RGRYSYNC[8]\, Y => XNOR3_6_Y);
    
    \DFN1C0_RGRY[4]\ : DFN1C0
      port map(D => XOR2_63_Y, CLK => r_clk, CLR => READ_RESET_P, 
        Q => \RGRY[4]\);
    
    DFN1C0_2 : DFN1C0
      port map(D => \VCC\, CLK => r_clk, CLR => RESET_POLA, Q => 
        DFN1C0_2_Q);
    
    AND2_69 : AND2
      port map(A => \WBINNXTSHIFT[2]\, B => INV_8_Y, Y => 
        AND2_69_Y);
    
    \DFN1C0_MEM_WADDR[2]\ : DFN1C0
      port map(D => \WBINNXTSHIFT[2]\, CLK => w_clk, CLR => 
        WRITE_RESET_P, Q => \MEM_WADDR[2]\);
    
    XOR3_3 : XOR3
      port map(A => \RGRYSYNC[10]\, B => \RGRYSYNC[9]\, C => 
        \RGRYSYNC[8]\, Y => XOR3_3_Y);
    
    XOR2_27 : XOR2
      port map(A => \WBINNXTSHIFT[8]\, B => INV_3_Y, Y => 
        XOR2_27_Y);
    
    AND2_MEMORYRE : AND2
      port map(A => NAND2_1_Y, B => re, Y => MEMORYRE);
    
    \XOR2_WBINNXTSHIFT[3]\ : XOR2
      port map(A => XOR2_49_Y, B => AO1_30_Y, Y => 
        \WBINNXTSHIFT[3]\);
    
    XOR2_7 : XOR2
      port map(A => \MEM_RADDR[4]\, B => \GND\, Y => XOR2_7_Y);
    
    AND2_5 : AND2
      port map(A => AND2_65_Y, B => XOR2_14_Y, Y => AND2_5_Y);
    
    XOR2_56 : XOR2
      port map(A => \RBINNXTSHIFT[6]\, B => \RBINNXTSHIFT[7]\, Y
         => XOR2_56_Y);
    
    XOR2_14 : XOR2
      port map(A => \MEM_WADDR[2]\, B => \GND\, Y => XOR2_14_Y);
    
    AND2_50 : AND2
      port map(A => \MEM_WADDR[6]\, B => \GND\, Y => AND2_50_Y);
    
    XNOR3_23 : XNOR3
      port map(A => \RGRYSYNC[4]\, B => \RGRYSYNC[3]\, C => 
        \RGRYSYNC[2]\, Y => XNOR3_23_Y);
    
    XNOR3_1 : XNOR3
      port map(A => \RGRYSYNC[1]\, B => XOR3_2_Y, C => XNOR3_4_Y, 
        Y => XNOR3_1_Y);
    
    XNOR2_3 : XNOR2
      port map(A => \RBINSYNC[7]\, B => \WBINNXTSHIFT[5]\, Y => 
        XNOR2_3_Y);
    
    DFN1C0_7 : DFN1C0
      port map(D => \WGRY[7]\, CLK => r_clk, CLR => READ_RESET_P, 
        Q => DFN1C0_7_Q);
    
    XOR2_11 : XOR2
      port map(A => \RBINNXTSHIFT[0]\, B => \RBINNXTSHIFT[1]\, Y
         => XOR2_11_Y);
    
    XNOR2_22 : XNOR2
      port map(A => \WDIFF[3]\, B => \AFVALCONST[1]\, Y => 
        XNOR2_22_Y);
    
    NAND3A_3 : NAND3A
      port map(A => NOR3A_1_Y, B => OR2A_5_Y, C => NAND3A_1_Y, Y
         => NAND3A_3_Y);
    
    AND2_52 : AND2
      port map(A => AND2_16_Y, B => AND2_10_Y, Y => AND2_52_Y);
    
    XOR2_25 : XOR2
      port map(A => \WBINNXTSHIFT[1]\, B => \WBINNXTSHIFT[2]\, Y
         => XOR2_25_Y);
    
    XNOR2_15 : XNOR2
      port map(A => \RBINNXTSHIFT[8]\, B => \WBINSYNC[6]\, Y => 
        XNOR2_15_Y);
    
    AO1_22 : AO1
      port map(A => AND2_18_Y, B => AO1_35_Y, C => AO1_34_Y, Y
         => AO1_22_Y);
    
    \XNOR2_RBINSYNC[7]\ : XNOR2
      port map(A => \RGRYSYNC[7]\, B => XNOR3_16_Y, Y => 
        \RBINSYNC[7]\);
    
    XNOR3_3 : XNOR3
      port map(A => \WGRYSYNC[8]\, B => \WGRYSYNC[7]\, C => 
        \WGRYSYNC[6]\, Y => XNOR3_3_Y);
    
    \DFN1C0_RGRYSYNC[10]\ : DFN1C0
      port map(D => DFN1C0_6_Q, CLK => w_clk, CLR => 
        WRITE_RESET_P, Q => \RGRYSYNC[10]\);
    
    \XNOR2_RBINSYNC[1]\ : XNOR2
      port map(A => XNOR3_10_Y, B => XNOR3_1_Y, Y => 
        \RBINSYNC[1]\);
    
    \DFN1C0_RGRYSYNC[9]\ : DFN1C0
      port map(D => DFN1C0_1_Q, CLK => w_clk, CLR => 
        WRITE_RESET_P, Q => \RGRYSYNC[9]\);
    
    AND2_34 : AND2
      port map(A => \MEM_RADDR[1]\, B => \GND\, Y => AND2_34_Y);
    
    AND2_66 : AND2
      port map(A => AND2_57_Y, B => XOR2_52_Y, Y => AND2_66_Y);
    
    AO1_6 : AO1
      port map(A => XOR2_58_Y, B => AND2_48_Y, C => AND2_9_Y, Y
         => AO1_6_Y);
    
    XNOR3_15 : XNOR3
      port map(A => \WGRYSYNC[5]\, B => \WGRYSYNC[4]\, C => 
        \WGRYSYNC[3]\, Y => XNOR3_15_Y);
    
    \DFN1C0_MEM_RADDR[3]\ : DFN1C0
      port map(D => \RBINNXTSHIFT[3]\, CLK => r_clk, CLR => 
        READ_RESET_P, Q => \MEM_RADDR[3]\);
    
    XOR2_67 : XOR2
      port map(A => \MEM_RADDR[7]\, B => \GND\, Y => XOR2_67_Y);
    
    AND2_63 : AND2
      port map(A => XNOR2_15_Y, B => XNOR2_17_Y, Y => AND2_63_Y);
    
    AND3_2 : AND3
      port map(A => XNOR2_16_Y, B => XNOR2_0_Y, C => XNOR2_3_Y, Y
         => AND3_2_Y);
    
    AO1_12 : AO1
      port map(A => XOR2_18_Y, B => AO1_31_Y, C => AND2_67_Y, Y
         => AO1_12_Y);
    
    NOR3A_1 : NOR3A
      port map(A => OR2A_1_Y, B => AO1C_1_Y, C => \WDIFF[3]\, Y
         => NOR3A_1_Y);
    
    XOR2_32 : XOR2
      port map(A => \WBINNXTSHIFT[2]\, B => INV_8_Y, Y => 
        XOR2_32_Y);
    
    OR3_0 : OR3
      port map(A => AND2_46_Y, B => AND2_40_Y, C => AND2_6_Y, Y
         => OR3_0_Y);
    
    AND2_9 : AND2
      port map(A => \MEM_WADDR[5]\, B => \GND\, Y => AND2_9_Y);
    
    XOR2_65 : XOR2
      port map(A => \MEM_WADDR[3]\, B => \GND\, Y => XOR2_65_Y);
    
    NOR3A_0 : NOR3A
      port map(A => OR2A_0_Y, B => AO1C_2_Y, C => \WDIFF[6]\, Y
         => NOR3A_0_Y);
    
    DFN1C0_afull : DFN1C0
      port map(D => OR2_0_Y, CLK => w_clk, CLR => WRITE_RESET_P, 
        Q => afull);
    
    XOR2_58 : XOR2
      port map(A => \MEM_WADDR[5]\, B => \GND\, Y => XOR2_58_Y);
    
    AO1_32 : AO1
      port map(A => XOR2_1_Y, B => AND2_15_Y, C => AND2_45_Y, Y
         => AO1_32_Y);
    
    XOR2_43 : XOR2
      port map(A => \RBINNXTSHIFT[3]\, B => \RBINNXTSHIFT[4]\, Y
         => XOR2_43_Y);
    
    INV_2 : INV
      port map(A => \RBINSYNC[3]\, Y => INV_2_Y);
    
    AO1_9 : AO1
      port map(A => AND2_51_Y, B => AO1_10_Y, C => AO1_38_Y, Y
         => AO1_9_Y);
    
    DFN1C0_DVLDX : DFN1C0
      port map(D => DVLDI, CLK => r_clk, CLR => READ_RESET_P, Q
         => DVLDX);
    
    AND2_39 : AND2
      port map(A => AND2_42_Y, B => XOR2_4_Y, Y => AND2_39_Y);
    
    NAND2_0 : NAND2
      port map(A => \full\, B => \VCC\, Y => NAND2_0_Y);
    
    NAND3A_1 : NAND3A
      port map(A => \WDIFF[4]\, B => \AFVALCONST[1]\, C => 
        OR2A_1_Y, Y => NAND3A_1_Y);
    
    XNOR3_0 : XNOR3
      port map(A => \RGRYSYNC[7]\, B => \RGRYSYNC[6]\, C => 
        \RGRYSYNC[5]\, Y => XNOR3_0_Y);
    
    \DFN1C0_RGRY[6]\ : DFN1C0
      port map(D => XOR2_56_Y, CLK => r_clk, CLR => READ_RESET_P, 
        Q => \RGRY[6]\);
    
    \XNOR3_RBINSYNC[4]\ : XNOR3
      port map(A => \RGRYSYNC[4]\, B => XOR3_3_Y, C => XNOR3_21_Y, 
        Y => \RBINSYNC[4]\);
    
    AND2_27 : AND2
      port map(A => XOR2_4_Y, B => XOR2_45_Y, Y => AND2_27_Y);
    
    DFN1C0_DVLDI : DFN1C0
      port map(D => AND2A_0_Y, CLK => r_clk, CLR => READ_RESET_P, 
        Q => DVLDI);
    
    XNOR2_10 : XNOR2
      port map(A => \RBINNXTSHIFT[4]\, B => \WBINSYNC[2]\, Y => 
        XNOR2_10_Y);
    
    \XNOR2_RBINSYNC[3]\ : XNOR2
      port map(A => XNOR3_0_Y, B => XNOR3_20_Y, Y => 
        \RBINSYNC[3]\);
    
    AND2_MEMORYWE : AND2
      port map(A => NAND2_0_Y, B => we, Y => MEMORYWE);
    
    AO1_20 : AO1
      port map(A => AND2_58_Y, B => AO1_1_Y, C => AO1_24_Y, Y => 
        AO1_20_Y);
    
    \DFN1E1C0_data_out[1]\ : DFN1E1C0
      port map(D => \QXI[1]\, CLK => r_clk, CLR => READ_RESET_P, 
        E => DVLDI, Q => data_out(1));
    
    \DFN1C0_WGRY[2]\ : DFN1C0
      port map(D => XOR2_15_Y, CLK => w_clk, CLR => WRITE_RESET_P, 
        Q => \WGRY[2]\);
    
    AO1_0 : AO1
      port map(A => AND2_17_Y, B => AO1_18_Y, C => AO1_10_Y, Y
         => AO1_0_Y);
    
    XOR2_29 : XOR2
      port map(A => \WBINNXTSHIFT[0]\, B => \WBINNXTSHIFT[1]\, Y
         => XOR2_29_Y);
    
    \DFN1C0_WGRYSYNC[8]\ : DFN1C0
      port map(D => DFN1C0_17_Q, CLK => r_clk, CLR => 
        READ_RESET_P, Q => \WGRYSYNC[8]\);
    
    XOR2_40 : XOR2
      port map(A => \RBINSYNC[10]\, B => \WBINNXTSHIFT[8]\, Y => 
        XOR2_40_Y);
    
    \DFN1C0_RGRYSYNC[1]\ : DFN1C0
      port map(D => DFN1C0_0_Q, CLK => w_clk, CLR => 
        WRITE_RESET_P, Q => \RGRYSYNC[1]\);
    
    XOR3_0 : XOR3
      port map(A => \WGRYSYNC[8]\, B => \WGRYSYNC[7]\, C => 
        \WGRYSYNC[6]\, Y => XOR3_0_Y);
    
    XOR2_2 : XOR2
      port map(A => \MEM_RADDR[7]\, B => \GND\, Y => XOR2_2_Y);
    
    DFN1C0_8 : DFN1C0
      port map(D => \WGRY[1]\, CLK => r_clk, CLR => READ_RESET_P, 
        Q => DFN1C0_8_Q);
    
    \DFN1C0_RGRY[5]\ : DFN1C0
      port map(D => XOR2_69_Y, CLK => r_clk, CLR => READ_RESET_P, 
        Q => \RGRY[5]\);
    
    XNOR3_10 : XNOR3
      port map(A => \RGRYSYNC[4]\, B => \RGRYSYNC[3]\, C => 
        \RGRYSYNC[2]\, Y => XNOR3_10_Y);
    
    \XNOR2_WDIFF[1]\ : XNOR2
      port map(A => XOR2_12_Y, B => NOR2A_0_Y, Y => \WDIFF[1]\);
    
    AND2_36 : AND2
      port map(A => AND2_41_Y, B => XOR2_13_Y, Y => AND2_36_Y);
    
    XOR2_37 : XOR2
      port map(A => \WBINNXTSHIFT[6]\, B => \WBINNXTSHIFT[7]\, Y
         => XOR2_37_Y);
    
    AND2A_0 : AND2A
      port map(A => \empty\, B => re, Y => AND2A_0_Y);
    
    AO1_26 : AO1
      port map(A => XOR2_13_Y, B => AO1_35_Y, C => AND2_20_Y, Y
         => AO1_26_Y);
    
    \DFN1C0_RGRY[7]\ : DFN1C0
      port map(D => XOR2_16_Y, CLK => r_clk, CLR => READ_RESET_P, 
        Q => \RGRY[7]\);
    
    XOR3_5 : XOR3
      port map(A => \WGRYSYNC[8]\, B => \WGRYSYNC[7]\, C => 
        \WGRYSYNC[6]\, Y => XOR3_5_Y);
    
    \XOR2_RBINNXTSHIFT[5]\ : XOR2
      port map(A => XOR2_71_Y, B => AO1_5_Y, Y => 
        \RBINNXTSHIFT[5]\);
    
    AO1_23 : AO1
      port map(A => AND2_37_Y, B => AO1_3_Y, C => AO1_13_Y, Y => 
        AO1_23_Y);
    
    AOI1_0 : AOI1
      port map(A => AND3_0_Y, B => AO1_21_Y, C => NAND3A_4_Y, Y
         => AOI1_0_Y);
    
    AND2_33 : AND2
      port map(A => AND2_42_Y, B => AND2_27_Y, Y => AND2_33_Y);
    
    XOR2_44 : XOR2
      port map(A => \WBINNXTSHIFT[7]\, B => \WBINNXTSHIFT[8]\, Y
         => XOR2_44_Y);
    
    \DFN1C0_RGRYSYNC[2]\ : DFN1C0
      port map(D => DFN1C0_5_Q, CLK => w_clk, CLR => 
        WRITE_RESET_P, Q => \RGRYSYNC[2]\);
    
    AO1_10 : AO1
      port map(A => XOR2_22_Y, B => AND2_3_Y, C => AND2_13_Y, Y
         => AO1_10_Y);
    
    XOR2_41 : XOR2
      port map(A => \RBINNXTSHIFT[2]\, B => \RBINNXTSHIFT[3]\, Y
         => XOR2_41_Y);
    
    XOR2_35 : XOR2
      port map(A => \MEM_RADDR[2]\, B => \GND\, Y => XOR2_35_Y);
    
    \DFN1C0_RGRYSYNC[0]\ : DFN1C0
      port map(D => DFN1C0_21_Q, CLK => w_clk, CLR => 
        WRITE_RESET_P, Q => \RGRYSYNC[0]\);
    
    \XOR2_RBINNXTSHIFT[10]\ : XOR2
      port map(A => XOR2_5_Y, B => AO1_22_Y, Y => 
        \RBINNXTSHIFT[10]\);
    
    \DFN1C0_WGRY[1]\ : DFN1C0
      port map(D => XOR2_25_Y, CLK => w_clk, CLR => WRITE_RESET_P, 
        Q => \WGRY[1]\);
    
    \DFN1E1C0_data_out[2]\ : DFN1E1C0
      port map(D => \QXI[2]\, CLK => r_clk, CLR => READ_RESET_P, 
        E => DVLDI, Q => data_out(2));
    
    DFN1P0_empty : DFN1P0
      port map(D => EMPTYINT, CLK => r_clk, PRE => READ_RESET_P, 
        Q => \empty\);
    
    \DFN1C0_WGRYSYNC[4]\ : DFN1C0
      port map(D => DFN1C0_4_Q, CLK => r_clk, CLR => READ_RESET_P, 
        Q => \WGRYSYNC[4]\);
    
    AO1_30 : AO1
      port map(A => XOR2_14_Y, B => AO1_1_Y, C => AND2_8_Y, Y => 
        AO1_30_Y);
    
    \XOR2_RBINNXTSHIFT[7]\ : XOR2
      port map(A => XOR2_67_Y, B => AO1_19_Y, Y => 
        \RBINNXTSHIFT[7]\);
    
    \XNOR3_RBINSYNC[2]\ : XNOR3
      port map(A => XNOR3_18_Y, B => XNOR3_2_Y, C => XNOR3_24_Y, 
        Y => \RBINSYNC[2]\);
    
    AND2_41 : AND2
      port map(A => AND2_31_Y, B => AND2_47_Y, Y => AND2_41_Y);
    
    AND2_0 : AND2
      port map(A => AND2_31_Y, B => XOR2_7_Y, Y => AND2_0_Y);
    
    XOR2_69 : XOR2
      port map(A => \RBINNXTSHIFT[5]\, B => \RBINNXTSHIFT[6]\, Y
         => XOR2_69_Y);
    
    AO1_16 : AO1
      port map(A => XOR2_0_Y, B => AO1_25_Y, C => AND2_50_Y, Y
         => AO1_16_Y);
    
    AND2_17 : AND2
      port map(A => XOR2_7_Y, B => XOR2_22_Y, Y => AND2_17_Y);
    
    \XNOR2_WBINSYNC[1]\ : XNOR2
      port map(A => XNOR3_15_Y, B => XNOR3_19_Y, Y => 
        \WBINSYNC[1]\);
    
    AO1_29 : AO1
      port map(A => XOR2_31_Y, B => AO1_2_Y, C => AND2_14_Y, Y
         => AO1_29_Y);
    
    NOR2A_0 : NOR2A
      port map(A => \RBINSYNC[2]\, B => \WBINNXTSHIFT[0]\, Y => 
        NOR2A_0_Y);
    
    XOR2_6 : XOR2
      port map(A => \MEM_RADDR[2]\, B => \GND\, Y => XOR2_6_Y);
    
    AND2_54 : AND2
      port map(A => AND2_7_Y, B => XOR2_6_Y, Y => AND2_54_Y);
    
    AO1_13 : AO1
      port map(A => XOR2_74_Y, B => AND2_14_Y, C => AND2_62_Y, Y
         => AO1_13_Y);
    
    \DFN1C0_MEM_WADDR[6]\ : DFN1C0
      port map(D => \WBINNXTSHIFT[6]\, CLK => w_clk, CLR => 
        WRITE_RESET_P, Q => \MEM_WADDR[6]\);
    
    \XOR2_WBINNXTSHIFT[5]\ : XOR2
      port map(A => XOR2_68_Y, B => AO1_8_Y, Y => 
        \WBINNXTSHIFT[5]\);
    
    \DFN1E1C0_data_out[6]\ : DFN1E1C0
      port map(D => \QXI[6]\, CLK => r_clk, CLR => READ_RESET_P, 
        E => DVLDI, Q => data_out(6));
    
    \XOR2_WDIFF[7]\ : XOR2
      port map(A => XOR2_42_Y, B => AO1_2_Y, Y => \WDIFF[7]\);
    
    AO1_36 : AO1
      port map(A => XOR2_6_Y, B => AO1_17_Y, C => AND2_15_Y, Y
         => AO1_36_Y);
    
    XOR2_53 : XOR2
      port map(A => \WBINNXTSHIFT[5]\, B => INV_0_Y, Y => 
        XOR2_53_Y);
    
    DFN1C0_19 : DFN1C0
      port map(D => \RGRY[8]\, CLK => w_clk, CLR => WRITE_RESET_P, 
        Q => DFN1C0_19_Q);
    
    AO1_33 : AO1
      port map(A => AND2_60_Y, B => AO1_31_Y, C => AO1_23_Y, Y
         => AO1_33_Y);
    
    \DFN1C0_WGRYSYNC[3]\ : DFN1C0
      port map(D => DFN1C0_20_Q, CLK => r_clk, CLR => 
        READ_RESET_P, Q => \WGRYSYNC[3]\);
    
    OR2A_0 : OR2A
      port map(A => \WDIFF[8]\, B => \AFVALCONST[1]\, Y => 
        OR2A_0_Y);
    
    XNOR2_12 : XNOR2
      port map(A => \RBINSYNC[8]\, B => \WBINNXTSHIFT[6]\, Y => 
        XNOR2_12_Y);
    
    XNOR2_7 : XNOR2
      port map(A => \RBINNXTSHIFT[7]\, B => \WBINSYNC[5]\, Y => 
        XNOR2_7_Y);
    
    XOR2_12 : XOR2
      port map(A => \WBINNXTSHIFT[1]\, B => INV_2_Y, Y => 
        XOR2_12_Y);
    
    AND2_48 : AND2
      port map(A => \MEM_WADDR[4]\, B => \GND\, Y => AND2_48_Y);
    
    AND2_45 : AND2
      port map(A => \MEM_RADDR[3]\, B => \GND\, Y => AND2_45_Y);
    
    DFN1C0_5 : DFN1C0
      port map(D => \RGRY[2]\, CLK => w_clk, CLR => WRITE_RESET_P, 
        Q => DFN1C0_5_Q);
    
    DFN1C0_21 : DFN1C0
      port map(D => \RGRY[0]\, CLK => w_clk, CLR => WRITE_RESET_P, 
        Q => DFN1C0_21_Q);
    
    AO1_19 : AO1
      port map(A => XOR2_52_Y, B => AO1_0_Y, C => AND2_1_Y, Y => 
        AO1_19_Y);
    
    \XOR2_WBINNXTSHIFT[7]\ : XOR2
      port map(A => XOR2_39_Y, B => AO1_16_Y, Y => 
        \WBINNXTSHIFT[7]\);
    
    \RAM4K9_QXI[5]\ : RAM4K9
      port map(ADDRA11 => \GND\, ADDRA10 => \GND\, ADDRA9 => 
        \GND\, ADDRA8 => \GND\, ADDRA7 => \MEM_WADDR[7]\, ADDRA6
         => \MEM_WADDR[6]\, ADDRA5 => \MEM_WADDR[5]\, ADDRA4 => 
        \MEM_WADDR[4]\, ADDRA3 => \MEM_WADDR[3]\, ADDRA2 => 
        \MEM_WADDR[2]\, ADDRA1 => \MEM_WADDR[1]\, ADDRA0 => 
        \MEM_WADDR[0]\, ADDRB11 => \GND\, ADDRB10 => \GND\, 
        ADDRB9 => \MEM_RADDR[9]\, ADDRB8 => \MEM_RADDR[8]\, 
        ADDRB7 => \MEM_RADDR[7]\, ADDRB6 => \MEM_RADDR[6]\, 
        ADDRB5 => \MEM_RADDR[5]\, ADDRB4 => \MEM_RADDR[4]\, 
        ADDRB3 => \MEM_RADDR[3]\, ADDRB2 => \MEM_RADDR[2]\, 
        ADDRB1 => \MEM_RADDR[1]\, ADDRB0 => \MEM_RADDR[0]\, DINA8
         => \GND\, DINA7 => data_in(29), DINA6 => data_in(28), 
        DINA5 => data_in(21), DINA4 => data_in(20), DINA3 => 
        data_in(13), DINA2 => data_in(12), DINA1 => data_in(5), 
        DINA0 => data_in(4), DINB8 => \GND\, DINB7 => \GND\, 
        DINB6 => \GND\, DINB5 => \GND\, DINB4 => \GND\, DINB3 => 
        \GND\, DINB2 => \GND\, DINB1 => \GND\, DINB0 => \GND\, 
        WIDTHA0 => \VCC\, WIDTHA1 => \VCC\, WIDTHB0 => \VCC\, 
        WIDTHB1 => \GND\, PIPEA => \GND\, PIPEB => \GND\, WMODEA
         => \GND\, WMODEB => \GND\, BLKA => MEMWENEG, BLKB => 
        MEMRENEG, WENA => \GND\, WENB => \VCC\, CLKA => w_clk, 
        CLKB => r_clk, RESET => WRITE_RESET_P, DOUTA8 => OPEN, 
        DOUTA7 => \RAM4K9_QXI[5]_DOUTA7\, DOUTA6 => 
        \RAM4K9_QXI[5]_DOUTA6\, DOUTA5 => \RAM4K9_QXI[5]_DOUTA5\, 
        DOUTA4 => \RAM4K9_QXI[5]_DOUTA4\, DOUTA3 => 
        \RAM4K9_QXI[5]_DOUTA3\, DOUTA2 => \RAM4K9_QXI[5]_DOUTA2\, 
        DOUTA1 => \RAM4K9_QXI[5]_DOUTA1\, DOUTA0 => 
        \RAM4K9_QXI[5]_DOUTA0\, DOUTB8 => OPEN, DOUTB7 => OPEN, 
        DOUTB6 => OPEN, DOUTB5 => OPEN, DOUTB4 => OPEN, DOUTB3
         => OPEN, DOUTB2 => OPEN, DOUTB1 => \QXI[5]\, DOUTB0 => 
        \QXI[4]\);
    
    XOR2_26 : XOR2
      port map(A => \WBINNXTSHIFT[5]\, B => \WBINNXTSHIFT[6]\, Y
         => XOR2_26_Y);
    
    DFN1C0_1 : DFN1C0
      port map(D => \RGRY[9]\, CLK => w_clk, CLR => WRITE_RESET_P, 
        Q => DFN1C0_1_Q);
    
    AND2_59 : AND2
      port map(A => XOR2_18_Y, B => XOR2_36_Y, Y => AND2_59_Y);
    
    \DFN1C0_RGRY[10]\ : DFN1C0
      port map(D => XOR2_66_Y, CLK => r_clk, CLR => READ_RESET_P, 
        Q => \RGRY[10]\);
    
    \DFN1C0_WGRYSYNC[7]\ : DFN1C0
      port map(D => DFN1C0_7_Q, CLK => r_clk, CLR => READ_RESET_P, 
        Q => \WGRYSYNC[7]\);
    
    AND2_4 : AND2
      port map(A => \MEM_WADDR[3]\, B => \GND\, Y => AND2_4_Y);
    
    AND2_FULLINT : AND2
      port map(A => AND3_1_Y, B => XOR2_40_Y, Y => FULLINT);
    
    \XOR2_WDIFF[6]\ : XOR2
      port map(A => XOR2_38_Y, B => AO1_12_Y, Y => \WDIFF[6]\);
    
    AND2_40 : AND2
      port map(A => \WBINNXTSHIFT[1]\, B => INV_5_Y, Y => 
        AND2_40_Y);
    
    XNOR3_12 : XNOR3
      port map(A => \RGRYSYNC[7]\, B => \RGRYSYNC[6]\, C => 
        \RGRYSYNC[5]\, Y => XNOR3_12_Y);
    
    XOR2_50 : XOR2
      port map(A => \MEM_RADDR[10]\, B => \GND\, Y => XOR2_50_Y);
    
    \DFN1C0_WGRYSYNC[6]\ : DFN1C0
      port map(D => DFN1C0_15_Q, CLK => r_clk, CLR => 
        READ_RESET_P, Q => \WGRYSYNC[6]\);
    
    AND2_42 : AND2
      port map(A => XOR2_8_Y, B => XOR2_9_Y, Y => AND2_42_Y);
    
    \DFN1C0_WGRY[8]\ : DFN1C0
      port map(D => XOR2_46_Y, CLK => w_clk, CLR => WRITE_RESET_P, 
        Q => \WGRY[8]\);
    
    XNOR2_5 : XNOR2
      port map(A => \RBINSYNC[9]\, B => \WBINNXTSHIFT[7]\, Y => 
        XNOR2_5_Y);
    
    \XNOR2_WBINSYNC[3]\ : XNOR2
      port map(A => XOR3_0_Y, B => XNOR3_13_Y, Y => \WBINSYNC[3]\);
    
    AO1_5 : AO1
      port map(A => XOR2_7_Y, B => AO1_18_Y, C => AND2_3_Y, Y => 
        AO1_5_Y);
    
    AND2_67 : AND2
      port map(A => \WBINNXTSHIFT[5]\, B => INV_0_Y, Y => 
        AND2_67_Y);
    
    XNOR2_16 : XNOR2
      port map(A => \RBINSYNC[5]\, B => \WBINNXTSHIFT[3]\, Y => 
        XNOR2_16_Y);
    
    \XOR2_WDIFF[4]\ : XOR2
      port map(A => XOR2_24_Y, B => AO1_28_Y, Y => \WDIFF[4]\);
    
    \DFN1C0_RGRY[3]\ : DFN1C0
      port map(D => XOR2_43_Y, CLK => r_clk, CLR => READ_RESET_P, 
        Q => \RGRY[3]\);
    
    XOR3_2 : XOR3
      port map(A => \RGRYSYNC[10]\, B => \RGRYSYNC[9]\, C => 
        \RGRYSYNC[8]\, Y => XOR3_2_Y);
    
    XOR2_39 : XOR2
      port map(A => \MEM_WADDR[7]\, B => \GND\, Y => XOR2_39_Y);
    
    AND2_8 : AND2
      port map(A => \MEM_WADDR[2]\, B => \GND\, Y => AND2_8_Y);
    
    \XOR2_WDIFF[8]\ : XOR2
      port map(A => XOR2_27_Y, B => AO1_29_Y, Y => \WDIFF[8]\);
    
    XOR2_3 : XOR2
      port map(A => \MEM_RADDR[1]\, B => \GND\, Y => XOR2_3_Y);
    
    XOR2_54 : XOR2
      port map(A => \WBINNXTSHIFT[3]\, B => \WBINNXTSHIFT[4]\, Y
         => XOR2_54_Y);
    
    XNOR3_21 : XNOR3
      port map(A => \RGRYSYNC[7]\, B => \RGRYSYNC[6]\, C => 
        \RGRYSYNC[5]\, Y => XNOR3_21_Y);
    
    XOR3_1 : XOR3
      port map(A => \RGRYSYNC[10]\, B => \RGRYSYNC[9]\, C => 
        \RGRYSYNC[8]\, Y => XOR3_1_Y);
    
    XOR2_51 : XOR2
      port map(A => \MEM_RADDR[4]\, B => \GND\, Y => XOR2_51_Y);
    
    AO1_27 : AO1
      port map(A => AND2_52_Y, B => AO1_20_Y, C => AO1_37_Y, Y
         => AO1_27_Y);
    
    \XOR3_WBINSYNC[6]\ : XOR3
      port map(A => \WGRYSYNC[8]\, B => \WGRYSYNC[7]\, C => 
        \WGRYSYNC[6]\, Y => \WBINSYNC[6]\);
    
    XOR2_66 : XOR2
      port map(A => \RBINNXTSHIFT[10]\, B => \GND\, Y => 
        XOR2_66_Y);
    
    AND2_56 : AND2
      port map(A => AND2_53_Y, B => AND2_52_Y, Y => AND2_56_Y);
    
    \XNOR2_RBINSYNC[5]\ : XNOR2
      port map(A => XOR3_1_Y, B => XNOR3_22_Y, Y => \RBINSYNC[5]\);
    
    XNOR3_16 : XNOR3
      port map(A => \RGRYSYNC[10]\, B => \RGRYSYNC[9]\, C => 
        \RGRYSYNC[8]\, Y => XNOR3_16_Y);
    
    \DFN1C0_MEM_WADDR[1]\ : DFN1C0
      port map(D => \WBINNXTSHIFT[1]\, CLK => w_clk, CLR => 
        WRITE_RESET_P, Q => \MEM_WADDR[1]\);
    
    \XOR2_RBINNXTSHIFT[1]\ : XOR2
      port map(A => XOR2_70_Y, B => AND2_61_Y, Y => 
        \RBINNXTSHIFT[1]\);
    
    XOR2_17 : XOR2
      port map(A => \MEM_WADDR[8]\, B => \GND\, Y => XOR2_17_Y);
    
    XOR2_73 : XOR2
      port map(A => \MEM_WADDR[6]\, B => \GND\, Y => XOR2_73_Y);
    
    AND2_53 : AND2
      port map(A => AND2_65_Y, B => AND2_58_Y, Y => AND2_53_Y);
    
    DFN1C0_13 : DFN1C0
      port map(D => \RGRY[7]\, CLK => w_clk, CLR => WRITE_RESET_P, 
        Q => DFN1C0_13_Q);
    
    AND3_7 : AND3
      port map(A => AND2_63_Y, B => AND3_6_Y, C => AND3_5_Y, Y
         => AND3_7_Y);
    
    XOR2_28 : XOR2
      port map(A => \MEM_WADDR[1]\, B => \GND\, Y => XOR2_28_Y);
    
    \DFN1C0_MEM_WADDR[5]\ : DFN1C0
      port map(D => \WBINNXTSHIFT[5]\, CLK => w_clk, CLR => 
        WRITE_RESET_P, Q => \MEM_WADDR[5]\);
    
    XOR2_15 : XOR2
      port map(A => \WBINNXTSHIFT[2]\, B => \WBINNXTSHIFT[3]\, Y
         => XOR2_15_Y);
    
    \DFN1C0_MEM_RADDR[0]\ : DFN1C0
      port map(D => \RBINNXTSHIFT[0]\, CLK => r_clk, CLR => 
        READ_RESET_P, Q => \MEM_RADDR[0]\);
    
    AO1_17 : AO1
      port map(A => XOR2_3_Y, B => AND2_61_Y, C => AND2_34_Y, Y
         => AO1_17_Y);
    
    XNOR2_17 : XNOR2
      port map(A => \RBINNXTSHIFT[9]\, B => \WBINSYNC[7]\, Y => 
        XNOR2_17_Y);
    
    \RAM4K9_QXI[3]\ : RAM4K9
      port map(ADDRA11 => \GND\, ADDRA10 => \GND\, ADDRA9 => 
        \GND\, ADDRA8 => \GND\, ADDRA7 => \MEM_WADDR[7]\, ADDRA6
         => \MEM_WADDR[6]\, ADDRA5 => \MEM_WADDR[5]\, ADDRA4 => 
        \MEM_WADDR[4]\, ADDRA3 => \MEM_WADDR[3]\, ADDRA2 => 
        \MEM_WADDR[2]\, ADDRA1 => \MEM_WADDR[1]\, ADDRA0 => 
        \MEM_WADDR[0]\, ADDRB11 => \GND\, ADDRB10 => \GND\, 
        ADDRB9 => \MEM_RADDR[9]\, ADDRB8 => \MEM_RADDR[8]\, 
        ADDRB7 => \MEM_RADDR[7]\, ADDRB6 => \MEM_RADDR[6]\, 
        ADDRB5 => \MEM_RADDR[5]\, ADDRB4 => \MEM_RADDR[4]\, 
        ADDRB3 => \MEM_RADDR[3]\, ADDRB2 => \MEM_RADDR[2]\, 
        ADDRB1 => \MEM_RADDR[1]\, ADDRB0 => \MEM_RADDR[0]\, DINA8
         => \GND\, DINA7 => data_in(27), DINA6 => data_in(26), 
        DINA5 => data_in(19), DINA4 => data_in(18), DINA3 => 
        data_in(11), DINA2 => data_in(10), DINA1 => data_in(3), 
        DINA0 => data_in(2), DINB8 => \GND\, DINB7 => \GND\, 
        DINB6 => \GND\, DINB5 => \GND\, DINB4 => \GND\, DINB3 => 
        \GND\, DINB2 => \GND\, DINB1 => \GND\, DINB0 => \GND\, 
        WIDTHA0 => \VCC\, WIDTHA1 => \VCC\, WIDTHB0 => \VCC\, 
        WIDTHB1 => \GND\, PIPEA => \GND\, PIPEB => \GND\, WMODEA
         => \GND\, WMODEB => \GND\, BLKA => MEMWENEG, BLKB => 
        MEMRENEG, WENA => \GND\, WENB => \VCC\, CLKA => w_clk, 
        CLKB => r_clk, RESET => WRITE_RESET_P, DOUTA8 => OPEN, 
        DOUTA7 => \RAM4K9_QXI[3]_DOUTA7\, DOUTA6 => 
        \RAM4K9_QXI[3]_DOUTA6\, DOUTA5 => \RAM4K9_QXI[3]_DOUTA5\, 
        DOUTA4 => \RAM4K9_QXI[3]_DOUTA4\, DOUTA3 => 
        \RAM4K9_QXI[3]_DOUTA3\, DOUTA2 => \RAM4K9_QXI[3]_DOUTA2\, 
        DOUTA1 => \RAM4K9_QXI[3]_DOUTA1\, DOUTA0 => 
        \RAM4K9_QXI[3]_DOUTA0\, DOUTB8 => OPEN, DOUTB7 => OPEN, 
        DOUTB6 => OPEN, DOUTB5 => OPEN, DOUTB4 => OPEN, DOUTB3
         => OPEN, DOUTB2 => OPEN, DOUTB1 => \QXI[3]\, DOUTB0 => 
        \QXI[2]\);
    
    \DFN1C0_MEM_RADDR[10]\ : DFN1C0
      port map(D => \RBINNXTSHIFT[10]\, CLK => r_clk, CLR => 
        READ_RESET_P, Q => \MEM_RADDR[10]\);
    
    NAND3A_4 : NAND3A
      port map(A => NOR3A_0_Y, B => OR2A_2_Y, C => NAND3A_0_Y, Y
         => NAND3A_4_Y);
    
    AND3_4 : AND3
      port map(A => XNOR2_22_Y, B => XNOR2_21_Y, C => XNOR2_6_Y, 
        Y => AND3_4_Y);
    
    \DFN1C0_RGRY[0]\ : DFN1C0
      port map(D => XOR2_11_Y, CLK => r_clk, CLR => READ_RESET_P, 
        Q => \RGRY[0]\);
    
    AND2_21 : AND2
      port map(A => \WBINNXTSHIFT[6]\, B => INV_6_Y, Y => 
        AND2_21_Y);
    
    \XOR2_WBINNXTSHIFT[1]\ : XOR2
      port map(A => XOR2_60_Y, B => AND2_24_Y, Y => 
        \WBINNXTSHIFT[1]\);
    
    AO1_37 : AO1
      port map(A => AND2_10_Y, B => AO1_6_Y, C => AO1_7_Y, Y => 
        AO1_37_Y);
    
    \DFN1C0_WGRY[4]\ : DFN1C0
      port map(D => XOR2_47_Y, CLK => w_clk, CLR => WRITE_RESET_P, 
        Q => \WGRY[4]\);
    
    XNOR3_17 : XNOR3
      port map(A => \WGRYSYNC[8]\, B => \WGRYSYNC[7]\, C => 
        \WGRYSYNC[6]\, Y => XNOR3_17_Y);
    
    XOR2_0 : XOR2
      port map(A => \MEM_WADDR[6]\, B => \GND\, Y => XOR2_0_Y);
    
    XOR2_70 : XOR2
      port map(A => \MEM_RADDR[1]\, B => \GND\, Y => XOR2_70_Y);
    
    NAND2_1 : NAND2
      port map(A => \empty\, B => \VCC\, Y => NAND2_1_Y);
    
    NAND3A_5 : NAND3A
      port map(A => NOR3A_2_Y, B => OR2A_3_Y, C => NAND3A_2_Y, Y
         => NAND3A_5_Y);
    
    \DFN1C0_RGRYSYNC[8]\ : DFN1C0
      port map(D => DFN1C0_19_Q, CLK => w_clk, CLR => 
        WRITE_RESET_P, Q => \RGRYSYNC[8]\);
    
    AO1_4 : AO1
      port map(A => XOR2_45_Y, B => AND2_25_Y, C => AND2_64_Y, Y
         => AO1_4_Y);
    
    XOR2_68 : XOR2
      port map(A => \MEM_WADDR[5]\, B => \GND\, Y => XOR2_68_Y);
    
    AND2_37 : AND2
      port map(A => XOR2_31_Y, B => XOR2_74_Y, Y => AND2_37_Y);
    
    XNOR3_4 : XNOR3
      port map(A => \RGRYSYNC[7]\, B => \RGRYSYNC[6]\, C => 
        \RGRYSYNC[5]\, Y => XNOR3_4_Y);
    
    \DFN1E1C0_data_out[4]\ : DFN1E1C0
      port map(D => \QXI[4]\, CLK => r_clk, CLR => READ_RESET_P, 
        E => DVLDI, Q => data_out(4));
    
    XNOR2_14 : XNOR2
      port map(A => \RBINSYNC[3]\, B => \WBINNXTSHIFT[1]\, Y => 
        XNOR2_14_Y);
    
    \XOR2_RBINNXTSHIFT[2]\ : XOR2
      port map(A => XOR2_35_Y, B => AO1_17_Y, Y => 
        \RBINNXTSHIFT[2]\);
    
    XOR2_42 : XOR2
      port map(A => \WBINNXTSHIFT[7]\, B => INV_7_Y, Y => 
        XOR2_42_Y);
    
    AO1_21 : AO1
      port map(A => AND3_4_Y, B => NAND3A_5_Y, C => NAND3A_3_Y, Y
         => AO1_21_Y);
    
    \DFN1C0_MEM_RADDR[9]\ : DFN1C0
      port map(D => \RBINNXTSHIFT[9]\, CLK => r_clk, CLR => 
        READ_RESET_P, Q => \MEM_RADDR[9]\);
    
    XOR2_36 : XOR2
      port map(A => \WBINNXTSHIFT[6]\, B => INV_6_Y, Y => 
        XOR2_36_Y);
    
    XOR2_74 : XOR2
      port map(A => \WBINNXTSHIFT[8]\, B => INV_3_Y, Y => 
        XOR2_74_Y);
    
    XNOR2_8 : XNOR2
      port map(A => \RBINNXTSHIFT[2]\, B => \WBINSYNC[0]\, Y => 
        XNOR2_8_Y);
    
    XNOR3_2 : XNOR3
      port map(A => \RGRYSYNC[7]\, B => \RGRYSYNC[6]\, C => 
        \RGRYSYNC[5]\, Y => XNOR3_2_Y);
    
    XOR2_71 : XOR2
      port map(A => \MEM_RADDR[5]\, B => \GND\, Y => XOR2_71_Y);
    
    AND2_28 : AND2
      port map(A => XNOR2_12_Y, B => XNOR2_5_Y, Y => AND2_28_Y);
    
    AND2_25 : AND2
      port map(A => \WBINNXTSHIFT[3]\, B => INV_4_Y, Y => 
        AND2_25_Y);
    
    \XNOR3_RBINSYNC[0]\ : XNOR3
      port map(A => XNOR3_12_Y, B => XNOR3_23_Y, C => XNOR3_7_Y, 
        Y => \RBINSYNC[0]\);
    
    \DFN1C0_WGRYSYNC[5]\ : DFN1C0
      port map(D => DFN1C0_18_Q, CLK => r_clk, CLR => 
        READ_RESET_P, Q => \WGRYSYNC[5]\);
    
    AO1C_2 : AO1C
      port map(A => \AFVALCONST[0]\, B => \WDIFF[7]\, C => 
        \AFVALCONST[1]\, Y => AO1C_2_Y);
    
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
-- LPMTYPE:LPM_SOFTFIFO
-- LPM_HINT:MEMFF
-- INSERT_PAD:NO
-- INSERT_IOREG:NO
-- GEN_BHV_VHDL_VAL:F
-- GEN_BHV_VERILOG_VAL:F
-- MGNTIMER:F
-- MGNCMPL:T
-- DESDIR:C:/Users/Lab-user1/Desktop/MasterThesis/Langmuir-DataHub-EMUScience-FPGA/smartgen\FPGA_Buffer
-- GEN_BEHV_MODULE:F
-- SMARTGEN_DIE:IS4X4M1
-- SMARTGEN_PACKAGE:vq100
-- AGENIII_IS_SUBPROJECT_LIBERO:T
-- WWIDTH:32
-- WDEPTH:256
-- RWIDTH:8
-- RDEPTH:1024
-- CLKS:2
-- WCLOCK_PN:w_clk
-- RCLOCK_PN:r_clk
-- WCLK_EDGE:RISE
-- RCLK_EDGE:RISE
-- ACLR_PN:reset
-- RESET_POLARITY:1
-- INIT_RAM:F
-- WE_POLARITY:1
-- RE_POLARITY:1
-- FF_PN:full
-- AF_PN:afull
-- WACK_PN:WACK
-- OVRFLOW_PN:OVERFLOW
-- WRCNT_PN:WRCNT
-- WE_PN:we
-- EF_PN:empty
-- AE_PN:AEMPTY
-- DVLD_PN:DVLD
-- UDRFLOW_PN:UNDERFLOW
-- RDCNT_PN:RDCNT
-- RE_PN:re
-- CONTROLLERONLY:F
-- FSTOP:YES
-- ESTOP:YES
-- WRITEACK:NO
-- OVERFLOW:NO
-- WRCOUNT:NO
-- DATAVALID:NO
-- UNDERFLOW:NO
-- RDCOUNT:NO
-- AF_PORT_PN:AFVAL
-- AE_PORT_PN:AEVAL
-- AFFLAG:STATIC
-- AEFLAG:NONE
-- AFVAL:129
-- DATA_IN_PN:data_in
-- DATA_OUT_PN:data_out
-- CASCADE:0

-- _End_Comments_

