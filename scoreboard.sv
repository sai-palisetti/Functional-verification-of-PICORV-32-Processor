class scoreboard;
    
typedef mailbox #(transaction) mail_gen;

     mail_gen mon2scb;   
  int no_transactions;
   logic [31:0]scoreboard_regs[0:31];
   integer i=0;
   //logic Branch_taken=0;
   //logic [31:0] prev_pc,curr_pc;
   logic [31:0] temp_rs1,temp_rs2;
   logic [4:0] rd_addr;
  function new(mailbox mon2scb);
    this.mon2scb = mon2scb;
	for ( i=0;i<32;i++) begin
		scoreboard_regs[i] = 0;
	end
  endfunction
   
  task main;
    transaction trans;
	 mon2scb.get(trans);
	 		  no_transactions++;

  forever begin
     	  $display("----------[Scoreboard Transaction : %0d]------",no_transactions);
          $display("Scoreboard Decode: 0x%08x  0x%08x \n ",trans.mem_addr,trans.mem_rdata); 
		  
		  //$display("--------------------------------------");
        if(trans.mem_rdata[6:0]==7'b0010011) begin
		     $display("Instruction:ADDI");
			 $display("[Scoreboard]LD_RS1: %02d 0x%08x",trans.mem_rdata[19:15],scoreboard_regs[trans.mem_rdata[19:15]]);
             scoreboard_regs[trans.mem_rdata[11:7]] = scoreboard_regs[trans.mem_rdata[19:15]] + {{20{trans.mem_rdata[31]}} , trans.mem_rdata[31:20]} ;
			 scoreboard_regs[0] = 0;
			rd_addr=trans.mem_rdata[11:7];
			
			 mon2scb.get(trans);
			if(scoreboard_regs[rd_addr]==trans.decode_rd[rd_addr])
					$display("[Scoreboard]ST_RD: %02d 0x%08x",rd_addr,scoreboard_regs[rd_addr]);
			else
				$fatal("RD from Scoreboard : %02d 0x%08x RD from design:0x%08x",rd_addr, scoreboard_regs[rd_addr],trans.decode_rd[rd_addr]);
								  no_transactions++;
	    end
		else if(trans.mem_rdata[6:0]==7'b0110011) begin 
			case (trans.mem_rdata[14:12])
			
				3'b000: begin
					if(trans.mem_rdata[31:25] == 7'b0000000) begin
						$display("Instruction:ADD");
						$display("[Scoreboard]rs1 %02d: 0x%08x rs2 %02d: 0x%08x",trans.mem_rdata[19:15],scoreboard_regs[trans.mem_rdata[19:15]],trans.mem_rdata[24:20],scoreboard_regs[trans.mem_rdata[24:20]]);
                        scoreboard_regs[trans.mem_rdata[11:7]] = scoreboard_regs[trans.mem_rdata[19:15]] + scoreboard_regs[trans.mem_rdata[24:20]];
						scoreboard_regs[0] = 0;
						rd_addr=trans.mem_rdata[11:7];
						mon2scb.get(trans);
						if(scoreboard_regs[rd_addr]==trans.decode_rd[rd_addr])
						 $display("[Scoreboard]ST_RD: %02d 0x%08x",rd_addr,scoreboard_regs[rd_addr]);
			            else
				         $fatal("RD from Scoreboard : %02d 0x%08x RD from design:0x%08x",rd_addr, scoreboard_regs[rd_addr],trans.decode_rd[rd_addr]);
								  no_transactions++;
                      end
				    else if (trans.mem_rdata[31:25] == 7'b0100000) begin
						$display("Instruction:SUB");
						$display("[Scoreboard]rs1 %02d: 0x%08x rs2 %02d: 0x%08x",trans.mem_rdata[19:15],scoreboard_regs[trans.mem_rdata[19:15]],trans.mem_rdata[24:20],scoreboard_regs[trans.mem_rdata[24:20]]);
						scoreboard_regs[trans.mem_rdata[11:7]] = scoreboard_regs[trans.mem_rdata[19:15]] - scoreboard_regs[trans.mem_rdata[24:20]];
						scoreboard_regs[0] = 0;
						rd_addr=trans.mem_rdata[11:7];
						mon2scb.get(trans);
						if(scoreboard_regs[rd_addr]==trans.decode_rd[rd_addr])
						 $display("[Scoreboard]ST_RD: %02d 0x%08x",rd_addr,scoreboard_regs[rd_addr]);
			            else
				        $fatal("RD from Scoreboard : %02d 0x%08x RD from design:0x%08x",rd_addr, scoreboard_regs[rd_addr],trans.decode_rd[rd_addr]);
								  no_transactions++;
					end
				end

				3'b001: begin
					$display("Instruction:SLL");
					$display("[Scoreboard]rs1 %02d: 0x%08x rs2 %02d: 0x%08x",trans.mem_rdata[19:15],scoreboard_regs[trans.mem_rdata[19:15]],trans.mem_rdata[24:20],scoreboard_regs[trans.mem_rdata[24:20]]);
					scoreboard_regs[trans.mem_rdata[11:7]] = scoreboard_regs[trans.mem_rdata[19:15]] << scoreboard_regs[trans.mem_rdata[24:20]][4:0];
					scoreboard_regs[0] = 0;
					rd_addr=trans.mem_rdata[11:7];
					mon2scb.get(trans);
					if(scoreboard_regs[rd_addr]==trans.decode_rd[rd_addr])
						$display("[Scoreboard]ST_RD: %02d 0x%08x",rd_addr,scoreboard_regs[rd_addr]);
			        else
						$fatal("RD from Scoreboard : %02d 0x%08x RD from design:0x%08x",rd_addr, scoreboard_regs[rd_addr],trans.decode_rd[rd_addr]);								 
						no_transactions++;
					end

				3'b010: begin
					$display("Instruction:SLT");
					$display("[Scoreboard]rs1 %02d: 0x%08x rs2 %02d: 0x%08x",trans.mem_rdata[19:15],scoreboard_regs[trans.mem_rdata[19:15]],trans.mem_rdata[24:20],scoreboard_regs[trans.mem_rdata[24:20]]);
					if($signed(scoreboard_regs[trans.mem_rdata[19:15]]) < $signed(scoreboard_regs[trans.mem_rdata[24:20]]))
					   scoreboard_regs[trans.mem_rdata[11:7]] = 1;
					else
					   scoreboard_regs[trans.mem_rdata[11:7]] = 0;
					   scoreboard_regs[0] = 0;
					   rd_addr=trans.mem_rdata[11:7];
						mon2scb.get(trans);
						if(scoreboard_regs[rd_addr]==trans.decode_rd[rd_addr])
						   $display("[Scoreboard]ST_RD: %02d 0x%08x",rd_addr,scoreboard_regs[rd_addr]);
			            else
				            $fatal("RD from Scoreboard : %02d 0x%08x RD from design:0x%08x",rd_addr, scoreboard_regs[rd_addr],trans.decode_rd[rd_addr]);
								  no_transactions++;
					end

				
				3'b011: begin
					$display("Instruction:SLTU");
					$display("[Scoreboard]rs1 %02d: 0x%08x rs2 %02d: 0x%08x",trans.mem_rdata[19:15],scoreboard_regs[trans.mem_rdata[19:15]],trans.mem_rdata[24:20],scoreboard_regs[trans.mem_rdata[24:20]]);
					if(scoreboard_regs[trans.mem_rdata[19:15]] == 0 && scoreboard_regs[trans.mem_rdata[24:20]]==0)
					   scoreboard_regs[trans.mem_rdata[11:7]] = 0 ;
					 else
					   scoreboard_regs[trans.mem_rdata[11:7]] = 1 ;
					   
				    if( scoreboard_regs[trans.mem_rdata[19:15]] < scoreboard_regs[trans.mem_rdata[24:20]] )
					   scoreboard_regs[trans.mem_rdata[11:7]] = 1;
					 else
					   scoreboard_regs[trans.mem_rdata[11:7]] = 0;	
					   
					scoreboard_regs[0] = 0;
					   
					rd_addr=trans.mem_rdata[11:7];
						mon2scb.get(trans);
					if(scoreboard_regs[rd_addr]==trans.decode_rd[rd_addr])
						$display("[Scoreboard]ST_RD: %02d 0x%08x",rd_addr,scoreboard_regs[rd_addr]);
			        else
				       $fatal("RD from Scoreboard : %02d 0x%08x RD from design:0x%08x",rd_addr, scoreboard_regs[rd_addr],trans.decode_rd[rd_addr]);
								  no_transactions++;
					end

				3'b100: begin
					$display("Instruction:XOR");
					$display("[Scoreboard]rs1 %02d: 0x%08x rs2 %02d: 0x%08x",trans.mem_rdata[19:15],scoreboard_regs[trans.mem_rdata[19:15]],trans.mem_rdata[24:20],scoreboard_regs[trans.mem_rdata[24:20]]);
					scoreboard_regs[trans.mem_rdata[11:7]] = scoreboard_regs[trans.mem_rdata[19:15]] ^ scoreboard_regs[trans.mem_rdata[24:20]];
					scoreboard_regs[0] = 0;
					rd_addr=trans.mem_rdata[11:7];
					mon2scb.get(trans);
					if(scoreboard_regs[rd_addr]==trans.decode_rd[rd_addr])
						$display("[Scoreboard]ST_RD: %02d 0x%08x",rd_addr,scoreboard_regs[rd_addr]);
			        else
				        $fatal("RD from Scoreboard : %02d 0x%08x RD from design:0x%08x",rd_addr, scoreboard_regs[rd_addr],trans.decode_rd[rd_addr]);
								  no_transactions++;
					end
				
				3'b101: begin
					if(trans.mem_rdata[31:25] == 7'b0000000) begin
						$display("Instruction:SRL");
						$display("[Scoreboard]rs1 %02d: 0x%08x rs2 %02d: 0x%08x",trans.mem_rdata[19:15],scoreboard_regs[trans.mem_rdata[19:15]],trans.mem_rdata[24:20],scoreboard_regs[trans.mem_rdata[24:20]]);
                        scoreboard_regs[trans.mem_rdata[11:7]] = scoreboard_regs[trans.mem_rdata[19:15]] >> scoreboard_regs[trans.mem_rdata[24:20]][4:0];
						scoreboard_regs[0] = 0;
						rd_addr=trans.mem_rdata[11:7];
					mon2scb.get(trans);
					if(scoreboard_regs[rd_addr]==trans.decode_rd[rd_addr])
						$display("[Scoreboard]ST_RD: %02d 0x%08x",rd_addr,scoreboard_regs[rd_addr]);
			        else
				       $fatal("RD from Scoreboard : %02d 0x%08x RD from design:0x%08x",rd_addr, scoreboard_regs[rd_addr],trans.decode_rd[rd_addr]);
								  no_transactions++;
					end
				    else if (trans.mem_rdata[31:25] == 7'b0100000) begin
						$display("Instruction:SRA");
						$display("[Scoreboard]rs1 %02d: 0x%08x rs2 %02d: 0x%08x",trans.mem_rdata[19:15],scoreboard_regs[trans.mem_rdata[19:15]],trans.mem_rdata[24:20],scoreboard_regs[trans.mem_rdata[24:20]]);
						//temp_rs1 = scoreboard_regs[trans.mem_rdata[19:15]];
						//temp_rs2 = scoreboard_regs[trans.mem_rdata[24:20]];
						scoreboard_regs[trans.mem_rdata[11:7]] = $signed (scoreboard_regs[trans.mem_rdata[19:15]]) >>> (scoreboard_regs[trans.mem_rdata[24:20]][4:0]);
						//scoreboard_regs[trans.mem_rdata[11:7]] = {{temp_rs2{temp_rs1[31]}},temp_rs1[31:temp_rs2]};
						scoreboard_regs[0] = 0;
						rd_addr=trans.mem_rdata[11:7];
					mon2scb.get(trans);
					if(scoreboard_regs[rd_addr]==trans.decode_rd[rd_addr])
						$display("[Scoreboard]ST_RD: %02d 0x%08x",rd_addr,scoreboard_regs[rd_addr]);
			        else
				       $fatal("RD from Scoreboard : %02d 0x%08x RD from design:0x%08x",rd_addr, scoreboard_regs[rd_addr],trans.decode_rd[rd_addr]);
								  no_transactions++;
					end
				end
				
               3'b110: begin
			        $display("Instruction:OR");
					$display("[Scoreboard]rs1 %02d: 0x%08x rs2 %02d: 0x%08x",trans.mem_rdata[19:15],scoreboard_regs[trans.mem_rdata[19:15]],trans.mem_rdata[24:20],scoreboard_regs[trans.mem_rdata[24:20]]);
			        scoreboard_regs[trans.mem_rdata[11:7]] = scoreboard_regs[trans.mem_rdata[19:15]] | scoreboard_regs[trans.mem_rdata[24:20]];
					scoreboard_regs[0] = 0;
					rd_addr=trans.mem_rdata[11:7];
					mon2scb.get(trans);
					if(scoreboard_regs[rd_addr]==trans.decode_rd[rd_addr])
						$display("[Scoreboard]ST_RD: %02d 0x%08x",rd_addr,scoreboard_regs[rd_addr]);
			        else
				        $fatal("RD from Scoreboard : %02d 0x%08x RD from design:0x%08x",rd_addr, scoreboard_regs[rd_addr],trans.decode_rd[rd_addr]);
								  no_transactions++;
					end
					
			   3'b111: begin 
			         $display("Instruction:AND");
					 $display("[Scoreboard]rs1 %02d: 0x%08x rs2 %02d: 0x%08x",trans.mem_rdata[19:15],scoreboard_regs[trans.mem_rdata[19:15]],trans.mem_rdata[24:20],scoreboard_regs[trans.mem_rdata[24:20]]);
					 scoreboard_regs[trans.mem_rdata[11:7]] = scoreboard_regs[trans.mem_rdata[19:15]] & scoreboard_regs[trans.mem_rdata[24:20]];
					 scoreboard_regs[0] = 0;
					 rd_addr=trans.mem_rdata[11:7];
					mon2scb.get(trans);
					if(scoreboard_regs[rd_addr]==trans.decode_rd[rd_addr])
						$display("[Scoreboard]ST_RD: %02d 0x%08x",rd_addr,scoreboard_regs[rd_addr]);
			        else
				     $fatal("RD from Scoreboard : %02d 0x%08x RD from design:0x%08x",rd_addr, scoreboard_regs[rd_addr],trans.decode_rd[rd_addr]);
								  no_transactions++;
					end
			endcase
			
		end
		
	
      $display("-----------------------------------------");

    end
  endtask
   
endclass