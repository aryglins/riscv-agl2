LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;


ENTITY tx_module IS

PORT(
	  enable : IN STD_LOGIC;
     fifo_empty_n : IN STD_LOGIC;
	  rd_ack  : OUT STD_LOGIC;
	  tx_out: OUT STD_LOGIC;
     sys_clk: IN STD_LOGIC;
     rst: IN STD_LOGIC;
	  ---
	  baud_i: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
	  ---
     tx_in: IN STD_LOGIC_VECTOR(7 DOWNTO 0)
     ------------------------
     
     );
END tx_module;

ARCHITECTURE camera_eye OF tx_module IS

TYPE state_type IS ( reset, idle, start, bit0, bit1, bit2, bit3, bit4, bit5, bit6, bit7, stop,endst);
SIGNAL state: state_type;

SIGNAL tx: STD_LOGIC:='1';
SIGNAL bd_en: STD_LOGIC:='0';
SIGNAL input_reg: STD_LOGIC_VECTOR(7 DOWNTO 0):=(others => '0');
SIGNAL output_reg: STD_LOGIC_VECTOR(7 DOWNTO 0):=(others => '0');
SIGNAL ready: STD_LOGIC:='0';
SIGNAL baudout: STD_LOGIC:='0';
SIGNAL en_count: STD_LOGIC:='0';
SIGNAL from_RX_in: STD_LOGIC:='0';
SIGNAL samp_clk: STD_LOGIC:='0';
SIGNAL clk_counter: STD_LOGIC_VECTOR(15 DOWNTO 0):=(others => '0');

SIGNAL start_detect: STD_LOGIC:='0';
SIGNAL error_vector: STD_LOGIC_VECTOR(3 DOWNTO 0):=(others => '0');


BEGIN
--baud_out<=baudout;
tx_out<= tx;

--sample_out<= samp_clk;
--outdetect<= start_detect;
-- BAUD = 9600  -> SAMPLING FREQ = 16* BAUD = 153600 Hz
-- 153600 => 6.51uS 
-- 6.51 / 20ns = 325,52 clock cycles 
-- clk_counter limit = 325 

PROCESS(sys_clk)
BEGIN
IF (bd_en = '0') THEN
        clk_counter<= (OTHERS =>'0');
        samp_clk<= '0'; 
        ELSE
       IF (RISING_EDGE(sys_clk)) THEN
        IF(enable = '1') THEN
         IF (clk_counter < baud_i) THEN  --433    5207
         clk_counter <= clk_counter + '1';
         ELSE clk_counter<= (OTHERS =>'0'); 
         
         END IF;
            
         IF(clk_counter = (baud_i - '1')) THEN --432
      --     baudout<= not baudout;
            samp_clk<= '1';
         ELSE samp_clk<= '0'; 
         END IF;
         
  --       IF(clk_counter= 5207) THEN
--           baudout<= not baudout; 
    --     END IF;
     
--     else clk_counter<=0;
--          samp_clk<= '0'; 
   END IF;
   END IF;
	END IF;
END PROCESS;





----------------------------------------------------------------------------------
--                         rx state machine                                     -- 
----------------------------------------------------------------------------------
--
--PROCESS(RX_in)
--BEGIN
--IF state= idle THEN
--    IF FALLING_EDGE(RX_in) THEN
--       start_detect<='1';
--    END IF;
--END IF;
--IF state= reset THEN
--      start_detect<='0';    
--END IF;
--END PROCESS;   
----------------------------------------------------------------------------------
--PROCESS(ready)
--BEGIN
--
--    IF RISING_EDGE(ready) THEN
--   
--END IF;
--END PROCESS;   


PROCESS(sys_clk,start_detect)
BEGIN

IF( rst='1') THEN
     state<= idle;
ELSE    
IF RISING_EDGE(sys_clk) THEN
	IF(enable = '1') THEN
       CASE state IS
              WHEN reset=> state<= idle;    
				  WHEN idle =>
                     if (fifo_empty_n  = '1') then
                       state<= start;
                       bd_en<='1';
                       else state <= RESET;
                            bd_en<='0';
                         end if;
              WHEN start=>
                        if (samp_clk= '1') then
                        state<= bit0;
                        else state <= start;
                        end if;
              WHEN bit0=> 
                         if (samp_clk= '1') then
                        state<= bit1;
                        else state <= bit0;
                        end if;                        
              WHEN bit1=> 
                         if (samp_clk= '1') then
                        state<= bit2;
                        else state <= bit1;
                        end if;
              WHEN bit2=>
                         if (samp_clk= '1') then
                        state<= bit3;
                        else state <= bit2;
                        end if;
                        
              WHEN bit3=>
                       if (samp_clk= '1') then
                        state<= bit4;
                        else state <= bit3;
                        end if;
              WHEN bit4=>
                       if (samp_clk= '1') then
                        state<= bit5;
                        else state <= bit4;
                        end if;
              WHEN bit5=>
                        if (samp_clk= '1') then
                        state<= bit6;
                        else state <= bit5;
                        end if;
              WHEN bit6=>
                        if (samp_clk= '1') then
                        state<= bit7;
                        else state <= bit6;
                        end if;
              WHEN bit7=>
                       if (samp_clk= '1') then
                        state<= stop;
                        else state <= bit7;
                        end if;
              WHEN stop=>
                      if (samp_clk= '1') then
                        state<= endst;
                        
                        else state <= stop;
                        end if;
					WHEN endst => 
							state <= reset;
                 
      END CASE;
END IF;
END IF;
END IF;
END PROCESS;

PROCESS(sys_clk,state)
BEGIN
IF RISING_EDGE(sys_clk) THEN
IF(enable = '1') THEN
CASE STATE IS
     WHEN reset => tx <='1';
	               rd_ack <= '0';
	  
     WHEN idle => tx <='1';
	               rd_ack <= '0';
                 -- state_out<= "0000";
     WHEN start => 
                  tx<= '0';
						rd_ack <= '0';
                  --state_out<= "0001";
     WHEN bit0 => 
                   tx<= tx_in(0);
						 rd_ack <= '0';
                  --state_out<= "0010";
     WHEN bit1 => 
                  tx<= tx_in(1);
						rd_ack <= '0';
                  ---state_out<= "0011";
     WHEN bit2 => 
                  tx<= tx_in(2);
						rd_ack <= '0';
                  --state_out<= "0100";
     WHEN bit3 => 
                  tx<= tx_in(3);
						rd_ack <= '0';
                  --state_out<= "0101";
     WHEN bit4 => 
                  tx<= tx_in(4);
						rd_ack <= '0';
                  --state_out<= "0110";
     WHEN bit5 => 
                  tx<= tx_in(5);
						rd_ack <= '0';
                  --state_out<= "0111";
     WHEN bit6 => 
                  tx<= tx_in(6);
						rd_ack <= '0';
                  --state_out<= "1000";
     WHEN bit7 => 
                  tx<= tx_in(7);
						rd_ack <= '0';
                  --state_out<= "1001";
     WHEN stop => 
                  tx<= '1';
						rd_ack <= '0';
                  --state_out<= "1010";
      WHEN endst => 
                  tx<= '1';
						rd_ack <= '1';
                  --state_out<= "1010";

END CASE;
END IF;
END IF;
END PROCESS;
	
END camera_eye;