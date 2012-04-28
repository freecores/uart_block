--! Baud generator
--! http://www.fpga4fun.com/SerialInterface.html
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

--! Use CPU Definitions package
use work.pkgDefinitions.all;

entity baud_generator is
    Port ( rst : in STD_LOGIC;
			  clk : in  STD_LOGIC;
           cycle_wait : in  STD_LOGIC_VECTOR ((nBitsLarge-1) downto 0);
           baud : out  STD_LOGIC);
end baud_generator;

architecture Behavioral of baud_generator is
signal genTick : std_logic;
begin
	process (rst, clk)
	variable wait_clk_cycles : STD_LOGIC_VECTOR ((nBitsLarge-1) downto 0);
	variable half_cycle : STD_LOGIC_VECTOR ((nBitsLarge-1) downto 0);
	begin
		if rst = '1' then
			wait_clk_cycles := (others => '0');
			half_cycle := '0' & cycle_wait(cycle_wait'high downto 1);
			genTick <= '0';
		elsif rising_edge(clk) then
			if wait_clk_cycles = cycle_wait then				
				genTick <= '1';				
				wait_clk_cycles := (others => '0');				
			else				
				wait_clk_cycles := wait_clk_cycles + conv_std_logic_vector(1, (nBitsLarge-1)); 
				-- If we're at half of the cycle
				if wait_clk_cycles = half_cycle then
					genTick <= '0';
				end if;				
			end if;			
		end if;
	end process;
	
	baud <= genTick;	

end Behavioral;

