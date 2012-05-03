--! Top wishbone Master to test the uart_wishbone_slave
library ieee;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

--! Use CPU Definitions package
use work.pkgDefinitions.all;

entity SERIALMASTER is
	port(
            -- WISHBONE Signals
            ACK_I:  in  std_logic;
            ADR_O:  out std_logic_vector( 1 downto 0 );
            CLK_I:  in  std_logic;
            CYC_O:  out std_logic;
            DAT_I:  in  std_logic_vector( 31 downto 0 );
            DAT_O:  out std_logic_vector( 31 downto 0 );
            RST_I:  in  std_logic;
            SEL_O:  out std_logic;
            STB_O:  out std_logic;
            WE_O:   out std_logic;
				
				-- NON-WISHBONE Signals
				byte_rec : out std_logic_vector(7 downto 0)
         );

end SERIALMASTER;

architecture Behavioral of SERIALMASTER is
signal masterSerialStates : testMaster;
signal byteIncome : std_logic_vector(7 downto 0);
begin
	
	process (CLK_I)
	variable contWait : integer range 0 to 50000000;
	variable nextState: testMaster;
	begin
		if rising_edge(CLK_I) then
			if RST_I = '1' then
				masterSerialStates <= idle;
				nextState := idle;
				contWait := 0;
				byteIncome <= (others => '0');
			else
				case masterSerialStates is
					when idle =>
						masterSerialStates <= config_clock;
						nextState := idle;
					
					when config_clock =>
						nextState := config_baud;
						ADR_O <= "00";
						WE_O <= '1';
						STB_O <= '1';
						DAT_O <= conv_std_logic_vector(50000000, (nBitsLarge));		-- 50Mhz
						if ACK_I = '1' then
							-- Byte received wait some cycles to continue						
							masterSerialStates <= wait_cycles;									
							byte_rec	<= "00000001";
						end if;
					
					when config_baud =>
						nextState := send_byte;
						ADR_O <= "01";
						WE_O <= '1';
						STB_O <= '1';
						DAT_O <= conv_std_logic_vector(115200, (nBitsLarge));	--115200 bps
						if ACK_I = '1' then
							-- Byte received wait some cycles to continue
							masterSerialStates <= wait_cycles;													
							byte_rec	<= "00000010";
						end if;
					
					when send_byte =>
						nextState := receive_byte;
						ADR_O <= "10";
						WE_O <= '1';
						STB_O <= '1';
						--DAT_O <= conv_std_logic_vector(64, (nBitsLarge));	--Send the '@'
						DAT_O <= conv_std_logic_vector(0, (nBitsLarge-8)) & byteIncome;	--Send the '@'
						if ACK_I = '1' then
							-- Byte received wait some cycles to continue
							masterSerialStates <= wait_cycles;													
							byte_rec	<= "00000100";
						end if;
					
					when receive_byte =>
						nextState := send_byte;
						ADR_O <= "11";
						WE_O <= '0';
						STB_O <= '1';
						if ACK_I = '1' then
							-- Byte received wait some cycles to continue
							masterSerialStates <= wait_cycles;
							byte_rec	<= DAT_I(7 downto 0);
							byteIncome <= DAT_I(7 downto 0);
							--byte_rec	<= "00001000";							
						end if;
					
					when wait_cycles =>
						-- wait some cycles (90)
						if contWait < 25000000 then
							contWait := contWait + 1;
							STB_O <= '0';
						else
							contWait := 0;
							masterSerialStates <= nextState;
						end if;
				end case;
			end if;
		end if;		
	end process;
		

end Behavioral;

