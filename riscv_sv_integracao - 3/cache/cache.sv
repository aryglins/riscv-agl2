/************************************
*
*/
//`include "cache_structs_def.sv"
//=================================================
// Import the Packages
//=================================================
import cache_parameters::*;
import memory_mapping::*;

module cache 	
(
	input wire						rst,					// Reset Input
	
	input wire                  	clk, 				// Clock Input
	
	/// PROCESSOR -> CACHE
	input processor_request_t		proc_req,			// processor request
	
	/// PROCESSOR <- CACHE
	output processor_response_t		proc_res,
	
	/// CACHE -> MEMORY
	output memory_request_t			mem_req,			// memory request
	
	/// CACHE <- MEMORY
	input  memory_response_t		mem_res
);
	
	//--------------Internal STRUCTS---------------- 
	set_t						sets [NUMBER_OF_SETS];
	replaced_buf_t				rep_buf;
	cache_state_t 				state;
	//------------
	
	//BUFFERS
	reg [TAG_WIDTH-1:0] tag_buf;
	reg [LINE_WIDTH-1:0] line_buf;
	reg [OFFSET_WIDTH:0] offset_buf;
	
	//REGISTERS
	logic [LINE_WIDTH:0] line_count;
	
	//AUXILIARY MEMORYS
	reg	[SET_COUNT_WIDTH-1:0] set_to_replace[LINES_PER_SET];
	
	//WIRES
	logic [NUMBER_OF_SETS-1:0]	hit_array;
	wire miss;				// Data miss
	wire hit;				// Data hit
	wire [TAG_WIDTH-1:0] addr_tag;
	wire [LINE_WIDTH-1:0] addr_line;
	wire [OFFSET_WIDTH:0] addr_offset;
	wire proc_valid_read;
	wire proc_valid_write;
	wire proc_valid_op;
	
	wire [WORD_WIDTH-1:0] proc_res_data;

	//CONTINUOUS ASSIGNMENTS
	assign proc_valid_read = proc_req.cs  & ~proc_req.rw; //VALID READ REQUEST
	assign proc_valid_write = proc_req.cs & proc_req.rw; //VALID WRITE REQUEST
	assign proc_valid_op = proc_valid_read | proc_valid_write; //VALID OPERATION REQUEST
	
	assign addr_tag = proc_req.addr[TAG_MSB:TAG_LSB];
	assign addr_line = proc_req.addr[LINE_MSB:LINE_LSB];

	assign hit = |(hit_array) & proc_valid_op;
	assign miss = ~(|(hit_array)) & proc_valid_op;	
		
	generate
		if(OFFSET_WIDTH > 0) begin
			assign addr_offset[OFFSET_MSB+1] = 1'b0;
			assign addr_offset[OFFSET_MSB:OFFSET_LSB] = proc_req.addr[OFFSET_MSB:OFFSET_LSB];
		end
		else begin
			assign addr_offset[0] = 'b0;
		end
	endgenerate
	
	genvar i;
	generate
		for ( i=0; i < NUMBER_OF_SETS; i=i+1) begin : out_gen
			
			/**HIT MUX*/
			assign hit_array[i] = sets[i].valid[addr_line] & (sets[i].tag[addr_line] == addr_tag);
			 
			/**READ_DATA MUX*/
			assign proc_res_data = (hit_array[i] & proc_valid_read) ? sets[i].data[line_buf][offset_buf] : 'Z;
			
		end 
	endgenerate
	
	
	always_ff @(posedge clk or posedge rst) begin
		if(rst) begin
			proc_res.data <= {(WORD_WIDTH){1'b0}};
		end
		else begin
			if(proc_valid_read) begin
				proc_res.data <= proc_res_data;
			end
		end
	end
				
	always_ff @(posedge clk or posedge rst) begin
		if(rst) begin
			tag_buf <= 'b0;
			line_buf <= 'b0;
			offset_buf <= 'b0;
			rep_buf.addr <= 'b0;
			line_count <= {(LINE_WIDTH){1'd0}};
		end
		
		else begin
			case(state)		
				
				flush_op: begin
					if(line_count < LINES_PER_SET) begin
						for(int i = 0; i < NUMBER_OF_SETS; i++) begin
							sets[i].valid[line_count] <= 1'b0;
						end
						set_to_replace[line_count] <= {(SET_COUNT_WIDTH){1'd0}};
						line_count <= line_count + { {(LINE_WIDTH-1){1'b0}}, {1'b1}};
					end
				end		
				
				idle: begin
					tag_buf <= addr_tag;
					line_buf <= addr_line;
					offset_buf <= addr_offset;
										
					for(int i = 0; i < NUMBER_OF_SETS; i++) begin
						if(hit_array[i] & proc_valid_write) begin
							sets[i].data[addr_line][addr_offset] <= proc_req.data;
							sets[i].dirty[addr_line] <= 'b1;
						end
					end	
					
				end
				
				rw_op : begin

				end
				
				def_set_replaced: begin		
					if(sets[set_to_replace[line_buf]].valid[line_buf] 
						&& sets[set_to_replace[line_buf]].dirty[line_buf]) begin
						
						rep_buf.addr[TAG_MSB:TAG_LSB] <= sets[set_to_replace[line_buf]].tag[line_buf];
						rep_buf.addr[LINE_MSB:LINE_LSB] <= line_buf;
						rep_buf.addr[OFFSET_MSB:OFFSET_LSB] <= {(OFFSET_WIDTH){1'b0}};
						rep_buf.data <= sets[set_to_replace[line_buf]].data[line_buf];
						
					end
				end
				
				allocate: begin
					if(mem_res.ack) begin
						for(int i = 0; i < NUMBER_OF_SETS; i++) begin	
							if (set_to_replace[line_buf] == i) begin
								sets[i].data[line_buf] <= mem_res.data;
								sets[i].valid[line_buf] <= 1'b1;
								sets[i].dirty[line_buf] <= 1'b0;
								sets[i].tag[line_buf] <= tag_buf;
							end
						end
						set_to_replace[line_buf] <= set_to_replace[line_buf] + {{(LINE_WIDTH-1){1'b0}}, 1'b1};
					end
				end
				
			endcase
		end
	end
	
	always_ff @(posedge clk or posedge rst) begin
		if(rst) begin
			state <= flush_op;
		end
		else begin
			case(state)
				
				flush_op: begin
					if(line_count < LINES_PER_SET) begin
						state <= flush_op;
					end
					else begin
						state <= idle;
					end
				end
				
				idle: begin		
					if (miss) begin
						state <= def_set_replaced;
					end
					else if(proc_valid_write | proc_valid_read) begin
						state <= rw_op;
					end
					else begin
						state <= idle;
					end
				end			
				
				rw_op : begin
					state <= idle;
				end
				
				def_set_replaced: begin		
					if(sets[set_to_replace[line_buf]].valid[line_buf] &&
						sets[set_to_replace[line_buf]].dirty[line_buf]) begin
						
						state <= write_back;
					end
					else begin
						state <= allocate;
					end
				end
				
				allocate: begin
					if(mem_res.ack) begin
						state <= idle;
					end
					else begin
						state <= allocate;
					end
				end
				
				write_back: begin
					if(mem_res.ack == 'b0) begin
						state <= write_back;
					end
					else begin
						state <= allocate;
					end
				end
				
			endcase
		end
	end 
	
	always_comb begin
		proc_res.hold_cpu = 'b0;
		mem_req.cs = 'b0;
		mem_req.rw = 'b0;
		mem_req.addr = 'b0;
		for(int i = 0; i < BLOCK_SIZE; i = i + 1) begin
			mem_req.data[i] = 'b0;
		end	
		
		case(state)
			flush_op: begin
				if(line_count < LINES_PER_SET && rst == 1'b0) begin
					proc_res.hold_cpu = 'b1;
				end
				else begin
					proc_res.hold_cpu = 'b0;
				end
			end
		
			idle: begin
				if (miss) begin
					proc_res.hold_cpu = 'b1;
				end
				else if (proc_valid_read) begin
					proc_res.hold_cpu = 'b1;
				end
				else if (proc_valid_write) begin
					proc_res.hold_cpu = 'b1;
				end
				
			end
			allocate: begin
				proc_res.hold_cpu = 'b1;
				if(mem_res.ack == 'b0) begin
					mem_req.cs = 'b1;
					mem_req.rw = 'b0;
					mem_req.addr[TAG_MSB:TAG_LSB] = tag_buf;
					mem_req.addr[LINE_MSB:LINE_LSB] = line_buf;
					mem_req.addr[OFFSET_MSB:OFFSET_LSB] <= 'b0;

				end
			end			
			
			write_back: begin
				proc_res.hold_cpu = 'b1;
				
				if(mem_res.ack == 'b0) begin
					mem_req.cs = 'b1;
					mem_req.rw = 'b1;
					mem_req.addr = rep_buf.addr;
					mem_req.data = rep_buf.data;
				end
				else begin
					mem_req.cs = 'b0;
					mem_req.rw = 'b0;		
				end
			end
			
			rw_op : begin

			end
			
			default: begin
				proc_res.hold_cpu = 'b1;			
			end
			
		endcase
	end
  
 
endmodule
