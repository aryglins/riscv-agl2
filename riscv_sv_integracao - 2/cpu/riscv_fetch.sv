// -----------------------------------------------------------------------------
// FILE NAME      : riscv_fetch
// AUTHOR         : voo,caram
// AUTHOR'S EMAIL : {voo,caram}@cin.ufpe.br
// -----------------------------------------------------------------------------
// RELEASE HISTORY
// VERSION 	DATE         AUTHOR		DESCRIPTION
// 2.0		2017-01-30   voo   		version sv
// -----------------------------------------------------------------------------
`timescale 1ns/1ps

import memory_mapping::*;

module riscv_fetch (

		input logic	clk_i,
		input 	logic rst_i,
		//
		input  logic [31:0]  inst_cache_d,
		output logic [31:0]  inst_cache_a,
		output 	logic	   inst_cache_ren,
		//
		output logic [31:0]	npc_o,
		output logic [31:0]	ir_o,
		//
		output 	logic		taken_br,
		input 	logic		pred_miss,
		//input logic [1:0] 	inst_cache_mux_sel_i,
		//
		input logic [31:0]	br_addr,
		input logic [31:0] 	jalr_addr,
		input logic [2:0]		pc_input_sel_i, 
		input logic [31:0]	MEPC,
		//
		input 	logic		stall_i,
		input 	logic		interrupt_req,
		//
		input  logic			rst_eval_regs,
		input  logic			en_eval_regs, 
		output logic [63:0]	clk_counter_o,
		output logic [63:0]	inst_counter_o,
		output logic [63:0]	branch_counter_o	
);
localparam TAM_1 = 32; //DEFINE
localparam TAM_2 = 64; //DEFINE

localparam OP_LUI 		= 7'b0110111;  //DEFINE
localparam OP_AUIPC 	= 7'b0010111;  //DEFINE
localparam OP_JAL 		= 7'b1101111;  //DEFINE
localparam OP_JALR 		= 7'b1100111;  //DEFINE
localparam OP_BRANCH	= 7'b1100011;  //DEFINE
localparam OP_LOAD 		= 7'b0000011;  //DEFINE
localparam OP_STORE 	= 7'b0100011;  //DEFINE
localparam OP_ARIT_I	= 7'b0010011;  //DEFINE
localparam OP_ARIT 		= 7'b0110011;  //DEFINE
//localparam OP_FENCE = 7'0001111;
localparam OP_SYSTEM	= 7'b1110011;


// REGISTERS
logic [TAM_1 -1:0] 	program_counter ;//= 32'h0000A000; change
logic 				pred_miss_r;

// ADDER
logic [TAM_1 -1:0] 	pc_adder;

// MUXES
logic [TAM_1 -1:0] 	pc_input_mux; 
logic [5:0] 	pc_input_mux_sel; //here
logic [1:0] 	pc_input_mux_sel_w;

//
logic [TAM_1 -1:0] 	inst_reg_mux;    
logic inst_reg_mux_sel; 
// 
// PIPELINE REGISTERS - IF/DEC-EXE
logic [TAM_1 -1:0] 	instruction_reg;//= 32'd0;
logic [TAM_1 -1:0]  npc;//= 32'd0;
logic take_br_r;
//wire take_br_r;

// WIRES
logic take_br;
//logic [TAM_1 -1:0]  prev_br = 32'd0;
logic [TAM_1 -1:0]  sb_si_ext;
logic [TAM_1 -1:0]  uj_si_ext;


// PERFORMANCE EVAL REGISTERS

int clk_counter;
logic [63:0] inst_counter;
longint branch_counter;

logic reset; //	= 1'b0;
typedef enum bit [1:0]
		{rst, idle, ready} st_type;
st_type state;

initial	state = rst;

always_ff @(posedge clk_i or posedge rst_i) 
begin
	if (rst_i == 1'b1) begin
	  state <= rst;
	end
	else begin
	  case (state)
		rst 	: state <= idle;
		idle 	: state <= ready;
		ready 	: state <= ready;
	  default   : state <= rst;
	  endcase;
	end
end
 
 
always_comb begin
	case (state)
      rst 	: reset = 1'b1;
      idle 	: reset = 1'b1;
      ready : reset = 1'b0;
	endcase;
end      

//
assign clk_counter_o    = clk_counter;
assign inst_counter_o   = inst_counter;
assign branch_counter_o = branch_counter;
//
assign npc_o 				= npc;
assign ir_o  				= instruction_reg;
assign taken_br 			= take_br_r;
assign inst_cache_ren 		=  1'b1 & ~rst_i; // !!!!!!!!!!!!
//------------------------BRANCH-PREDICTION-----------------------//
always_comb begin
	if(stall_i)begin
		pc_input_mux_sel_w = 2'b00;
		take_br = 1'b0;
	end
	else begin			
		//offset negativo: sempre ocorre | offset positivo: não ocorre
		case (inst_reg_mux[6:0]) 
			OP_JAL 		: 	begin	
								pc_input_mux_sel_w = 2'b01;
								take_br = 1'b1;
							end
			OP_BRANCH 	:	begin 
								if (inst_reg_mux[31]) begin   
										pc_input_mux_sel_w = 2'b10;
										take_br = 1'b1;
								end 
								else begin
									pc_input_mux_sel_w = 2'b00;
									take_br = 1'b0;
								end
							end
			OP_SYSTEM 	: 	begin 
								if (inst_reg_mux[31]) begin
									pc_input_mux_sel_w = 2'b11;
									take_br = 1'b1;
								end
								else begin
									pc_input_mux_sel_w = 2'b00;
									take_br = 1'b0;
								end
							end
			default		:  	begin
									pc_input_mux_sel_w = 2'b00;
									take_br = 1'b0;
							end
		endcase 
	end
end
//

assign	pc_input_mux_sel = {interrupt_req , pc_input_sel_i , pc_input_mux_sel_w}; // {1,3,2} bits

always_comb begin	
	case (pc_input_mux_sel)
		6'b000000 : pc_input_mux	 = 		program_counter + 4;//operação normal
		6'b000001 : pc_input_mux	 =  	uj_si_ext + program_counter ; //jal
		6'b000010 : pc_input_mux	 =  	sb_si_ext + program_counter ;  //OP_BRANCH
		6'b001100 : pc_input_mux	 =  	npc + 4 ; //previsão errada, pc anterior
		6'b010000 : pc_input_mux	 =  	program_counter; 	// BREAK
		6'b010100 : pc_input_mux	 =  	npc; 					
		6'b000100 : pc_input_mux	 =  	br_addr ;  			
		6'b001000 : pc_input_mux	 =  	jalr_addr; // desvio incondicional indireto		
		6'b000011 :	pc_input_mux	 = 		MEPC  ;   	//registrador da exceção		
		6'b100000 :	pc_input_mux	 =		32'h0000201c; 
		6'b100001 :	pc_input_mux	 =		32'h0000201c; 
		6'b100010 :	pc_input_mux	 =		32'h0000201c; 
		6'b100011 :	pc_input_mux	 =		32'h0000201c; 
		6'b100100 :	pc_input_mux	 =		32'h0000201c; 
		6'b110100 :	pc_input_mux	 =		32'h0000201c; 
		6'b110000 :	pc_input_mux	 =		32'h0000201c; 
		default: 	pc_input_mux	 =		32'h00000000; 
	endcase

end

assign inst_cache_a = pc_input_mux;

always_comb begin
	case (pred_miss) // confirmação da previsao de desvio
		1'b0		: 	inst_reg_mux = inst_cache_d;		
		1'b1		: 	inst_reg_mux = {TAM_1-1{1'b0}};	 //bolha
		default 	:	inst_reg_mux = {TAM_1-1{1'b0}};
	endcase
end           
                
always_ff @(posedge clk_i or posedge reset) 
begin
	if (reset) begin
		program_counter <= INST_ROM_BEGIN-4; //DEFINE
		npc <= {TAM_1-1{1'b0}};
		take_br_r <= 1'b0;
	end
	else begin
		if (stall_i == 1'b0) begin
			program_counter <= pc_input_mux;
			npc <= program_counter;
			take_br_r <= take_br;
		end
	end
end

assign sb_si_ext [31:13] = {TAM_1-13{inst_cache_d[31]}};  //extensão do signal
assign sb_si_ext [12:0]  =  {inst_cache_d[31], inst_cache_d[7], inst_cache_d[30:25], inst_cache_d [11:8], 1'b0};  //OP_BRANCH
assign uj_si_ext [31:21] =  {TAM_1-21{inst_cache_d[31]}}; //extensão do signal
assign uj_si_ext [20:0]  =   {inst_cache_d[31] , inst_cache_d[19 : 12] , inst_cache_d[20] , inst_cache_d[30 : 21] , 1'b0};
//-------------------------UPDATE-INSTRUCTION-----------------------//
always_ff @(posedge clk_i or posedge reset) 
begin
	if (reset) begin
		instruction_reg <= {TAM_1-1{1'b0}};
	end
	else begin
		if (stall_i == 1'b0) begin
			instruction_reg <= inst_reg_mux;
		end	
	end
end				
//-------------------------COUNTER-PERFORMANCE------------------------//
always_ff @(posedge clk_i) begin // or posedge reset or posedge rst_eval_regs
	if (rst_eval_regs || reset ) begin
		clk_counter <= 0;
	end
	else begin
		if(en_eval_regs) begin
			clk_counter <= clk_counter + 1;
		end
	end
end

always_ff @(posedge clk_i) begin // or posedge reset or posedge rst_eval_regs
	if (rst_eval_regs || reset ) begin 
		branch_counter <=0;
	end 
	else begin
		if (take_br == 1'b1 && en_eval_regs == 1'b1) begin
			branch_counter <= branch_counter + 1;
		end
	end
end

always_ff @(posedge clk_i) begin // or posedge reset or posedge rst_eval_regs
	if (rst_eval_regs || reset) begin
		inst_counter <= 0;
	end
	else begin
		if (stall_i == 1'b0 && en_eval_regs == 1'b1) begin
			inst_counter <= inst_counter + 1;
		end
	end
end 


endmodule 