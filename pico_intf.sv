interface pico_interface(input logic clk,reset);
	logic trap;

	logic        mem_valid;
	logic        mem_instr;
	logic             mem_ready;

	logic [31:0] mem_addr;
	logic [31:0] mem_wdata;
	logic [ 3:0] mem_wstrb;
	logic      [31:0] mem_rdata;

	// Look-Ahead Interface
	logic            mem_la_read;
	logic            mem_la_write;
	logic     [31:0] mem_la_addr;
	logic [31:0] mem_la_wdata;
	logic [ 3:0] mem_la_wstrb;

	// Pico Co-Processor Interface (PCPI)
	logic        pcpi_valid;
	logic [31:0] pcpi_insn;
	logic     [31:0] pcpi_rs1;
	logic     [31:0] pcpi_rs2;
	logic             pcpi_wr;
	logic      [31:0] pcpi_rd;
	logic             pcpi_wait;
	logic             pcpi_ready;

	// IRQ Interface
	logic      [31:0] irq;
	logic [31:0] eoi;

	logic        rvfi_valid;
	logic [63:0] rvfi_order;
	logic [31:0] rvfi_insn;
	logic        rvfi_trap;
	logic        rvfi_halt;
	logic        rvfi_intr;
	logic [ 1:0] rvfi_mode;
	logic [ 1:0] rvfi_ixl;
	logic [ 4:0] rvfi_rs1_addr;
	logic [ 4:0] rvfi_rs2_addr;
	logic [31:0] rvfi_rs1_rdata;
	logic [31:0] rvfi_rs2_rdata;
	logic [ 4:0] rvfi_rd_addr;
	logic [31:0] rvfi_rd_wdata;
	logic [31:0] rvfi_pc_rdata;
	logic [31:0] rvfi_pc_wdata;
	logic [31:0] rvfi_mem_addr;
	logic [ 3:0] rvfi_mem_rmask;
	logic [ 3:0] rvfi_mem_wmask;
	logic [31:0] rvfi_mem_rdata;
	logic [31:0] rvfi_mem_wdata;

	logic [63:0] rvfi_csr_mcycle_rmask;
	logic [63:0] rvfi_csr_mcycle_wmask;
	logic [63:0] rvfi_csr_mcycle_rdata;
	logic [63:0] rvfi_csr_mcycle_wdata;

	logic [63:0] rvfi_csr_minstret_rmask;
	logic [63:0] rvfi_csr_minstret_wmask;
	logic [63:0] rvfi_csr_minstret_rdata;
	logic [63:0] rvfi_csr_minstret_wdata;


	// Trace Interface
	logic        trace_valid;
	logic [35:0] trace_data;
	
	//cpu registers
	logic [31:0] decode_rd [0:31];
   assign decode_rd = test_top.uut.cpuregs;
	
	clocking cb @(posedge clk);
		default input #1 output #0;
		//output clk;
		input  mem_valid;
		input  mem_instr;
		output  mem_ready;
		input  mem_addr;
		input  mem_wdata;
		input  mem_wstrb;
		output mem_rdata;
		
	endclocking
	
		clocking monitor_cb @(posedge clk);
		default input #1 output #0;
		//output clk;
		input  mem_valid;
		input  mem_instr;
		input  mem_ready;
		input  mem_addr;
		input  mem_wdata;
		input  mem_wstrb;
		input mem_rdata;
		input decode_rd;
	endclocking

	modport tb(clocking cb,input clk,reset);
	modport monitor(clocking monitor_cb,input clk,reset);


endinterface