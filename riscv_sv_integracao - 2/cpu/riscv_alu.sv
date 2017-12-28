// -----------------------------------------------------------------------------
// FILE NAME      : riscv_busca
// AUTHOR         : voo
// AUTHOR'S EMAIL : voo@cin.ufpe.br
// -----------------------------------------------------------------------------


module riscv_alu ( 
	input  logic clk,  					
	input  logic rst,  					
	input  logic div_en, 				
          
	input  logic [31:0] A, 						
	input  logic [31:0] B, 	  	
	input  logic [4:0] op,					
          
	output logic freeze_pipe, 		
	output logic [31:0] C, 		
	output logic [31:0] C_hi					

	//output logic oflw					
);

localparam TAM_1 = 32;
localparam TAM_2 = 64;

logic [TAM_1-1:0] add ;//= `{32'h00000000}; 	  		  
logic [TAM_2-1:0] mul64; 		
logic [TAM_1-1:0] sub;	
logic [TAM_1-1:0] a_w;	
logic [TAM_1-1:0] b_w;
logic [TAM_1:0]	 aU_w; //signal
logic [TAM_1:0]	 bU_w; //signal
logic [TAM_1-1:0] c_w;
logic [TAM_1-1:0] b_sub_w;
logic [TAM_1-1:0] a_and_b;
logic [TAM_1-1:0] a_or_b;
logic [TAM_1-1:0] a_xor_b;
logic [TAM_1-1:0] a_SLT_b;  
logic [TAM_1-1:0] a_SLTU_b;
logic [TAM_1-1:0] a_SLL_b;
logic [TAM_1-1:0] a_SRL_b;
logic [TAM_1-1:0] a_SRA_b;
logic div_z;
logic [TAM_1-1:0] quot_w;
logic [TAM_1-1:0] rem_w;

logic ov;

comparator comparator (.a(a_w), .b(b_w), .cmp(a_SLT_b));

riscv_div riscv_div (.clk(clk), .rst(rst), .div_en(div_en), .a(A), .b(B), .q(quot_w), .r(rem_w), .div_zero(div_z), .freeze_pipe(freeze_pipe)); 
//div_zero

assign	C 		= c_w; 
assign	a_w 	=  A;
assign	b_w 	=  B;
//------------------------------------//

assign	aU_w =  {1'b0 , A};  
assign	bU_w =  {1'b0 , B};
//------------------------------------//	
//assign	//operacoes parciais
assign	mul64 = A * B;
//------------------------------------//	
//assign	//operacoes totais
assign	add		= (a_w + b_w);
assign	sub 	= (a_w - b_w);		
assign	a_and_b = (a_w & b_w);
assign	a_or_b 	= (a_w | b_w);
assign	a_xor_b = (a_w ^ b_w);
//------------------------------------//
	always_comb begin				
	case (op) 
		5'b00000: c_w		= add	  [31:0];		
		5'b10000: c_w		= sub	  [31:0];		5'b00001: c_w		= a_SLL_b [31:0];	
		5'b00010: c_w		= a_SLT_b [31:0];	
		5'b00011: c_w		= a_SLTU_b[31:0];	
		5'b00100: c_w		= a_xor_b [31:0];	
		5'b00101: c_w		= a_SRL_b [31:0];	
		5'b10101: c_w		= a_SRA_b [31:0];	
		5'b00110: c_w		= a_or_b  [31:0];	
		5'b00111: c_w		= a_and_b [31:0];	
		5'b01000: c_w		= mul64	  [31:0];  	
		5'b01100: c_w		= quot_w  [31:0]; 	
		5'b01110: c_w		= rem_w	  [31:0];
		default:  c_w		= 32'h00000000; 				
	endcase
	
	end
//------------------------------------//		
assign	C_hi = mul64[TAM_2-1:TAM_1];

		
always_comb  begin //comb begin// 
	//--------------------//
	//a_SRA_b = '{32{a_w[31]}}; 
	//-------------------//
	case (b_w[4:0])
		5'b00000 : begin
				a_SLL_b = a_w[31:0]; 
				a_SRL_b = a_w[31:0]; 
				a_SRA_b = a_w[31:0]; 
		end
		5'b00001 : begin
				a_SLL_b = {a_w[30: 0], 1'b0};
				a_SRL_b = { 1'b0, a_w[30: 0]};
				a_SRA_b = {1'b1, a_w[31:1]};
		
		end
		5'b00010 : begin
				a_SLL_b = {a_w[29: 0], 2'd0};
				a_SRL_b = { 2'd0, a_w[29: 0]};
				a_SRA_b = {{2{a_w[31]}} , a_w[31:2]};
		end
		5'b00011 : begin
				a_SLL_b = {a_w[28: 0], 3'd0};
				a_SRL_b = {3'd0,a_w[28: 0]};
				a_SRA_b = {{3{a_w[31]}},a_w[31:3]};
		end
		5'b00100 :begin 
				a_SLL_b = {a_w[27: 0], 4'd0};
				a_SRL_b = {4'd0, a_w[27: 0]};
				a_SRA_b = {{4{a_w[31]}}, a_w[31:4]};
		end
		5'b00101 :begin
				a_SLL_b = {a_w[26: 0], 5'd0};
				a_SRL_b = {5'd0, a_w[26: 0]};
				a_SRA_b = {{5{a_w[31]}},a_w[31:5]};
		end
		5'b00110 :begin 
				a_SLL_b = {a_w[25: 0], 6'd0};
				a_SRL_b = {6'd0, a_w[25: 0]};
				a_SRA_b = {{6{a_w[31]}},a_w[31:6]};
		end
		5'b00111 :begin 
				a_SLL_b = {a_w[24: 0], 7'd0};
				a_SRL_b = { 7'd0, a_w[24: 0]};
				a_SRA_b = {{7{a_w[31]}}, a_w[31:7]};
		end
		5'b01000 :begin 
				a_SLL_b = {a_w[23: 0], 8'd0};
				a_SRL_b = {8'd0,a_w[23: 0]};
				a_SRA_b = {{8{a_w[31]}},a_w[31:8]};
		end
		5'b01001 :begin 
				a_SLL_b = {a_w[22: 0], {9{1'b0}} }; 
				a_SRL_b = {{9{1'b0}}, a_w[22: 0] };
				a_SRA_b = {{9{a_w[31]}},a_w[31:9]};
		end
		5'b01010 :begin
				a_SLL_b = {a_w[21: 0], 10'd0};
				a_SRL_b = {10'd0,a_w[21: 0]};
				a_SRA_b = {{10{a_w[31]}},a_w[31:10]};
		end
		5'b01011 :begin
				a_SLL_b = {a_w[20: 0], 11'd0};
				a_SRL_b = {11'd0, a_w[20: 0]};
				a_SRA_b = {{11{a_w[31]}},a_w[31:11]};
		end
		5'b01100 :begin
				a_SLL_b = {a_w[19: 0], 12'd0};
				a_SRL_b = {12'd0, a_w[19: 0]};
				a_SRA_b = {{12{a_w[31]}},a_w[31:12]};
		end
		5'b01101 :begin
				a_SLL_b = {a_w[18: 0], 13'd0};
				a_SRL_b = {13'd0,a_w[18: 0]};
				a_SRA_b = {{13{a_w[31]}},a_w[31:13]};
		end
		5'b01110 :	begin
				a_SLL_b = {a_w[17: 0], 14'd0};
				a_SRL_b = {14'd0, a_w[17: 0]};
				a_SRA_b = {{14{a_w[31]}},a_w[31:14]};
		end
		5'b01111 :begin
				a_SLL_b = {a_w[16: 0], 15'd0};
				a_SRL_b = {15'd0, a_w[16: 0]};
				a_SRA_b = {{15{a_w[31]}},a_w[31:15]};
		end
		5'b10000 :begin
				a_SLL_b = {a_w[15: 0], 16'd0};
				a_SRL_b = {16'd0, a_w[15: 0]};
				a_SRA_b = {{16{a_w[31]}},a_w[31:16]};
		end
		5'b10001 :begin
				a_SLL_b = {a_w[14: 0], 17'd0};
				a_SRL_b = {17'd0, a_w[14: 0]};
				a_SRA_b = {{17{a_w[31]}}, a_w[31:17]};
		end
		5'b10010 :begin
				a_SLL_b = {a_w[13: 0], 18'd0};
				a_SRL_b = {18'd0, a_w[13: 0]};
				a_SRA_b = {{18{a_w[31]}}, a_w[31:18]};
		end
		5'b10011 :begin
				a_SLL_b = {a_w[12: 0], 19'd0};
				a_SRL_b = {19'd0, a_w[12: 0]};
				a_SRA_b = {{19{a_w[31]}},a_w[31:19]};
		end
		5'b10100 :begin
				a_SLL_b = {a_w[11: 0], 20'd0};
				a_SRL_b = {20'd0,a_w[11: 0]};
				a_SRA_b = {{20{a_w[31]}},a_w[31:20]};
		end
		5'b10101 :begin
				a_SLL_b = {a_w[10: 0], 21'd0};
				a_SRL_b = {21'd0, a_w[10: 0]};
				a_SRA_b = {{21{a_w[31]}},a_w[31:21]};
		end
		5'b10110 :begin
				a_SLL_b = {a_w[9:0] , 22'd0};
				a_SRL_b = {22'd0,a_w[9:0]};
				a_SRA_b = {{22{a_w[31]}},a_w[31:22]};
		end
		5'b10111 :begin
				a_SLL_b = {a_w[8:0],  23'd0};
				a_SRL_b = {23'd0, a_w[8:0]};
				a_SRA_b = {{23{a_w[31]}},a_w[31:23]};
		end
		5'b11000 :begin
				a_SLL_b = {a_w[7:0] , 24'd0};
				a_SRL_b = {24'd0, a_w[7:0]};
				a_SRA_b = {{24{a_w[31]}},a_w[31:24]};
		end
		5'b11001 :begin
				a_SLL_b = {a_w[6:0] , 25'd0};
				a_SRL_b = {25'd0, a_w[6:0]};
				a_SRA_b = {{25{a_w[31]}},a_w[31:25]};
		end
		5'b11010 :begin
				a_SLL_b = {a_w[5:0] , 26'd0};
				a_SRL_b = {26'd0, a_w[5:0]};
				a_SRA_b = {{26{a_w[31]}},a_w[31:26]};
		end
		5'b11011 :begin
				a_SLL_b = {a_w[4:0] , 27'd0};
				a_SRL_b = {27'd0, a_w[4:0]};
				a_SRA_b = {{27{a_w[31]}},a_w[31:27]};
		end
		5'b11100 :begin
				a_SLL_b = {a_w[3:0] , 28'd0};
				a_SRL_b = {28'd0, a_w[3:0]};
				a_SRA_b = {{28{a_w[31]}},a_w[31:28]};
		end
		5'b11101 :begin 
				a_SLL_b = {a_w[2:0] , 29'd0};
				a_SRL_b = {29'd0, a_w[2:0]};
				a_SRA_b = {{29{a_w[31]}},a_w[31:29]};
		end
		5'b11110 :begin
				a_SLL_b = {a_w[1:0] , 30'd0};
				a_SRL_b = {30'd0, a_w[1:0]};
				a_SRA_b = {{30{a_w[31]}},a_w[31:30]};
		end
		5'b11111 :begin
				a_SLL_b = {a_w[0], 31'd0};
				a_SRL_b = {31'd0, a_w[0]};
				a_SRA_b = {{31{a_w[31]}},a_w[31]};
		end
		default	: begin
				a_SLL_b =  32'h00000000;	
				a_SRL_b =  32'h00000000;	
				a_SRA_b =  32'h00000000;	
		end
	endcase
end

always_ff @(aU_w, bU_w) begin
	if  (aU_w < bU_w) begin
		a_SLTU_b = 32'h00000001;
	end
	else begin
		a_SLTU_b = 32'h00000000;
	end
end


endmodule 