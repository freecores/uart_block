--! uart control unit
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--! Use CPU Definitions package
use work.pkgDefinitions.all;

entity uart_control is
    Port ( rst : in  STD_LOGIC;														-- Global reset
           clk : in  STD_LOGIC;														-- Global clock
			  WE	: in STD_LOGIC;														-- Write enable
           reg_addr : in  STD_LOGIC_VECTOR (1 downto 0);			  			-- Register address
			  start : in std_logic;														-- Start (Strobe)
			  done : out std_logic;														-- Done (ACK)
           DAT_I : in  STD_LOGIC_VECTOR ((nBitsLarge-1) downto 0);		-- Data Input (Wishbone)
           DAT_O : out  STD_LOGIC_VECTOR ((nBitsLarge-1) downto 0);		-- Data output (Wishbone)
			  baud_wait : out STD_LOGIC_VECTOR ((nBitsLarge-1) downto 0);	-- Signal to control the baud rate frequency
			  data_byte_tx : out std_logic_vector((nBits-1) downto 0);	  	-- 1 Byte to be send to serial_transmitter
			  data_byte_rx : in std_logic_vector((nBits-1) downto 0);     	-- 1 Byte to be received by serial_receiver
           tx_data_sent : in  STD_LOGIC;										  	-- Signal comming from serial_transmitter
           rx_data_ready : in  STD_LOGIC);										-- Signal comming from serial_receiver
end uart_control;

architecture Behavioral of uart_control is
signal config_clk : std_logic_vector((nBitsLarge-1) downto 0);
signal config_baud : std_logic_vector((nBitsLarge-1) downto 0);
signal byte_to_receive : std_logic_vector((nBitsLarge-1) downto 0);
signal byte_to_transmitt : std_logic_vector((nBitsLarge-1) downto 0);
signal controlStates : uartControl;

signal sigDivRst : std_logic;
signal sigDivDone : std_logic;
signal sigDivQuotient : std_logic_vector((nBitsLarge-1) downto 0);
signal sigDivReminder : std_logic_vector((nBitsLarge-1) downto 0);
signal sigDivNumerator : std_logic_vector((nBitsLarge-1) downto 0);
signal sigDivDividend : std_logic_vector((nBitsLarge-1) downto 0);

-- Divisor component
component divisor is
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;			  
           quotient : out  STD_LOGIC_VECTOR ((nBitsLarge-1) downto 0);
			  reminder : out  STD_LOGIC_VECTOR ((nBitsLarge-1) downto 0);
           numerator : in  STD_LOGIC_VECTOR ((nBitsLarge-1) downto 0);
           divident : in  STD_LOGIC_VECTOR ((nBitsLarge-1) downto 0);
           done : out  STD_LOGIC);
end component;

begin
	-- Instantiate block for calculate division
	uDiv : divisor port map (
		rst => sigDivRst,
		clk => clk,
		quotient => sigDivQuotient,
		reminder => sigDivReminder,
		numerator => sigDivNumerator,
		divident => sigDivDividend,
		done => sigDivDone
	);
	
	-- Process that read uart control registers
	process (rst, clk, reg_addr,WE)
	begin
		if rising_edge(clk) then
			if (WE = '0') and (start = '1') then
				case reg_addr is
					when "00" =>
						DAT_O <= config_clk;
					when "01" =>
						DAT_O <= config_baud;						
					when "10" =>
						-- Byte that will be transmitted
						DAT_O <= "0000000000000000000000000" & byte_to_transmitt;						
					when "11" =>
						-- Byte that will be received
						DAT_O <= "0000000000000000000000000" & byte_to_receive;
					when others =>
						null;
				end case;						
			end if;
		end if;
	end process;
	
	-- Process that populate the uart control registers
	process (rst, clk, reg_addr,WE)
	begin 
		if rst = '1' then
			config_clk <= (others => '0');
			config_baud <= (others => '0');
			byte_to_transmitt <= (others => '0');
			byte_to_receive <= (others => '0');
		elsif rising_edge(clk) then
			if (WE = '1') and (start = '1') then
				case reg_addr is
					when "00" =>
						config_clk <= DAT_I;
					when "01" =>
						config_baud <= DAT_I;
					when "10" =>
						-- Byte that will be transmitted
						byte_to_transmitt <= DAT_I((nBits-1) downto 0);
					when others =>
						null;
				end case;						
			end if;
		end if;
	end process;
	
	-- Process to handle the next state logic
	process (rst, clk, reg_addr, WE)
	variable baud_configured : std_logic;
	variable clk_configured : std_logic;
	variable div_result_baud_wait : std_logic_vector ((nBitsLarge-1) downto 0);
	begin
		if rst = '1' then
			controlStates <= idle;
			baud_configured <= '0';
			clk_configured <= '0';
			div_result_baud_wait <= (others => '0');
			done <= '0';
		elsif rising_edge(clk) then
			case controlStates is				
				when idle =>
					done <= '0';
					-- Go to config state
					if (reg_addr = "00") and (WE = '1') then
						controlStates <= config_state_clk;
						clk_configured <= '1';						
					elsif (reg_addr = "01") and (WE = '1') then
						controlStates <= config_state_baud;						
						baud_configured <= '1';
					end if;
				
				when config_state_clk =>
					sigDivRst <= '1';
					sigDivNumerator <= config_clk;					
					if baud_configured = '0' then
						-- Baud not configured yet so wait for it...
						controlStates <= idle;
						done <= '1';
					else
						-- If already configured wait for division completion...
						controlStates <= start_division;
					end if;
					
				when config_state_baud =>
					sigDivRst <= '1';
					sigDivDividend <= config_baud;					
					if clk_configured = '0' then
						-- Clock not configured yet so wait for it...
						controlStates <= idle;
						done <= '1';
					else
						-- If already configured wait for division completion...
						controlStates <= start_division;
					end if;
				
				when start_division =>
					sigDivRst <= '0';
					controlStates <= wait_division;
				
				when wait_division =>
					if sigDivDone = '0' then
						controlStates <= wait_division;
					else
						-- Division done, get the result to put on the wait_cycles signal of the baud generator
						div_result_baud_wait := sigDivQuotient;
						controlStates <= config_state_baud_generator;
					end if;
				
				when config_state_baud_generator =>
					-- Configure the wait_cycle for the desired baud rate...
					baud_wait <= div_result_baud_wait;
					controlStates <= rx_tx_state;
					done <= '1';
				
				-- Control the serial_receiver or serial_transmitter block
				when rx_tx_state =>															
					controlStates <= rx_tx_state;
					if (WE = '1') and (start = '1') then
						if reg_addr = "10" then
							controlStates <= tx_state_wait;
							done <= '0';
						end if;												
					end if;
					
					if (WE = '0') and (start = '1') then
						if reg_addr = "11" then
							controlStates <= rx_state_wait;
							done <= '0';
						end if;
					end if;
					
					
				-- Send data and wait to transmit
				when tx_state_wait =>
					data_byte_tx <= byte_to_transmitt;
					if tx_data_sent = '0' then
						controlStates <= tx_state_wait;
					else
						controlStates <= rx_tx_state;
						done <= '1';
					end if;
				
				-- Receive data and wait to receive
				when rx_state_wait =>
					if rx_data_ready = '1' then
						byte_to_receive <= data_byte_rx;
						done <= '1';
						controlStates <= rx_tx_state;
					else
						controlStates <= rx_state_wait;
					end if;
			end case;		
		end if;
	end process;

end Behavioral;

