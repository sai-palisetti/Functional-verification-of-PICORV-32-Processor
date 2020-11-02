class transaction;
    bit  mem_valid;
	bit  mem_instr;
	bit  mem_ready;

	bit [31:0] mem_addr;
	bit [31:0] mem_wdata;
	bit [ 3:0] mem_wstrb;
	rand bit [31:0] mem_rdata;
	logic [31:0] decode_rd [0:31];
	
	string name;
	
	constraint valid_instr{
		mem_rdata[6:0] inside {7'b0000011};
		//mem_rdata[14:12] dist {3'b000 :=20, 3'b001 :=20, 3'b010 :=20, 3'b100 :=20, 3'b101 :=20};
				mem_rdata[14:12] inside {3'b000};

		mem_rdata[21:20] inside {2'b00};
	}
	extern function new(string name = "transaction");
	extern function print();
endclass

function transaction::new(string name="transaction");
	this.name=name;
		//$display("mem_rdata = %b\n", mem_rdata);

endfunction

function transaction::print();
	this.name=name;
		$display("mem_rdata[7:0] = %b\n mem_rdata[14:12]=%b\n", mem_rdata[6:0],mem_rdata[14:12]);

endfunction