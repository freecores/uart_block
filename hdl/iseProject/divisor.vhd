--! Unsigned division circuit, based on slow division algorithm (Restoring division)
--! http://en.wikipedia.org/wiki/Division_%28digital%29
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;

--! Use CPU Definitions package
use work.pkgDefinitions.all;

entity divisor is
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;			  
           quotient : out  STD_LOGIC_VECTOR ((nBitsLarge-1) downto 0);
			  reminder : out  STD_LOGIC_VECTOR ((nBitsLarge-1) downto 0);
           numerator : in  STD_LOGIC_VECTOR ((nBitsLarge-1) downto 0);
           divident : in  STD_LOGIC_VECTOR ((nBitsLarge-1) downto 0);
           done : out  STD_LOGIC);
end divisor;

architecture Behavioral of divisor is 

begin
	
	-- Division algorithm Q=N/D
	process (rst, clk)
	variable Q : unsigned(quotient'length-1 downto 0);
	variable R : unsigned(reminder'length-1 downto 0);
	variable D : unsigned(reminder'length-1 downto 0);
	variable N : unsigned(reminder'length-1 downto 0);
	variable iteractions : integer;
	begin
		if (rst = '1') then
			quotient <= (others => '0');
			reminder <= (others => '0');
			done <= '0';
			
			-- Initialize variables
			iteractions := quotient'length;			
			D := unsigned(divident);	
			N := unsigned(numerator);
			-- initialize quotient and remainder to zero
			Q := (others => '0');
			R := (others => '0');
		elsif rising_edge(clk) then 
			if iteractions > 0 then
				iteractions := iteractions - 1;
				-- left-shift R by 1 bit 
				R := (R((R'HIGH - 1) downto 0) & '0');
				
				--set the least-significant bit of R equal to bit i of the numerator(dividend)
				R(0)	:= N(iteractions);
				
				if (R >= D) then 
					R := R - D;
					Q(iteractions) := '1';
				end if;
			else
				done <= '1';
				quotient <= CONV_STD_LOGIC_VECTOR(Q,32);
				reminder <= CONV_STD_LOGIC_VECTOR(R,32);
			end if;
		end if;
	end process;

end Behavioral;

