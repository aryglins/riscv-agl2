

package cache_parameters;
	import memory_mapping::*;	
	
	parameter CACHE_SIZE 		= 256;	//Cache size in words
	parameter BLOCK_SIZE		= 2;		//Block size in words
	parameter NUMBER_OF_SETS 	= 2; 		//Quantity of sets
	
	
	parameter LINES_PER_SET = CACHE_SIZE/(BLOCK_SIZE*NUMBER_OF_SETS);
	
	parameter LINE_WIDTH = clog2(LINES_PER_SET);
	parameter OFFSET_WIDTH = clog2(BLOCK_SIZE);
	parameter TAG_WIDTH = ADDR_WIDTH - (LINE_WIDTH + OFFSET_WIDTH);
	
	parameter SET_COUNT_WIDTH = clog2(NUMBER_OF_SETS);
	
	parameter TAG_MSB = ADDR_WIDTH - 1;
	parameter TAG_LSB = ADDR_WIDTH - TAG_WIDTH;
	
	parameter LINE_MSB = TAG_LSB - 1;
	parameter LINE_LSB = TAG_LSB - LINE_WIDTH;
	
	parameter OFFSET_MSB = LINE_LSB-1;
	parameter OFFSET_LSB = 0;
	
	typedef struct { 
		logic [WORD_WIDTH-1:0] data [LINES_PER_SET][BLOCK_SIZE];
		logic [TAG_WIDTH-1:0] tag [LINES_PER_SET];
		logic valid [LINES_PER_SET];
		logic dirty [LINES_PER_SET];
	} set_t; 
	
	typedef struct { 
		logic [WORD_WIDTH-1:0] data [BLOCK_SIZE];
		logic [ADDR_WIDTH-1:0]  addr; 	// Address Input
	} replaced_buf_t; 
	
	typedef struct {
		logic [ADDR_WIDTH-1:0] 	addr;	// Address Input
		logic                  	cs; 	// Chip Select
		logic                  	rw;		// Read 0/Write 1 - 
		logic [WORD_WIDTH-1:0] 	data;
	} processor_request_t;
	
	typedef struct {
		logic					hold_cpu;
		logic [WORD_WIDTH-1:0] 	data;
	} processor_response_t;
	
	typedef struct {
		logic [ADDR_WIDTH-1:0] 		addr; 	// Address Input
		logic                  		cs; 	// Chip Select
		logic                  		rw;		// Read 0/Write 1
		logic [WORD_WIDTH-1:0] 		data[BLOCK_SIZE]; 		// Data 
	} memory_request_t;
	
	
	typedef struct {
		logic                  		ack; 
		logic [WORD_WIDTH-1:0] 	 	data[BLOCK_SIZE];	// Data 
	} memory_response_t;
	
	typedef enum {idle, def_set_replaced, allocate, write_back, flush_op, rw_op} cache_state_t;
	
endpackage