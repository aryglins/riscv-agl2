`timescale 1ns/1ps

import memory_mapping::*;

 module inst_mem_ctrl (
	 input logic clk,
	 input logic rst,
	 
	//CPU:
	 input logic rd,
	 input logic [31:0] addr_i,
	 output logic [31:0] instr_o,
	 output logic [1:0] cmp,
	 
	//MEM0:
	 output logic mem0_rd,
	 output logic [31:0] mem0_addr_o,
	 input logic [31:0] mem0_data_i,
	 
	//MEM1:
	output logic mem1_rd,
	output logic [31:0] mem1_addr_o,
	input logic [31:0] mem1_data_i 
 );

 logic [31:0] addr_from_cpu;
 logic [31:0] addr;
 logic [31:0] addr_rom;
 logic addr_cmp_ram = 1'b0;
 logic add_cmp_rom;
 logic [1:0] addcmp2;
 logic [1:0] addcmp2_r;

assign addcmp2 		= {add_cmp_rom, addr_cmp_ram};
assign cmp 				= addcmp2;	
assign addr_from_cpu = addr_i;
assign addr 			= addr_from_cpu - DATA_RAM_BEGIN;
assign addr_rom 		= addr_from_cpu - INST_ROM_BEGIN;
assign mem0_addr_o  	= addr_rom;
assign mem1_addr_o  	= addr;	

always_comb begin
	//ROM
	 if(addr_i >= INST_ROM_BEGIN && addr_i < INST_ROM_END) begin
		add_cmp_rom <= 1'b1;
	 end
	 else begin
		add_cmp_rom <= 1'b0;
	 end
end	 
		
 always_comb begin
	//RAM 
	if(addr_i >= DATA_RAM_BEGIN && addr_i < DATA_RAM_END) begin
		addr_cmp_ram <= 1'b1;
	 end
	 else begin
		addr_cmp_ram <= 1'b0;
	 end
end

  always_ff @(posedge clk) begin
	 if (rst) begin
		 addcmp2_r <= 2'b00;
	 end
	 else	begin
		 addcmp2_r <= addcmp2;
	 end
  end
  
  always_comb begin 
  
		if(addcmp2_r == 2'b10)
			instr_o 	= mem0_data_i;
		else if(addcmp2_r == 2'b01)
			instr_o 	= mem1_data_i;
		else
			instr_o 	= 32'h00000000;			
//		case (addcmp2_r) 
//			2'b10: instr_o 	<= mem0_data_i;   
//			2'b01 :instr_o 	<= mem1_data_i;
//			default: instr_o 	<= 32'h00000000;
//		endcase              
  end

	always_comb begin
		if(rd) begin
			if (addcmp2 == 2'b10) begin
				mem0_rd = 1'b1;
				mem1_rd = 1'b0; 
			end
			else if (addcmp2 == 2'b01) begin				  
				mem1_rd  = 1'b1;
				mem0_rd  = 1'b0;
			end
			else begin
				mem0_rd = 1'b0;
				mem1_rd = 1'b0;
			end
		end
		else begin
			mem0_rd = 1'b0;
			mem1_rd = 1'b0;       
		end
  end

  
endmodule 