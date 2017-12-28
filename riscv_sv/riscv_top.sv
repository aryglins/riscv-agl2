`timescale 1ns/1ps
module riscv_top
(
	input CLOCK_50,
	//input logic RST,
	input  BUTTON,
	//------------------------------------------------------------
	output [6:0] HEX0_D,  //	Seven Segment Digit 0
	output [6:0] HEX1_D	, //	Seven Segment Digit 1
	output [6:0] HEX2_D	, //	Seven Segment Digit 2
	output [6:0] HEX3_D  //	Seven Segment Digit 3
	//------------------------------------------------------------
//	input [9:0] SW,
//	output [9:0] LEDG,
//	//------------------------------------------------------------
//	//	--////////////////////////	UART	/////////////////////////--
//	//------------------------------------------------------------
//	output UART_TXD,//	UART Transmitter
//	input UART_RXD,//	UART Receiver
//	output UART_CTS,//	UART Clear To Send
//	input UART_RTS,//	UART Requst To Send
//	//------------------------------------------------------------
//	//	--////////////////////	GPIO	////////////////////////////--
//	//	------------------------------------------------------------
//	input [1:0] GPIO0_CLKIN,//	GPIO Connection 0 Clock In Bus
//	output [1:0] GPIO0_CLKOUT,//	GPIO Connection 0 Clock Out Bus
//	inout [31:0] GPIO0_D,//	GPIO Connection 0 Data Bus
//	input [1:0] GPIO1_CLKIN,//	GPIO Connection 1 Clock In Bus
//	output [1:0] GPIO1_CLKOUT,//	GPIO Connection 1 Clock Out Bus
//	inout [31:0] GPIO1_D //	GPIO Connection 1 Data Bus
);
//------------------------------------------------
reg pll_button;
reg xclk_50;
wire  rst_debouncer;
//------------------------------------------------
logic  [15:0] pio_out;
//------------------------------------------------
logic [1:0] cmp ;
logic [31:0] sp ;
logic [31:0] ra ;
logic [31:0] ir ;
//------------------------------------------------
logic [7:0] regout;
//------------------------------------------------
logic [7:0] tx	;	
logic spi_en 	;
logic spi_clk 	;
logic spi_rx 	;
logic spi_tx_;
//------------------------------------------------
logic uart0_rx;
logic uart0_tx;
logic full;
logic empty;
//------------------------------------------------ 
logic [31:0] result_out;
logic [31:0] instruction_out;

//------------PLL-50/100-MHz-Low-active--------------//
//BUTTON initial == 1 , after == 0
 	pll_50 pll_50 (.areset(BUTTON),.inclk0(CLOCK_50),.c0(xclk_50),.locked(pll_button));	
//------------------------------------------------------//

//--------------BUTTON==rst----------------------//
	button_debouncer debouncer (.clk(xclk_50), .rst_n(~BUTTON), .data_in(1'b1), .data_out(rst_debouncer) );

//----------------------TOP-RISCV----------------------//

	riscv_wishbone cpu (
	.CLK(xclk_50),
	.RST(~rst_debouncer),
	//--------------------------------//
	.pio_0_out(pio_out),
	.pio_0_in(16'h000F),
	//--------------------------------//
	.cmp(cmp),
	.sp(sp),
	.ra(ra),
	.ir(ir),
	//--------------------------------//
	//.regout(regout),
	//--------------------------------//
	.spi_tx(tx),
	.ssp_en_o(spi_en),
	.ssp_mosi_o(spi_tx_),
	.ssp_miso_i(spi_rx),
	.ssp_clk_o(spi_clk),
	//--------------------------------//
	.uart_rx(uart0_rx),
	.uart_tx(uart0_tx),
	.uart_full(full),
	.uart_empty(empty),
	//--------------------------------//
	.result(result_out),
	.instruction_o(instruction_out)
);
//------------------------------------------------------//

	always_ff @(posedge xclk_50) begin

		if(instruction_out == 32'hFFFFFFFF)
		begin // FAIL
			HEX0_D <=7'b1111111;//7'b1000111;
			HEX1_D <=7'b1111111;//7'b1110111;
			HEX2_D <=7'b1111111;//7'b0110000;
			HEX3_D <=7'b1111111;//7'b0001110;
		end
		else begin // 
			HEX0_D <= 7'b1000010;
			HEX1_D <= 7'b0000001;
			HEX2_D <= 7'b0001001;
			HEX3_D <= 7'b0110000;
		end
		 
	end


endmodule 

