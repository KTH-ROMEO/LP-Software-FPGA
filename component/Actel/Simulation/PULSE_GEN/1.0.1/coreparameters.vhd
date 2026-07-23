----------------------------------------------------------------------
-- Created by Microsemi SmartDesign Mon Jul 13 15:41:12 2026
-- Parameters for PULSE_GEN
----------------------------------------------------------------------


LIBRARY ieee;
   USE ieee.std_logic_1164.all;
   USE ieee.std_logic_unsigned.all;
   USE ieee.numeric_std.all;

package coreparameters is
    constant PULSE_START_TIME : integer := 4000;
    constant PULSE_TYPE : integer := 0;
    constant PULSE_WIDTH : integer := 60;
end coreparameters;
