LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY TOP_LEVEL IS
	PORT(i_SCLK : IN  STD_LOGIC;
		  i_MOSI : IN  STD_LOGIC;
		  i_SSn  : IN  STD_LOGIC;
		  o_MISO : OUT STD_LOGIC);
END ENTITY TOP_LEVEL;

ARCHITECTURE BEHAVIOR OF TOP_LEVEL IS

SIGNAL w_SCLKDIV      : STD_LOGIC;
SIGNAL w_MISO         : STD_LOGIC;
SIGNAL w_SCLKPHYSICAL : STD_LOGIC;
SIGNAL w_MOSI         : STD_LOGIC;
SIGNAL w_SSn          : STD_LOGIC;

BEGIN

	CLOCK_DELAY : ENTITY WORK.CLOCK_DELAY PORT MAP(i_SCLK    => i_SCLK,
																  o_SCLKDIV => w_SCLKDIV);
																  
	PHYSICAL_LAYER : ENTITY WORK.PHYSICAL_LAYER PORT MAP(i_SCLK    => i_SCLK,
																		  i_SCLKDIV => w_SCLKDIV,
																		  i_MOSI    => i_MOSI,
																		  i_MISO    => w_MISO,
																		  i_SSn     => i_SSn,
																		  o_SCLK    => w_SCLKPHYSICAL,
																		  o_MOSI    => w_MOSI,
																		  o_MISO    => o_MISO,
																		  o_SSn     => w_SSn);
	
	LAYER_LINK : ENTITY WORK.LAYER_LINK PORT MAP(i_SCLK => w_SCLKPHYSICAL,
															   i_MOSI => w_MOSI,
																i_SSn  => w_SSn,
																o_MISO => w_MISO);

END BEHAVIOR;