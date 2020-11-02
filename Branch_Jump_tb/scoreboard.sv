class scoreboard;
    
typedef mailbox #(transaction) mail_gen;

     mail_gen mon2scb;   
  int no_transactions;
   logic [31:0]scoreboard_regs[0:31];
   logic [4:0] rd_addr;

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
		  //$display("--------------------------------------");


		case (trans.mem_rdata[6:0])
			7'b0110111 : begin
				$display("Instruction:LUI");	
				scoreboard_regs[trans.mem_rdata[11:7]] = {trans.mem_rdata[31:12],{12{1'b0}}};
				scoreboard_regs[0]=32'b0;
			//	$display("[Scoreboard]ST_RD %02d 0x%08x",trans.mem_rdata[11:7],scoreboard_regs[trans.mem_rdata[11:7]]);			
				rd_addr=trans.mem_addr[11:7];
				mon2scb.get(trans);
				if(scoreboard_regs[rd_addr]==trans.decode_rd[rd_addr])
					$display("[Scoreboard]ST_RD: %02d 0x%08x",rd_addr,scoreboard_regs[rd_addr]);
				else
					$fatal("RD from Scoreboard : %02d 0x%08x RD from design:0x%08x",rd_addr, scoreboard_regs[rd_addr],trans.decode_rd[rd_addr]);
					
				//no_transactions++;
				
			end
			7'b0010111 : begin
				$display("Instruction:AUIPC");	
				scoreboard_regs[trans.mem_rdata[11:7]] = {trans.mem_rdata[31:12],{12{1'b0}}}+trans.mem_addr;
				scoreboard_regs[0]=32'b0;				
			//	$display("[Scoreboard]ST_RD %02d 0x%08x",trans.mem_rdata[11:7],scoreboard_regs[trans.mem_rdata[11:7]]);			
				rd_addr=trans.mem_addr[11:7];
				mon2scb.get(trans);
				if(scoreboard_regs[rd_addr]==trans.decode_rd[rd_addr])
					$display("[Scoreboard]ST_RD: %02d 0x%08x",rd_addr,scoreboard_regs[rd_addr]);
				else
					$fatal("RD from Scoreboard : %02d 0x%08x RD from design:0x%08x",rd_addr, scoreboard_regs[rd_addr],trans.decode_rd[rd_addr]);
					
	//			no_transactions++;
			
			end
			7'b1100011: begin
				case (trans.mem_rdata[14:12])
			
				3'b000: begin
					$display("Instruction:BEQ");
					$display("rs1 %02d: 0x%08x \nrs2 %02d: 0x%08x",trans.mem_rdata[19:15],scoreboard_regs[trans.mem_rdata[19:15]],trans.mem_rdata[24:20],scoreboard_regs[trans.mem_rdata[24:20]]);
					if(scoreboard_regs[trans.mem_rdata[19:15]]==scoreboard_regs[trans.mem_rdata[24:20]])begin
						$display("Branch condition Evaluated true");
						prev_pc = trans.mem_addr;
						Branch_taken=1;
						curr_pc = {{20{trans.mem_rdata[31]}},trans.mem_rdata[7],trans.mem_rdata[30:25],trans.mem_rdata[11:8],1'b0};
						if(curr_pc[31])begin
							curr_pc=~curr_pc+1'b1;
							curr_pc=prev_pc-curr_pc;
						end
						else
							curr_pc=prev_pc+curr_pc;
							
						$display("next_pc : 0x%08x",curr_pc);

						mon2scb.get(trans);
								  no_transactions++;

						mon2scb.get(trans);
						if(curr_pc==trans.mem_addr)
							$display("Program Counter Branched to 0x%08x correctly",curr_pc);
						else
							$fatal("Branched to 0x%08x Expected : 0x%08x ",trans.mem_addr,curr_pc);
						
						
					end
					else begin
						$display("branch not taken");
						curr_pc=trans.mem_addr+32'd4;
						$display("next_pc : 0x%08x",curr_pc);
						mon2scb.get(trans);
						if(curr_pc==trans.mem_addr)
							$display("Branch condition evaluated false");
						else
							$fatal("Branched to 0x%08x Expected : 0x%08x ",trans.mem_addr,curr_pc);

					end
				
				end

				3'b001: begin
					$display("Instruction:BNE");
					$display("rs1 %02d: 0x%08x \nrs2 %02d: 0x%08x",trans.mem_rdata[19:15],scoreboard_regs[trans.mem_rdata[19:15]],trans.mem_rdata[24:20],scoreboard_regs[trans.mem_rdata[24:20]]);
					if(scoreboard_regs[trans.mem_rdata[19:15]]!=scoreboard_regs[trans.mem_rdata[24:20]])begin
												$display("Branch condition Evaluated true");
						prev_pc = trans.mem_addr;
						Branch_taken=1;
						curr_pc = {{20{trans.mem_rdata[31]}},trans.mem_rdata[7],trans.mem_rdata[30:25],trans.mem_rdata[11:8],1'b0};
						if(curr_pc[31])begin
							curr_pc=~curr_pc+1'b1;
							curr_pc=prev_pc-curr_pc;
						end
						else
							curr_pc=prev_pc+curr_pc;
							
						$display("next_pc : 0x%08x",curr_pc);

						mon2scb.get(trans);
								  no_transactions++;

						mon2scb.get(trans);
						if(curr_pc==trans.mem_addr)
							$display("Program Counter Branched to 0x%08x correctly",curr_pc);
						else
							$fatal("Branched to 0x%08x Expected : 0x%08x ",trans.mem_addr,curr_pc);
						
						
					end
					else begin
						$display("branch not taken");
						curr_pc=trans.mem_addr+32'd4;
						$display("next_pc : 0x%08x",curr_pc);
						mon2scb.get(trans);
						if(curr_pc==trans.mem_addr)
							$display("Branch condition evaluated false");
						else
							$fatal("Branched to 0x%08x Expected : 0x%08x ",trans.mem_addr,curr_pc);

					end
				
				end

				3'b100: begin
					$display("Instruction:BLT");
					$display("rs1 %02d: 0x%08x \nrs2 %02d: 0x%08x",trans.mem_rdata[19:15],scoreboard_regs[trans.mem_rdata[19:15]],trans.mem_rdata[24:20],scoreboard_regs[trans.mem_rdata[24:20]]);
					if($signed(scoreboard_regs[trans.mem_rdata[19:15]])<$signed(scoreboard_regs[trans.mem_rdata[24:20]]))begin
						$display("Branch condition Evaluated true");
						prev_pc = trans.mem_addr;
						Branch_taken=1;
						curr_pc = {{20{trans.mem_rdata[31]}},trans.mem_rdata[7],trans.mem_rdata[30:25],trans.mem_rdata[11:8],1'b0};
						if(curr_pc[31])begin
							curr_pc=~curr_pc+1'b1;
							curr_pc=prev_pc-curr_pc;
						end
						else
							curr_pc=prev_pc+curr_pc;
							
						$display("next_pc : 0x%08x",curr_pc);

						mon2scb.get(trans);
								  no_transactions++;

						mon2scb.get(trans);
						if(curr_pc==trans.mem_addr)
							$display("Program Counter Branched to 0x%08x correctly",curr_pc);
						else
							$fatal("Branched to 0x%08x Expected : 0x%08x ",trans.mem_addr,curr_pc);
						
						
					end
					else begin
						$display("branch not taken");
						curr_pc=trans.mem_addr+32'd4;
						$display("next_pc : 0x%08x",curr_pc);
						mon2scb.get(trans);
						if(curr_pc==trans.mem_addr)
							$display("Branch condition evaluated false");
						else
							$fatal("Branched to 0x%08x Expected : 0x%08x ",trans.mem_addr,curr_pc);

					end
				
				end
				
				3'b101: begin
					$display("Instruction:BGE");
					$display("rs1 %02d: 0x%08x \nrs2 %02d: 0x%08x",trans.mem_rdata[19:15],scoreboard_regs[trans.mem_rdata[19:15]],trans.mem_rdata[24:20],scoreboard_regs[trans.mem_rdata[24:20]]);
					if($signed(scoreboard_regs[trans.mem_rdata[19:15]])>=$signed(scoreboard_regs[trans.mem_rdata[24:20]]))begin
						$display("Branch condition Evaluated true");
						prev_pc = trans.mem_addr;
						Branch_taken=1;
						curr_pc = {{20{trans.mem_rdata[31]}},trans.mem_rdata[7],trans.mem_rdata[30:25],trans.mem_rdata[11:8],1'b0};
						if(curr_pc[31])begin
							curr_pc=~curr_pc+1'b1;
							curr_pc=prev_pc-curr_pc;
						end
						else
							curr_pc=prev_pc+curr_pc;
							
						$display("next_pc : 0x%08x",curr_pc);

						mon2scb.get(trans);
								  no_transactions++;

						mon2scb.get(trans);
						if(curr_pc==trans.mem_addr)
							$display("Program Counter Branched to 0x%08x correctly",curr_pc);
						else
							$fatal("Branched to 0x%08x Expected : 0x%08x ",trans.mem_addr,curr_pc);
						
						
					end
					else begin
						$display("branch not taken");
						curr_pc=trans.mem_addr+32'd4;
						$display("next_pc : 0x%08x",curr_pc);
						mon2scb.get(trans);
						if(curr_pc==trans.mem_addr)
							$display("Branch condition evaluated false");
						else
							$fatal("Branched to 0x%08x Expected : 0x%08x ",trans.mem_addr,curr_pc);

					end
				
				end

				3'b110: begin
					$display("Instruction:BLTU");
					$display("rs1 %02d: 0x%08x \nrs2 %02d: 0x%08x",trans.mem_rdata[19:15],scoreboard_regs[trans.mem_rdata[19:15]],trans.mem_rdata[24:20],scoreboard_regs[trans.mem_rdata[24:20]]);
					if(scoreboard_regs[trans.mem_rdata[19:15]]<scoreboard_regs[trans.mem_rdata[24:20]])begin
						$display("Branch condition Evaluated true");
						prev_pc = trans.mem_addr;
						Branch_taken=1;
						curr_pc = {{20{trans.mem_rdata[31]}},trans.mem_rdata[7],trans.mem_rdata[30:25],trans.mem_rdata[11:8],1'b0};
						if(curr_pc[31])begin
							curr_pc=~curr_pc+1'b1;
							curr_pc=prev_pc-curr_pc;
						end
						else
							curr_pc=prev_pc+curr_pc;
							
						$display("next_pc : 0x%08x",curr_pc);

						mon2scb.get(trans);
								  no_transactions++;

						mon2scb.get(trans);
						if(curr_pc==trans.mem_addr)
							$display("Program Counter Branched to 0x%08x correctly",curr_pc);
						else
							$fatal("Branched to 0x%08x Expected : 0x%08x ",trans.mem_addr,curr_pc);
						
						
					end
					else begin
						$display("branch not taken");
						curr_pc=trans.mem_addr+32'd4;
						$display("next_pc : 0x%08x",curr_pc);
						mon2scb.get(trans);
						if(curr_pc==trans.mem_addr)
							$display("Branch condition evaluated false");
						else
							$fatal("Branched to 0x%08x Expected : 0x%08x ",trans.mem_addr,curr_pc);

					end
				
				end
				
				3'b111: begin
					$display("Instruction:BGEU");
					$display("rs1 %02d: 0x%08x \nrs2 %02d: 0x%08x",trans.mem_rdata[19:15],scoreboard_regs[trans.mem_rdata[19:15]],trans.mem_rdata[24:20],scoreboard_regs[trans.mem_rdata[24:20]]);
					if(scoreboard_regs[trans.mem_rdata[19:15]]>=scoreboard_regs[trans.mem_rdata[24:20]])begin
						$display("Branch condition Evaluated true");
						prev_pc = trans.mem_addr;
						Branch_taken=1;
						curr_pc = {{20{trans.mem_rdata[31]}},trans.mem_rdata[7],trans.mem_rdata[30:25],trans.mem_rdata[11:8],1'b0};
						if(curr_pc[31])begin
							curr_pc=~curr_pc+1'b1;
							curr_pc=prev_pc-curr_pc;
						end
						else
							curr_pc=prev_pc+curr_pc;
							
						$display("next_pc : 0x%08x",curr_pc);

						mon2scb.get(trans);
								  no_transactions++;

						mon2scb.get(trans);
						if(curr_pc==trans.mem_addr)
							$display("Program Counter Branched to 0x%08x correctly",curr_pc);
						else
							$fatal("Branched to 0x%08x Expected : 0x%08x ",trans.mem_addr,curr_pc);
						
						
					end
					else begin
						$display("branch not taken");
						curr_pc=trans.mem_addr+32'd4;
						$display("next_pc : 0x%08x",curr_pc);
						mon2scb.get(trans);
						if(curr_pc==trans.mem_addr)
							$display("Branch condition evaluated false");
						else
							$fatal("Branched to 0x%08x Expected : 0x%08x ",trans.mem_addr,curr_pc);

					end
				
				end
				
//				default: mon2scb.get(trans);
			
				endcase
			end
		 7'b1100111 :begin
			$display("Instruction:JALR");
			$display("rs1  : %02d 0x%08x",trans.mem_rdata[19:15],scoreboard_regs[trans.mem_rdata[19:15]]);					
			curr_pc = {{21{trans.mem_rdata[31]}},trans.mem_rdata[30:20]};

			if(curr_pc[31])begin
				curr_pc=~curr_pc+1'b1;
				curr_pc=scoreboard_regs[trans.mem_rdata[19:15]]-curr_pc;
			end
			else
				curr_pc=scoreboard_regs[trans.mem_rdata[19:15]]+curr_pc;
				
			scoreboard_regs[trans.mem_rdata[11:7]] = trans.mem_addr + 32'd4;
			scoreboard_regs[0]=32'd0;
			$display("LD_rd %02d 0x%08x",trans.mem_rdata[11:7],scoreboard_regs[trans.mem_rdata[11:7]]);
	
			$display("next_pc : 0x%08x",curr_pc);
			mon2scb.get(trans);
			if(curr_pc==trans.mem_addr)begin
				$display("Program Counter Jumped to 0x%08x correctly",curr_pc);
			end
			else
				$fatal("Jumped to 0x%08x Expected : 0x%08x ",trans.mem_addr,curr_pc);
		 end
		 7'b 1101111 : begin
			$display("Instruction:JAL");	
			scoreboard_regs[trans.mem_rdata[11:7]] = trans.mem_addr + 32'd4;
			scoreboard_regs[0]=32'd0;			
			$display("LD_rd %02d 0x%08x",trans.mem_rdata[11:7],scoreboard_regs[trans.mem_rdata[11:7]]);			
			prev_pc=trans.mem_addr;
			curr_pc = {{12{trans.mem_rdata[31]}},trans.mem_rdata[19:12],trans.mem_rdata[20],trans.mem_rdata[30:21],1'b0};
			if(curr_pc[31])begin
				curr_pc=~curr_pc+1'b1;
				curr_pc=prev_pc-curr_pc;
			end
			else
				curr_pc=prev_pc+curr_pc;
				
			$display("next_pc : 0x%08x",curr_pc);				
			mon2scb.get(trans);
			if(curr_pc==trans.mem_addr)begin
				$display("Program Counter Jumped to 0x%08x correctly",curr_pc);
			end
			else
				$fatal("Jumped to 0x%08x Expected : 0x%08x ",trans.mem_addr,curr_pc);
			
			
		 end
		endcase
      $display("-----------------------------------------");

    end
  endtask
   
endclass