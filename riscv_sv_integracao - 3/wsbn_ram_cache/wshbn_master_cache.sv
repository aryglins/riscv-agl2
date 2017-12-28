import cache_parameters::*;
import memory_mapping::*;

module wshbn_master_cache (
		
		//---------	WHISHBONE MASTER INTERFACE	--------//
		input logic 					CLK_I,
		input logic 					RST_I,
		
		input logic  [WORD_WIDTH-1:0] 	DAT_I,
		input logic 					ACK_I,
		
		output logic [ADDR_WIDTH-1:0] 	ADR_O,
		output logic [WORD_WIDTH-1:0] 	DAT_O,
		
		output logic 					WE_O,
		output logic					STB_O,
		output logic					CYC_O,
		//---------------------------------------------//
		
		input memory_request_t			mem_req,
		output memory_response_t		mem_res
);

	typedef enum {idle, op} wshbn_master_st_t;

	wshbn_master_st_t state;
	wshbn_master_st_t next_state;

	logic [OFFSET_WIDTH:0] offset_counter;

	always_ff @ (posedge CLK_I or posedge RST_I) begin
		if(RST_I) begin
			state <= idle;
		end
		else begin
			state <= next_state;
		end
	end

	always_ff @ (posedge CLK_I or posedge RST_I) begin
		if(RST_I) begin
			offset_counter <= 'd0;
		end
		else begin
			case (state)
				idle: begin
					offset_counter <= 'd0;
				end
				op: begin
					if(ACK_I) begin
						offset_counter <= offset_counter + 'd1;
						
						if(!mem_req.rw) begin
							mem_res.data[offset_counter] <= DAT_I;
						end 
					end
				end
			endcase
		end
	end
		
	always_comb begin
		
		ADR_O 	= 'h0;
		DAT_O  	= 'h0;
		WE_O	= 1'b0;
		STB_O	= 1'b0;
		CYC_O	= 1'b0;
		mem_res.ack = 1'b0;

		case (state)
			idle: begin
				if(mem_req.cs) begin
					next_state = op;
				end 
				else begin
					next_state = idle;
				end
			end
			op: begin			
				if(offset_counter < BLOCK_SIZE) begin
					next_state = op;
					CYC_O = 'b1;
					STB_O = 'b1;
					ADR_O = mem_req.addr + offset_counter;
					DAT_O = mem_req.data[offset_counter];
					WE_O = mem_req.rw;
				end
				else begin
					next_state = idle;
					mem_res.ack = 1'b1;
				end
			end
		endcase
	end

endmodule