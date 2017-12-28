import cache_parameters::*;
import memory_mapping::*;

module wshbn_slave_ram (
		
		//---------	WHISHBONE SLAVE INTERFACE	--------//
		input logic						CLK_I,
		input logic						RST_I,
		
		input logic [ADDR_WIDTH-1:0]	ADR_I,
		input logic [WORD_WIDTH-1:0]	DAT_I,
		input logic						WE_I,
		input logic						STB_I,
		input logic						CYC_I,
		
		output logic [WORD_WIDTH-1:0]	DAT_O,
		output logic					ACK_O

);
	typedef enum {idle, op, stall, stall2} wshbn_slave_st_t;

	wshbn_slave_st_t state;
	wshbn_slave_st_t next_state;
	
	logic [ADDR_WIDTH-1:0] addr;
	logic [WORD_WIDTH-1:0] data_in;
	logic [WORD_WIDTH-1:0] data_out;
	logic				   wren;
	
	ram	
	/*#(
		.ADDR_WIDTH(ADDR_WIDTH),
		.DEPTH(DATA_RAM_DEPTH),
		.WIDTH(WORD_WIDTH),
		.INIT_FILE(DATA_FILE)
	)*/ ram1
	(
		.address(addr),
		.clock(CLK_I),
		.data(data_in),
		.wren(wren),
		.q(data_out)
	);
	
	always_ff @ (posedge CLK_I or posedge RST_I) begin
		if(RST_I) begin
			state <= idle;
		end
		else begin
			state <= next_state;
		end
	end
	
	always_comb begin
		addr 	= 'h0;
		data_in	= 'h0;
		wren	= 1'b0;
		ACK_O	= 1'b0;
		DAT_O	= 'h0;
		
		case (state)
			idle: begin
				if(STB_I) begin
					next_state = stall;
					addr = ADR_I;
					data_in = DAT_I;
					wren = WE_I;
				end 
				else begin
					next_state = idle;
				end
			end

			op: begin
				if (STB_I) begin
					addr = ADR_I;
					data_in = DAT_I;
					wren = WE_I;
					DAT_O = data_out;
					ACK_O = 1'b1;
				end
				
				if(CYC_I) begin
					next_state = stall;
				end
				else begin
					next_state = idle;
				end
			end
			
			stall :begin
				if (STB_I) begin
					addr = ADR_I;
					data_in = DAT_I;
					wren = WE_I;
					DAT_O = data_out;
					ACK_O = 1'b0;
				end
				next_state = stall2;
			end
			
			stall2 :begin
				if (STB_I) begin
					addr = ADR_I;
					data_in = DAT_I;
					wren = WE_I;
					DAT_O = data_out;
					ACK_O = 1'b0;
				end
				next_state = op;
			end
		endcase
	end

endmodule