LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;



---    MAQUINA DE ESTADOS COM 3 ESTADOS:
 --         IDLE
 --       SAMPLING 
 --         RESET
------------------------------------------
--     BORDA DE DESCIDA DE sin ATIVA MAQ DE ESTADOS 
--     'SAMPLING' ATIVA SAMPLER: PROCESSO Q A CADA sampler_clk (1/2 baud) AMOSTRA O VALOR DE sin ARMAZENA EM UM REG DE DESLOCAMENTO.
--     AO FIM DE 10 'samples'  START + 8 BITS + STOP , PASSA PARA A FRENTE ('ARQUITET. PIPELINE')
--              PROXIMO ESTAGIO CONFERE INTEGRIDADE. BITS DE START- STOP, SE START = '0' E STOP = '1', MANDA O BYTE P/ SAIDA
--

ENTITY receiver IS

PORT(
	 enable : IN STD_LOGIC;
     sin         :  IN STD_LOGIC;
	 sys_clk  :  IN STD_LOGIC;
	 rst         :  IN STD_LOGIC;
    	---------------------------
    -- estado  : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
   --  baudout : OUT STD_LOGIC;
    -- sampout : OUT STD_LOGIC;	
	 baud_i: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
     data_out    : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
     error_stop : OUT STD_LOGIC;
     error_start : OUT STD_LOGIC;       
	 data_avaliable: OUT STD_LOGIC
	);
END receiver;

ARCHITECTURE homer OF receiver IS



SIGNAL start_detected      : STD_LOGIC; -- HABILITA BAUD_RATE A PARTIR DA DETEC��O DE BORDA DE DESCIDA
SIGNAL data_out_mux : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL bdcounter    : STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL baud         : STD_LOGIC;
SIGNAL sampled_data : STD_LOGIC_VECTOR(9 DOWNTO 0);
SIGNAL s_done       : STD_LOGIC;
SIGNAL data_reg     : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL stop_errf    : STD_LOGIC;
SIGNAL start_errf    : STD_LOGIC;
SIGNAL valid_flg    : STD_LOGIC;
SIGNAL bdcnt        : INTEGER RANGE 0 TO 20;

SIGNAL s_clk       : STD_LOGIC;  

TYPE control_state IS (IDLE, START_BIT, BIT0,BIT1,BIT2,BIT3,BIT4,BIT5,BIT6,BIT7,STOP_BIT, preRESET,RESET );
    attribute syn_encoding : string;
	attribute syn_encoding of control_state : type is "safe";
SIGNAL state  : control_state;


BEGIN

data_avaliable<= valid_flg;
error_start<= start_errf;
error_stop<= stop_errf;
data_out<= data_reg;
--sampout<= s_clk;
--baudout<= baud;

PROCESS(sin,rst,state) 
BEGIN
IF (rst= '1' OR state = reset) THEN
	   start_detected <= '0';	 
	   ELSE 
       IF (falling_edge(sin)) THEN
			IF (enable = '1') THEN
              start_detected <= '1';
	   END IF;
		END IF;
END IF;
END PROCESS;

--------------------------------
-- GERADOR DE BAUD
--------------------------------
PROCESS(bdcounter, sys_clk) 
BEGIN
IF (enable = '1') THEN
 IF (start_detected = '1') THEN
           IF RISING_EDGE(sys_clk) THEN
                IF (bdcounter < baud_i) THEN --433
				bdcounter<= bdcounter + '1';
                ELSE
				bdcounter<=  (OTHERS =>'0');
		        END IF;
		 

          IF(bdcounter = (baud_i - '1')) THEN -- 432
                baud<= '1';
          ELSE
                baud<= '0';
          END IF;
          
          IF(bdcounter = ("0" & baud_i(15 downto 1))) THEN --216
                s_clk<='1';
          ELSE
                s_clk<='0';
          END IF;
  END IF;
  ELSE
    s_clk<='0';
    baud<='0';
    bdcounter<= (OTHERS =>'0');
END IF; 
END IF;      
END PROCESS;
----------------------------------

PROCESS(rst,sys_clk)
BEGIN
IF (rst = '1') THEN
    state<= IDLE;
    ELSE
    IF (RISING_EDGE(sys_clk) ) THEN
	 IF (enable = '1') THEN
       CASE (state) IS
            
            WHEN IDLE =>
                        IF (start_detected = '1') THEN
                            state<= START_BIT;
                        ELSE
                            state<= IDLE;
                        END IF;    
            WHEN START_BIT =>
								IF(s_clk = '1')THEN
                         sampled_data(0) <= sin;
								END IF; 
                        IF (baud = '1') THEN
                            state<= BIT0;
                        ELSE
                            state<= START_BIT; 
                        END IF;                   
            WHEN BIT0 =>
                        IF(s_clk = '1')THEN
                            sampled_data(1) <= sin; 
                        END IF;      
                        IF (baud = '1') THEN
                            state<= BIT1;
                        ELSE
                            state<= BIT0;
                        END IF; 
            WHEN BIT1 =>
                         IF(s_clk = '1')THEN
                            sampled_data(2) <= sin; 
                         END IF;    
                        IF (baud = '1') THEN
                            state<= BIT2;
                        ELSE
                            state<= BIT1;
                        END IF;
            WHEN BIT2 =>
                        IF(s_clk = '1')THEN
                            sampled_data(3) <= sin; 
                         END IF;
                        IF (baud = '1') THEN
                            state<= BIT3;
                        ELSE
                            state<= BIT2;
                        END IF;
            WHEN BIT3 =>
                        IF(s_clk = '1')THEN
                            sampled_data(4) <= sin; 
                         END IF;
                        IF (baud = '1') THEN
                            state<= BIT4;
                        ELSE
                            state<= BIT3;
                        END IF;
            WHEN BIT4 =>
                        IF(s_clk = '1')THEN
                            sampled_data(5) <= sin; 
                         END IF;
                        IF (baud = '1') THEN
                            state<= BIT5;
                        ELSE
                            state<= BIT4;
                        END IF;
            WHEN BIT5 =>
                        IF(s_clk = '1')THEN
                            sampled_data(6) <= sin; 
                         END IF;
                        IF (baud = '1') THEN
                            state<= BIT6;
                        ELSE
                            state<= BIT5;
                        END IF;
            WHEN BIT6 =>
                        IF(s_clk = '1')THEN
                            sampled_data(7) <= sin; 
                         END IF;
                        IF (baud = '1') THEN
                            state<= BIT7;
                        ELSE
                            state<= BIT6;
                        END IF;
            WHEN BIT7 =>IF(s_clk = '1')THEN
                            sampled_data(8) <= sin; 
                         END IF;
                        IF (baud = '1') THEN
                            state<= STOP_BIT;
                        ELSE
                            state<= BIT7;
                        END IF;
            WHEN STOP_BIT =>
                        IF(s_clk = '1')THEN
                            sampled_data(9) <= sin; 
                         END IF;
                        IF (baud = '1') THEN
                            state<= preRESET;
                        ELSE
                            state<= STOP_BIT;
                        END IF;
            WHEN preRESET =>
                        STATE<= RESET;
            WHEN RESET =>
                        STATE<= IDLE;            
       END CASE;
      END IF;
		END IF;
END IF;
END PROCESS;

--
--PROCESS(rst,sys_clk,state, sampled_data)
--	BEGIN
--	IF (rst = '1'OR state= IDLE ) THEN
--	   -- data_reg<= (OTHERS=>'0');
--		stop_errf  <= '0';
--		start_errf <= '0'; 
--		valid_flg <= '0';
--	ELSE	
--	IF (RISING_EDGE(sys_clk)) THEN
--		IF (state = preRESET) THEN
--			IF ((sampled_data(0) = '0') AND (sampled_data(9) = '1')) THEN
--				data_reg<= sampled_data(8 DOWNTO 1);
--				valid_flg <= '1';
--		    ELSE
--				IF (sampled_data(0) = '1') THEN
--                     start_errf<= '1';
--                END IF;
--                IF (sampled_data(9) = '0') THEN
--                     stop_errf<= '1';
--                END IF;
--            END IF;
--       END IF;
--    END IF;
--END IF;
--END PROCESS; 


PROCESS(rst,sys_clk,state, sampled_data)
	BEGIN
	IF (rst = '1'OR state= IDLE ) THEN
	   -- data_reg<= (OTHERS=>'0');
		stop_errf  <= '0';
		start_errf <= '0'; 
		valid_flg <= '0';
	ELSE	
	IF (RISING_EDGE(sys_clk)) THEN
	IF (enable = '1') THEN
		IF (state = preRESET) THEN
			
				IF ((sampled_data(0) = '0') AND (sampled_data(9) = '1')) THEN
				data_reg<= sampled_data(8 DOWNTO 1);
				valid_flg <= '1';
		    ELSE
				IF (sampled_data(0) = '1') THEN
                     start_errf<= '1';
                END IF;
                IF (sampled_data(9) = '0') THEN
                     stop_errf<= '1';
                END IF;
            END IF;
       END IF;
    END IF;
END IF;
END IF;
END PROCESS; 

--PROCESS(state,sin)
--BEGIN
--       CASE (state) IS
--            
--            
--            WHEN START_BIT =>
--                         IF(s_clk = '1')THEN
--                            sampled_data(0) <= sin; 
--                         END IF;                      
--            WHEN BIT0 =>
--                         IF(s_clk = '1')THEN
--                            sampled_data(1) <= sin; 
--                         END IF;      
--            WHEN BIT1 =>
--                        IF(s_clk = '1')THEN
--                            sampled_data(2) <= sin; 
--                         END IF;
--            WHEN BIT2 =>
--                        IF(s_clk = '1')THEN
--                            sampled_data(3) <= sin; 
--                         END IF;
--            WHEN BIT3 =>
--                        IF(s_clk = '1')THEN
--                            sampled_data(4) <= sin; 
--                         END IF;
--            WHEN BIT4 =>
--                        IF(s_clk = '1')THEN
--                            sampled_data(5) <= sin; 
--                         END IF;
--            WHEN BIT5 =>
--                     IF(s_clk = '1')THEN
--                            sampled_data(6) <= sin; 
--                         END IF;
--            WHEN BIT6 =>
--                        IF(s_clk = '1')THEN
--                            sampled_data(7) <= sin; 
--                         END IF;
--            WHEN BIT7 =>
--                        IF(s_clk = '1')THEN
--                            sampled_data(8) <= sin; 
--                         END IF;
--            WHEN STOP_BIT =>
--                        IF(s_clk = '1')THEN
--                            sampled_data(9) <= sin; 
--                         END IF;
--           WHEN OTHERS =>   sampled_data<= sampled_data;             
--       END CASE;
--END PROCESS;



--PROCESS(state)
--BEGIN
--       CASE (state) IS
--            
--            WHEN IDLE =>
--                       estado<= "1111";
--            WHEN START_BIT =>
--                             estado<= "0001";                
--            WHEN BIT0 =>
--                       estado<= "0010";
--                            
--            WHEN BIT1 =>
--                       estado<= "0011";
--            WHEN BIT2 =>
--                       estado<= "0100";
--            WHEN BIT3 =>
--                        estado<= "0101";
--            WHEN BIT4 =>
--                        estado<= "0110";
--            WHEN BIT5 =>
--                    estado<= "0111";
--            WHEN BIT6 =>
--                       estado<= "1000";
--            WHEN BIT7 =>
--                        estado<= "1001";
--            WHEN STOP_BIT =>
--                      estado<= "1010";
--            WHEN RESET =>
--                        estado<= "1011";
--            WHEN preRESET =>
--                        estado<= "0000";            
--       END CASE;
--    
--END PROCESS;






END homer;





	
