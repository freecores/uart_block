--! Top level for interconnection between communication blocks: serial_transmitter, serial_receiver, baud_generator
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--! Use CPU Definitions package
use work.pkgDefinitions.all;

entity uart_communication_blocks is
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
end uart_communication_blocks;

architecture Behavioral of uart_communication_blocks is

-- Declare components...
component baud_generator is
    Port ( rst : in STD_LOGIC;
			  clk : in  STD_LOGIC;
           cycle_wait : in  STD_LOGIC_VECTOR ((nBitsLarge-1) downto 0);
			  baud_oversample : out std_logic;
           baud : out  STD_LOGIC);
end component;

component serial_transmitter is
    Port ( rst : in  STD_LOGIC;
           baudClk : in  STD_LOGIC;
           data_byte : in  STD_LOGIC_VECTOR ((nBits-1) downto 0);
			  data_sent : out STD_LOGIC;
           serial_out : out  STD_LOGIC);
end component;

component serial_receiver is
    Port ( 
			  rst : in STD_LOGIC;
			  baudClk : in  STD_LOGIC;
			  baudOverSampleClk : in  STD_LOGIC;
           serial_in : in  STD_LOGIC;
           data_ready : out  STD_LOGIC;
           data_byte : out  STD_LOGIC_VECTOR ((nBits-1) downto 0));
end component;
signal baud_tick : std_logic;
signal baud_tick_oversample : std_logic;
begin
	-- Instantiate baud generator
	uBaudGen : baud_generator port map (
		rst => rst,
		clk => clk,
		cycle_wait => cycle_wait_baud,
		baud_oversample => baud_tick_oversample,
		baud => baud_tick		
	);
	
	-- Instantiate serial_transmitter
	uTransmitter : serial_transmitter port map (
		rst => not start_tx,
		baudClk => baud_tick,
		data_byte => byte_tx,
		data_sent => data_sent_tx,
		serial_out => serial_out 
	);
	
	-- Instantiate serial_receiver
	uReceiver : serial_receiver port map(
		rst => rst,
		baudClk => baud_tick,
		baudOverSampleClk => baud_tick_oversample,
		serial_in => serial_in,
		data_ready => data_received_rx,
		data_byte => byte_rx
	);

end Behavioral;

