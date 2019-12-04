LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY PHYSICAL_LAYER is
	port(i_SCLK    : in  std_logic;
		  i_SCLKDIV : in  STD_LOGIC;
		  i_MOSI    : in  std_logic;
		  i_MISO    : in  std_logic;
		  i_SSn     : in  std_logic;
		  o_SCLK    : out std_logic;
		  o_MOSI    : out std_logic;
		  o_MISO    : out std_logic;
		  o_SSn     : out std_logic);
END ENTITY PHYSICAL_LAYER;

architecture BEHAVIOR of PHYSICAL_LAYER is

signal w_MOSI     : std_logic;
SIGNAL w_MISO     : STD_LOGIC;

begin

	p_MOSI : process(i_SCLK, i_MOSI, i_SSn)
	begin
	
		IF(i_SSn = '0' AND RISING_EDGE(i_SCLK)) THEN
			
			w_MOSI <= i_MOSI;
			
		END IF;
		
	end process p_MOSI;
	
	p_MISO : PROCESS(i_SCLK, i_MISO, i_SSn)
	BEGIN
	
		IF(i_SSn = '0') THEN
						
			IF(i_SCLK = '1') THEN
				w_MISO <= i_MISO;
			ELSIF(i_SCLK = '0') THEN
				w_MISO <= '0';
				
				IF(i_MISO = 'U') THEN
					w_MISO <= 'U';
				END IF;
				
			END IF;
		
		END IF;

	END PROCESS p_MISO;

	o_MOSI <= w_MOSI;
	o_MISO <= w_MISO;
	o_SSn  <= i_SSn;
	o_SCLK <= i_SCLKDIV;
	
end BEHAVIOR;

