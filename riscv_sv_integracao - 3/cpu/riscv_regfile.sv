// +FHDR---------------------------------------------------
// 
// FILE NAME      : riscv_regfile
// AUTHOR         : 
// AUTHOR'S EMAIL : 
// ------------------------------------------------------
// RELEASE HISTORY
// VERSION 	DATE         AUTHOR		DESCRIPTION
// 1.0		2016-08-11      	Initial version
// ------------------------------------------------------
`timescale 1ns/1ps

module riscv_regfile(
	input logic [4:0]  rd_i,
	input logic [4:0]  rs1_i,
	input logic [4:0]  rs2_i,	
	input logic [31:0] data_in,
	input logic clk_i,
	input logic rst_i,
	input logic wrten_i,	                     
	output logic [31:0] ra ,
	output logic [31:0] sp ,
	output logic [31:0] op1_o,
	output logic [31:0] op2_o,
	output logic [31:0] result	
);
//
parameter TAM = 32;
reg  [TAM-1:0] regfile [0:TAM-1];
//read
assign ra = regfile[1];
assign sp = regfile[2];
assign result =  regfile [29] ; // resultados das operações guardado em T4  == x29
	always_comb 	begin
		op1_o = regfile[rs1_i] ;		
	end

	always_comb 
	begin
		op2_o = regfile[rs2_i] ;		
	end
	
//write
	always_ff @(posedge clk_i or posedge rst_i) 
		begin
		if(rst_i)begin
			regfile <= '{TAM{  {TAM{1'b0}} }};			
		end
		else begin		
			if(wrten_i == 1'b1 && rd_i != 5'b00000)
			begin
				regfile[rd_i] <= data_in;
			end
			else
				regfile <= regfile;
		
		end
	end

endmodule 