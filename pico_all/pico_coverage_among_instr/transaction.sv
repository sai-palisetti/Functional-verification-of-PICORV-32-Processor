class transaction;
    //declaring the transaction items
    bit  mem_valid;
	bit  mem_instr;
	bit  mem_ready;

	bit [31:0] mem_addr;
	bit [31:0] mem_wdata;
	bit [ 3:0] mem_wstrb;
	rand bit [31:0] mem_rdata;
	logic [31:0] decode_rd [0:31];
	
	string name;
	//constaints, to generate the valid instructions of pico RV
	constraint valid_instr_load_store_branch_jump_ui{
		//mem_rdata[6:0] inside {7'b0000011};
		mem_rdata[6:0] dist {7'b0110111:=1,  // lui
							 7'b0010111 :=1, // auipc
							 7'b1101111:=1,  // jal
							 7'b1100111:=5,  // jalr
							 7'b1100011:/20, // branch
							 7'b0000011:/18, // load
							 7'b0100011:/12, // store
							 7'b0110011:/22, // immediate
							 7'b0010011:/20  // reg
							}; 
		
		if(mem_rdata[6:0]==7'b0000011 ){ //load
			mem_rdata[14:12] dist {3'b000 :=20, 3'b001 :=20, 3'b010 :=20, 3'b100 :=20, 3'b101 :=20};
			if(mem_rdata[13])   //lw
				mem_rdata[21:20] inside {2'b00};		
			else if(mem_rdata[12])  //lh and lhu
				mem_rdata[20] inside {1'b0};	
		}
		
		
		else if(mem_rdata[6:0]==7'b0100011 ){ //store
			mem_rdata[14:12] dist {3'b000 :=33, 3'b001 :=33, 3'b010 :=34};
			
			if(mem_rdata[13])   //sw
				mem_rdata[8:7] inside {2'b00};		
			else if(mem_rdata[12])  //sh
				mem_rdata[7] inside {1'b0};	
		}		
		
		else if(mem_rdata[6:0]==7'b 1100011) { // branch
			!(mem_rdata[14:12] inside {3'b010,3'b011});
			mem_rdata[8] inside {1'b0}; // The 12-bit B-immediate encodes signed offsets in multiples of 2
		}
		else if (mem_rdata[6:0] == 7'b1100111){ //jalr
			mem_rdata[14:12] inside {3'b000};
			mem_rdata[21:20] inside {2'b00};
		}
		else if (mem_rdata[6:0] == 7'b1101111)
			mem_rdata[21] inside {1'b0}; // J-immediate encodes a signed offset in multiples of 2 bytes.
	
	
	
		else if( mem_rdata[6:0] == 7'b0110011){
		 mem_rdata[14:12] dist {3'b000:=20, 3'b001:=10, 3'b010:=5, 3'b011:=5, 3'b100:=10, 3'b101:=20, 3'b110:=10, 3'b111:=10};
		 
		  if( mem_rdata[14:12] == 3'b000 || mem_rdata[14:12] == 3'b101 )
			 mem_rdata[31:25] dist {7'b0000000:=50,7'b0100000:=50};
		  else
			 mem_rdata[31:25] inside {7'b0000000};
	      }
		
		else if( mem_rdata[6:0] == 7'b0010011) {
		 mem_rdata[14:12] dist {3'b000:=20, 3'b001:=10, 3'b010:=10, 3'b011:=10, 3'b100:=15, 3'b101:=20, 3'b110:=15, 3'b111:=10};
		 
          if( mem_rdata[14:12] == 3'b101 )
			 mem_rdata[31:25] dist {7'b0000000:=50,7'b0100000:=50};
		  else if ( mem_rdata[14:12] == 3'b001 )
			 mem_rdata[31:25] inside {7'b0000000};
	    }
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