--! Test baud_generator module
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
--! Use Global Definitions package
use work.pkgDefinitions.all;
 
ENTITY testUart_communication_block IS
END testUart_communication_block;
 
ARCHITECTURE behavior OF testUart_communication_block IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT uart_communication_blocks
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
			  cycle_wait_baud : in std_logic_vector((nBitsLarge-1) downto 0);
           byte_tx : in  STD_LOGIC_VECTOR ((nBits-1) downto 0);
           byte_rx : out  STD_LOGIC_VECTOR ((nBits-1) downto 0);
           data_sent_tx : out  STD_LOGIC;
           data_received_rx : out  STD_LOGIC;
			  serial_out : out std_logic;
			  serial_in : in std_logic;
           start_tx : in  STD_LOGIC);
    END COMPONENT;
    

   --Inputs
   signal rst : std_logic := '0';
   signal clk : std_logic := '0';
   signal cycle_wait_baud : std_logic_vector((nBitsLarge-1) downto 0) := (others => '0');
   signal byte_tx : std_logic_vector((nBits-1) downto 0) := (others => '0');
   signal serial_in : std_logic := '0';
   signal start_tx : std_logic := '0';

 	--Outputs
   signal byte_rx : std_logic_vector((nBits-1) downto 0);
   signal data_sent_tx : std_logic;
   signal data_received_rx : std_logic;
   signal serial_out : std_logic;

   -- Clock period definitions   
	constant clk_period : time := 0.543 us; -- 0.543us (1.8432Mhz) 2ns (50Mhz)
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: uart_communication_blocks PORT MAP (
          rst => rst,
          clk => clk,
          cycle_wait_baud => cycle_wait_baud,
          byte_tx => byte_tx,
          byte_rx => byte_rx,
          data_sent_tx => data_sent_tx,
          data_received_rx => data_received_rx,
          serial_out => serial_out,
          serial_in => serial_in,
          start_tx => start_tx
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
      -- Setup communication blocks
		rst <= '1';
		cycle_wait_baud <= conv_std_logic_vector(16, (nBitsLarge));
      wait for 2 ns;	
		rst <= '0';

      wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
