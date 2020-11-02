class scoreboard;
    
typedef mailbox #(transaction) mail_gen;

     mail_gen mon2scb;   
  int no_transactions;
   logic [31:0]scoreboard_regs[0:31];
   logic [4:0] rd_addr;
	bit [31:0] load_addr;
bit [31:0] load_addr_rs;
// temp registers for load instruction
    bit  temp_mem_valid;
	bit  temp_mem_instr;
	bit  temp_mem_ready;

	bit [31:0] temp_mem_addr;
	bit [31:0] temp_mem_wdata;
	bit [ 3:0] temp_mem_wstrb;
    bit [31:0] temp_mem_rdata;
	logic [31:0] temp_decode_rd [0:31];
	
   integer i=0;
   logic Branch_taken=0;
   logic [31:0] prev_pc,curr_pc;
  function new(mailbox mon2scb);
    this.mon2scb = mon2scb;
	for ( i=0;i<32;i++) begin
		scoreboard_regs[i] = 0;
	end
  endfunction
   
  task main;
    transaction trans;
	 mon2scb.get(trans);
  forever begin
     	  $display("----------[Scoreboard Transaction : %0d]------",no_transactions);
          $display("Scoreboard Decode: 0x%08x  0x%08x \n ",trans.mem_addr,trans.mem_rdata); 
		  no_transactions++;
		  $display("--------------------------------------");
	// mon2scb.get(trans);


		case (trans.mem_rdata[6:0])
			7'b0000011 : begin
				case (trans.mem_rdata[14:12])
					3'b000 : begin
						$display("Instruction:LB");	
						 load_addr= {{20{trans.mem_rdata[31]}},trans.mem_rdata[31:20]};
						 load_addr_rs = trans.mem_rdata[19:15];
						$display("[Scoreboard]Load Adress: 0x%08x , rs1: %02d : 0x%08x",load_addr,trans.mem_rdata[19:15],scoreboard_regs[trans.mem_rdata[19:15]]);			
						rd_addr=trans.mem_rdata[11:7];
						mon2scb.get(trans);
						temp_mem_valid =trans.mem_valid ;
						temp_mem_instr =trans.mem_instr ;
						temp_mem_ready =trans.mem_ready ;
						temp_mem_addr  =trans.mem_addr;
						temp_mem_wdata =trans.mem_wdata ;
						temp_mem_rdata =trans.mem_rdata ;
						temp_decode_rd =trans.decode_rd ;
						mon2scb.get(trans);
						 load_addr= load_addr+scoreboard_regs[load_addr_rs];
						 						$display("[Scoreboard]Load Adress: 0x%08x , rs1: %02d : 0x%08x",load_addr,load_addr_rs,scoreboard_regs[load_addr_rs]);			

						// load_addr= {load_addr[31:2],2'b00};
						 //						$display("[Scoreboard]Load Adress: 0x%08x , rs1: %02d : 0x%08x",load_addr,trans.mem_rdata[19:15],scoreboard_regs[trans.mem_rdata[19:15]]);			
						//if(load_addr[1:0]==2'b00)
						//scoreboard_regs[rd_addr]={{24{trans.mem_rdata[31]}},trans.mem_rdata[31:24]};	
						//else begin
						case (load_addr[1:0])
							2'b11 : begin
								scoreboard_regs[rd_addr]={{24{trans.mem_rdata[31]}},trans.mem_rdata[31:24]};	
							end
							2'b10 : begin
								scoreboard_regs[rd_addr]={{24{trans.mem_rdata[23]}},trans.mem_rdata[23:16]};	
							end
							2'b01 : begin
								scoreboard_regs[rd_addr]={{24{trans.mem_rdata[15]}},trans.mem_rdata[15:8]};	
							end
							2'b00 : begin
								scoreboard_regs[rd_addr]={{24{trans.mem_rdata[7]}},trans.mem_rdata[7:0]};	
							end
						
						endcase
						
						//end
						scoreboard_regs[0]=32'b0;
						load_addr= {load_addr[31:2],2'b00};
						//scoreboard_regs[rd_addr]={{24{trans.mem_rdata[7]}},trans.mem_rdata[7:0]};
						if(trans.mem_addr==load_addr)
							$display("[Scoreboard]LD_RD: %02d 0x%08x",rd_addr,scoreboard_regs[rd_addr]);
						else
							$fatal("RD from Scoreboard : %02d 0x%08x RD from design:0x%08x",rd_addr, scoreboard_regs[rd_addr],trans.decode_rd[rd_addr]);
		
						trans.mem_valid =temp_mem_valid ;
						trans.mem_instr =temp_mem_instr ;
						trans.mem_ready =temp_mem_ready ;
						trans.mem_addr  =temp_mem_addr  ;
						trans.mem_wdata =temp_mem_wdata ;
						trans.mem_rdata =temp_mem_rdata ;
						trans.decode_rd =temp_decode_rd ;
						
						no_transactions++;
						end
				
				endcase
			end
		endcase
       $display("-----------------------------------------");

    end
  endtask
   
endclass