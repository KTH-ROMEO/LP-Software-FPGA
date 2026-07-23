----------------------------------------------------------------------
-- Created by Microsemi SmartDesign Mon Jul 13 15:41:12 2026
-- Parameters for CLK_GEN
----------------------------------------------------------------------


LIBRARY ieee;
   USE ieee.std_logic_1164.all;
   USE ieee.std_logic_unsigned.all;
   USE ieee.numeric_std.all;

package coreparameters is
    constant CLK_PERIOD : integer := 31250000;
    constant DUTY_CYCLE : integer := 50;
end coreparameters;
