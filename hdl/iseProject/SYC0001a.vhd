----------------------------------------------------------------------
-- Module name:     SYC0001a.VHD
--
-- Description:     A simple WISHBONE SYSCON for FPGA.  For more infor-
--                  mation, please refer to the WISHBONE Public Domain
--                  Library Technical Reference Manual.
--
-- History:         Project complete:           SEP 20, 2001
--                                              WD Peterson
--                                              Silicore Corporation
--
-- Release:         Notice is hereby given that this document is not
--                  copyrighted, and has been placed into the public
--                  domain.  It may be freely copied and distributed
--                  by any means.
--
-- Disclaimer:      In no event shall Silicore Corporation be liable
--                  for incidental, consequential, indirect or special
--                  damages resulting from the use of this file.  The
--                  user assumes all responsibility for its use.
--
----------------------------------------------------------------------

----------------------------------------------------------------------
-- Load the IEEE 1164 library and make it visible.
----------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;


----------------------------------------------------------------------
-- Entity declaration.
----------------------------------------------------------------------

entity SYC0001a is
    port(
            -- WISHBONE Interface

            CLK_O:  out std_logic;
            RST_O:  out std_logic;


            -- NON-WISHBONE Signals

            EXTCLK: in  std_logic;
            EXTRST: in  std_logic
         );

end SYC0001a;


----------------------------------------------------------------------
-- Architecture definition.
----------------------------------------------------------------------

architecture SYC0001a1 of SYC0001a IS

begin


    ------------------------------------------------------------------
    -- Make selected signals available to the outside world.
    ------------------------------------------------------------------

    MAKE_VISIBLE: process( EXTCLK, EXTRST )
    begin

        CLK_O <= EXTCLK;
        RST_O <= EXTRST;

    end process MAKE_VISIBLE;

end architecture SYC0001a1;
