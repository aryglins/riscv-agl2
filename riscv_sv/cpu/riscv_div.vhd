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
USE IEEE.STD_LOGIC_unSIGNED.ALL;

ENTITY riscv_div IS 
PORT (
      clk : IN STD_LOGIC;
      rst : IN STD_LOGIC;
      --
      div_en : IN STD_LOGIC;
      a : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      b : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      --
      q: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      r: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      --
      --div_zero : OUT STD_LOGIC;
      freeze_pipe  : OUT STD_LOGIC
      );
END riscv_div;


ARCHITECTURE v1 OF riscv_div IS

SIGNAL div_count : STD_LOGIC_VECTOR(5 DOWNTO 0):=(OTHERS => '0');
SIGNAL div_n : STD_LOGIC_VECTOR(31 DOWNTO 0):=(OTHERS => '0');
SIGNAL div_d : STD_LOGIC_VECTOR(31 DOWNTO 0):=(OTHERS => '0');
SIGNAL div_r : STD_LOGIC_VECTOR(31 DOWNTO 0):=(OTHERS => '0');

SIGNAL div_sub : STD_LOGIC_VECTOR(32 DOWNTO 0):=(OTHERS => '0');

SIGNAL div_neg  : STD_LOGIC:='0';
SIGNAL div_done : STD_LOGIC:='0';
SIGNAL div_by_zero_r : STD_LOGIC:='0';

TYPE st IS (idle, div, end_div);
SIGNAL state : st;  

BEGIN

div_sub <= ('0' & div_r(30 DOWNTO 0) &  div_n(31)) - div_d;

q <= div_n;
r <= div_r;


PROCESS(clk, rst, a, b, div_count,div_en)
BEGIN
  IF(rst = '1') THEN 
    div_count <= (others =>'0');
    state <= idle;
    div_done <= '0';
ELSE
  IF (RISING_EDGE(clk)) THEN
    CASE (state) IS
    
    WHEN idle =>  div_count <= "100000";
                  div_done <= '0';
                  div_n <= a;
                  div_d <= b;
                  div_r <= (others => '0');
                  IF ( div_en = '1') THEN
                    state <= div;
                  ELSE 
                    state <= idle;
                END IF;
    WHEN div =>   
              if (div_done = '0' )then 
                div_count <= div_count - '1';
                state <= div; 
                if (div_sub(32) = '0') then --div_sub >= 0
                  div_r <= div_sub(31 downto 0);
                  div_n <= div_n(30 downto 0) & '1';
                else -- div_sub < 0
                  div_r <= div_r(30 downto 0) & div_n(31);
                  div_n <= div_n(30 downto 0) &  '0';
               end if;
               if (div_count = 1) then
                 div_done <= '1';
               end if;
          else state <= end_div;
               div_done <= '0';
               --div_r <= div_r;  
        end if;
   WHEN end_div => state <= idle;
 END CASE;
 END IF;
 END IF;
 END PROCESS;       

PROCESS(state)
BEGIN
  CASE (state) IS
    WHEN idle => freeze_pipe <= '0' ;
    WHEN div =>  freeze_pipe <= '0' ; 
    WHEN end_div => freeze_pipe <= '1';
 END CASE;
 END PROCESS; 


END v1;
      --     if (rst)
--	     /* verilator lint_off WIDTH */
--             div_count <= 0;
--           else if (decode_valid_i)
--             div_count <= OPTION_OPERAND_WIDTH;
--	    /* verilator lint_on WIDTH */
--           else if (|div_count)
--             div_count <= div_count - 1;
--
--         always @(posedge clk `OR_ASYNC_RST) begin
--            if (rst) begin
--               div_n <= 0;
--               div_d <= 0;
--               div_r <= 0;
--               div_neg <= 1'b0;
--               div_done <= 1'b0;
--	       div_by_zero_r <= 1'b0;div_n <= 0;
--               div_d <= 0;
--               div_r <= 0;
--               div_neg <= 1'b0;
--               div_done <= 1'b0;
--	       div_by_zero_r <= 1'b0;
--            end else if (decode_valid_i & op_div_i) begin
--	       div_n <= rfa_i;
--               div_d <= rfb_i;
--               div_r <= 0;
--               div_neg <= 1'b0;
--               div_done <= 1'b0;
--	       div_by_zero_r <= !(|rfb_i);
--
--               /*
--                * Convert negative operands in the case of signed division.
--                * If only one of the operands is negative, the result is
--                * converted back to negative later on
--                */
--               if (op_div_signed_i) begin
--                  if (rfa_i[OPTION_OPERAND_WIDTH-1] ^
--		      rfb_i[OPTION_OPERAND_WIDTH-1])
--                    div_neg <= 1'b1;
--
--                  if (rfa_i[OPTION_OPERAND_WIDTH-1])
--                    div_n <= ~rfa_i + 1;
--
--                  if (rfb_i[OPTION_OPERAND_WIDTH-1])
--                    div_d <= ~rfb_i + 1;
--               end
--            end else if (!div_done) begin
--               if (!div_sub[OPTION_OPERAND_WIDTH]) begin // div_sub >= 0
--                  div_r <= div_sub[OPTION_OPERAND_WIDTH-1:0];
--                  div_n <= {div_n[OPTION_OPERAND_WIDTH-2:0], 1'b1};
--               end else begin // div_sub < 0
--                  div_r <= {div_r[OPTION_OPERAND_WIDTH-2:0],
--                            div_n[OPTION_OPERAND_WIDTH-1]};
--                  div_n <= {div_n[OPTION_OPERAND_WIDTH-2:0], 1'b0};
--               end
--               if (div_count == 1)
--                 div_done <= 1'b1;
--           end
--         end
--
--         assign div_valid = div_done & !decode_valid_i;
--         assign div_result = div_neg ? ~div_n + 1 : div_n;
--	 assign div_by_zero = div_by_zero_r;
--      end