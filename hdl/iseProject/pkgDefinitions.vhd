--! @file
--! @brief Global definitions

--! @mainpage
--! <H1>Main document of the uart_block project</H1>\n
--! <H2>Features</H2>
--! Wishbone slave \n
--! Calculate baudrate based on clock speed \n\n
--! Interesting links \n
--! http://opencores.org/ \n

--! Use standard library

library IEEE;
use IEEE.STD_LOGIC_1164.all;

package pkgDefinitions is

--! Declare constants, enums, functions used by the design
constant nBits		: integer := 8;

type txStates is (tx_idle, tx_start, bit0, bit1, bit2, bit3, bit4, bit5, bit6, bit7, tx_stop1, tx_stop2);
type rxStates is (rx_idle, bit0, bit1, bit2, bit3, bit4, bit5, bit6, bit7, rx_stop);
type rxFilterStates is (s0, s1, s2);

end pkgDefinitions;

package body pkgDefinitions is

end pkgDefinitions;
