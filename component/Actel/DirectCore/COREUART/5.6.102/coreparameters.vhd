----------------------------------------------------------------------
-- Created by Microsemi SmartDesign Mon May 13 12:36:27 2019
-- Parameters for COREUART
----------------------------------------------------------------------


LIBRARY ieee;
   USE ieee.std_logic_1164.all;
   USE ieee.std_logic_unsigned.all;
   USE ieee.numeric_std.all;

package coreparameters is
    constant BAUD_VAL_FRCTN_EN : integer := 1;
    constant FAMILY : integer := 15;
    constant HDL_license : string( 1 to 1 ) := "U";
    constant RX_FIFO : integer := 0;
    constant RX_LEGACY_MODE : integer := 0;
    constant testbench : string( 1 to 4 ) := "None";
    constant TX_FIFO : integer := 0;
    constant USE_SOFT_FIFO : integer := 0;
end coreparameters;
