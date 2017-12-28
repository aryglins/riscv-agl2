// 
// FILE NAME      : riscv_cpu_no
// AUTHOR         : voo,caram
// AUTHOR'S EMAIL : {voo,caram}@cin.ufpe.br
// -----------------------------------------------------------------------------
// RELEASE HISTORY
// VERSION 	DATE         AUTHOR		DESCRIPTION
// 2.0		2017-01-30   voo   		version sv
// -------------------------------------------------------------------
`timescale 1ns/1ps


module riscv_cpu_no ( 
	input logic clk_i,
	input logic rst_i,
	//
	output logic inst_cache_rden,
	output logic [31:0] inst_cache_add,
	input  logic [31:0] inst_cache_data,
	output logic [31:0] ra,
	output logic [31:0] sp,
	output logic mem_clken,
	output logic [31:0] ir_o,
	
	input  logic interrupt_req,
	input  logic mem_busy,
	input  logic data_av,
	output logic 	[31:0] data_add,
	output logic 	[31:0] data_o,
	input  logic [31:0] data_i,
	output logic 	data_rden,
	output logic 	data_wren,
	//      
	input  logic rst_eval_regs,
	input  logic en_eval_regs,
	output logic 	[63:0] clk_counter_o,
	output logic 	[63:0] inst_counter_o,
	output logic 	[63:0] branch_counter_o,
	output logic	[31:0] result,
	output logic    [31:0] instruction_o
	//
);

/*____________WIRES/REGS_____________________*/
//----------------REGFILE------------------//
logic [4:0] rd_mux;
logic [4:0] rs1_w;
logic [4:0] rs2_w;
logic [31:0] wb_mux;
logic rf_wrten_pipe;
logic [31:0] rs1o_w;
logic [31:0] rs2o_w;
//----------------------------------------//
//-------------------ALU------------------//
logic por;
logic [31:0] op1_mux;
logic [31:0] op2_mux;
logic [31:0] alu_o_w;
logic [31:0] alu_hi_w;
logic [31:0] alu_hi_r;
logic [4:0]  alu_sel;
//----------------DECODER-----------------//
logic [4:0] wb_add_reg;
logic [6:0] opcode_r;
logic [1:0] rom_mux_sel_w;
logic [1:0] unalign_str_mux_sel_w;
logic data_add_mux_sel_w;
logic [1:0] rs2_mux_sel;
logic [1:0] rs1_mux_sel;
logic [31:0] rs1_mux;
logic [31:0] rs2_mux;
logic [2:0] mem_align_mux_w;
logic ir_en; //
logic [6:0] opcode_w;
logic [2:0] func3_w;
logic [6:0] func7_w;
logic alu_wen;
logic div_en;
logic alu_busy;
logic [2:0] op2_mux_sel;
logic op1_mux_sel;
logic [3:0] wb_mux_sel_w;
logic rf_wrten_w;
logic load_mem_W;
logic load_mem_r;
logic data_wr;
//----------------------------------------//
//logic [31:0]  alu_byp;
logic [3:0] wb_mux_sel;
logic [3:0] wb_mux_sel_int;
//----------------------------------------//
logic [31:0] vec_instr_r;
logic [31:0] npc;
logic [31:0] instr_r;
logic [31:0] MEPC;
logic [31:0] br_add;
//----------------FETCH-------------------//
//----------------------------------------//
logic take_br;
wire ir_mux_sel_w;
logic [2:0] pc_mux_sel_w;
logic [4:0] rd_w;

//----------------INTERNOS-------------------//
logic [19:0] s_imm_sign_ext_a;
logic [31:0] i_imm_sign_ext;
logic [31:0] s_imm_sign_ext;
logic [31:0] b_sign_ext;
logic [12:0] imm_SB_w;
logic [11:0] imm_S_w;
logic [11:0] imm_I_w;
logic [19:0] imm_U_w;
logic [31:0] u_imm;
logic [31:0] data_o_mux;
//logic [31:0] data_add_mux;
logic [31:0] data_add_r;
logic [2:0] mem_align_mux_r;
logic unalign_wren_w;
//logic unalign_wren_r;
logic [31:0] sb_byte;
logic [31:0] sh_halfw;
//logic data_add_mux_sel_r;
logic [1:0] unalign_str_mux_sel_r;
logic [31:0] alu_reg;
logic [3:0] wb_mux_sel_pipe;
logic [31:0]  npc_r;
logic [31:0]  rs2_reg;
logic [31:0] extUbyte  ;
logic [31:0] extbyte 	 ;
logic [31:0] extUhalfw ;
logic [31:0] exthalfw  ;
logic [7:0] byte_mux;
logic [15:0] halfw_mux;
logic [31:0] mem_align_mux; //signal 32 bits aligned
//----------------------------------------//
//---------------PORT MAP-----------------//

riscv_regfile riscv_regfile(
.clk_i(clk_i),
 .rst_i(rst_i),
 .rd_i(rd_mux),
 .rs1_i(rs1_w),
 .rs2_i(rs2_w),
 .data_in(wb_mux),
 .wrten_i(rf_wrten_pipe),
 .ra(ra),
 .sp(sp),
 .op1_o(rs1o_w),
 .op2_o(rs2o_w),
 .result(result)
); 

riscv_alu riscv_alu(
.clk(clk_i),
 .rst(rst_i),
 .div_en(div_en),
 .freeze_pipe(alu_busy),
 .A(op1_mux),
 .B(op2_mux),
 .C(alu_o_w),
 .C_hi(alu_hi_w),
 .op(alu_sel)
);

riscv_decoder riscv_decoder (
 .prev_rd(wb_add_reg),
 .prev_op(opcode_r),
 .curr_rs1(rs1_w),
 .curr_rs2(rs2_w),
 //.rom_mux_sel(rom_mux_sel_w),
 .mem_unalign_wren(unalign_wren_w),
 .mem_unalign_str_mux(unalign_str_mux_sel_w),
 .mem_unalign_add_mux(data_add_mux_sel_w),
 .rs2_mux_sel(rs2_mux_sel),
 .rs1_mux_sel(rs1_mux_sel),
 .rs1(rs1_mux),
 .rs2(rs2_mux),
 .mem_align_mux(mem_align_mux_w), // signal 2 bit for mux
 .alu_sel(alu_sel),
 .ir_en(ir_en),
 .take_br(take_br),
 .opcode_i(opcode_w),
 .func3_i(func3_w),
 .func7_i(func7_w),
 .alu_en(alu_wen),
 .div_en(div_en),
 .alu_busy(alu_busy),
 .mem_busy(mem_busy),
 .data_av(data_av),
 .op2_sel(op2_mux_sel),
 .op1_sel(op1_mux_sel),
 .wb_sel(wb_mux_sel_w),
 .pc_mux_sel_o(pc_mux_sel_w),
 .mem_clken(mem_clken),
 .rf_wrten(rf_wrten_w),
 .mem_rden(data_rden),
 .pred_miss(ir_mux_sel_w),
 .load_mem(load_mem_W),
 .load_mem_i(load_mem_r),
 .mem_wrten(data_wr) );
//
riscv_fetch riscv_fetch (
.clk_i(clk_i),
 .rst_i(rst_i),
 .inst_cache_d(inst_cache_data),
 .inst_cache_a(inst_cache_add),
 .inst_cache_ren(inst_cache_rden),
 .npc_o(npc), .ir_o(instr_r),
 .taken_br(take_br),
 .pred_miss(ir_mux_sel_w),
 //.inst_cache_mux_sel_i(rom_mux_sel_w),
 .br_addr(br_add),
 .jalr_addr(alu_o_w),
 .pc_input_sel_i(pc_mux_sel_w),
 .MEPC(MEPC),
 .stall_i(ir_en),
 .interrupt_req(interrupt_req),
 .rst_eval_regs (rst_eval_regs),
 .en_eval_regs(en_eval_regs),
 .clk_counter_o(clk_counter_o),
 .inst_counter_o(inst_counter_o), 
 .branch_counter_o(branch_counter_o));

//-------------------OPCODES---------------------//
localparam OP_LUI 	=	7'b0110111;
localparam OP_AUIPC 	=	7'b0010111;
localparam OP_JAL 	=	7'b1101111;
localparam OP_JALR 	=	7'b1100111;
localparam OP_BRANCH	=	7'b1100011;
localparam OP_LOAD 	=	7'b0000011;
localparam OP_STORE 	=	7'b0100011;
localparam OP_ARIT_I	=	7'b0010011;
localparam OP_ARIT 	=	7'b0110011;
localparam OP_FENCE 	=	7'b0001111;
localparam OP_SYSTEM	=	7'b1110011;
//----------------AUXILIARES-INSTRUCTION-----------------//
assign ir_o = br_add; //npc;
assign	instruction_o = (instr_r == 32'h001e6e13)? 32'hFFFFFFFF : instr_r;
assign opcode_w 	= instr_r  [6:0];
assign func3_w		= instr_r  [14:12];
assign func7_w		= instr_r  [31:25];
assign rs2_w		= instr_r  [24:20];
assign rs1_w		= instr_r  [19:15];
assign rd_w			= instr_r  [11:7];
assign imm_I_w  	= instr_r  [31:20]; //LOADs
assign imm_U_w  	= instr_r  [31:12]; //LUI, AUIPC
assign imm_S_w  	= {instr_r [31:25] , instr_r[11:7]}; //STORES
assign imm_SB_w 	= {instr_r[31] , instr_r[7] , instr_r[30:25] , instr_r[11:8] , 1'b0};//BRANCHS
//-------------------AUXILIARES-MEM--------------------//
//U TYPE
assign u_imm = {imm_U_w ,12'd0}; 
//I-TYPE
//SIGN EXTENSION
assign i_imm_sign_ext[31:12] = {20{imm_I_w[11]}};
assign i_imm_sign_ext[11:0]  = imm_I_w[11:0];	//LOADs
//S-TYPE
//SIGN EXTENSION
assign s_imm_sign_ext_a = {20{imm_S_w[11]}};
assign s_imm_sign_ext 	= {s_imm_sign_ext_a[19:0] , imm_S_w[11:0]};	//STORE
//B
assign b_sign_ext[31:13] 	= {19{imm_SB_w[12]}};
assign b_sign_ext[12:0] 	= {imm_SB_w[12:0]};
assign br_add 				= b_sign_ext + npc;
//
//----------------------------------------------------//
always_comb begin
	case (interrupt_req)
		1'b0:
			rd_mux = wb_add_reg;
		1'b1:
			rd_mux = 5'b00001;
		default:
			rd_mux = 5'b00000;
	endcase			
end
//---------------------ENTRADA-BRANCH-VERIFICAÇÃO-----------------------------//
always_comb begin
	case (rs1_mux_sel)
		2'b00:
			rs1_mux = rs1o_w;
		2'b01:
			rs1_mux = wb_mux;
		2'b10:
			rs1_mux = mem_align_mux;
		default:
			rs1_mux = 31'd0;
	endcase			
end
//-------------------ENTRADA-BRANCH-VERIFICAÇÃO-------------------------------//
always_comb begin
	case (rs2_mux_sel)
		2'b00:
			rs2_mux = rs2o_w;
		2'b01:
			rs2_mux = wb_mux;
		2'b10:
			rs2_mux = mem_align_mux; // //signal 32 bits aligned
		default:
			rs2_mux = 31'd0;
	endcase			
end
//------------------INPUT-A-ALU-------------------//	
always_comb begin
	case (op1_mux_sel)
		1'b0:
			op1_mux = rs1_mux;
		1'b1:
			op1_mux = u_imm;
		default:
			op1_mux = 31'd0;
	endcase			
end
//------------------INPUT-B-ALU-------------------//		  	  
always_comb begin
	case (op2_mux_sel)
	3'b000 :
		op2_mux = rs2_mux;
	3'b001 : 
		op2_mux = i_imm_sign_ext;
	3'b010 :
		op2_mux = s_imm_sign_ext;
	3'b011 :
		op2_mux = npc;
	3'b100 :
		op2_mux = 32'd0;
	default:
		op2_mux = 32'd0;
	endcase
end
//		   
assign data_o 		= data_o_mux;
assign data_add 	= alu_o_w; 
assign data_wren 	= data_wr || unalign_wren_w;
//
always_comb begin
	case (unalign_str_mux_sel_r)
		2'b00:
			data_o_mux = rs2_mux; //SB
		2'b01:
			data_o_mux = sb_byte; //SH
		2'b10:
			data_o_mux = sh_halfw; //SH
		default:
			data_o_mux = 32'd0;
	endcase
end
				  
//
// always_comb begin
//	case (data_add_mux_sel_r)
//	1'b0:
//		data_add_mux = alu_o_w; //estagio atual
//	1'b1:
//		data_add_mux = data_add_r; //proximo estagio wb
//	default:
//		data_add_mux = 32'd0;
//	endcase
//end

//					 
//// pipeline registers ex/wb					 
//always_ff @(posedge clk_i or posedge rst_i) begin
//	if (rst_i == 1'b1) begin
//		data_add_mux_sel_r <= 1'b0;
//	end
//	else begin
//		data_add_mux_sel_r <= data_add_mux_sel_w;
//	end
//end
//-----------------------------STORE-ALIGN--------------------------//
 always_ff @(posedge clk_i or posedge rst_i) begin
	if (rst_i == 1'b1) begin
		data_add_r <= 32'd0;
	end
	else begin
		data_add_r <= alu_o_w;
	end
end
//-----------------------------LOAD-ALIGN-SEL-------------------------//
 always_ff @(posedge clk_i or posedge rst_i) begin
	if (rst_i == 1'b1) begin
		mem_align_mux_r <= 3'b000;
	end
	else begin
		mem_align_mux_r <= mem_align_mux_w; //mem_align_mux_w
	end
end
//-----------------------------STORE-ALIGN-SEL-------------------------//
 always_ff @(posedge clk_i or posedge rst_i) begin
	if (rst_i == 1'b1) begin
		unalign_str_mux_sel_r <= 2'b00;
	end 
	else begin
		unalign_str_mux_sel_r <= unalign_str_mux_sel_w;
	end
end
//
 always_ff @(posedge clk_i or posedge rst_i) begin
	if (rst_i == 1'b1) begin
	//	unalign_wren_r <= 1'b0;
		load_mem_r <= 1'b0;
	end
	else begin
		//unalign_wren_r <= unalign_wren_w;
		load_mem_r <= load_mem_W;
	end
end
//wb
always_ff @(posedge clk_i or posedge rst_i) begin
	if (rst_i == 1'b1) begin
		alu_reg 	<= 32'd0;
		alu_hi_r 	<= 32'd0;
	end
	else begin //subida de clock
		if(alu_wen == 1'b1) begin
			alu_reg 	<= alu_o_w;
			alu_hi_r 	<= alu_hi_w;
		end
	end
end
//wb 
always_ff @(posedge clk_i or posedge rst_i) begin
	if (rst_i == 1'b1) begin
		wb_add_reg <= 5'b00000;
	end
	else begin
		wb_add_reg <= rd_w;
	end
end

// 
always_ff @(posedge clk_i or  posedge rst_i) begin
	if (rst_i == 1'b1) begin
		wb_mux_sel_pipe <= 4'd0;
	end
	else begin
		wb_mux_sel_pipe <= wb_mux_sel_w;
	end
end

//
always_ff @(posedge clk_i or posedge rst_i) begin
	if (rst_i == 1'b1) begin
		rf_wrten_pipe <= 1'b0;
	end 
	else begin
		rf_wrten_pipe <= rf_wrten_w || interrupt_req;
	end
end
//
always_ff @(posedge clk_i or posedge rst_i) begin
	if (rst_i == 1'b1) begin
		opcode_r <= 7'd0;
	end
	else begin
		opcode_r <= opcode_w;
	end
end
// 
always_ff @(posedge clk_i or posedge rst_i) begin
	if (rst_i == 1'b1) begin
		npc_r <= 32'd0;
	end
	else begin
		npc_r <= npc;
	end
end
//
always_ff @(posedge clk_i or posedge rst_i) begin
	if (rst_i == 1'b1) begin
		rs2_reg <= 32'd0;
	end
	else begin
		rs2_reg <= rs2_mux;
	end
end
//
// 
//----------------------------------------------------------
//WB
//----------------------------------------------------------
assign wb_mux_sel = wb_mux_sel_pipe;
//
////---UNALIGNED STORES
//-----------------------------STORE-ALIGN--------------------------//
always_comb begin
	case (data_add_r[1:0])
	2'b00: sb_byte  =  {data_i[31:8 ], rs2_reg[7:0]};//escrita nos menos significativos
	2'b01: sb_byte  =  {data_i[31:16], rs2_reg[7:0], data_i[7:0]};
	2'b10: sb_byte  =  {data_i[31:24], rs2_reg[7:0], data_i[15:0]};
	2'b11: sb_byte  =  {rs2_reg[7:0],  data_i[23:0]};
	default: sb_byte = 32'd0;
	endcase
end
//
always_comb begin
	case (data_add_r[1:0])
		2'b00: sh_halfw = {data_i [31:16], rs2_reg[15:0]};
		2'b10: sh_halfw = {rs2_reg[15: 0], data_i [15:0]};
		default: sh_halfw = 32'd0;
	endcase
end
			  
// //----UNALIGNED LOADS
always_comb begin
	case(data_add_r[1:0])
		2'b00	:	byte_mux = data_i[7:0] ;
		2'b01	:	byte_mux = data_i[15:8] ;
		2'b10	:	byte_mux = data_i[23:16];
		2'b11	:	byte_mux = data_i[31:24] ;
		default:	byte_mux = 8'd0;
	endcase
end
//-----------------------------LOAD-ALIGN--------------------------//
//-------------------LOAD-BYTE-SIGNAL--------------------//
assign extbyte[31:8] = {23{byte_mux[7]}}; 
assign extbyte[7 :0] = byte_mux[7:0];
//-------------------LOAD-BYTE-UNSIGNAL------------------//
assign extUbyte[31:8] = 23'd0;
assign extUbyte[7 :0] = byte_mux[7:0];
//-------------------LOAD-HALF-HI-LO--------------------//
always_comb begin			
	case (data_add_r[1:0])
		2'b00:	halfw_mux = data_i[15:0];
		2'b10:	halfw_mux = data_i[31:16];
		default:halfw_mux = 16'd0;
	endcase
end
//--------------LOAD-HALF-SIGNAL--------------------//
assign exthalfw[31:16] = {16{halfw_mux[15]}};
assign exthalfw[15:0]  = halfw_mux[15:0];
//-------------------LOAD-HALF-UNSIGNAL------------//
assign extUhalfw[31:16] = 16'd0;
assign extUhalfw[15:0]  = halfw_mux[15:0];
//-------------------------MUX-ALIGN-MEM-LOAD---------------------//			
always_comb begin
	case(mem_align_mux_r)
		3'b000:	mem_align_mux = data_i;		//signal 32 bits aligned
		3'b001:	mem_align_mux =	extbyte ;	//signal 32 bits aligned
		3'b010:	mem_align_mux =	extUbyte;	//signal 32 bits aligned
		3'b011:	mem_align_mux =	exthalfw ;	//signal 32 bits aligned
		3'b100:	mem_align_mux =	extUhalfw ;	//signal 32 bits aligned
		default:mem_align_mux =	32'd0; 		//signal 32 bits aligned
	endcase
end
//-------------------MEPC-INTERRUPT-------------------//
always_ff @(posedge clk_i or posedge rst_i) begin
	if (rst_i == 1'b1) begin
		MEPC <= 32'd0;
	end
	else begin
		if(interrupt_req ==  1'b1) begin
			MEPC <= npc; 
		end 
	end
end
//-------------------WRITE-BACK-------------------//	
assign wb_mux_sel_int =  wb_mux_sel;
always_comb begin				
	case (wb_mux_sel_int)
	4'b0000:	wb_mux =	alu_reg; // resultado da alu
	4'b0001:	wb_mux =	data_i ; //LW
	4'b0010:	wb_mux =	npc_r + 4; //jumps
	4'b0011:	wb_mux =	extUbyte; //LBU
	4'b0100:	wb_mux =	extUhalfw; //LHU
	4'b0101:	wb_mux =	extbyte; //LB
	4'b0110:	wb_mux =	exthalfw; //LH
	4'b0111:	wb_mux =	alu_hi_r; // C_hi da alu
	//4'b1000:	wb_mux =	oolong_reg;
	4'b1001:	wb_mux =	MEPC; //retorno da rot. trat. exceção
	default:	wb_mux =  	32'd0;
	endcase
end
/* //######################TESTE#######################
initial begin
	integer file;
	#20ns;
	
	file = $fopen("results/output_sv.txt", "w");
	forever begin
		if (instr_r == 32'h001e6e13) begin
			$fwrite(file, "ERROR!!! INSTRUCTION FAIL DETECTED %h \n ", instr_r);
		end
		else begin
			$fwrite(file, "INSTRUCTION : %h \n", instr_r);
		end
		#20ns;
	end
	$fclose(file);
	
end
//##################################################### */

endmodule 