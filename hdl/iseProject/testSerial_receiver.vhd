--! Test serial_receiver module
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
--! Use CPU Definitions package
use work.pkgDefinitions.all;
 
ENTITY testSerial_receiver IS
END testSerial_receiver;
 
ARCHITECTURE behavior OF testSerial_receiver IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT serial_receiver
    PORT(
         rst : IN  std_logic;
         baudClk : IN  std_logic;
         baudOverSampleClk : IN  std_logic;
         serial_in : IN  std_logic;
         data_ready : OUT  std_logic;
         data_byte : OUT  std_logic_vector((nBits-1) downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal rst : std_logic := '0';
   signal baudClk : std_logic := '0';
   signal baudOverSampleClk : std_logic := '0';
   signal serial_in : std_logic := '0';

 	--Outputs
   signal data_ready : std_logic;
   signal data_byte : std_logic_vector((nBits-1) downto 0);

   -- Clock period definitions
   constant baudClk_period : time := 8.6805 us;
   constant baudOverSampleClk_period : time := 1 us;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: serial_receiver PORT MAP (
          rst => rst,
          baudClk => baudClk,
          baudOverSampleClk => baudOverSampleClk,
          serial_in => serial_in,
          data_ready => data_ready,
          data_byte => data_byte
        );

   -- Clock process definitions
   baudClk_process :process
   begin
		baudClk <= '0';
		wait for baudClk_period/2;
		baudClk <= '1';
		wait for baudClk_period/2;
   end process;
 
   baudOverSampleClk_process :process
   begin
		baudOverSampleClk <= '0';
		wait for baudOverSampleClk_period/2;
		baudOverSampleClk <= '1';
		wait for baudOverSampleClk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      rst <= '1';
		serial_in <= '1';	-- Idle
      wait for 3 us;	
		rst <= '0';
		wait for baudClk_period * 3;
		
		-- Receive 0xC4 value (11000100)
		-- Start bit here
		serial_in <= '0';
		wait for baudClk_period;
		
		serial_in <= '0';
      wait for baudClk_period;
		serial_in <= '0';
      wait for baudClk_period;
		serial_in <= '1';
      wait for baudClk_period;
		serial_in <= '0';
      wait for baudClk_period;
		serial_in <= '0';
      wait for baudClk_period;
		serial_in <= '0';
      wait for baudClk_period;
		serial_in <= '1';
      wait for baudClk_period;
		serial_in <= '1';
      wait for baudClk_period;
		
		-- Stop bit here
		serial_in <= '1';
		wait for baudClk_period * 3;

      -- Stop Simulation
		assert false report "NONE. End of simulation." severity failure;

      wait;
   end process;

END;
