--! Data receiver
--! http://www.fpga4fun.com/SerialInterface.html
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--! Use CPU Definitions package
use work.pkgDefinitions.all;

entity serial_receiver is
    Port ( 
			  rst : in STD_LOGIC;
			  baudClk : in  STD_LOGIC;
			  baudOverSampleClk : in  STD_LOGIC;
           serial_in : in  STD_LOGIC;
           data_ready : out  STD_LOGIC;
           data_byte : out  STD_LOGIC_VECTOR ((nBits-1) downto 0));
end serial_receiver;

architecture Behavioral of serial_receiver is
signal current_s,next_s: rxStates; 
signal filterRx : rxFilterStates; 
signal syncDetected : std_logic;

begin
	-- First we need to oversample(8x baud rate) out serial channel to syncronize with the PC
	process (rst, baudOverSampleClk, serial_in)
	begin
		if rst = '1' then
			filterRx <= s0;			
			syncDetected <= '0';
		elsif rising_edge(baudOverSampleClk) then
			case filterRx is
				when s0 =>
					syncDetected <= '0';
					-- Spike down detected, verify if it's valid for at least 3 cycles
					if serial_in = '0' then
						filterRx <= s1;						
					else
						filterRx <= s0;						
					end if;
					
				when s1 =>
					syncDetected <= '0';
					if serial_in = '0' then
						filterRx <= s2;
						syncDetected <= '0';
					else
						filterRx <= s0;
					end if;
				
				when s2 =>					
					-- Real Beginning of start bit detected 
					if serial_in = '0' then
						filterRx <= s2;
						syncDetected <= '1';
					else
						-- Start bit end detected
						--filterRx <= s2;
						--syncDetected <= '1';
					end if; 
			end case;
		end if;
	end process;
	
	-- Next state logic for rx Receiver (On this case our reset is the syncDetected signal
	process (syncDetected, baudClk, serial_in) 
	begin
		if syncDetected = '0' then
			current_s <= rx_idle;			
		elsif rising_edge(baudClk) then
			current_s <= next_s;
		end if;
	end process;
	
	-- Process to handle the serial receive
	process (current_s) 
	begin
		case current_s is
			when rx_idle =>
				data_ready <= '0';
				--data_byte <= (others => 'Z');
				next_s <=  bit0;
			
			when bit0 =>
				data_ready <= '0';
				data_byte(0) <= serial_in;
				next_s <=  bit1;
			
			when bit1 =>
				data_ready <= '0';
				data_byte(1) <= serial_in;
				next_s <=  bit2;
			
			when bit2 =>
				data_ready <= '0';
				data_byte(2) <= serial_in;
				next_s <=  bit3;
			
			when bit3 =>
				data_ready <= '0';
				data_byte(3) <= serial_in;
				next_s <=  bit4;
			
			when bit4 =>
				data_ready <= '0';
				data_byte(4) <= serial_in;
				next_s <=  bit5;
			
			when bit5 =>
				data_ready <= '0';
				data_byte(5) <= serial_in;
				next_s <=  bit6;
			
			when bit6 =>
				data_ready <= '0';
				data_byte(6) <= serial_in;
				next_s <=  bit7;
				
			when bit7 =>
				data_ready <= '0';
				data_byte(7) <= serial_in;
				next_s <=  rx_stop;
			
			when rx_stop =>
				data_ready <= '1';
				next_s <=  rx_idle;
			
		end case;
	end process;

end Behavioral;

