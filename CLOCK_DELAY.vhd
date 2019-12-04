library ieee;
use ieee.std_logic_1164.all;

entity CLOCK_DELAY is
	generic (w_N   :     natural := 2);
	port(i_SCLK    : in  std_logic;   -- IN
		  o_SCLKDIV : OUT STD_LOGIC := '0'); -- OUT
end entity CLOCK_DELAY;

architecture BEHAVIOR of CLOCK_DELAY is
BEGIN
	process(i_SCLK)
	variable TEMP : integer range 0 to w_N := 0;
	BEGIN
			
		if(rising_edge(i_SCLK)) then
			
			if(TEMP < (w_N / 2)) then
				
				o_SCLKDIV <= '1';
				TEMP := TEMP + 1;
					
			else
				
				o_SCLKDIV <= '0';
			
				if(TEMP = (w_N - 1)) then
							
					TEMP := 0;
							
				else
							
					TEMP := TEMP + 1;
					
				END IF;
			
			end if;
		
		end if;
		
	end process;
	
end BEHAVIOR;