--! Test baud_generator module
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

--! Use Global Definitions package
use work.pkgDefinitions.all;
 
 ENTITY testBaud_generator IS
END testBaud_generator;
 
ARCHITECTURE behavior OF testBaud_generator IS 
      
    COMPONENT baud_generator
    PORT(
         rst : IN  std_logic;
         clk : IN  std_logic;
         cycle_wait : in  STD_LOGIC_VECTOR ((nBitsLarge-1) downto 0);
			baud_oversample : out std_logic;
         baud : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal rst : std_logic := '0';
   signal clk : std_logic := '0';
   signal cycle_wait : std_logic_vector((nBitsLarge-1) downto 0) := (others => '0');

 	--Outputs
   signal baud : std_logic;
	signal baud_oversample : std_logic;

   -- Clock period definitions (1.8432MHz)
   constant clk_period : time := 0.543 us; -- 0.543us (1.8432Mhz) 2ns (50Mhz)
 
BEGIN
 
	--! Instantiate the Unit Under Test (UUT)
   uut: baud_generator PORT MAP (
          rst => rst,
          clk => clk,
          cycle_wait => cycle_wait,
			 baud_oversample => baud_oversample,
          baud => baud
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- Test the baud generator waiting for 16 clock cycles for 1.8432MHz clock
		rst <= '1';
		cycle_wait <= conv_std_logic_vector(16, (nBitsLarge));
      wait for 2 ns;	
		rst <= '0';

      wait for clk_period*300;

      -- Stop Simulation
		assert false report "NONE. End of simulation." severity failure;

      wait;
   end process;

END;
