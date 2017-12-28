import cache_parameters::*;

package wshbn_ports_defs;
	
	typedef struct {
		logic [ADDR_WIDTH-1:0] 	addr;	// 
		logic                  	rd; 	
		logic                  	wr;		
		logic [WORD_WIDTH-1:0] 	data;
	} master_input_t;
	
	typedef struct {
		logic					hold_cpu;
		logic [WORD_WIDTH-1:0] 	data;
	} processor_response_t;
	
	typedef struct {
		logic [ADDR_WIDTH-1:0] 		addr; 	// Address Input
		logic                  		cs; 	// Chip Select
		logic                  		rw;		// Read 0/Write 1
		logic [WORD_WIDTH-1:0] 		data[BLOCK_SIZE]; 		// Data bi-directional
	} memory_request_t;
	
	
	typedef struct {
		logic                  		ack; 	// Chip Select
		logic [WORD_WIDTH-1:0] 	 	data[BLOCK_SIZE];	// Data bi-directional
	} memory_response_t;
	
	typedef enum {idle, def_set_replaced, allocate, write_back, flush_op, rw_op} cache_state_t;
	
endpackage