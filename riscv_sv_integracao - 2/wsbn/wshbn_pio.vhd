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


ENTITY wshbn_pio IS 
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
	---
	pio_0_in  : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
	pio_0_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
);
END wshbn_pio;

ARCHITECTURE v1 OF wshbn_pio IS


SIGNAL reg_wren  : STD_LOGIC:='0';
--SIGNAL reg_rden  : STD_LOGIC:='0';
SIGNAL r_ack_o   : STD_LOGIC:='0'; 
SIGNAL out_reg   : STD_LOGIC_VECTOR(15 DOWNTO 0):=(others => '0');
--SIGNAL in_reg    : STD_LOGIC_VECTOR(15 DOWNTO 0):=(others => '0');

BEGIN

reg_wren <= CYC_I and STB_I and WE_I;
--reg_rden <= CYC_I and STB_I and (not WE_I);
ACK_O <= r_ack_o;

-- SLAVE SÍNCRONO : ACK NO CLK SEGUINTE
PROCESS(CLK_I, CYC_I, STB_I, r_ack_o)
BEGIN
	IF(RISING_EDGE(CLK_I)) THEN
		r_ack_o <= CYC_I AND STB_I AND NOT(r_ack_o);
	END IF;
END PROCESS;


PROCESS(rst_i,clk_I,DAT_I,reg_wren)
BEGIN
if (rst_i = '1')then
out_reg <= (others => '0');
else
	IF (RISING_EDGE(clk_I)) THEN
		IF (reg_wren = '1') THEN
			out_reg <= DAT_I(15 DOWNTO 0);
		END IF;
	END IF;
end if;
END PROCESS;


--PROCESS(clk_I,reg_rden,pio_0_in)
--BEGIN
--if (rst_i = '1')then
--in_reg <= (others => '0');
--else
--	IF (RISING_EDGE(clk_I)) THEN
--		IF (reg_rden = '1') THEN
--			in_reg <= pio_0_in;
--		END IF;
--	END IF;
--end if;
--END PROCESS;

pio_0_out <= out_reg;

DAT_O <= X"0000" & pio_0_in; --X"2AAA"; -- in_reg; 


END V1;
