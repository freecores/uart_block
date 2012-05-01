--! @file
--! @brief Global definitions

--! @mainpage
--! <H1>Main document of the uart_block project</H1>\n
--! <H2>Features</H2>
--! Wishbone slave \n
--! Calculate baudrate based on clock speed \n\n
--! Interesting links \n
--! http://opencores.org/ \n
--! http://www.erg.abdn.ac.uk/~gorry/course/phy-pages/async.html \n

--! Use standard library

library IEEE;
use IEEE.STD_LOGIC_1164.all;

package pkgDefinitions is

--! Declare constants, enums, functions used by the design
constant nBits		  : integer := 8;
constant nBitsLarge : integer := 32;

type txStates is (tx_idle, tx_start, bit0, bit1, bit2, bit3, bit4, bit5, bit6, bit7, tx_stop1, tx_stop2);
type rxStates is (bit0, bit1, bit2, bit3, bit4, bit5, bit6, bit7, rx_stop, rx_idle);
type rxFilterStates is (s0, s1, s2, s3);

type uartControl is (idle, config_state_clk, config_state_baud, start_division, wait_division, config_state_baud_generator, 
	rx_tx_state, tx_state_wait, rx_state_wait);

end pkgDefinitions;

package body pkgDefinitions is

end pkgDefinitions;
