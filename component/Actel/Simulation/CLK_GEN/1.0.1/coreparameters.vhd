----------------------------------------------------------------------
-- Created by Microsemi SmartDesign Thu Oct 30 20:47:20 2025
-- Parameters for CLK_GEN
----------------------------------------------------------------------


LIBRARY ieee;
   USE ieee.std_logic_1164.all;
   USE ieee.std_logic_unsigned.all;
   USE ieee.numeric_std.all;

package coreparameters is
    constant CLK_PERIOD : integer := 100000;
    constant DUTY_CYCLE : integer := 50;
end coreparameters;
