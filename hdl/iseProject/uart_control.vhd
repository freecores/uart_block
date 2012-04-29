--! uart control unit
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--! Use CPU Definitions package
use work.pkgDefinitions.all;

entity uart_control is
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
			  WE	: in STD_LOGIC;
           reg_addr : in  STD_LOGIC_VECTOR (1 downto 0);			  
           DAT_I : in  STD_LOGIC_VECTOR ((nBitsLarge-1) downto 0);
           DAT_O : out  STD_LOGIC_VECTOR ((nBitsLarge-1) downto 0);
           tx_busy : in  STD_LOGIC;
           rx_ready : in  STD_LOGIC);
end uart_control;

architecture Behavioral of uart_control is
signal config_clk : std_logic_vector((nBitsLarge-1) downto 0);
signal config_baud : std_logic_vector((nBitsLarge-1) downto 0);
signal byte_out : std_logic_vector((nBitsLarge-1) downto 0);
signal byte_in : std_logic_vector((nBitsLarge-1) downto 0);
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
	
	-- Process that populate/read the uart control registers
	process (rst, clk, reg_addr,WE)
	begin 
		if rst = '1' then
			config_clk <= (others => '0');
			config_baud <= (others => '0');
			byte_out <= (others => '0');
			byte_in <= (others => '0');
		elsif rising_edge(clk) then
			if WE = '1' then
				case reg_addr is
					when "00" =>
						config_clk <= DAT_I;
					when "01" =>
						config_baud <= DAT_I;
					when "10" =>
						byte_out <= DAT_I((nBits-1) downto 0);
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
	begin
		if rst = '1' then
			controlStates <= idle;
			baud_configured <= '0';
			clk_configured <= '0';
		elsif rising_edge(clk) then
			case controlStates is				
				when idle =>
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
						-- Division done, configure the Baud generator
					end if;
				
			end case;		
		end if;
	end process;

end Behavioral;

