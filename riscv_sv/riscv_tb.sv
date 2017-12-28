// -----------------------------------------------------------------------------
// FILE NAME      : tb
// AUTHOR         : voo
// AUTHOR'S EMAIL : voo@cin.ufpe.br
// -----------------------------------------------------------------------------
// RELEASE HISTORY
// VERSION 	DATE         AUTHOR		DESCRIPTION
// 2.0		2017-01-30   voo   		version sv
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
module tb (

);
logic  clk;
logic rst;
//SPI
logic spi_mosi;
logic spi_clk;
logic spi_en;
logic [7:0] spi_tx;
//PARALLEL I/O
logic [15:0] pio_out;
//logic [7:0] regout;
//UART
logic rx 	;
logic tx 	;
logic full 	;
logic empty ;

logic  	[1:0]  cmp;
logic 	[31:0] sp;
logic	[31:0] ra;
logic	[31:0] ir;
logic	[31:0] result; //retorno das operações
logic	[31:0] instruction_o; //retorno das instruções

initial begin
	clk = 1'b0;
	while (1) begin
		#10ns
		clk = ~clk;
	end
end	

initial begin
	rst = 1'b1;
	repeat (2) @(posedge clk);
	rst = 1'b0;	
end

riscv_wishbone DUT (
.CLK(clk),
.RST(rst),
.pio_0_out(pio_out),
.pio_0_in(16'h000F),
.cmp(cmp),
.sp(sp),
.ra(ra),
.ir(ir),
//.regout(regout),
.spi_tx(spi_tx),
.ssp_en_o(spi_en),
.ssp_mosi_o(spi_mosi), 
.ssp_miso_i(1'b1),
//.ssp_clk_o(spi_clk),
.uart_rx(rx),
.uart_tx(tx),
.uart_full(full),
.uart_empty(empty),
.result(result),
.instruction_o(instruction_o) );

//######################TESTE#######################
initial begin
	integer file;
	#20ns;
	
	file = $fopen("results/output_sv.txt", "w");
	forever begin
		if (instruction_o == 32'h001e6e13) begin
			$fwrite(file, "ERROR!!! INSTRUCTION FAIL DETECTED %h  VALUE %d \n ", instruction_o,result);
		end
		else begin
			$fwrite(file, "INSTRUCTION : %h RESULT: %d \n", instruction_o, result);
		end
		#20ns;
	end
	$fclose(file);
	
end
//#####################################################

endmodule 