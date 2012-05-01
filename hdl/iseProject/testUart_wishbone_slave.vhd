--! Test uart_wishbone_slave (Main test module)
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
 
--! Use Global Definitions package
use work.pkgDefinitions.all;
 
ENTITY testUart_wishbone_slave IS
END testUart_wishbone_slave;
 
ARCHITECTURE behavior OF testUart_wishbone_slave IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT uart_wishbone_slave
    PORT(
         RST_I : IN  std_logic;
         CLK_I : IN  std_logic;
         ADR_I0 : IN  std_logic_vector(1 downto 0);
         DAT_I0 : IN  std_logic_vector(31 downto 0);
         DAT_O0 : OUT  std_logic_vector(31 downto 0);
         WE_I : IN  std_logic;
         STB_I : IN  std_logic;
         ACK_O : OUT  std_logic;
         serial_in : IN  std_logic;
         serial_out : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal RST_I : std_logic := '0';
   signal CLK_I : std_logic := '0';
   signal ADR_I0 : std_logic_vector(1 downto 0) := (others => '0');
   signal DAT_I0 : std_logic_vector(31 downto 0) := (others => '0');
   signal WE_I : std_logic := '0';
   signal STB_I : std_logic := '0';
   signal serial_in : std_logic := '0';

 	--Outputs
   signal DAT_O0 : std_logic_vector(31 downto 0);
   signal ACK_O : std_logic;
   signal serial_out : std_logic;

   -- Clock period definitions (1.8432MHz)
   constant CLK_I_period : time := 0.543 us; -- 0.543us (1.8432Mhz) 2ns (50Mhz)
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: uart_wishbone_slave PORT MAP (
          RST_I => RST_I,
          CLK_I => CLK_I,
          ADR_I0 => ADR_I0,
          DAT_I0 => DAT_I0,
          DAT_O0 => DAT_O0,
          WE_I => WE_I,
          STB_I => STB_I,
          ACK_O => ACK_O,
          serial_in => serial_in,
          serial_out => serial_out
        );

   -- Clock process definitions
   CLK_I_process :process
   begin
		CLK_I <= '0';
		wait for CLK_I_period/2;
		CLK_I <= '1';
		wait for CLK_I_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- Reset the slave
		RST_I <= '1';
      wait for 1 ns;	
		RST_I <= '0';
		wait for CLK_I_period*3;

      -- Configure the clock... 
		ADR_I0 <= "00";
		WE_I <= '1';
		STB_I <= '1';
		DAT_I0 <= conv_std_logic_vector(50000000, (nBitsLarge));		
		wait until ACK_O = '1';
		WE_I <= '0';
		STB_I <= '0';
		ADR_I0 <= (others => 'U');
		wait for CLK_I_period;
		
		-- Configure the Baud... 
		ADR_I0 <= "01";
		WE_I <= '1';
		STB_I <= '1';
		DAT_I0 <= conv_std_logic_vector(115200, (nBitsLarge));		
		wait until ACK_O = '1';
		WE_I <= '0';
		STB_I <= '0';
		ADR_I0 <= (others => 'U');
		wait for CLK_I_period;
		
		-- Ask to send some data...(0xC4)
		ADR_I0 <= "10";
		WE_I <= '1';
		STB_I <= '1';
		DAT_I0 <= x"000000C4";		
		wait until ACK_O = '1';
		WE_I <= '0';
		STB_I <= '0';
		ADR_I0 <= (others => 'U');
		wait for CLK_I_period;

      -- Stop Simulation
		assert false report "NONE. End of simulation." severity failure;
   end process;

END;
