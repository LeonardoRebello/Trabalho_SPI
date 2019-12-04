LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY LAYER_LINK is
	PORT(i_SCLK : IN  STD_LOGIC;
	     i_MOSI : IN  STD_LOGIC;
		  i_SSn  : IN  STD_LOGIC;
		  o_MISO : OUT STD_LOGIC);
END LAYER_LINK;

ARCHITECTURE BEHAVIOR OF LAYER_LINK IS

TYPE t_STATE IS (OCIOSO, CONTROLE, PARIDADEINSTRUCAO, INSTRUCAO, LEITURA, ESPERAACKNACK, 
	CONFIMALEITURA, ESCRITA, PARIDADEESCRITA, ENVIAACKNACK, ENVIAACKNACKI);
SIGNAL ATUAL              : t_STATE;
SIGNAL w_CONTADOR         : INTEGER RANGE 0 TO 9 := 0;
SIGNAL w_CONTADORPARIDADE : INTEGER RANGE 0 TO 9 := 0;
SIGNAL w_DATARECEIPT      : STD_LOGIC_VECTOR(8 DOWNTO 0);
SIGNAL w_DATA             : STD_LOGIC;
SIGNAL w_REGISTER         : STD_LOGIC_VECTOR(7 DOWNTO 0) := X"00";

BEGIN

	PROCESS (i_SSn, i_SCLK)
	BEGIN
		
		IF (i_SSn = '1') THEN
		
			ATUAL <= OCIOSO;
			
		ELSIF (RISING_EDGE(i_SCLK)) THEN
		
			CASE ATUAL is
	
				WHEN OCIOSO =>
				
					w_CONTADOR <= 0;
					w_CONTADORPARIDADE <= 0;
					ATUAL <= CONTROLE;
			
				WHEN CONTROLE => 
			
					w_CONTADOR <= w_CONTADOR + 1;
					w_DATARECEIPT <= STD_LOGIC_VECTOR(SHIFT_LEFT(UNSIGNED(w_DATARECEIPT), 1));
					w_DATARECEIPT(0) <= i_MOSI;
			
					IF(w_CONTADOR < 8) THEN
				
						IF(i_MOSI = '1') THEN
						
							w_CONTADORPARIDADE <= w_CONTADORPARIDADE + 1;
						
						END IF;
						
						ATUAL <= CONTROLE;
				
					ELSE
						
						w_CONTADOR <= 0;
						ATUAL <= PARIDADEINSTRUCAO;
				
					END IF;
					
				WHEN PARIDADEINSTRUCAO =>
				
					IF((((w_CONTADORPARIDADE mod 2) = 0) AND (w_DATARECEIPT(0) = '0')) OR
					 (((w_CONTADORPARIDADE mod 2) = 1) AND (w_DATARECEIPT(0) = '1'))) THEN
					
						w_DATA <= '0';
						ATUAL <= INSTRUCAO;
					
					ELSE
					
						w_DATA <= '1';
						ATUAL <= ENVIAACKNACKI;
					
					END IF;
				
				WHEN ENVIAACKNACKI =>
				
					ATUAL <= OCIOSO;
				
				WHEN INSTRUCAO =>
				
					w_CONTADORPARIDADE <= 0;
					w_DATA <= 'U';
					
					IF(w_DATARECEIPT(8 DOWNTO 1) = X"00") THEN
					
						ATUAL <= ESCRITA;
					
					ELSIF(w_DATARECEIPT(8 DOWNTO 1) = X"FF") THEN
					
						ATUAL <= LEITURA;
					
					ELSE
					
						ATUAL <= OCIOSO;
					
					END IF;
					
				WHEN LEITURA =>
				
					IF(w_CONTADOR = 9) THEN
					
						ATUAL <= ESPERAACKNACK;
						
					ELSE
					
						w_CONTADOR <= w_CONTADOR + 1;
					
						IF(w_CONTADOR < 8) THEN
					
							w_DATA <= w_REGISTER(7 - w_CONTADOR);
					
							IF(w_DATA = '1') THEN
					
								w_CONTADORPARIDADE <= w_CONTADORPARIDADE + 1;
					
							END IF;
						
						ELSE
					
							IF((w_CONTADORPARIDADE MOD 2) = 0) THEN
						
								w_DATA <= '0';
							
							ELSE
						
								w_DATA <= '1';
							
							END IF;
						
						END IF;
					
					END IF;
					
				WHEN ESPERAACKNACK =>
				
					ATUAL <= CONFIMALEITURA;
					
				WHEN CONFIMALEITURA =>
				
					w_DATA <= 'U';
					w_CONTADOR <= 0;
					w_CONTADORPARIDADE <= 0;
					
					IF(i_MOSI = '0') THEN
					
						ATUAL <= OCIOSO;
					
					ELSE
					
						ATUAL <= LEITURA;
					
					END IF;
					
				WHEN ESCRITA =>
				
					w_CONTADOR <= w_CONTADOR + 1;
					w_DATARECEIPT <= STD_LOGIC_VECTOR(SHIFT_LEFT(UNSIGNED(w_DATARECEIPT), 1));
					w_DATARECEIPT(0) <= i_MOSI;
					
					IF(w_CONTADOR < 8) THEN
					
						IF(i_MOSI = '1') THEN
						
							w_CONTADORPARIDADE <= w_CONTADORPARIDADE + 1;
						
						END IF;
					
						ATUAL <= ESCRITA;
					
					ELSE
					
						ATUAL <= PARIDADEESCRITA;
					
					END IF;
					
				WHEN PARIDADEESCRITA =>
				
					w_CONTADOR <= 0;
					
					IF((((w_CONTADORPARIDADE mod 2) = 0) AND (w_DATARECEIPT(0) = '0')) OR
					 (((w_CONTADORPARIDADE mod 2) = 1) AND (w_DATARECEIPT(0) = '1'))) THEN
					 
						w_REGISTER <= w_DATARECEIPT(8 DOWNTO 1);
						w_DATA <= '0';
					 
					ELSE
				
						w_DATA <= '1';
					
					END IF;
					
					ATUAL <= ENVIAACKNACK;
				
				WHEN ENVIAACKNACK =>
				
					IF(w_DATA = '1') THEN
					
						ATUAL <= ESCRITA;
					
					ELSE
					
						ATUAL <= OCIOSO;
					
					END IF;
					
			END CASE;
		
		END IF;
	
	END PROCESS;
	
	o_MISO <= w_DATA WHEN ATUAL = INSTRUCAO ELSE w_DATA WHEN ATUAL = LEITURA 
					ELSE w_DATA WHEN ATUAL = ENVIAACKNACK ELSE w_DATA WHEN ATUAL = ENVIAACKNACKI ELSE 'U';
	
END BEHAVIOR;