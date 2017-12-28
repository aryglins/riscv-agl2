// -----------------------------------------------------------------------------
// FILE NAME      : riscv_busca
// AUTHOR         : voo
// AUTHOR'S EMAIL : voo@cin.ufpe.br
// -----------------------------------------------------------------------------
`timescale 1ns/1ps

module interrupt_controller ( 

	input logic CLK_I,
	input logic RST_I,
	input logic interrupt0,
	input logic interrupt1,
	input logic interrupt2,
	input logic interrupt3,
	//
	output logic inti
);

typedef enum bit [1:0]
		{s0, s1, s2} st_type;
st_type state;

initial	state = s0;

always_ff @(posedge CLK_I or posedge RST_I) begin
//rst_I,interrupt0,interrupt1,interrupt2,interrupt3
	if (RST_I == 1'b1) begin
		state <= s0;
	end
	else begin
		case (state)
			s0: begin
				if (interrupt0 == 1'b1 || interrupt1 == 1'b1 || interrupt2 == 1'b1 || interrupt3 == 1'b1) begin
					state <= s1;
				end
				else state <= s0;
			end
			s1: state<= s2;
			s2: begin
				if (interrupt0 == 1'b1 || interrupt1 == 1'b1 || interrupt2 == 1'b1 || interrupt3 == 1'b1) begin
					state <= s2;
				end
				else state <= s0;
			end
		endcase
	end
end
always_comb begin
	case (state)
		s0 : inti = 1'b0;
		s1 : inti = 1'b1;
		s2 : inti = 1'b0;
	endcase
end
endmodule 
