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
		//mem_rdata[6:0] dist {7'b1101111:=12,7'b1100111:=13,7'b1100011:/75};
		mem_rdata[6:0] inside { 7'b0110011};
		mem_rdata[14:12] dist {3'b000:/20, 3'b001:/10, 3'b010:/10, 3'b011:/10, 3'b100:/10, 3'b101:/20, 3'b110:/10, 3'b111:/10};
		if( mem_rdata[14:12] == 3'b000 || mem_rdata[14:12] == 3'b101 )
			 mem_rdata[31:25] dist {7'b0000000:/50,7'b0100000:/50};
		else
			 mem_rdata[31:25] inside {7'b0000000};
	
	}
	
	constraint load_reg{
	  mem_rdata[6:0] inside { 7'b0010011};
	  mem_rdata[14:12] inside { 3'b 000};
	  mem_rdata[11:7] dist {[1:31]:/100};
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
		$display("mem_rdata[6:0] = %b\n mem_rdata[14:12]=%b\n mem_rdata[31:25]=%b\n", mem_rdata[6:0],mem_rdata[14:12],mem_rdata[31:25]);

endfunction