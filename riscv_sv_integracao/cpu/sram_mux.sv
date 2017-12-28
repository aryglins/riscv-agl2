// -----------------------------------------------------------------------------
// FILE NAME      : sram_mux
// AUTHOR         : voo,caram
// AUTHOR'S EMAIL : {voo,caram}@cin.ufpe.br
// -----------------------------------------------------------------------------
// RELEASE HISTORY
// VERSION 	DATE         AUTHOR		DESCRIPTION
// 2.0		2017-01-30   voo   		version sv
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
module sram_mux (
		input  logic [31:0] inst_add_i,
		output logic [15:0] inst_dat_o,
		input  logic inst_rden,
		//
		input  logic [31:0]  data_add_i ,
		output logic [15:0]  data_dat_o ,
		input  logic [15:0]  data_dat_i ,
		input  logic data_rden ,
		input  logic data_wren ,
		//      
		output logic [31:0]  address	,
		input  logic [15:0]  data_i	,
		output logic rden	,
		output logic wren	,
		output logic [15:0]  data_o	
);

always_comb //ff @(inst_rden,data_rden,data_wren,inst_add_i,data_i,data_dat_i,data_add_i)
begin
if(inst_rden == 1'b1) begin
		address		<= inst_add_i;
		inst_dat_o 	<= data_i;
		rden		<= inst_rden;
		wren		<= 1'b0;
		data_o		<= 15'd0;
		data_dat_o  <= 15'd0;
end
else if(data_rden == 1'b1 || data_wren == 1'b1 )begin
		address		 <= data_add_i;
		inst_dat_o 	<= 15'd0;
		rden		<= data_rden;
		wren		<= data_wren;
		data_o		<= data_dat_i;
		data_dat_o  <= data_i;
end
else begin
		address	 	<= 31'd0;
		inst_dat_o  <=  15'd0;
		rden		<= 1'b0;
		wren		<= 1'b0;
		data_o		<= 15'd0;
		data_dat_o  <= 15'd0;
end
end

endmodule 