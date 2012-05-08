--! Test divisor module
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
 
--! Use Global Definitions package
use work.pkgDefinitions.all;
 
ENTITY testDivisor IS
END testDivisor;
 
ARCHITECTURE behavior OF testDivisor IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT divisor
    PORT(
         rst : IN  std_logic;
         clk : IN  std_logic;
         quotient : OUT  std_logic_vector((nBitsLarge-1) downto 0);
         reminder : OUT  std_logic_vector((nBitsLarge-1) downto 0);
         numerator : IN  std_logic_vector((nBitsLarge-1) downto 0);
         divident : IN  std_logic_vector((nBitsLarge-1) downto 0);
         done : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal rst : std_logic := '0';
   signal clk : std_logic := '0';
   signal numerator : std_logic_vector((nBitsLarge-1) downto 0) := (others => '0');
   signal divident : std_logic_vector((nBitsLarge-1) downto 0) := (others => '0');

 	--Outputs
   signal quotient : std_logic_vector((nBitsLarge-1) downto 0);
   signal reminder : std_logic_vector((nBitsLarge-1) downto 0);
   signal done : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	--! Instantiate the Unit Under Test (UUT)
   uut: divisor PORT MAP (
          rst => rst,
          clk => clk,
          quotient => quotient,
          reminder => reminder,
          numerator => numerator,
          divident => divident,
          done => done
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
      -- hold reset state for 100 ns.
		rst <= '1';
		numerator <= conv_std_logic_vector(50000000, 32);
		divident <= conv_std_logic_vector(115200, 32);
      wait for 20 ns;	
		rst <= '0';
		
		wait until done = '1';
      wait for clk_period;
		
		rst <= '1';
		numerator <= conv_std_logic_vector(40, 32);
		divident <= conv_std_logic_vector(5, 32);
      wait for 20 ns;	
		rst <= '0';
		
		wait until done = '1';
		wait for clk_period;

      -- insert stimulus here 
		assert false report "NONE. End of simulation." severity failure;
      
   end process;

END;
