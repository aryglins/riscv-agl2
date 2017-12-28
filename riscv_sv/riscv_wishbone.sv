// -----------------------------------------------------------------------------
// FILE NAME      : riscv_wishbone
// AUTHOR         : voo,caram
// AUTHOR'S EMAIL : {voo,caram}@cin.ufpe.br
// -----------------------------------------------------------------------------
// RELEASE HISTORY
// VERSION 	DATE         AUTHOR		DESCRIPTION
// 2.0		2017-01-30   voo   		version sv
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
module riscv_wishbone (

		input logic CLK,
		input logic RST,
		//--------------------------------//
		output logic [15:0] pio_0_out,
		input  logic [15:0] pio_0_in,
		//--------------------------------//
		output logic [1:0] cmp,
		output logic [31:0] sp,
		output logic [31:0] ra,
		output logic [31:0] ir,
		//--------------------------------//
		//output logic [7:0] regout,	
		//--------------------------------//
		output logic [7:0] spi_tx, 	
		output logic ssp_en_o,  
		output logic ssp_mosi_o,
		input  logic ssp_miso_i,
		//output logic ssp_clk_o, 
		//----logic ---------------------------//
		input  logic uart_rx,
		output logic uart_tx,
		output logic uart_full,
		output logic uart_empty,
		output logic [31:0] result,
		output logic    [31:0] instruction_o
);

    logic  ACK_I_M0; 		//wshbn_master wbus 
	
	//--------------------------------------------------------//
	logic [7:0] ADR; 		// ADR = ADR_O_M0 wshbn_master	 wbus 
    logic  [7:0] ADR_O_M0; 	//wshbn_master
	//--------------------------------------------------------//
	logic ACK_O_S0;
	logic ACK_O_S1;
	//--------------------------------------------------------//
	logic  ACMP0;
    logic  ACMP1;
    logic  ACMP2;
    logic  ACMP3;
	logic  ACMP7;
	logic  ACMP5;
	//--------------------------------------------------------//
    logic  CYC ;				//CYC = CYC_O_M0; 		//wshbn_master wbus,wshbn_timer SLV1,wshbn_pio SLV0
    logic  CYC_O_M0 ;  			//wshbn_master wbus
    logic  [31:0] DAT_O_M0 ; 	//wshbn_master wbus
    logic  [31:0] DAT_O_S0 ;	//wshbn_pio SLV0
    logic  [31:0] DAT_O_S1 ;	//wshbn_timer
   // logic  [31:0] DAT_O_S2 ; 	//UART
   // logic  [31:0] DAT_O_S3 ; 	//SPI
	//--------------------------------------------------------//
   logic  [31:0] DRD ;			// DAT_I wshbn_master wbus
	logic  [31:0] DWR ;			// DWR = DAT_O_M0 		//wshbn_master wbus, wshbn_timer SLV1,wshbn_pio SLV0
	//--------------------------------------------------------//
	logic  STB    ; 			//STB = STB_O_M0 	wshbn_master wbus
	logic  STB_O_M0;			//wshbn_master wbus
    logic  STB_I_S0;			//wshbn_pio SLV0
    logic  STB_I_S1;			//wshbn_timer SLV1
	
	//--------------------------------------------------------//
   // logic  STB_I_S2; //?
   // logic  STB_I_S3; //?
	//logic  STB_I_S5; //?
	//logic  STB_I_S7; //?
	//--------------------------------------------------------//

    logic  WE     ;			// WE  = WE_O_M0 		//wshbn_master wbus,wshbn_timer SLV1,wshbn_pio SLV0	
    logic  WE_O_M0; //wshbn_master	 
	logic [1:0] st;
	//--------------------------------------------------------//
	logic [31:0] inst_cache_add;		//inst_mem_ctrl inst_mem
	logic [31:0] inst_cache_data;		//i_cache M0 -> inst_mem_ctrl inst_mem
	logic inst_cache_rden ;				//inst_mem_ctrl inst_mem -> i_cache M0
	//--------------------------------------------------------//
	logic [31:0] data_cache_data_o;
	logic [31:0] data_cache_data_i;
	logic [29:0] data_cache_addr_i;
	logic data_cache_wren;
	logic data_cache_rden;
	logic data_cache_busy;
	//--------------------------------------------------------//
	logic [31:0] ext_ram_data_o;
	logic [31:0] ext_ram_data_i;
	logic [29:0] ext_ram_addr_i;
	logic ext_ram_wren;
	logic ext_ram_rden;
	logic ext_ram_busy;
	//--------------------------------------------------------//
	logic [31:0] cpu_data_add;
	logic [31:0] cpu_data_i;
	logic [31:0] cpu_data_o;
	logic cpu_data_wren;
	logic cpu_data_rden;
	//--------------------------------------------------------//
	logic [31:0] wshbn_data_o;
	logic [31:0] wshbn_data_i;
	logic wshbn_data_wren;
	logic wshbn_data_rden;
	//--------------------------------------------------------//
	logic wshbn_stall_w	;
	logic wshbn_busy		; 
	logic mem_busy  		; 
	logic data_av  		; 
	//--------------------------------------------------------//
	logic tmr_interrupt; 
	logic interrupt_req; 
	//--------------------------------------------------------//
	logic [29:0] wshbn_addr;	 
	
	reg rst_eval_regs = 1'b0;
	reg en_eval_regs = 1'b1;
	logic [63:0] clk_counter;
	logic [63:0] inst_counter ;
	logic [63:0] branch_counter ;
	//--------------------------------------------------------//	
	logic [31:0] inst_add;				//riscv_cpu_no cpu1 -> inst_mem_ctrl inst_mem
	logic [31:0] inst; 					//inst_mem_ctrl inst_mem -> riscv_cpu_no cpu1
	logic [31:0] ext_inst_add;			//inst_mem_ctrl inst_mem
	logic [31:0] ext_inst_data;			//inst_mem_ctrl inst_mem
	logic inst_rden;					//riscv_cpu_no cpu1 -> inst_mem_ctrl inst_mem
	logic ext_inst_rden;				//inst_mem_ctrl inst_mem
	logic mem_clken;	//?
	
	//--------------------------------------------------------//
	inst_mem_ctrl inst_mem (.clk(CLK), .rst(RST), .rd(inst_rden), .addr_i(inst_add),.instr_o(inst), .cmp(cmp), .mem0_rd(inst_cache_rden), .mem0_addr_o(inst_cache_add),.mem0_data_i(inst_cache_data), .mem1_rd(ext_inst_rden), .mem1_addr_o(ext_inst_add), .mem1_data_i(ext_inst_data) );	 
	// ? [12:2]
	i_cache M0 (.address(inst_cache_add[12:2]), .clock(CLK), .rden(inst_cache_rden), .q(inst_cache_data) ); 
	//--------------------------------------------------------//
	d_cache M1(.address(data_cache_addr_i[11:0]), .clock(CLK), .data(data_cache_data_i), .wren(data_cache_wren), .q(data_cache_data_o));
	//--------------------------------------------------------//
	riscv_cpu_no cpu1 (.clk_i(CLK), .rst_i(RST), .inst_cache_rden(inst_rden), .inst_cache_add(inst_add),
	.inst_cache_data(inst), .ra(ra), .sp(sp), .ir_o(ir),.mem_clken(mem_clken), .interrupt_req(interrupt_req), .mem_busy(mem_busy),
	.data_av(1'b0), .data_add(cpu_data_add), .data_o(cpu_data_o), .data_i(cpu_data_i), .data_rden(cpu_data_rden),
	.data_wren(cpu_data_wren),.rst_eval_regs(rst_eval_regs),.en_eval_regs(en_eval_regs),.clk_counter_o(clk_counter),
	.inst_counter_o(inst_counter),.branch_counter_o(branch_counter), .result(result), .instruction_o(instruction_o) );
	//--------------------------------------------------------//
	 mem_ctrl mem_controller (.clk(CLK), .rst(RST), .rd(cpu_data_rden), .wr(cpu_data_wren),
	.addr_i(cpu_data_add), .data_i(cpu_data_o), .data_o(cpu_data_i), .hold_cpu(mem_busy), 
	.wshbn_rd(wshbn_data_rden), .wshbn_wr(wshbn_data_wren), .wshbn_addr_o(wshbn_addr),
	.wshbn_data_o(wshbn_data_i), .wshbn_data_i(wshbn_data_o), .wshbn_busy(wshbn_busy),.wshbn_data_av(data_av),
	.mem0_rd (data_cache_rden), .mem0_wr(data_cache_wren), .mem0_addr_o(data_cache_addr_i),
	.mem0_data_o(data_cache_data_i), .mem0_data_i(data_cache_data_o), .mem0_busy(data_cache_busy),
	.mem1_rd(ext_ram_rden), .mem1_wr(ext_ram_wren), .mem1_addr_o(ext_ram_addr_i), .mem1_data_o(ext_ram_data_i),
	.mem1_data_i(ext_ram_data_o), .mem1_busy(ext_ram_busy) );
	//--------------------------------------------------------//
	interrupt_controller int_ctrl (.CLK_I(CLK), .RST_I(RST), .interrupt0(tmr_interrupt), .interrupt1(1'b0), .interrupt2(1'b0), .interrupt3 (1'b0), .inti(interrupt_req)	);
	//--------------------------------------------------------//
	wshbn_master wbus ( .CLK_I(CLK), .RST_I(RST), .ADR_O(ADR_O_M0), .DAT_I(DRD), .DAT_O(DAT_O_M0),	.WE_O(WE_O_M0), .STB_O(STB_O_M0), .ACK_I(ACK_I_M0), .CYC_O(CYC_O_M0), .busy(wshbn_busy),.data_av(data_av), .stall_cpu(wshbn_stall_w), .add_i(wshbn_addr[7:0]), .data_i(wshbn_data_i),.data_o(wshbn_data_o), .wr(wshbn_data_wren), .rd(wshbn_data_rden), .st(st) ); 	
	//--------------------------------------------------------//
	wshbn_pio SLV0( .CLK_I(CLK), .RST_I(RST), .ADR_I(ADR[3:0]), .DAT_I(DWR),.DAT_O(DAT_O_S0), .WE_I(WE), .STB_I(STB_I_S0), .ACK_O (ACK_O_S0), .CYC_I(CYC),.pio_0_in(pio_0_in), .pio_0_out(pio_0_out) );	
	//--------------------------------------------------------//
	wshbn_timer SLV1 (.CLK_I(CLK), .RST_I(RST), .ADR_I(ADR[3:0]), .DAT_I(DWR), .DAT_O(DAT_O_S1),.WE_I(WE), .STB_I(STB_I_S1), .ACK_O(ACK_O_S1), .CYC_I(CYC), .interrupt (tmr_interrupt) );	
	//--------------------------------------------------------//
	always @(ADR)  begin					// TODO
			//ACMP7 = ( ADR[7]  & ADR[6]  & ADR[5]  & ADR[4]  );
			//ACMP5 = ( ADR[7]  & ADR[6]  & ADR[5]  & ~ADR[4] );
			//ACMP3 = ( ~ADR[7] & ~ADR[6] & ADR[5]  & ADR[4]  );
			//ACMP2 = ( ~ADR[7] & ~ADR[6] & ADR[5]  & ~ADR[4] );
			ACMP1 = ( ~ADR[7] & ~ADR[6] & ~ADR[5] & ADR[4]  );
			ACMP0 = ( ~ADR[7] & ~ADR[6] & ~ADR[5] & ~ADR[4] );
	end
	//--------------------------------------------------------//
	always @(ACMP1, ACMP0, CYC, STB) // TODO ACMP7, ACMP5, ACMP3, ACMP2, 
	begin
			//STB_I_S7 = CYC & STB & ACMP7;
			//STB_I_S5 = CYC & STB & ACMP5;		  
			//STB_I_S3 = CYC & STB & ACMP3;
			//STB_I_S2 = CYC & STB & ACMP2;
			STB_I_S1 = CYC & STB & ACMP1;
			STB_I_S0 = CYC & STB & ACMP0;
			
	end
	//--------------------------------------------------------// 
	assign ACK_I_M0 = ACK_O_S0; //ACK_I_M0 wshbn_master wbus 
	assign CYC = CYC_O_M0; 		//wshbn_master wbus
	assign ADR = ADR_O_M0;	 	//wshbn_master wbus 
	assign WE  = WE_O_M0; 		//wshbn_master wbus	 
	assign DWR = DAT_O_M0; 		//wshbn_master wbus
	assign STB = STB_O_M0; 		//wshbn_master wbus
	//--------------------------------------------------------//
	always @(DAT_O_S1, DAT_O_S0, ADR )  // TODO DAT_O_S3 DAT_O_S2
	begin                                   
			case ( ADR[7:4] ) 
				4'b0000:  DRD <= DAT_O_S0; 		// IO wshbn_pio SLV0
				4'b0001:  DRD <= DAT_O_S1; 		//	wshbn_timer
				//4'b0010:  DRD <= DAT_O_S2; 		// UART
				//4'b0011:  DRD <= DAT_O_S3; 		// I2C/I2S/SPI
				default :  DRD <= DAT_O_S0;		// wshbn_pio SLV0
			endcase
			
	end
endmodule 

