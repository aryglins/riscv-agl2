-- // +FHDR------------------------------------------------------------------------
-- // -----------------------------------------------------------------------------
-- // FILE NAME      : riscv_div
-- // AUTHOR         : caram
-- // AUTHOR'S EMAIL : caram@cin.ufpe.br
-- // -----------------------------------------------------------------------------
-- // RELEASE HISTORY
-- // VERSION 	DATE         AUTHOR		DESCRIPTION
-- // 1.0		2015-01-18   caram   	Initial version
-- // -----------------------------------------------------------------------------


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY wshbn_master IS 
PORT(
		CLK_I	: IN STD_LOGIC;
		RST_I : IN STD_LOGIC;
		ADR_O : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		DAT_I : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		--
		DAT_O : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		WE_O	: OUT STD_LOGIC;
		STB_O : OUT STD_LOGIC;
		ACK_I : IN STD_LOGIC;
		CYC_O : OUT STD_LOGIC;
		---
		st: OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		---
		stall_cpu : OUT STD_LOGIC;
		data_av : OUT STD_LOGIC;
		busy : OUT STD_LOGIC;
		add_i : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		data_i: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		data_o: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		rd    : IN STD_LOGIC;
		wr    : IN STD_LOGIC
		--cs		: IN STD_LOGIC
);
END wshbn_master;

ARCHITECTURE v1 OF wshbn_master IS


SIGNAL adr_r : STD_LOGIC_VECTOR(7 DOWNTO 0):=(others => '0');
SIGNAL dat_o_r : STD_LOGIC_VECTOR(31 DOWNTO 0):=(others => '0');
SIGNAL slave_data_r : STD_LOGIC_VECTOR(31 DOWNTO 0):=(others => '0');

SIGNAL  rd_slave_en:    std_logic:='0';
SIGNAL  stall_w    :    std_logic:='0';


TYPE wshbn_master_fsm IS (idle,c0,c1,c2,rd0,rd1,rd2);
SIGNAL state : wshbn_master_fsm:=idle;


BEGIN

PROCESS(rst_I,CLK_I,state,ACK_I)--,cs
BEGIN
IF (rst_I = '1') THEN
	state <= idle;
ELSE 
	IF(RISING_EDGE(CLK_I))THEN
		CASE (state) IS
		
		WHEN idle => IF(wr = '1' ) THEN
							state <= c0;
						ELSIF(rd = '1') THEN 
							 state <= rd0;
						 ELSE 
							state <= idle;
						 END IF;
		WHEN c0 => state <= c1;
		WHEN c1 =>  IF (ACK_I = '1') THEN
							state <= c2;
						ELSE 
							state <= c1;
						END IF;
		WHEN c2 =>  state <= idle;
		WHEN rd0 => state <= rd1;
		WHEN rd1 =>  IF (ACK_I = '1') THEN
							state <= rd2;
						ELSE 
							state <= rd1;
						END IF;
		WHEN rd2 =>  state <= idle;  
		END CASE;
	END IF;
END IF;
END PROCESS;

PROCESS(state)
BEGIN
		CASE (state) IS
		WHEN idle => WE_O  <= '0';
						 CYC_O <= '0';
						 --SEL_O <= '0';
						 STB_O <= '0';
						 rd_slave_en <= '0';
						 st<="00";
						 stall_w <= '0';
						 busy <= '0';
						 data_av <= '0';
		WHEN c0 	 => WE_O  <= '1';
						 CYC_O <= '1';
						 --SEL_O <= '0';
						 STB_O <= '1';
						 rd_slave_en <= '0';
						 st<="01";
						 stall_w <= '0';
						 busy <= '1';
						 data_av <= '0';
		WHEN c1	 => WE_O  <= '1';
						 CYC_O <= '1';
						 --SEL_O <= '0';
						 STB_O <= '1'; 
						 rd_slave_en <= '0';
						 st<="10";
						 stall_w <= '0';
						 busy <= '1';
						 data_av <= '1';
		WHEN c2	 => WE_O  <= '0';
						 CYC_O <= '0';
						 --SEL_O <= '0';
						 STB_O <= '0'; 
						 rd_slave_en <= '0';
						 st<="11";
						 stall_w<= '0';
						 busy <= '0';
						 data_av <= '0';
		WHEN rd0 	 => WE_O  <= '0';
						 CYC_O <= '1';
						 --SEL_O <= '0';
						 STB_O <= '1';
						 rd_slave_en <= '1';
						 st<="01";
						 stall_w<= '1';
						 busy <= '1';
						 data_av <= '0';
		WHEN rd1	 => WE_O  <= '0';
						 CYC_O <= '1';
						 --SEL_O <= '0';
						 STB_O <= '1'; 
						 rd_slave_en <= '1';
						 st<="10";
						 stall_w <= '1';
						 busy <= '1';
						 data_av <= '1';
		WHEN rd2	 => WE_O  <= '0';
						 CYC_O <= '0';
						 --SEL_O <= '0';
						 STB_O <= '0'; 
						 rd_slave_en <= '0';
						 st<="11";			
						 stall_w <= '0';	
						 busy <= '0'; 
						 data_av <= '0';
		END CASE;
END PROCESS;		

PROCESS(rst_i,clk_i,add_i)
BEGIN
IF (rst_i = '1') THEN
	adr_r	<= (others=>'0');
ELSE
	IF(RISING_EDGE(clk_i))THEN
			IF (wr = '1' OR rd = '1') THEN
				adr_r<= add_i;
			END IF;
	END IF;
END IF;
END PROCESS;


PROCESS(rst_i,clk_i, data_i)
BEGIN
IF (rst_i = '1') THEN
	dat_o_r<= (others=>'0');
ELSE
	IF(RISING_EDGE(clk_i))THEN
			IF (wr = '1') THEN
				dat_o_r<= data_i;
			END IF;
	END IF;
END IF;
END PROCESS;

PROCESS(clk_i, DAT_I,rd_slave_en,rst_i)
BEGIN
IF (rst_i = '1') THEN
	slave_data_r<= (others=>'0');
ELSE
	IF(RISING_EDGE(clk_i))THEN
			IF (rd_slave_en = '1') THEN
				slave_data_r<= DAT_I;
			END IF;
	END IF;
END IF;
END PROCESS;



DAT_O <= dat_o_r;
ADR_O <= adr_r;

data_o <= slave_data_r;


stall_cpu <= stall_w;


  
  


END v1;
