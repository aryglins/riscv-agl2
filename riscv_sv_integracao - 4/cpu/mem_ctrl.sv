// -----------------------------------------------------------------------------
// FILE NAME      : mem_ctrl
// AUTHOR         : voo
// AUTHOR'S EMAIL : voo@cin.ufpe.br
// -----------------------------------------------------------------------------
// RELEASE HISTORY
// VERSION 	DATE         AUTHOR		DESCRIPTION
// 2.0		2017-01-30   voo   		version sv
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
import memory_mapping::*;

module mem_ctrl (
	input logic	clk,
	input logic	rst,
	//CPU:
	input logic rd,      
	input logic wr,      
	input  logic [31:0] addr_i,
	input  logic [31:0] data_i,
	output logic [31:0] data_o,
    output logic hold_cpu,
	//WISHBONE:
	output logic wshbn_rd,     
	output logic wshbn_wr,     
	output logic [29:0] wshbn_addr_o,
	output logic [31:0] wshbn_data_o,
	input  logic [31:0] wshbn_data_i,
	input  logic wshbn_busy,
	input  logic wshbn_data_av,
  //
  //MEM0:
	output logic mem0_rd,
	output logic mem0_wr,
	output logic [29:0] mem0_addr_o,
	output logic [31:0] mem0_data_o,
	input  logic [31:0] mem0_data_i,
	input mem0_busy,
	//MEM1:
 	output logic mem1_rd,
	output logic mem1_wr,
	output logic [29:0] mem1_addr_o,
	output logic [31:0] mem1_data_o,
	input  [31:0] mem1_data_i,
	input mem1_busy 
);

reg  [31:0] addr_mem;
reg  [31:0] addr_from_cpu;
reg  [31:0] addr_from_cpu_r; 
reg  [31:0] wshbn_data_r; 
reg  [31:0] add_ext;

reg bus_trns;
reg addr_ext_cmp;
reg addr_data_cmp;
reg addr_cmp;
reg addr_cmp_r;
 

reg [2:0] addcmp3;



assign addcmp3 = {addr_cmp,1'b0,addr_ext_cmp};
assign addr_from_cpu = addr_i;     
//assign addr_mem =  addr_from_cpu - 32'h00002000;
assign add_ext  =  addr_from_cpu - DATA_RAM_BEGIN;

assign wshbn_data_o = data_i;
assign mem0_data_o  = data_i;
assign mem1_data_o  = data_i;	

assign wshbn_addr_o = addr_from_cpu [31:2];
assign mem0_addr_o  = add_ext [31:2];//addr_mem [31:2]; 
//assign mem1_addr_o  = add_ext [31:2];

always_ff @(posedge clk or posedge rst) begin
	if (rst == 1'b1) begin
		addr_cmp_r <= 1'b0;
	end
	else	begin
		addr_cmp_r <= addr_cmp;
	end
end

always_ff @(addr_from_cpu) begin //wishbone
	if (addr_i < DATA_RAM_BEGIN) begin
		addr_cmp = 1'b1;
	end
	else begin
		addr_cmp = 1'b0;
	end
end

/* always_ff @(addr_from_cpu) begin
	if (addr_from_cpu >= 32'h00002800) begin
		addr_data_cmp = 1'b1;
	end
	else begin
		addr_data_cmp = 1'b0;
	end 
end */


always_ff @(addr_from_cpu) begin //ram
	if (addr_i >= DATA_RAM_BEGIN && addr_i < DATA_RAM_END) begin
		addr_ext_cmp = 1'b1;
	end
	else begin
		addr_ext_cmp = 1'b0;
	end 
end


always_comb begin
	if  ( (rd == 1'b1) ^ (wr == 1'b1)) begin
		case (addcmp3)		
		3'b100: begin	
				wshbn_rd    = rd;
                wshbn_wr    = wr;     
                bus_trns 	= 1'b1;
                mem0_rd     = 1'b0;
                mem0_wr     = 1'b0;
			//	mem1_rd     = 1'b0;
             //   mem1_wr     = 1'b0;   
			end
		/* 3'b010: begin
				wshbn_rd    = 1'b0;
                wshbn_wr    = 1'b0;
                bus_trns    = 1'b0;
                mem0_rd     = rd;
                mem0_wr     = wr;
             //   mem1_rd     = 1'b0;
            //    mem1_wr     = 1'b0;
            end  */  
		3'b001: begin 				  
				wshbn_rd     = 1'b0;
                wshbn_wr     = 1'b0;
                bus_trns     = 1'b0;           
                mem0_rd      = rd;//1'b0;
                mem0_wr      = wr;//1'b0;
				//mem1_rd      = rd;
              //  mem1_wr      = wr;
			end
		default: begin
                wshbn_rd     = 1'b0;
                wshbn_wr     = 1'b0;
                bus_trns     = 1'b0;           
                mem0_rd      = 1'b0;
                mem0_wr      = 1'b0;  
			//	mem1_rd      = 1'b0;
			//	mem1_wr      = 1'b0;      
			end
		endcase
	end
	else begin
		wshbn_rd    = 1'b0;
		wshbn_wr    = 1'b0;  
		bus_trns    = 1'b0;           
		mem0_rd     = 1'b0;
		mem0_wr     = 1'b0; 
	//	mem1_rd     = 1'b0;
	//	mem1_wr     = 1'b0; 
	end
end

assign hold_cpu = (bus_trns || wshbn_busy || mem0_busy) && (~wshbn_data_av);



always_ff @(posedge clk or posedge rst) begin
	if (rst == 1'b1) begin
		wshbn_data_r <= 32'd0;
	end
	else if (wr == 1'b1 || rd == 1'b1) begin
		// addr_from_cpu_r <=  addr_from_cpu;
		wshbn_data_r <= wshbn_data_i;
	end
end
 
 

always_comb begin
    if ( addr_cmp_r == 1'b1) begin
		data_o = wshbn_data_r;
		//ws <= '1';
    end
	else data_o = mem0_data_i;
		//ws <= '0';
end

endmodule

