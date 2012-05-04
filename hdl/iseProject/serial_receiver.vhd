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
signal current_s: rxStates; 
signal filterRx : rxFilterStates; 
signal syncDetected : std_logic;
--signal getPoint : std_logic;

begin
	-- First we need to oversample(4x baud rate) out serial channel to syncronize with the PC
	process (rst, baudOverSampleClk, serial_in, current_s)
	begin
		if rst = '1' then
			filterRx <= s0;			
			syncDetected <= '0';
		elsif rising_edge(baudOverSampleClk) then
			case filterRx is
				when s0 =>
					syncDetected <= '0';
					-- Spike down detected, verify if it's valid for at least 3 cycles
					-- We shoose a little bit on the end to enforce the baud clk to sample 
					-- the data at the right time... iE we're going to start sampling when
					-- the stop has been detected and we already for some of the first bit
					-- signal
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
					syncDetected <= '0';
					if serial_in = '0' then
						filterRx <= s3;
						syncDetected <= '0';
					else
						filterRx <= s0;
					end if;
				
				when s3 =>
					syncDetected <= '0';
					if serial_in = '0' then
						filterRx <= s4;
						syncDetected <= '0';
					else
						filterRx <= s0;
					end if;
				
				when s4 =>					
					-- Real Beginning of start bit detected 
					if serial_in = '0' then
						filterRx <= s4;
						syncDetected <= '1';					
					end if; 
					
					-- Reset out sync detector when finished to receive a byte
					if current_s = rx_idle then
						filterRx <= s0;						
					end if;
			end case;
		end if;
	end process;
		
	-- Process to handle the serial receive (On this case our reset is the syncDetected signal
	-- Always include all of your signals on the sensivity list!! (Even if the simulation is already ok)
	process (syncDetected, baudOverSampleClk, serial_in) 
	variable byteReceived : STD_LOGIC_VECTOR ((nBits-1) downto 0);
	variable waitBestPoint : integer range 0 to 10;
	constant numTicks : integer := 7;
	begin
		if syncDetected = '0' then
			current_s <= bit0;			
			data_ready <= '0';
			byteReceived := (others => '0');
			waitBestPoint := 0;
			--getPoint <= '0';
		elsif rising_edge(baudOverSampleClk) then
			case current_s is				
				when bit0 =>
					data_ready <= '0';				
					if (waitBestPoint < numTicks) then
						waitBestPoint := waitBestPoint + 1;
						--getPoint <= '0';
					else
						waitBestPoint := 0;
						byteReceived(0) := serial_in;					
						current_s <=  bit1;
						--getPoint <= '1';
					end if;										

				when bit1 =>
					data_ready <= '0';
					if (waitBestPoint < numTicks) then
						waitBestPoint := waitBestPoint + 1;
						--getPoint <= '0';
					else
						waitBestPoint := 0;
						byteReceived(1) := serial_in;					
						current_s <=  bit2;
						--getPoint <= '1';
					end if;					

				when bit2 =>
					data_ready <= '0';
					if (waitBestPoint < numTicks) then
						waitBestPoint := waitBestPoint + 1;
						--getPoint <= '0';
					else
						waitBestPoint := 0;
						byteReceived(2) := serial_in;					
						current_s <=  bit3;
						--getPoint <= '1';
					end if;					

				when bit3 =>
					data_ready <= '0';
					if (waitBestPoint < numTicks) then
						waitBestPoint := waitBestPoint + 1;
						--getPoint <= '0';
					else
						waitBestPoint := 0;
						byteReceived(3) := serial_in;					
						current_s <=  bit4;
						--getPoint <= '1';
					end if;					

				when bit4 =>
					data_ready <= '0';
					if (waitBestPoint < numTicks) then
						waitBestPoint := waitBestPoint + 1;
						--getPoint <= '0';
					else
						waitBestPoint := 0;
						byteReceived(4) := serial_in;					
						current_s <=  bit5;
						--getPoint <= '1';
					end if;					

				when bit5 =>
					data_ready <= '0';
					if (waitBestPoint < numTicks) then
						waitBestPoint := waitBestPoint + 1;
						--getPoint <= '0';
					else
						waitBestPoint := 0;
						byteReceived(5) := serial_in;					
						current_s <=  bit6;
						--getPoint <= '1';
					end if;					

				when bit6 =>
					data_ready <= '0';
					if (waitBestPoint < numTicks) then
						waitBestPoint := waitBestPoint + 1;
						--getPoint <= '0';
					else
						waitBestPoint := 0;
						byteReceived(6) := serial_in;					
						current_s <=  bit7;
						--getPoint <= '1';
					end if;										
					
				when bit7 =>
					data_ready <= '0';
					if (waitBestPoint < numTicks) then
						waitBestPoint := waitBestPoint + 1;
						--getPoint <= '0';
					else
						waitBestPoint := 0;
						byteReceived(7) := serial_in;					
						data_byte <= byteReceived;
						current_s <=  rx_stop;
						--getPoint <= '1';
					end if;									

				when rx_stop =>
					data_ready <= '1';			
					data_byte <= byteReceived;				
					current_s <=  rx_idle;	

				when rx_idle =>
					data_ready <= '1';			
					data_byte <= byteReceived;				
					current_s <=  rx_idle;	
										
			end case; 
		end if;
	end process;
		
end Behavioral;

