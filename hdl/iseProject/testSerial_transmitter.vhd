--! Test serial_transmitter module
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
--! Use CPU Definitions package
use work.pkgDefinitions.all;
 
ENTITY testSerial_transmitter IS
END testSerial_transmitter;
 
ARCHITECTURE behavior OF testSerial_transmitter IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT serial_transmitter
    PORT(
         rst : IN  std_logic;
         baudClk : IN  std_logic;
         data_byte : IN  std_logic_vector(7 downto 0);
         data_sent : OUT  std_logic;
         serial_out : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal rst : std_logic := '0';
   signal baudClk : std_logic := '0';
   signal data_byte : std_logic_vector(7 downto 0) := (others => '0');

 	--Outputs
   signal data_sent : std_logic;
   signal serial_out : std_logic;

   -- Clock period definitions
   constant baudClk_period : time := 10 ns;
 
BEGIN
 
	--! Instantiate the Unit Under Test (UUT)
   uut: serial_transmitter PORT MAP (
          rst => rst,
          baudClk => baudClk,
          data_byte => data_byte,
          data_sent => data_sent,
          serial_out => serial_out
        );

   -- Clock process definitions
   baudClk_process :process
   begin
		baudClk <= '0';
		wait for baudClk_period/2;
		baudClk <= '1';
		wait for baudClk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- Prepare the data to be sent 0x55
		rst <= '1';
		data_byte <= "01010101";
      wait for 50 ns;	
		rst <= '0';

      wait until data_sent = '1';
		wait for baudClk_period*3;
		
		-- Prepare the data to be sent
		rst <= '1';
		data_byte <= "11000100";
      wait for 50 ns;	
		rst <= '0';

      wait until data_sent = '1';
		wait for baudClk_period*3;
      
		-- Stop Simulation
		assert false report "NONE. End of simulation." severity failure;

      wait;
   end process;

END;
