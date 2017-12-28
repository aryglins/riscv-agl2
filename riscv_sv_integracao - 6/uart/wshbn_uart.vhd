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


ENTITY wshbn_uart IS
PORT(

	CLK_I	: IN STD_LOGIC;
	RST_I : IN STD_LOGIC;
	ADR_I : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
	DAT_I : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
	DAT_O : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
	WE_I	: IN STD_LOGIC;
	STB_I : IN STD_LOGIC;
	ACK_O : OUT STD_LOGIC;
	CYC_I : IN STD_LOGIC;
	----------------------
	uart_full : OUT STD_LOGIC;
	uart_empty: OUT STD_LOGIC;
	TXD : OUT STD_LOGIC;
	RXD : IN  STD_LOGIC
     );
END wshbn_uart;


ARCHITECTURE rtl OF wshbn_uart IS

SIGNAL tx_reg: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL rdrqst: STD_LOGIC;
SIGNAL empty: STD_LOGIC;
SIGNAL full: STD_LOGIC;

COMPONENT uart_fifo IS
	PORT
	(	
		aclr		: IN STD_LOGIC ;
		clock		: IN STD_LOGIC ;
		data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		rdreq		: IN STD_LOGIC ;
		wrreq		: IN STD_LOGIC ;
		empty		: OUT STD_LOGIC ;
		full		: OUT STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		usedw		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
END COMPONENT;

      
COMPONENT tx_module IS
PORT(
	  enable : IN STD_LOGIC;
     fifo_empty_n : IN STD_LOGIC;
	  rd_ack  : OUT STD_LOGIC;
	  tx_out: OUT STD_LOGIC;
     sys_clk: IN STD_LOGIC;
     rst: IN STD_LOGIC;
	  baud_i: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
     tx_in: IN STD_LOGIC_VECTOR(7 DOWNTO 0)
------------------------
);
END COMPONENT;      

COMPONENT receiver IS
PORT(
	  enable : IN STD_LOGIC;
     sin        :  IN STD_LOGIC;
	  sys_clk     :  IN STD_LOGIC;
	  rst         :  IN STD_LOGIC;
    	---------------------------
		baud_i: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
     data_out      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
     error_stop    : OUT STD_LOGIC;
     error_start   : OUT STD_LOGIC;       
	  data_avaliable: OUT STD_LOGIC
	);
END COMPONENT;

SIGNAL reg_wren  : STD_LOGIC:='0'; 
SIGNAL r_ack_o   : STD_LOGIC:='0'; 
SIGNAL out_reg : STD_LOGIC_VECTOR(15 DOWNTO 0):=(others => '0');


SIGNAL txd_r : STD_LOGIC_VECTOR(7 DOWNTO 0):=(others => '0');


SIGNAL d_in_mux : STD_LOGIC_VECTOR(7 DOWNTO 0):=(others => '0');
SIGNAL d_out_mux : STD_LOGIC_VECTOR(15 DOWNTO 0):=(others => '0');

SIGNAL ctrl_r : STD_LOGIC_VECTOR(7 DOWNTO 0):=(others => '0');
SIGNAL tx_data : STD_LOGIC_VECTOR(7 DOWNTO 0):=(others => '0');
SIGNAL rx_data : STD_LOGIC_VECTOR(7 DOWNTO 0):=(others => '0');
SIGNAL status_r : STD_LOGIC_VECTOR(15 DOWNTO 0):=(others => '0');
SIGNAL tx_status_w : STD_LOGIC_VECTOR(7 DOWNTO 0):=(others => '0');
SIGNAL rx_status_w : STD_LOGIC_VECTOR(7 DOWNTO 0):=(others => '0');

SIGNAL baud_r:  STD_LOGIC_VECTOR(15 DOWNTO 0):=(others => '0');
SIGNAL baud_wr  : STD_LOGIC:='0'; 

SIGNAL ctrl_wr  : STD_LOGIC:='0'; 
SIGNAL tx_fifo_wr  : STD_LOGIC:='0'; 
SIGNAL rx_fifo_rd : STD_LOGIC:='0'; 
SIGNAL reg_rden : STD_LOGIC:='0';
SIGNAL tx_fifo_empty : STD_LOGIC:='0';
SIGNAL rx_fifo_empty : STD_LOGIC:='0';
SIGNAL tx_fifo_full : STD_LOGIC:='0';
SIGNAL rx_fifo_full : STD_LOGIC:='0';

SIGNAL rdreq_w : STD_LOGIC:='0';
SIGNAL wrreq_w : STD_LOGIC:='0';

SIGNAL fifo_empty_w : STD_LOGIC:='0';

SIGNAL data_out_from_rx : STD_LOGIC_VECTOR(7 DOWNTO 0):=(others => '0');

--SIGNAL send    : STD_LOGIC;
SIGNAL data_rdy: STD_LOGIC:='0';
     ----------------------
SIGNAL stop_f  :  STD_LOGIC:='0';
SIGNAL start_f :  STD_LOGIC:='0';
SIGNAL empt     :STD_LOGIC:='0';
SIGNAL   fll: STD_LOGIC:='0';

SIGNAL rx_rdreq : STD_LOGIC:='0';
SIGNAL rx_wrreq : STD_LOGIC:='0';

TYPE st IS (s0,s1,s2);
signal fifo_st: st;


BEGIN


reg_rden <= CYC_I and STB_I and (not WE_I);
reg_wren <= CYC_I and STB_I and WE_I;
ACK_O <= r_ack_o;

-- SLAVE SÍNCRONO : ACK NO CLK_I SEGUINTE
PROCESS(CLK_I, CYC_I, STB_I, r_ack_o)
BEGIN
	IF(RISING_EDGE(CLK_I)) THEN
		r_ack_o <= CYC_I AND STB_I AND NOT(r_ack_o);
	END IF;
END PROCESS;



PROCESS(baud_wr, clk_I, rst_I, DAT_I)
BEGIN
IF(rst_I = '1') THEN
	baud_r <= (others => '0');
ELSE
	IF(RISING_EDGE(clk_I)) THEN
		IF(baud_wr = '1') THEN
			baud_r <= DAT_I(15 DOWNTO 0);
		END IF;
	END IF;
END IF;
END PROCESS;



--
--     ----------------------
--     wrt_en  : IN  STD_LOGIC;
--	  send    : IN STD_LOGIC;
--     data_rdy: OUT STD_LOGIC;
--     ----------------------
--     stop_f  : OUT STD_LOGIC;
--     start_f : OUT STD_LOGIC;
--	  empt     : OUT STD_LOGIC;
--	  fll: OUT STD_LOGIC;
--     ----------------------
--     data_in_to_tx    : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
--     data_out_from_rx : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)


--PROCESS(CLK_I,wrt_en,RST_I,data_in_to_tx)
--BEGIN
--IF( RST_I='1') THEN
--    tx_reg<= (OTHERS=>'0');
--ELSE
--IF RISING_EDGE(CLK_I) THEN
--  if(wrt_en = '1') then
--	tx_reg<= data_in_to_tx;
--END IF;
--end if;
--END IF;
--END PROCESS;

--CTRL_REG : 20h
ctrl_wr <= reg_wren and  ((NOT ADR_I(3)) AND (NOT ADR_I(2)) AND (NOT ADR_I(1)) AND (NOT ADR_I(0))) ;
--TX_FIFO : 21h
tx_fifo_wr <= reg_wren and r_ack_o and ( (NOT ADR_I(3)) AND (NOT ADR_I(2)) AND (NOT ADR_I(1)) AND ( ADR_I(0)));-- and (not tx_fifo_full);
--RX_FIFO : 21h
rx_fifo_rd <= reg_rden and ( (NOT ADR_I(3)) AND (NOT ADR_I(2)) AND (NOT ADR_I(1)) AND ( ADR_I(0))) and (not rx_fifo_empty);
--BAUDRATE: 22h
baud_wr <= reg_wren and ( (NOT ADR_I(3)) AND (NOT ADR_I(2)) AND (ADR_I(1)) AND ( NOT ADR_I(0) ) );

--RXTX_STATUS : 24h
status_r <= "0000" & tx_fifo_full & tx_fifo_empty & rx_fifo_full & rx_fifo_empty & rx_status_w(3 downto 0) & tx_status_w(3 downto 0);
----LINE_CTRL : 24h
--line_ctrl_wr <= reg_wren and ( (NOT ADR_I(3)) AND (ADR_I(2)) AND (NOT ADR_I(1)) AND ( NOT ADR_I(0)));




PROCESS(ctrl_wr, clk_I, rst_I, DAT_I)
BEGIN
IF(rst_I = '1') THEN
	ctrl_r <= (others => '0');
ELSE
	IF(RISING_EDGE(clk_I)) THEN
		IF(ctrl_wr = '1') THEN
			ctrl_r <= DAT_I(7 DOWNTO 0);
		END IF;
	END IF;
END IF;
END PROCESS;


WITH (reg_rden & ADR_I) SELECT
d_out_mux <= "00000000" & ctrl_r WHEN  "10000",
				 "00000000" & rx_data WHEN "10001",
				 baud_r WHEN "10010",
				 status_r WHEN "10011",
				 (others => '0') WHEN OTHERS;
DAT_O <= "0000000000000000" & d_out_mux;

rdreq_w <= rdrqst and ctrl_r(0);
wrreq_w <= tx_fifo_wr and ctrl_r(0);
				 
tx_fifo : uart_fifo
PORT MAP
(
	aclr => rst_i,
	clock		=> CLK_I,
	data		=> DAT_I(7 DOWNTO 0),
	rdreq		=> rdreq_w,
	wrreq		=> wrreq_w,
	empty		=> tx_fifo_empty,
	full		=> tx_fifo_full,
	q			=> tx_data,
	usedw		=> tx_status_w
);
uart_full <= tx_fifo_full;
uart_empty <= ctrl_r(0);--tx_fifo_empty;


rx_rdreq <= rx_fifo_rd and ctrl_r(0);

rx_wrreq <= data_rdy and ctrl_r(0); 

rx_fifo : uart_fifo
PORT MAP
(
	aclr => rst_i,
	clock		=> CLK_I,
	data		=> data_out_from_rx,
	rdreq		=> rx_rdreq,
	wrreq		=> rx_wrreq,
	empty		=> rx_fifo_empty,
	full		=> rx_fifo_full,
	q			=> rx_data,
	usedw		=> rx_status_w
);
--
U1: receiver
PORT MAP(
		enable => ctrl_r(0),
     sin      => RXD,     
	 sys_clk  => CLK_I,
	 rst      =>RST_I,  
	 baud_i => baud_r,
    	------------------------
     data_out  => data_out_from_rx,
     error_stop => stop_f,
     error_start => start_f,       
	 data_avaliable => data_rdy
	);    

fifo_empty_w <= not tx_fifo_empty;

--send <= reg_wren;--tx_fifo_wr;-- not tx_fifo_empty;
U2: tx_module 
PORT MAP(
	  enable => ctrl_r(0),
     fifo_empty_n => fifo_empty_w,
	  rd_ack  => rdrqst,
	  tx_out => TXD, 
     sys_clk => CLK_I,
     rst=> RST_I,
	  baud_i => baud_r,
     tx_in => tx_data
     );
--rdrqst <= '1';
	--empt<= rdrqst;
   
END rtl;