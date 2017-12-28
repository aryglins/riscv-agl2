LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;


ENTITY uart_phy IS
PORT(

	CLK_I	: IN STD_LOGIC;
	RST_I : IN STD_LOGIC;
	ADR_I : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
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
END uart_phy;


ARCHITECTURE rtl OF uart_phy IS

SIGNAL tx_reg: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL rdrqst: STD_LOGIC;
SIGNAL empty: STD_LOGIC;
SIGNAL full: STD_LOGIC;

COMPONENT uart_fifo IS
	PORT
	(
		clock		: IN STD_LOGIC ;
		data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		rdreq		: IN STD_LOGIC ;
		wrreq		: IN STD_LOGIC ;
		empty		: OUT STD_LOGIC ;
		full		: OUT STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		usedw		: OUT STD_LOGIC_VECTOR (3 DOWNTO 0)
	);
END COMPONENT;

      
COMPONENT tx_module IS
PORT(
     fifo_empty_n : IN STD_LOGIC;
	  rd_ack  : OUT STD_LOGIC;
	  tx_out: OUT STD_LOGIC;
     sys_clk: IN STD_LOGIC;
     rst: IN STD_LOGIC;
     tx_in: IN STD_LOGIC_VECTOR(7 DOWNTO 0)
------------------------
);
END COMPONENT;      

COMPONENT receiver IS
PORT(
     sin        :  IN STD_LOGIC;
	  sys_clk     :  IN STD_LOGIC;
	  rst         :  IN STD_LOGIC;
    	---------------------------
     data_out      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
     error_stop    : OUT STD_LOGIC;
     error_start   : OUT STD_LOGIC;       
	  data_avaliable: OUT STD_LOGIC
	);
END COMPONENT;

SIGNAL reg_wren  : STD_LOGIC; 
SIGNAL r_ack_o   : STD_LOGIC; 
SIGNAL out_reg : STD_LOGIC_VECTOR(15 DOWNTO 0);


SIGNAL txd_r : STD_LOGIC_VECTOR(7 DOWNTO 0);


SIGNAL d_in_mux : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL d_out_mux : STD_LOGIC_VECTOR(7 DOWNTO 0);

SIGNAL ctrl_r : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL tx_data : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL rx_data : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL rx_status_r : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL tx_status_r : STD_LOGIC_VECTOR(7 DOWNTO 0);


SIGNAL ctrl_wr  : STD_LOGIC; 
SIGNAL tx_fifo_wr  : STD_LOGIC; 
SIGNAL rx_fifo_rd : STD_LOGIC; 
SIGNAL reg_rden : STD_LOGIC;
SIGNAL tx_fifo_empty : STD_LOGIC;
SIGNAL rx_fifo_empty : STD_LOGIC;
SIGNAL tx_fifo_full : STD_LOGIC;
SIGNAL rx_fifo_full : STD_LOGIC;

SIGNAL data_out_from_rx : STD_LOGIC_VECTOR(7 DOWNTO 0);

SIGNAL send    : STD_LOGIC;
SIGNAL data_rdy: STD_LOGIC;
     ----------------------
SIGNAL stop_f  :  STD_LOGIC;
SIGNAL start_f :  STD_LOGIC;
SIGNAL empt     :STD_LOGIC;
SIGNAL   fll: STD_LOGIC;


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
tx_fifo_wr <= reg_wren and r_ack_o;-- and ( (NOT ADR_I(3)) AND (NOT ADR_I(2)) AND (NOT ADR_I(1)) AND ( ADR_I(0))) and (not tx_fifo_full);
--RX_FIFO : 21h
rx_fifo_rd <= reg_rden and ( (NOT ADR_I(3)) AND (NOT ADR_I(2)) AND (NOT ADR_I(1)) AND ( ADR_I(0))) and (not rx_fifo_empty);
--TX_STATUS : 22h
--RX_STATUS : 23h
----LINE_CTRL : 24h
--line_ctrl_wr <= reg_wren and ( (NOT ADR_I(3)) AND (ADR_I(2)) AND (NOT ADR_I(1)) AND ( NOT ADR_I(0)));

WITH (reg_rden & ADR_I(3 DOWNTO 0)) SELECT
d_out_mux <= ctrl_r WHEN  "10000",
				 rx_data WHEN "10001",
				 tx_status_r WHEN "10010",
				 rx_status_r WHEN "10011",
				 (others => '0') WHEN OTHERS;
DAT_O <= "000000000000000000000000" & d_out_mux;

				 
tx_fifo : uart_fifo
PORT MAP
(
	clock		=> CLK_I,
	data		=> DAT_I(7 DOWNTO 0),
	rdreq		=> rdrqst,
	wrreq		=> R_ack_o,--tx_fifo_wr,
	empty		=> tx_fifo_empty,
	full		=> tx_fifo_full,
	q			=> tx_data,
	usedw		=> tx_status_r(3 downto 0)
);
uart_full <= tx_fifo_full;
uart_empty <= tx_fifo_empty;

--rx_fifo : uart_fifo
--PORT MAP
--(
--	clock		=> CLK_I,
--	data		=> data_out_from_rx,
--	rdreq		=> rx_fifo_rd,
--	wrreq		=> data_rdy,
--	empty		=> rx_fifo_empty,
--	full		=> rx_fifo_full,
--	q			=> rx_data,
--	usedw		=> rx_status_r(6 downto 0)
--);
--
--U1: receiver
--PORT MAP(
--     sin      => RXD,     
--	 sys_clk  => CLK_I,
--	 rst      =>RST_I,  
--    	--------------------------
--     data_out  => data_out_from_rx,
--     error_stop => stop_f,
--     error_start => start_f,       
--	 data_avaliable => data_rdy
--	);    

send <= reg_wren;--tx_fifo_wr;-- not tx_fifo_empty;
U2: tx_module 
PORT MAP(
     fifo_empty_n => not tx_fifo_empty,
	  rd_ack  => rdrqst,
	  tx_out => TXD, 
     sys_clk => CLK_I,
     rst=> RST_I,
     tx_in => tx_data
     );
--rdrqst <= '1';
	--empt<= rdrqst;
   
END rtl;