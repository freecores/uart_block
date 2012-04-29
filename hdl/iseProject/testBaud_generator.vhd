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
         baud : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal rst : std_logic := '0';
   signal clk : std_logic := '0';
   signal cycle_wait : std_logic_vector((nBitsLarge-1) downto 0) := (others => '0');

 	--Outputs
   signal baud : std_logic;

   -- Clock period definitions (1.8432MHz)
   constant clk_period : time := 5.43 us;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: baud_generator PORT MAP (
          rst => rst,
          clk => clk,
          cycle_wait => cycle_wait,
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
      -- Test the baud generator waiting for 10 clock cycles
		rst <= '1';
		cycle_wait <= conv_std_logic_vector(16, (nBitsLarge));
      wait for 10 us;	
		rst <= '0';

      wait for clk_period*100;

      -- Stop Simulation
		assert false report "NONE. End of simulation." severity failure;

      wait;
   end process;

END;
