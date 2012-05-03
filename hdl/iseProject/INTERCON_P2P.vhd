
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity INTERCON_P2P is
port (
            -- External (non-WISHBONE) inputs
            EXTCLK: in std_logic;
            EXTRST: in std_logic;
            -- External signals for simulation purposes
            byte_out: out std_logic_vector(7 downto 0);
				data_avaible : out std_logic;
            tx: out std_logic;
			   rx : in std_logic
        );
end INTERCON_P2P;

architecture Behavioral of INTERCON_P2P is
component SYC0001a
    port(
            -- WISHBONE Interface
            CLK_O:  out std_logic;
            RST_O:  out std_logic;
            -- NON-WISHBONE Signals
            EXTCLK: in  std_logic;
            EXTRST: in  std_logic
         );
end component SYC0001a;

component SERIALMASTER is
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
end component;

component uart_wishbone_slave is
    Port ( RST_I : in  STD_LOGIC;
           CLK_I : in  STD_LOGIC;
           ADR_I0 : in  STD_LOGIC_VECTOR (1 downto 0);
           DAT_I0 : in  STD_LOGIC_VECTOR (31 downto 0);
           DAT_O0 : out  STD_LOGIC_VECTOR (31 downto 0);
           WE_I : in  STD_LOGIC;
           STB_I : in  STD_LOGIC;
           ACK_O : out  STD_LOGIC;
			  serial_in : in std_logic;
			  data_Avaible : out std_logic;											
			  serial_out : out std_logic
			  );
end component;
signal CLK : std_logic;
signal RST : std_logic;
signal ACK : std_logic;
signal WE  : std_logic;
signal STB  : std_logic;
signal ADR : std_logic_vector(  1 downto 0 ); 
signal dataI : std_logic_vector (31 downto 0);
signal dataO : std_logic_vector (31 downto 0);
begin
	uSysCon: component SYC0001a
    port map(
		 CLK_O   =>  CLK,
		 RST_O   =>  RST,
		 EXTCLK  =>  EXTCLK,
		 EXTRST  =>  EXTRST
    );
	
	uMasterSerial : component SERIALMASTER
	port map(
		ACK_I => ACK,
		ADR_O => ADR,
		CLK_I => CLK,
		CYC_O => open,
		DAT_I => dataI,
		DAT_O => dataO,
		RST_I => RST,
		SEL_O => open,
		STB_O => STB,
		byte_rec => byte_out,
		WE_O => WE
	);
	
	uUartWishboneSlave: component uart_wishbone_slave 
	port map(
		RST_I => RST,
		CLK_I => CLK,
		ADR_I0 => ADR,
		DAT_I0 => dataO,
		DAT_O0 => dataI,
		WE_I => WE,
		STB_I => STB,
		ACK_O => ACK,
		serial_in => rx,
		data_Avaible => open,
		serial_out => tx
   );

end Behavioral;

