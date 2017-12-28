// -----------------------------------------------------------------------------
// FILE NAME      : riscv_decoder
// AUTHOR         : voo,caram
// AUTHOR'S EMAIL : {voo,caram}@cin.ufpe.br
// -----------------------------------------------------------------------------
// RELEASE HISTORY
// VERSION 	DATE         AUTHOR		DESCRIPTION
// 2.0		2017-01-30   voo   		version sv
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
module riscv_decoder (
	input logic [4:0] prev_rd,
	input logic [6:0] prev_op,
	input logic [4:0] curr_rs1,
	input logic [4:0] curr_rs2,
	
	//output logic [1:0] ////rom_mux_sel,
	
	output logic mem_unalign_wren,
	output logic [1:0] mem_unalign_str_mux,
	output logic mem_unalign_add_mux,
	
	input logic [6:0] opcode_i,
	input logic [6:0] func7_i,
	input logic [2:0] func3_i,

	input int rs1,
	input int rs2,
	
	input logic take_br,
	//output logic take_br_exe, //remove after
	output logic [2:0] op2_sel,
	output logic [4:0] alu_sel, 
	
	output logic alu_en,
	output logic div_en,
	input logic alu_busy ,
	input logic  mem_busy,
	input logic data_av, //remove after
	output logic [2:0] mem_align_mux,
	
	output logic ir_en,
	output logic op1_sel,
	output logic [3:0] wb_sel,
	output logic [2:0] pc_mux_sel_o,
	
	//hazards
	output logic [1:0] rs2_mux_sel,
	output logic [1:0] rs1_mux_sel,

	output logic mem_clken , //remove after
                           
	output logic rf_wrten  ,
	output logic mem_rden  ,
	output logic pred_miss ,
	input logic  load_mem_i,
	output logic load_mem, //OPA
	output logic mem_wrten 
); 

localparam OP_LUI 		= 7'b0110111;
localparam OP_AUIPC  	= 7'b0010111;
localparam OP_JAL 		= 7'b1101111;
localparam OP_JALR 		= 7'b1100111;
localparam OP_BRANCH 	= 7'b1100011;
localparam OP_LOAD 		= 7'b0000011;
localparam OP_STORE  	= 7'b0100011;
localparam OP_ARIT_I 	= 7'b0010011;
localparam OP_ARIT 		= 7'b0110011;
localparam OP_FENCE  	= 7'b0001111;
localparam OP_SYSTEM		= 7'b1110011;

localparam FUNC3_BEQ  = 3'b000;
localparam FUNC3_BNE  = 3'b001;
localparam FUNC3_BLT  = 3'b100;
localparam FUNC3_BGE  = 3'b101;
localparam FUNC3_BLTU = 3'b110;
localparam FUNC3_BGEU = 3'b111;

localparam FUNC3_LB  = 3'b000;
localparam FUNC3_LH  = 3'b001;
localparam FUNC3_LW  = 3'b010;
localparam FUNC3_LBU = 3'b100;
localparam FUNC3_LHU = 3'b101;

localparam FUNC3_SB = 3'b000;
localparam FUNC3_SH = 3'b001;
localparam FUNC3_SW = 3'b010;

localparam FUNC3_ADDI   = 3'b000;
localparam FUNC3_SLTI   = 3'b010;
localparam FUNC3_SLTIU  = 3'b011;
localparam FUNC3_XORI   = 3'b100;
localparam FUNC3_ORI    = 3'b110;
localparam FUNC3_ANDI   = 3'b111;

localparam FUNC3_SLLI   = 3'b001;
localparam FUNC3_SRLI   = 3'b101;
localparam FUNC3_SRAI   = 3'b101;

localparam FUNC3_ADD	   = 3'b000;
                       
localparam FUNC3_SLL	   = 3'b001;
localparam FUNC3_SLT	   = 3'b010;
localparam FUNC3_SLTU   = 3'b011;
localparam FUNC3_XOR	   = 3'b100;
localparam FUNC3_SR     = 3'b101;

localparam FUNC3_OR	    = 3'b110;
localparam FUNC3_AND	    = 3'b111;

localparam FUNC3_FENCE	   = 3'b000;
localparam FUNC3_FENCEI	   = 3'b001;
localparam FUNC3_SCALL	   = 3'b000;
localparam FUNC3_SBREAK	   = 3'b000;
localparam FUNC3_RDCYCLE	   = 3'b010;
localparam FUNC3_RDCYCLEH   = 3'b010;
localparam FUNC3_RDTIME	   = 3'b010;
localparam FUNC3_RDTIMEH	   = 3'b010;
localparam FUNC3_RDINSTRET  = 3'b010;
localparam FUNC3_RDINSTRETH = 3'b010;

localparam FUNC7_SRLI       = 7'b0000000;
localparam FUNC7_SRAI       = 7'b0100000;
localparam FUNC7_ADD	       = 7'b0000000;
localparam FUNC7_SUB	       = 7'b0100000;
localparam FUNC7_SRL	       = 7'b0000000;
localparam FUNC7_SRA	       = 7'b0100000;

//mux para ULA
always_comb begin
	
	case (opcode_i) 
		OP_LOAD  :  alu_sel = 5'b00000;   
		OP_STORE :  alu_sel = 5'b00000;
		OP_AUIPC :  alu_sel = 5'b00000;
		OP_LUI   :  alu_sel = 5'b00000;
		OP_JALR  :  alu_sel = 5'b00000;
		OP_ARIT  :  alu_sel = {func7_i[5],func7_i[0],func3_i};
		OP_ARIT_I:	begin
			if( (func3_i == 3'b001) || (func3_i == 3'b101) ) begin
				alu_sel = {func7_i[5], func7_i[0],func3_i};
			end
			else begin
				alu_sel = {2'b00, func3_i};
			end
		end
		default:  alu_sel =  {2'b00, func3_i};
	endcase
end

always @(*)// (func7_i,take_br,func3_i,prev_op,opcode_i,prev_rd,curr_rs1,curr_rs2,rs2,rs1,mem_busy,alu_busy)  // TODO
begin
	load_mem 		<= 1'b0; //OPA
	case (opcode_i)
		OP_LUI: begin
			//load_mem 		<= 1'b0; //OPA
			op2_sel		 	<= 3'b100;
			op1_sel 		<= 1'b1;
			wb_sel 			<= 4'b0000;
			pc_mux_sel_o 	<= 3'b000;
			rf_wrten 		<= 1'b1;
			mem_rden  		<= 1'b0;
			mem_wrten 		<= 1'b0;

			alu_en 			<= 1'b1;
			mem_clken 		<= 1'b0;
			//
			rs1_mux_sel 	<= 2'b00;
			rs2_mux_sel 	<= 2'b00;

			pred_miss		<= 1'b0;
			ir_en 			<= 1'b0;
			mem_align_mux  	<= 3'b000;
			//
			//rom_mux_sel 		<= 2'b00;
			mem_unalign_wren 	<= 1'b0;
			mem_unalign_str_mux <= 2'b00;
			mem_unalign_add_mux <= 1'b0;
			div_en 				<= 1'b0;

				
		end
		OP_AUIPC: begin
			op2_sel 		<= 3'b011;
			op1_sel 		<= 1'b1;
			wb_sel  		<= 4'b0000;
			pc_mux_sel_o 	<= 3'b000;
			rf_wrten		<= 1'b1;
			mem_rden 		<= 1'b0;
			mem_wrten		<= 1'b0;

			mem_clken 		<= 1'b0;

			alu_en 			<= 1'b1; //adds this offset to the pc, then places the result in register rd.
			//
			rs1_mux_sel 	<= 2'b00;
			rs2_mux_sel 	<= 2'b00;
			pred_miss 		<= 1'b0;

			ir_en 			<= 1'b0;
			mem_align_mux  <= 3'b000;

			//rom_mux_sel 	<= 2'b00;
			//				
			mem_unalign_wren 	<= 1'b0;
			mem_unalign_str_mux <= 2'b00;
			mem_unalign_add_mux <= 1'b0;
			div_en 				<= 1'b0;
			//load_mem 			<= 1'b0; 
		
		end
		OP_JAL: begin
		
			op2_sel 				<= 3'b000; 
			op1_sel 				<= 1'b0;  
			wb_sel  				<= 4'b0010;          
			rf_wrten				<= 1'b1;
			mem_rden  			<= 1'b0;

			pred_miss 			<= 1'b0;
			pc_mux_sel_o		<= 3'b000;

			mem_clken 			<= 1'b0;
                              
			mem_wrten 			<= 1'b0;
			alu_en 				<= 'b0;
			//                
			rs1_mux_sel 		<= 2'b00;
			rs2_mux_sel 		<= 2'b00;
                              
			ir_en 				<= 1'b0;
			mem_align_mux 		<= 3'b000;

			//rom_mux_sel 		<= 2'b00;
			mem_unalign_wren 	<= 1'b0;
			mem_unalign_str_mux 	<= 2'b00;
			mem_unalign_add_mux 	<= 1'b0;
			div_en 					<= 1'b0;
		//	load_mem 				<= 1'b0; //OPA

		end
		
		OP_JALR: begin
			if(prev_rd == curr_rs1 && prev_rd != 5'b00000) begin
				case (prev_op) 
					OP_LOAD 		:	rs1_mux_sel  <= 2'b10; //MEM_BYP
					OP_LUI 			:	rs1_mux_sel  <= 2'b01; //ALU_BYP 
					OP_AUIPC		:	rs1_mux_sel  <= 2'b01; //ALU_BYP
					OP_JAL 			:	rs1_mux_sel  <= 2'b01; //ALU_BYP
					OP_JALR 		:	rs1_mux_sel  <= 2'b01; //ALU_BYP
					OP_ARIT 		:	rs1_mux_sel  <= 2'b01; //ALU_BYP
					OP_ARIT_I 		:	rs1_mux_sel  <= 2'b01; //ALU_BYP
					OP_SYSTEM 		:	rs1_mux_sel  <= 2'b01; //ALU_BYP
					OP_STORE		:	rs1_mux_sel	 <= 2'b00; // NO BYP
					OP_BRANCH 		:	rs1_mux_sel  <= 2'b00;  // NO BYP
					default			: 	rs1_mux_sel  <= 2'b00;  // NO BYP
			   endcase
			end
			else begin 
				rs1_mux_sel <= 2'b00; // porque o mesmo que store e branch?
			end
			
			if (prev_rd == curr_rs2 && prev_rd != 5'b00000) begin
			   case (prev_op) 
					OP_LOAD 		: rs2_mux_sel  <= 2'b10; //MEM_BYP
					OP_LUI 		: rs2_mux_sel  <= 2'b01; //ALU_BYP 
					OP_AUIPC 	: rs2_mux_sel  <= 2'b01; //ALU_BYP
					OP_JAL 		: rs2_mux_sel  <= 2'b01; //ALU_BYP
					OP_JALR 		: rs2_mux_sel  <= 2'b01; //ALU_BYP
					OP_ARIT 		: rs2_mux_sel  <= 2'b01; //ALU_BYP
					OP_ARIT_I 	: rs2_mux_sel  <= 2'b01; //ALU_BYP
					OP_SYSTEM 	: rs2_mux_sel  <= 2'b01; //ALU_BYP
					OP_STORE 	: rs2_mux_sel  <= 2'b00; // NO BYP
					OP_BRANCH 	: rs2_mux_sel  <= 2'b00; // NO BYP
					default    : rs2_mux_sel  <= 2'b00;	// NO BYP
				endcase
			end
			else begin
				rs2_mux_sel <= 2'b00;
			end
			alu_en 		<= 1'b1;
			op2_sel 	<= 3'b001; // _imm_sign_ext
			op1_sel 	<= 1'b0;   // rs1o_w	
		
		//FLUSH PIPELINE?
		  wb_sel  			<= 4'b0010; 
		  rf_wrten 			<= 1'b1;
		  mem_rden  		<= 1'b0;
		  mem_wrten 		<= 1'b0;
		  pc_mux_sel_o 		<= 3'b010;				  
		  pred_miss 		<= 1'b1;
		  mem_clken 		<= 1'b0;

		ir_en 				<= 1'b0;
		mem_align_mux  	<= 3'b000;

		//rom_mux_sel 		<= 2'b10;
		mem_unalign_wren 	<= 1'b0;
		mem_unalign_str_mux <= 2'b00;
		mem_unalign_add_mux <= 1'b0;
		div_en 				<= 1'b0;
		//load_mem 			<= 1'b0;		//OPA

		end		
		OP_BRANCH: begin
			if (prev_rd == curr_rs1 && prev_rd != 5'b00000) begin
			   case (prev_op)
					OP_LOAD 	: rs1_mux_sel  <= 2'b10; // MEM_BYP
					OP_LUI 		: rs1_mux_sel  <= 2'b01; // ALU_BYP 
					OP_AUIPC 	: rs1_mux_sel  <= 2'b01; // ALU_BYP
					OP_JAL 		: rs1_mux_sel  <= 2'b01; // ALU_BYP
					OP_JALR 	: rs1_mux_sel  <= 2'b01; // ALU_BYP
					OP_ARIT 	: rs1_mux_sel  <= 2'b01; // ALU_BYP
					OP_ARIT_I 	: rs1_mux_sel  <= 2'b01; // ALU_BYP
					OP_SYSTEM 	: rs1_mux_sel  <= 2'b01; // ALU_BYP
					OP_STORE 	: rs1_mux_sel  <= 2'b00; // NO BYP
					OP_BRANCH 	: rs1_mux_sel  <= 2'b00; // NO BYP
					default 	: rs1_mux_sel  <= 2'b00; // NO BYP
			   endcase
			end
			else begin 
				rs1_mux_sel <= 2'b00;
			end
			
			if(prev_rd == curr_rs2 && prev_rd != 5'b00000) begin
				case (prev_op)
					OP_LOAD 	: rs2_mux_sel  <= 2'b10; //MEM_BYP
					OP_LUI 		: rs2_mux_sel  <= 2'b01; //ALU_BYP 
					OP_AUIPC 	: rs2_mux_sel  <= 2'b01; //ALU_BYP
					OP_JAL 		: rs2_mux_sel  <= 2'b01; //ALU_BYP
					OP_JALR		: rs2_mux_sel  <= 2'b01; //ALU_BYP
					OP_ARIT 	: rs2_mux_sel  <= 2'b01; //ALU_BYP
					OP_ARIT_I 	: rs2_mux_sel  <= 2'b01; //ALU_BYP
					OP_SYSTEM 	: rs2_mux_sel  <= 2'b01; //ALU_BYP
					OP_STORE 	: rs2_mux_sel  <= 2'b00; // NO BYP
					OP_BRANCH 	: rs2_mux_sel  <= 2'b00; // NO BYP
					default 	: rs2_mux_sel  <= 2'b00; // NO BYP
				endcase
			end
			else begin 
				rs2_mux_sel <= 2'b00;
			end
			
			alu_en 				<= 1'b0;
			mem_rden  			<= 1'b0;
			mem_clken 			<= 1'b0;
			mem_unalign_wren 	<= 1'b0;
			mem_unalign_str_mux <= 2'b00;
			mem_unalign_add_mux <= 1'b0;
			op2_sel 			<= 3'b000;
			//                     
			op1_sel	 			<= 1'b0;
			wb_sel    			<= 4'b0000;
			rf_wrten  			<= 1'b0;
			mem_wrten   		<= 1'b0;
			mem_align_mux  		<= 3'b000;
			ir_en 				<= 1'b0;
			div_en 				<= 1'b0;
			//load_mem 			= 1'b0; //OPA
							
			case (func3_i)
				FUNC3_BNE : begin							
					if (rs1 != rs2) begin        	// BRANCH 					
						if (take_br  == 1'b1) begin  	// PREVISAO CERTA
							pc_mux_sel_o 	<= 3'b000; 
							pred_miss  		<= 1'b0;
							//rom_mux_sel 	<= 2'b00;
						end 
						else begin                  // PREVISAO ERRADA
							//rom_mux_sel 	<= 2'b01;
							pc_mux_sel_o 	<= 3'b001; //AQUI
							pred_miss  		<= 1'b1;
						end
					end
					else  begin      					// ! BRANCH
						if (take_br == 1'b1) begin  	// PREVISAO ERRADA
							pc_mux_sel_o 	<= 3'b011; 	//PC <= PC ANTERIOR
							pred_miss  		<= 1'b1;
							//rom_mux_sel 	<= 2'b01;
						end
						else begin	                 // PREVISAO CERTA
							pc_mux_sel_o 	<= 3'b000; 	//PC <= PC+1
							pred_miss  		<= 1'b0;
							//rom_mux_sel 	<= 2'b00;
						end
					end
				end
				FUNC3_BEQ : begin
					if (rs1 == rs2) begin    // BRANCH  //rs1 esta sendo lido diferente de F							
						if (take_br  == 1'b1) begin  	// PREVISAO CERTA
							pc_mux_sel_o 	<= 3'b000; 
							pred_miss  		<= 1'b0;
							//rom_mux_sel		<= 2'b00;
						end
						else begin	                  	// PREVISAO ERRADA
							//rom_mux_sel 	<= 2'b01;
							pc_mux_sel_o 	<= 3'b001;  //AQUI
							pred_miss  		<= 1'b1;
						end	
					end 
					else begin     					// ! BRANCH
						if (take_br  == 1'b1) begin  	// PREVISAO ERRADA
							pc_mux_sel_o 	<= 3'b011; 	//PC <= PC ANTERIOR
							pred_miss  		<= 1'b1;
							//rom_mux_sel 	<= 2'b01;
						end	                  	// PREVISAO CERTA
						else begin
							pc_mux_sel_o 	<= 3'b000; 	//PC <= PC+1
							pred_miss  		<= 1'b0;
							////rom_mux_sel 	<= 2'b00;
						end
					end	
				end
				FUNC3_BLT : begin
					if (rs1 < rs2) begin        // BRANCH  //rs1 esta sendo lido diferente de F							
						if (take_br  == 1'b1) begin  // PREVISAO CERTA
							pc_mux_sel_o 	<= 3'b000; 
							pred_miss  		<= 1'b0;
							////rom_mux_sel 	<= 2'b00;
						end 
						else begin 				// PREVISAO ERRADA
							////rom_mux_sel 	<= 2'b01;
							pc_mux_sel_o 	<= 3'b001; //AQUI
							pred_miss  		<= 1'b1;
						end
					end
					else begin			        // ! BRANCH
						if (take_br  == 1'b1) begin  // PREVISAO ERRADA
							pc_mux_sel_o 	<= 3'b011; //PC <= PC ANTERIOR
							pred_miss  		<= 1'b1;
							////rom_mux_sel 	<= 2'b01;
						end	                  // PREVISAO CERTA
						else begin
							pc_mux_sel_o 	<= 3'b000; //PC <= PC+1
							pred_miss  		<= 1'b0;
							////rom_mux_sel 	<= 2'b00;
						end
					end
				end
				FUNC3_BGE : begin
					if(rs1 >= rs2) begin        // BRANCH  //rs1 esta sendo lido diferente de F							
						if(take_br == 1'b1) begin  // PREVISAO CERTA
							pc_mux_sel_o 	<= 3'b000; 
							pred_miss  		<= 1'b0;
							////rom_mux_sel 	<= 2'b00;
						end
						else begin	                 // PREVISAO ERRADA
							////rom_mux_sel 	<= 2'b01;
							pc_mux_sel_o 	<= 3'b001; //AQUI
							pred_miss  		<= 1'b1;
						end	
					end
					else  begin      // ! BRANCH
						if(take_br == 1'b1) begin  // PREVISAO ERRADA
							pc_mux_sel_o	<= 3'b011; //PC <= PC ANTERIOR
							pred_miss  		<= 1'b1;
							////rom_mux_sel 	<= 2'b01;
						end
						else begin	                // PREVISAO CERTA
							pc_mux_sel_o 	<= 3'b000; //PC <= PC+1
							pred_miss  		<= 1'b0;
							////rom_mux_sel 	<= 2'b00;
						end 
					end
				end
				FUNC3_BLTU : begin
					if( ({1'b0,rs1}) < ({1'b0,rs2}) ) begin        // BRANCH  //rs1 esta sendo lido diferente de F							
						if(take_br == 1'b1) begin  // PREVISAO CERTA
							pc_mux_sel_o 	<= 3'b000; 
							pred_miss  		<= 1'b0;
							////rom_mux_sel 	<= 2'b00;
						end
						else	begin                  // PREVISAO ERRADA
							////rom_mux_sel 	<= 2'b01;
							pc_mux_sel_o 	<= 3'b001; //AQUI
							pred_miss  		<= 1'b1;
						end	
					end
					else  begin     // ! BRANCH
						if(take_br == 1'b1) begin  // PREVISAO ERRADA
							pc_mux_sel_o 	<= 3'b011; //PC <= PC ANTERIOR
							pred_miss  		<= 1'b1;
							////rom_mux_sel		<= 2'b01;
						end
						else begin	                  // PREVISAO CERTA
							pc_mux_sel_o 	<= 3'b000; //PC <= PC+1
							pred_miss  		<= 1'b0;
							////rom_mux_sel		<= 2'b00;
						end
					end	
				end
				FUNC3_BGEU : begin
					if ( ({1'b0,rs1}) >= ({1'b0,rs2}) ) begin        // BRANCH  //rs1 esta sendo lido diferente de F							
						if(take_br == 1'b1) begin  // PREVISAO CERTA
							pc_mux_sel_o 	<= 3'b000; 
							pred_miss  		<= 1'b0;
							////rom_mux_sel 	<= 2'b00;
						end
						else begin	                  // PREVISAO ERRADA
							////rom_mux_sel 	<= 2'b01;
							pc_mux_sel_o 	<= 3'b001; //AQUI
							pred_miss  		<= 1'b1;
						end	
					end
					else begin       // ! BRANCH
						if(take_br == 1'b1) begin  // PREVISAO ERRADA
							pc_mux_sel_o 	<= 3'b011; //PC <= PC ANTERIOR
							pred_miss  		<= 1'b1;
							////rom_mux_sel 	<= 2'b01;
						end
						else begin	                  // PREVISAO CERTA
							pc_mux_sel_o 	<= 3'b000; //PC <= PC+1
							pred_miss  		<= 1'b0;
							////rom_mux_sel 	<= 2'b00;
						end 
					end	
				end
				default : begin
					pred_miss 			<= 1'b0;
					mem_align_mux  		<= 3'b000;
					////rom_mux_sel 		<= 2'b00;
					pc_mux_sel_o 		<= 3'b000;
				end	//
			endcase	
		end
		OP_LOAD: begin
			if (prev_rd == curr_rs1 && prev_rd != 5'b00000) begin
				case (prev_op)
					OP_LOAD 		: rs1_mux_sel  <= 2'b10; //MEM_BYP
					OP_LUI 			: rs1_mux_sel  <= 2'b01; //ALU_BYP 
					OP_AUIPC 		: rs1_mux_sel  <= 2'b01; //ALU_BYP
					OP_JAL 			: rs1_mux_sel  <= 2'b01; //ALU_BYP
					OP_JALR 		: rs1_mux_sel  <= 2'b01; //ALU_BYP
					OP_ARIT 		: rs1_mux_sel  <= 2'b01; //ALU_BYP
					OP_ARIT_I 		: rs1_mux_sel  <= 2'b01; //ALU_BYP
					OP_SYSTEM 		: rs1_mux_sel  <= 2'b01; //ALU_BYP
					OP_STORE 		:  rs1_mux_sel <= 2'b00; // NO BYP
					OP_BRANCH 		: rs1_mux_sel  <= 2'b00; // NO BYP
					default 		: rs1_mux_sel  <= 2'b00; // NO BYP
				endcase
			end
			else begin 
				rs1_mux_sel = 2'b00;
			end
			if (prev_rd == curr_rs2) begin
				case (prev_op)
					OP_LOAD 		: rs2_mux_sel  <= 2'b10; //MEM_BYP
					OP_LUI 			: rs2_mux_sel  <= 2'b01; //ALU_BYP 
					OP_AUIPC 		: rs2_mux_sel  <= 2'b01; //ALU_BYP
					OP_JAL 			: rs2_mux_sel  <= 2'b01; //ALU_BYP
					OP_JALR 		: rs2_mux_sel  <= 2'b01; //ALU_BYP
					OP_ARIT 		: rs2_mux_sel  <= 2'b01; //ALU_BYP
					OP_ARIT_I 		: rs2_mux_sel  <= 2'b01; //ALU_BYP
					OP_SYSTEM 		: rs2_mux_sel  <= 2'b01; //ALU_BYP
					OP_STORE 		: rs2_mux_sel  <= 2'b00; // NO BYP
					OP_BRANCH 		: rs2_mux_sel  <= 2'b00; // NO BYP
					default 		: rs2_mux_sel  <= 2'b00; // NO BYP
				endcase
			end
			else begin
				rs2_mux_sel <= 2'b00;
			end
			//load_mem 		<= 1'b0; //OPA
			alu_en 			<= 1'b0;
			op2_sel 			<= 3'b001; // _imm_sign_ext
			op1_sel 			<= 1'b0;  // rs1o_w
			////rom_mux_sel 	<= 2'b00;
			pc_mux_sel_o 	<= 3'b000; // PC + 1

			mem_wrten 		<= 1'b0;
			
			mem_clken 		<= 1'b1;
			pred_miss 		<= 1'b0;
			
			ir_en 			<= 1'b0;
			
			mem_unalign_wren 		<= 1'b0;
			mem_unalign_str_mux 	<= 2'b00;
			mem_unalign_add_mux 	<= 1'b0;
			
			div_en 		<= 1'b0;
			mem_rden  	<= 1'b1;

						
			if (mem_busy == 1'b1) begin
				ir_en 			<= 1'b1;
				pc_mux_sel_o 	<= 3'b100;
				rf_wrten 		<= 1'b0;

			end
			else begin

				ir_en 			<= 1'b0;
				pc_mux_sel_o 	<= 3'b000;
				rf_wrten 		<= 1'b1;
			end
						
				case (func3_i) 
					FUNC3_LW : begin
						wb_sel  		<= 4'b0001;
						mem_align_mux  	<= 3'b000;
					end                 
					FUNC3_LB	: begin 
						wb_sel  		<= 4'b0101;
						mem_align_mux  	<= 3'b001;
					end                 
					FUNC3_LBU: begin    
						wb_sel  		<= 4'b0011;
						mem_align_mux  	<= 3'b010;
					end                 
					FUNC3_LH : begin    
						wb_sel  		<= 4'b0110;
						mem_align_mux  	<= 3'b011;
					end                 
					FUNC3_LHU: begin	
						wb_sel  		<= 4'b0100;
						mem_align_mux  	<= 3'b100;
					end                 
					default  : begin    
						wb_sel 			<= 4'b0000;
						mem_align_mux  	<= 3'b000;
					end
				endcase		
		end
		OP_STORE: begin
			case (func3_i)
							
				FUNC3_SW: begin  
					if(prev_rd == curr_rs1 && prev_rd != 5'b00000) begin
						case (prev_op)
							OP_LOAD 		: rs1_mux_sel <= 2'b10; //MEM_BYP
							OP_LUI 			: rs1_mux_sel <= 2'b01; //ALU_BYP 
							OP_AUIPC 		: rs1_mux_sel <= 2'b01; //ALU_BYP
							OP_JAL 			: rs1_mux_sel <= 2'b01; //ALU_BYP
							OP_JALR 		: rs1_mux_sel <= 2'b01; //ALU_BYP
							OP_ARIT 		: rs1_mux_sel <= 2'b01; //ALU_BYP
							OP_ARIT_I		: rs1_mux_sel <= 2'b01; //ALU_BYP
							OP_SYSTEM 		: rs1_mux_sel <= 2'b01; //ALU_BYP
							OP_STORE 		: rs1_mux_sel <= 2'b00; // NO BYP
							OP_BRANCH 		: rs1_mux_sel <= 2'b00; // NO BYP
							default 		: rs1_mux_sel <= 2'b00; // NO BYP
						endcase
					end
					else begin
						rs1_mux_sel = 2'b00;
					end
					if (prev_rd == curr_rs2) begin
						case (prev_op)
							OP_LOAD 	: rs2_mux_sel <= 2'b10; //MEM_BYP
							OP_LUI 		: rs2_mux_sel <= 2'b01; //ALU_BYP 
							OP_AUIPC 	: rs2_mux_sel <= 2'b01; //ALU_BYP
							OP_JAL 		: rs2_mux_sel <= 2'b01; //ALU_BYP
							OP_JALR 	: rs2_mux_sel <= 2'b01; //ALU_BYP
							OP_ARIT 	: rs2_mux_sel <= 2'b01; //ALU_BYP
							OP_ARIT_I	: rs2_mux_sel <= 2'b01; //ALU_BYP
							OP_SYSTEM 	: rs2_mux_sel <= 2'b01; //ALU_BYP
							OP_STORE 	: rs2_mux_sel <= 2'b00; // NO BYP
							OP_BRANCH 	: rs2_mux_sel <= 2'b00; // NO BYP
							default 	: rs2_mux_sel <= 2'b00; // NO BYP
						endcase
					end
					else begin
						rs2_mux_sel <= 2'b00;
					end
					
					//load_mem 	= 1'b0; //OPA
					alu_en 			<= 1'b0;
					op2_sel 		<= 3'b010;	 // _imm_sign_ext
					op1_sel 		<= 1'b0;  	 // rs1o_w
					wb_sel  		<= 4'b0000; 	 // mem

					rf_wrten 	<= 1'b0;

					mem_rden  	<= 1'b0;
					mem_clken 	<= 1'b1;
					pred_miss 	<= 1'b0;


					////rom_mux_sel 	<= 2'b00;
					mem_align_mux  <= 3'b000;

					mem_unalign_wren 		<= 1'b0;
					mem_unalign_str_mux 	<= 2'b00;
					mem_unalign_add_mux 	<= 1'b0;
					div_en <= 1'b0;

					 mem_wrten				<= 1'b1;
					  
					if (mem_busy == 1'b1)  begin
						 ir_en 			<= 1'b1;
						 pc_mux_sel_o  <= 3'b100;

					end
					else begin
						 ir_en 			<= 1'b0;
						 pc_mux_sel_o 	<= 3'b000;

					end
				end
				FUNC3_SB: begin
					if (prev_rd == curr_rs1 && prev_rd != 5'b00000) begin
						case (prev_op)
							OP_LOAD 	: rs1_mux_sel <= 2'b10; //MEM_BYP
							OP_LUI 		: rs1_mux_sel <= 2'b01; //ALU_BYP 
							OP_AUIPC	: rs1_mux_sel <= 2'b01; //ALU_BYP
							OP_JAL 		: rs1_mux_sel <= 2'b01; //ALU_BYP
							OP_JALR 	: rs1_mux_sel <= 2'b01; //ALU_BYP
							OP_ARIT 	: rs1_mux_sel <= 2'b01; //ALU_BYP
							OP_ARIT_I 	: rs1_mux_sel <= 2'b01; //ALU_BYP
							OP_SYSTEM 	: rs1_mux_sel <= 2'b01; //ALU_BYP
							OP_STORE 	: rs1_mux_sel <= 2'b00; // NO BYP
							OP_BRANCH 	: rs1_mux_sel <= 2'b00; // NO BYP
							default 	: rs1_mux_sel <= 2'b00; // NO BYP
						endcase
					end
					else begin
						rs1_mux_sel <= 2'b00;
					end
					
					if (prev_rd == curr_rs2 && prev_rd != 5'b00000) begin
						case (prev_op) 
							OP_LOAD 	: rs2_mux_sel <= 2'b10; //MEM_BYP
							OP_LUI 		: rs2_mux_sel <= 2'b01; //ALU_BYP 
							OP_AUIPC 	: rs2_mux_sel <= 2'b01; //ALU_BYP
							OP_JAL 		: rs2_mux_sel <= 2'b01; //ALU_BYP
							OP_JALR 	: rs2_mux_sel <= 2'b01; //ALU_BYP
							OP_ARIT 	: rs2_mux_sel <= 2'b01; //ALU_BYP
							OP_ARIT_I 	: rs2_mux_sel <= 2'b01; //ALU_BYP
							OP_SYSTEM 	: rs2_mux_sel <= 2'b01; //ALU_BYP
							OP_STORE 	: rs2_mux_sel <= 2'b00; // NO BYP
							OP_BRANCH 	: rs2_mux_sel <= 2'b00; // NO BYP
							default		: rs2_mux_sel <= 2'b00; // NO BYP
						endcase
					end 
					else begin 
						rs2_mux_sel <= 2'b00;
					end 
					alu_en 		<= 1'b0;
					op2_sel 		<= 3'b010; // _imm_sign_ext
					op1_sel 		<= 1'b0;  // rs1o_w
					////rom_mux_sel <= 2'b00;

					rf_wrten  	<= 1'b0;
					mem_wrten 	<= 1'b0;

					mem_clken 	<= 1'b1;
					pred_miss 	<= 1'b0;
					//load_mem 			= 1'b0; //OPA
					
					if(load_mem_i == 1'b0) begin
						load_mem 	<= 1'b1; //OPA
						mem_rden  	<= 1'b1;
						ir_en 		<= 1'b1;
						pc_mux_sel_o 		<= 3'b100;
						mem_unalign_wren 	<= 1'b0;
					end
					else begin
						load_mem 	<= 1'b0; //OPA
						mem_rden 	<= 1'b0;
						ir_en 		<= 1'b0;
						pc_mux_sel_o 		<= 3'b000;
						mem_unalign_wren 	<= 1'b1;
					end;

					wb_sel  			<= 4'b0000;
					mem_align_mux  <= 3'b000;


					mem_unalign_str_mux <= 2'b01;
					mem_unalign_add_mux <= 1'b1;
					div_en 				  <= 1'b0;
				end 
				FUNC3_SH: begin
					if (prev_rd == curr_rs1 && prev_rd != 5'b00000) begin
						case (prev_op)
							OP_LOAD		: rs1_mux_sel <= 2'b10; //MEM_BYP
							OP_LUI 		: rs1_mux_sel <= 2'b01; //ALU_BYP 
							OP_AUIPC 	: rs1_mux_sel <= 2'b01; //ALU_BYP
							OP_JAL 		: rs1_mux_sel <= 2'b01; //ALU_BYP
							OP_JALR 	: rs1_mux_sel <= 2'b01; //ALU_BYP
							OP_ARIT 	: rs1_mux_sel <= 2'b01; //ALU_BYP
							OP_ARIT_I 	: rs1_mux_sel <= 2'b01; //ALU_BYP
							OP_SYSTEM 	: rs1_mux_sel <= 2'b01; //ALU_BYP
							OP_STORE 	: rs1_mux_sel <= 2'b00; // NO BYP
							OP_BRANCH 	: rs1_mux_sel <= 2'b00; // NO BYP
							default 	: rs1_mux_sel <= 2'b00; // NO BYP
						endcase
					end
					else begin 
						rs1_mux_sel <= 2'b00;
					end
					if (prev_rd == curr_rs2 && prev_rd != 5'b00000) begin
						case (prev_op)
								OP_LOAD 	: rs2_mux_sel <= 2'b10; //MEM_BYP
								OP_LUI 		: rs2_mux_sel <= 2'b01; //ALU_BYP 
								OP_AUIPC 	: rs2_mux_sel <= 2'b01; //ALU_BYP
								OP_JAL 		: rs2_mux_sel <= 2'b01; //ALU_BYP
								OP_JALR 	: rs2_mux_sel <= 2'b01; //ALU_BYP
								OP_ARIT 	: rs2_mux_sel <= 2'b01; //ALU_BYP
								OP_ARIT_I 	: rs2_mux_sel <= 2'b01; //ALU_BYP
								OP_SYSTEM 	: rs2_mux_sel <= 2'b01; //ALU_BYP
								OP_STORE 	: rs2_mux_sel <= 2'b00; // NO BYP
								OP_BRANCH 	: rs2_mux_sel <= 2'b00; // NO BYP
								default 		: rs2_mux_sel <= 2'b00; // NO BYP
						endcase
					end
					else begin
						rs2_mux_sel <= 2'b00;
					end
					alu_en 		<= 1'b0;
					op2_sel 	<= 3'b010; // _imm_sign_ext
					op1_sel 	<= 1'b0;  // rs1o_w
					////rom_mux_sel <= 2'b00;

					rf_wrten  <= 1'b0;
					mem_wrten <= 1'b0;

					mem_clken <= 1'b1;
					pred_miss <= 1'b0;

					wb_sel  	   <= 4'b0000;
					mem_align_mux  <= 3'b000;
					
					//load_mem 			= 1'b0; //OPA

					if(load_mem_i == 1'b0) begin
						load_mem 			<= 1'b1; //OPA
						mem_rden  			<= 1'b1;
						ir_en 				<= 1'b1;
						pc_mux_sel_o 		<= 3'b100;
						mem_unalign_wren 	<= 1'b0;
					end
					else begin
						load_mem 			<= 1'b0; //OPA
						mem_rden  			<= 1'b0;
						ir_en 				<= 1'b0;
						pc_mux_sel_o 		<= 3'b000;
						mem_unalign_wren 	<= 1'b1;
					end

					mem_unalign_str_mux  <= 2'b10;
					mem_unalign_add_mux  <= 1'b1;
					div_en 				 <= 1'b0;
				end
				default: begin
					op2_sel 		<= 3'b000; // _imm_sign_ext
					op1_sel 		<= 1'b0;  // rs1o_w
					wb_sel  		<= 4'b0000; // ALU_out
					pc_mux_sel_o 	<= 3'b000; // PC + 1
					rf_wrten 		<= 1'b0;
					mem_wrten 		<= 1'b0;	
					mem_rden  		<= 1'b0;
					rs1_mux_sel 	<= 2'b00;
					rs2_mux_sel 	<= 2'b00;
					alu_en 			<= 1'b0;
					mem_clken 		<= 1'b0;
					pred_miss 		<= 1'b0;
					
					ir_en 			<= 1'b0;
					mem_align_mux   <= 3'b000;
					////rom_mux_sel 	<= 2'b00;
					wb_sel  		<= 4'b0000;
					mem_unalign_wren <= 1'b0;
					mem_unalign_str_mux <= 2'b00;
					mem_unalign_add_mux <= 1'b0;
					div_en = 1'b0;
				end
			endcase
		end
										
		OP_ARIT_I: begin

				if (prev_rd == curr_rs1 && prev_rd != 5'b00000) begin
					  case (prev_op)
					    OP_LOAD		: rs1_mux_sel <= 2'b10; //MEM_BYP
					    OP_LUI 		: rs1_mux_sel <= 2'b01; //ALU_BYP 
					    OP_AUIPC	: rs1_mux_sel <= 2'b01; //ALU_BYP
					    OP_JAL 		: rs1_mux_sel <= 2'b01; //ALU_BYP
					    OP_JALR 	: rs1_mux_sel <= 2'b01; //ALU_BYP
					    OP_ARIT 	: rs1_mux_sel <= 2'b01; //ALU_BYP
					    OP_ARIT_I 	: rs1_mux_sel <= 2'b01; //ALU_BYP
					    OP_SYSTEM 	: rs1_mux_sel <= 2'b01; //ALU_BYP
					    OP_STORE 	: rs1_mux_sel <= 2'b00; // NO BYP
					    OP_BRANCH 	: rs1_mux_sel <= 2'b00; // NO BYP
					    default 	: rs1_mux_sel <= 2'b00; // NO BYP
					  endcase
				end
				else begin
					rs1_mux_sel <= 2'b00;
				end
					//load_mem 	 <= 1'b0; //OPA
					rs2_mux_sel  <= 2'b00;
					alu_en 		 <= 1'b1;
					op2_sel 	 <= 3'b001; // _imm_sign_ext
					op1_sel 	 <= 1'b0;  // rs1o_w
					wb_sel  	 <= 4'b0000; // ALU_out
					pc_mux_sel_o <= 3'b000; // PC + 1
					rf_wrten 	 <= 1'b1;
					mem_wrten 	 <= 1'b0;
					mem_rden  	 <= 1'b0;
					mem_clken 	 <= 1'b0;
					pred_miss 	 <= 1'b0;
					
					ir_en 			 <= 1'b0;
					mem_align_mux  	 <= 3'b000;
					////rom_mux_sel 	 <= 2'b00;
					mem_unalign_wren <= 1'b0;
					mem_unalign_str_mux <= 2'b00;
					mem_unalign_add_mux <= 1'b0;
					div_en 				<= 1'b0;
		end
		OP_ARIT: begin // curr_rs1 endereço do banco de registradores
				if (prev_rd == curr_rs1 && prev_rd != 5'b00000) begin
					case (prev_op)
					   OP_LOAD 	: rs1_mux_sel <= 2'b10; //MEM_BYP
					   OP_LUI 	: rs1_mux_sel <= 2'b01; //ALU_BYP 
					   OP_AUIPC : rs1_mux_sel <= 2'b01; //ALU_BYP
					   OP_JAL 	: rs1_mux_sel <= 2'b01; //ALU_BYP
					   OP_JALR 	: rs1_mux_sel <= 2'b01; //ALU_BYP
					   OP_ARIT 	: rs1_mux_sel <= 2'b01; //ALU_BYP
					   OP_ARIT_I: rs1_mux_sel <= 2'b01; //ALU_BYP
					   OP_SYSTEM: rs1_mux_sel <= 2'b01; //ALU_BYP
					   OP_STORE : rs1_mux_sel <= 2'b00; // NO BYP
					   OP_BRANCH: rs1_mux_sel <= 2'b00; // NO BYP
					   default 	: rs1_mux_sel <= 2'b00; // NO BYP
					endcase
				end
				else begin
					rs1_mux_sel <= 2'b00;
				end
				if (prev_rd == curr_rs2 && prev_rd != 5'b00000) begin
					case (prev_op) 
					  OP_LOAD 	: rs2_mux_sel <= 2'b10; //MEM_BYP
					  OP_LUI 	: rs2_mux_sel <= 2'b01; //ALU_BYP 
					  OP_AUIPC 	: rs2_mux_sel <= 2'b01; //ALU_BYP
					  OP_JAL 	: rs2_mux_sel <= 2'b01; //ALU_BYP
					  OP_JALR 	: rs2_mux_sel <= 2'b01; //ALU_BYP
					  OP_ARIT 	: rs2_mux_sel <= 2'b01; //ALU_BYP
					  OP_ARIT_I : rs2_mux_sel <= 2'b01; //ALU_BYP
					  OP_SYSTEM : rs2_mux_sel <= 2'b01; //ALU_BYP
					  OP_STORE 	: rs2_mux_sel <= 2'b00; // NO BYP
					  OP_BRANCH : rs2_mux_sel <= 2'b00; // NO BYP
					  default	: rs2_mux_sel <= 2'b00; // NO BYP
					endcase
				end
				else begin
					rs2_mux_sel <= 2'b00;
				end
				
				//load_mem 	<= 1'b0; //OPA
				alu_en 		<= 1'b1;
				op2_sel 	<= 3'b000; // _rs2o_w
				op1_sel 	<= 1'b0;  // rs1o_w
				
				mem_wrten <= 1'b0;
				mem_rden  <= 1'b0;
				mem_clken <= 1'b0;	
				pred_miss <= 1'b0;
				
				mem_align_mux  	 	<= 3'b000;
				////rom_mux_sel		 	<= 2'b00;
				mem_unalign_wren 	<= 1'b0;
				mem_unalign_str_mux <= 2'b00;
				mem_unalign_add_mux <= 1'b0;
				
				case ({func7_i , func3_i}) 
					10'b0000001000 :	begin
										wb_sel  	 <= 4'b0000; // ALU_LO
										div_en 		 <= 1'b0;
										ir_en 		 <= 1'b0;
										pc_mux_sel_o <= 3'b000;
										rf_wrten 	 <= 1'b1;
									end              
				    10'b0000001001 : begin          
										wb_sel  	 <= 4'b0111; // ALU_HI
				                        div_en 		 <= 1'b0;
				                        ir_en 		 <= 1'b0;
				                        pc_mux_sel_o <= 3'b000;
				                        rf_wrten 	 <= 1'b1;
									end              
					10'b0000001010 : 	begin        
										wb_sel  	 <= 4'b0111; // ALU_HI
				                        div_en 		 <= 1'b0;
				                        ir_en 		 <= 1'b0;
				                        pc_mux_sel_o <= 3'b000;
				                        rf_wrten 	 <= 1'b1;							
										end          
					10'b0000001011 : begin           
										wb_sel  	 <= 4'b0111; // ALU_HI
				                        div_en 		 <= 1'b0;
				                        ir_en 		 <= 1'b0;
				                        pc_mux_sel_o <= 3'b000;
				                        rf_wrten 	 <= 1'b1;							
										end
				    10'b0000001100 : begin
										wb_sel  		<= 4'b0000; // div
											if (alu_busy == 1'b0)  begin
												div_en 		 <= 1'b1;
												ir_en 		 <= 1'b1;
												pc_mux_sel_o <= 3'b100;
												rf_wrten 	 <= 1'b0;
											end 
											else begin
												div_en 		 <= 1'b0;
												ir_en 		 <= 1'b0;
												pc_mux_sel_o <= 3'b000;
												rf_wrten 	 <= 1'b1;
											end
										end
				    10'b0000001110 : begin
										wb_sel  = 4'b0000; // rem  
				                        if (alu_busy == 1'b0) begin
											div_en 		 <= 1'b1;
											ir_en 		 <= 1'b1;
											pc_mux_sel_o <= 3'b100;
											rf_wrten 	 <= 1'b0;
				                        end              
										else begin       
											div_en	 	 <= 1'b0;
											ir_en 		 <= 1'b0;
											pc_mux_sel_o <= 3'b000;
											rf_wrten 	 <= 1'b1;
				                        end
										end
					default	: begin 
								wb_sel 			<= 4'b0000; // ALU_LO
				                div_en 	 		<= 1'b0;
				                ir_en 	 		<= 1'b0;
				                pc_mux_sel_o 	<= 3'b000;
								rf_wrten 		<= 1'b1;
							end 
				endcase
		end			

		OP_SYSTEM: begin
			case ({func7_i, func3_i}) 
				10'b0000000000: begin	
									op2_sel 	 <= 3'b000; // _imm_sign_ext       ---- break
									op1_sel 	 <= 1'b0;  // rs1o_w
									wb_sel  	 <= 4'b0000; // ALU_out
									pc_mux_sel_o <= 3'b100; // PC
									rf_wrten 	 <= 1'b0;
									mem_wrten 	 <= 1'b0;	
									mem_rden  	 <= 1'b0;
									//
									rs1_mux_sel <= 2'b00;
									rs2_mux_sel <= 2'b00;
									//          
									alu_en 		<= 1'b0;
									mem_clken 	<= 1'b0;
									pred_miss 	<= 1'b0;
					
									ir_en 				<= 1'b1;
									mem_align_mux   	<= 3'b000;
									////rom_mux_sel 		<= 2'b00;
									mem_unalign_wren 	<= 1'b0;
									mem_unalign_str_mux <= 2'b00;
									mem_unalign_add_mux <= 1'b0;
									div_en 				<= 1'b0;
								//	load_mem = 1'b0; //OPA
									
								end
												
				10'b0000000010: begin	
									op2_sel <= 3'b000; // _imm_sign_ext       --- csrrs
									op1_sel <= 1'b0;  // rs1o_w
									wb_sel  <= 4'b1001; // MEPC
									pc_mux_sel_o 	<= 3'b000; // PC
									rf_wrten 		<= 1'b1;
									mem_wrten 		<= 1'b0;	
									mem_rden  		<= 1'b0;
									//
									rs1_mux_sel 	<= 2'b00;
									rs2_mux_sel 	<= 2'b00;
									//
									alu_en 			<= 1'b0;
									mem_clken 		<= 1'b0;
									pred_miss 		<= 1'b0;
				                                    
									ir_en 			<= 1'b0;
									mem_align_mux   <= 3'b000;
									////rom_mux_sel 	<= 2'b00;
									mem_unalign_wren 		<= 1'b0;
									mem_unalign_str_mux 	<= 2'b00;
									mem_unalign_add_mux 	<= 1'b0;
									div_en 			 <= 1'b0;
								//	load_mem 		 = 1'b0; //OPA
								end
				10'b1000000000: begin 	
									op2_sel <= 3'b000; // _imm_sign_ext   --- sret
									op1_sel <= 1'b0;  // rs1o_w
									wb_sel  <= 4'b0000; // MEPC
									pc_mux_sel_o 	<= 3'b000; // PC
									rf_wrten 		<= 1'b0;
									mem_wrten 		<= 1'b0;	
									mem_rden 		<= 1'b0;
									//              
									rs1_mux_sel 	<= 2'b00;
									rs2_mux_sel 	<= 2'b00;
									//              
									alu_en 			<= 1'b0;
									mem_clken 		<= 1'b0;
									pred_miss 		<= 1'b0;
				                                    
									ir_en 			<= 1'b0;
									mem_align_mux   <= 3'b000;
									////rom_mux_sel 	<= 2'b00;
									mem_unalign_wren 		<= 1'b0;
									mem_unalign_str_mux 	<= 2'b00;
									mem_unalign_add_mux 	<= 1'b0;
									div_en 			<= 1'b0;		
								//	load_mem 		= 1'b0;		//OPA		
								end				
				default:  begin			
									op2_sel 		 <= 3'b000; 
									op1_sel 		 <= 1'b0;  
									wb_sel  		 <= 4'b0000; 
									pc_mux_sel_o <= 3'b100; // PC
									rf_wrten 	 <= 1'b0;
									mem_wrten 	 <= 1'b0;	
									mem_rden  	 <= 1'b0;
									// 
									rs1_mux_sel  <= 2'b00;
									rs2_mux_sel  <= 2'b00;
									// 
									alu_en 		 <= 1'b0;
									mem_clken	 <= 1'b0;
									pred_miss 	 <= 1'b0;
						  
									ir_en 		   <= 1'b1;
									mem_align_mux  <= 3'b000; 
									////rom_mux_sel <= 2'b00; //check
									mem_unalign_wren   <= 1'b0;
									mem_unalign_str_mux <= 2'b00;
									mem_unalign_add_mux <= 1'b0;
									div_en <= 1'b0;
								//	load_mem = 1'b0; //OPA
	                  end
			endcase
			//load_mem = 1'b0;
		end
		default:  begin
			op2_sel		 		<= 3'b000; 	// _imm_sign_ext
			op1_sel 			<= 1'b0;  	// rs1o_w
			wb_sel  			<= 4'b0000; // ALU_out
			pc_mux_sel_o 		<= 3'b000; 	// PC + 1
			rf_wrten 			<= 1'b0;
			mem_wrten 			<= 1'b0;	
			mem_rden  			<= 1'b0;
			//                 
			rs1_mux_sel 		<= 2'b00;
			rs2_mux_sel 		<= 2'b00;
			//                  
			alu_en 				<= 1'b0;
			mem_clken 			<= 1'b0;
			pred_miss 			<= 1'b0;
                                
			ir_en 				<= 1'b0;
			mem_align_mux   	<= 3'b000;
			////rom_mux_sel 		<= 2'b00;
			//
			mem_unalign_wren 	 	<= 1'b0;
			mem_unalign_str_mux 	<= 2'b00;
			mem_unalign_add_mux 	<= 1'b0;
			div_en 				 	<= 1'b0;
			//load_mem 			 	<= 1'b0; //OPA
			end
		endcase
end
endmodule 