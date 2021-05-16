class scoreboard;
    
typedef mailbox #(transaction) mail_gen;

     mail_gen mon2scb;   
  int no_transactions;
   logic [31:0]scoreboard_regs[0:31];
   logic [4:0] rd_addr;
	bit [31:0] load_addr;
	bit is_load_unsigned;
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
     	  $display("-----------------[Scoreboard Transaction : %0d]-----------------",no_transactions);
          $display("Scoreboard Decode: 0x%08x  0x%08x \n ",trans.mem_addr,trans.mem_rdata); 
		  no_transactions++;
//		  $display("----------------------------------------------");
	// mon2scb.get(trans);


		case (trans.mem_rdata[6:0])
		
		
		
        7'b0010011 : begin
			case (trans.mem_rdata[14:12])
			
			    3'b000: begin
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
		//						  no_transactions++;
	             end
				 
				
				3'b001: begin
					$display("Instruction:SLLI");
					$display("[Scoreboard]LD_RS1: %02d: 0x%08x Shift_amt: %02d",trans.mem_rdata[19:15],scoreboard_regs[trans.mem_rdata[19:15]],trans.mem_rdata[24:20]);
					scoreboard_regs[trans.mem_rdata[11:7]] = scoreboard_regs[trans.mem_rdata[19:15]] << trans.mem_rdata[24:20];
					scoreboard_regs[0] = 0;
					rd_addr=trans.mem_rdata[11:7];
					mon2scb.get(trans);
					if(scoreboard_regs[rd_addr]==trans.decode_rd[rd_addr])
						$display("[Scoreboard]ST_RD: %02d 0x%08x",rd_addr,scoreboard_regs[rd_addr]);
			        else
						$fatal("RD from Scoreboard : %02d 0x%08x RD from design:0x%08x",rd_addr, scoreboard_regs[rd_addr],trans.decode_rd[rd_addr]);								 
		//				no_transactions++;
					end
				
				3'b010: begin
				   $display("Instruction:SLTI");
			       $display("[Scoreboard]LD_RS1: %02d 0x%08x",trans.mem_rdata[19:15],scoreboard_regs[trans.mem_rdata[19:15]]);
                   if($signed(scoreboard_regs[trans.mem_rdata[19:15]]) < $signed({{20{trans.mem_rdata[31]}} , trans.mem_rdata[31:20]}))
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
		//						  no_transactions++;
					end
					
				3'b011: begin
				   $display("Instruction:SLTIU");
			       $display("[Scoreboard]LD_RS1: %02d 0x%08x",trans.mem_rdata[19:15],scoreboard_regs[trans.mem_rdata[19:15]]);
  /*                  if(scoreboard_regs[trans.mem_rdata[19:15]] == 0 )
					   scoreboard_regs[trans.mem_rdata[11:7]] = 1 ;
					// else
					//   scoreboard_regs[trans.mem_rdata[11:7]] = 1 ;
					   
				   else if (scoreboard_regs[trans.mem_rdata[19:15]] < {{20{trans.mem_rdata[31]}} , trans.mem_rdata[31:20]} )
					   scoreboard_regs[trans.mem_rdata[11:7]] = 1;
				   else
					   scoreboard_regs[trans.mem_rdata[11:7]] = 0;	
	 */				   
	 
						scoreboard_regs[trans.mem_rdata[11:7]] =scoreboard_regs[trans.mem_rdata[19:15]] < {{20{trans.mem_rdata[31]}} , trans.mem_rdata[31:20]} ;

					scoreboard_regs[0] = 0;
					   
					rd_addr=trans.mem_rdata[11:7];
						mon2scb.get(trans);
					if(scoreboard_regs[rd_addr]==trans.decode_rd[rd_addr])
						$display("[Scoreboard]ST_RD: %02d 0x%08x",rd_addr,scoreboard_regs[rd_addr]);
			        else
				       $fatal("RD from Scoreboard : %02d 0x%08x RD from design:0x%08x",rd_addr, scoreboard_regs[rd_addr],trans.decode_rd[rd_addr]);
		//						  no_transactions++;
				 end
				 
				3'b100: begin
					$display("Instruction:XORI");
					$display("[Scoreboard]LD_RS1: %02d: 0x%08x",trans.mem_rdata[19:15],scoreboard_regs[trans.mem_rdata[19:15]]);
					scoreboard_regs[trans.mem_rdata[11:7]] = scoreboard_regs[trans.mem_rdata[19:15]] ^ {{20{trans.mem_rdata[31]}} , trans.mem_rdata[31:20]} ;
					scoreboard_regs[0] = 0;
					rd_addr=trans.mem_rdata[11:7];
					mon2scb.get(trans);
					if(scoreboard_regs[rd_addr]==trans.decode_rd[rd_addr])
						$display("[Scoreboard]ST_RD: %02d 0x%08x",rd_addr,scoreboard_regs[rd_addr]);
			        else
				        $fatal("RD from Scoreboard : %02d 0x%08x RD from design:0x%08x",rd_addr, scoreboard_regs[rd_addr],trans.decode_rd[rd_addr]);
		//						  no_transactions++;
				 end
				 
				3'b101: begin
					if(trans.mem_rdata[31:25] == 7'b0000000) begin
						$display("Instruction:SRLI");
					$display("[Scoreboard]LD_RS1: %02d: 0x%08x Shift_amt: %02d",trans.mem_rdata[19:15],scoreboard_regs[trans.mem_rdata[19:15]],trans.mem_rdata[24:20]);
                        scoreboard_regs[trans.mem_rdata[11:7]] = scoreboard_regs[trans.mem_rdata[19:15]] >> trans.mem_rdata[24:20];
						scoreboard_regs[0] = 0;
						rd_addr=trans.mem_rdata[11:7];
					mon2scb.get(trans);
					if(scoreboard_regs[rd_addr]==trans.decode_rd[rd_addr])
						$display("[Scoreboard]ST_RD: %02d 0x%08x",rd_addr,scoreboard_regs[rd_addr]);
			        else
				       $fatal("RD from Scoreboard : %02d 0x%08x RD from design:0x%08x",rd_addr, scoreboard_regs[rd_addr],trans.decode_rd[rd_addr]);
		//						  no_transactions++;
					end
				    else if (trans.mem_rdata[31:25] == 7'b0100000) begin
						$display("Instruction:SRAI");
					$display("[Scoreboard]LD_RS1: %02d: 0x%08x Shift_amt: %02d",trans.mem_rdata[19:15],scoreboard_regs[trans.mem_rdata[19:15]],trans.mem_rdata[24:20]);
						scoreboard_regs[trans.mem_rdata[11:7]] = $signed (scoreboard_regs[trans.mem_rdata[19:15]]) >>> trans.mem_rdata[24:20];
						scoreboard_regs[0] = 0;
						rd_addr=trans.mem_rdata[11:7];
					mon2scb.get(trans);
					if(scoreboard_regs[rd_addr]==trans.decode_rd[rd_addr])
						$display("[Scoreboard]ST_RD: %02d 0x%08x",rd_addr,scoreboard_regs[rd_addr]);
			        else
				       $fatal("RD from Scoreboard : %02d 0x%08x RD from design:0x%08x",rd_addr, scoreboard_regs[rd_addr],trans.decode_rd[rd_addr]);
		//						  no_transactions++;
					end
				end
				 
				
                3'b110: begin
			        $display("Instruction:ORI");
			       $display("[Scoreboard]LD_RS1: %02d 0x%08x",trans.mem_rdata[19:15],scoreboard_regs[trans.mem_rdata[19:15]]);
			        scoreboard_regs[trans.mem_rdata[11:7]] = scoreboard_regs[trans.mem_rdata[19:15]] | {{20{trans.mem_rdata[31]}} , trans.mem_rdata[31:20]} ;
					scoreboard_regs[0] = 0;
					rd_addr=trans.mem_rdata[11:7];
					mon2scb.get(trans);
					if(scoreboard_regs[rd_addr]==trans.decode_rd[rd_addr])
						$display("[Scoreboard]ST_RD: %02d 0x%08x",rd_addr,scoreboard_regs[rd_addr]);
			        else
				        $fatal("RD from Scoreboard : %02d 0x%08x RD from design:0x%08x",rd_addr, scoreboard_regs[rd_addr],trans.decode_rd[rd_addr]);
		//						  no_transactions++;
					end
					
			    3'b111: begin 
			         $display("Instruction:ANDI");
			       $display("[Scoreboard]LD_RS1: %02d 0x%08x",trans.mem_rdata[19:15],scoreboard_regs[trans.mem_rdata[19:15]]);
					 scoreboard_regs[trans.mem_rdata[11:7]] = scoreboard_regs[trans.mem_rdata[19:15]] & {{20{trans.mem_rdata[31]}} , trans.mem_rdata[31:20]} ;
					 scoreboard_regs[0] = 0;
					 rd_addr=trans.mem_rdata[11:7];
					mon2scb.get(trans);
					if(scoreboard_regs[rd_addr]==trans.decode_rd[rd_addr])
						$display("[Scoreboard]ST_RD: %02d 0x%08x",rd_addr,scoreboard_regs[rd_addr]);
			        else
				     $fatal("RD from Scoreboard : %02d 0x%08x RD from design:0x%08x",rd_addr, scoreboard_regs[rd_addr],trans.decode_rd[rd_addr]);
		//						  no_transactions++;
					end
			endcase
			
		end
				
				
		7'b0110011 : begin 
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
		//						  no_transactions++;
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
		//						  no_transactions++;
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
		//				no_transactions++;
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
		//						  no_transactions++;
					end

				
				3'b011: begin
					$display("Instruction:SLTU");
					$display("[Scoreboard]rs1 %02d: 0x%08x rs2 %02d: 0x%08x",trans.mem_rdata[19:15],scoreboard_regs[trans.mem_rdata[19:15]],trans.mem_rdata[24:20],scoreboard_regs[trans.mem_rdata[24:20]]);
					if(scoreboard_regs[trans.mem_rdata[19:15]] == 0 && scoreboard_regs[trans.mem_rdata[24:20]]==0)
					   scoreboard_regs[trans.mem_rdata[11:7]] = 0 ;
					   
				    else if( scoreboard_regs[trans.mem_rdata[19:15]] < scoreboard_regs[trans.mem_rdata[24:20]] )
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
		//						  no_transactions++;
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
		//						  no_transactions++;
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
		//						  no_transactions++;
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
	//							  no_transactions++;
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
	//							  no_transactions++;
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
	//							  no_transactions++;
					end
			endcase
			
		end
		
		
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

 			7'b0000011 : begin
				case (1'b1)
					trans.mem_rdata[13] : begin
						$display("[Scoreboard] Instruction:LW");	
						 load_addr= {{20{trans.mem_rdata[31]}},trans.mem_rdata[31:20]};
						 load_addr_rs = trans.mem_rdata[19:15];
//						$display("[Scoreboard]Load Adress: 0x%08x , rs1: %02d : 0x%08x",load_addr,trans.mem_rdata[19:15],scoreboard_regs[trans.mem_rdata[19:15]]);			
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
						$display("[Scoreboard]LD_RS1: %02d : 0x%08x",load_addr,load_addr_rs,scoreboard_regs[load_addr_rs]);			

					
						scoreboard_regs[rd_addr]=trans.mem_rdata[31:0];	
							
						scoreboard_regs[0]=32'b0;
						load_addr= {load_addr[31:2],2'b00};
						//scoreboard_regs[rd_addr]={{24{trans.mem_rdata[7]}},trans.mem_rdata[7:0]};
						if(trans.mem_addr==load_addr)
							$display("[Scoreboard]ST_RD: %02d 0x%08x \n[Scoreboard] Memory location : 0x%08x \t [Design] Memory location : 0x%08x",rd_addr,scoreboard_regs[rd_addr],load_addr,trans.mem_addr);
						else
							$fatal("[Scoreboard]ST_RD: %02d 0x%08x \n[Scoreboard] Memory location : 0x%08x \t [Design] Memory location : 0x%08x",rd_addr,scoreboard_regs[rd_addr],load_addr,trans.mem_addr);
		
						trans.mem_valid =temp_mem_valid ;
						trans.mem_instr =temp_mem_instr ;
						trans.mem_ready =temp_mem_ready ;
						trans.mem_addr  =temp_mem_addr  ;
						trans.mem_wdata =temp_mem_wdata ;
						trans.mem_rdata =temp_mem_rdata ;
						trans.decode_rd =temp_decode_rd ;
						
						no_transactions++;
					end

					trans.mem_rdata[12] : begin
							if(trans.mem_rdata[14]) begin
								$display("[Scoreboard] Instruction:LHU");
								is_load_unsigned=1'b1;
							end
							else
								$display("[Scoreboard] Instruction:LH");

						load_addr= {{20{trans.mem_rdata[31]}},trans.mem_rdata[31:20]};
						load_addr_rs = trans.mem_rdata[19:15];
//						$display("[Scoreboard]Load Adress: 0x%08x , rs1: %02d : 0x%08x",load_addr,trans.mem_rdata[19:15],scoreboard_regs[trans.mem_rdata[19:15]]);			
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
						$display("[Scoreboard]LD_RS1: %02d : 0x%08x",load_addr_rs,scoreboard_regs[load_addr_rs]);			

					
						case (load_addr[1])
							1'b1 : begin
								if(is_load_unsigned)
									scoreboard_regs[rd_addr]={16'b0,trans.mem_rdata[31:16]};
								else
									scoreboard_regs[rd_addr]={{16{trans.mem_rdata[31]}},trans.mem_rdata[31:16]};
								
							end
							1'b0 : begin
								if(is_load_unsigned)
									scoreboard_regs[rd_addr]={16'b0,trans.mem_rdata[15:0]};
								else
									scoreboard_regs[rd_addr]={{16{trans.mem_rdata[15]}},trans.mem_rdata[15:0]};
								
							end
							
						endcase
					//end
						is_load_unsigned=1'b0;				
						scoreboard_regs[0]=32'b0;
						load_addr= {load_addr[31:2],2'b00};
						//scoreboard_regs[rd_addr]={{24{trans.mem_rdata[7]}},trans.mem_rdata[7:0]};
						if(trans.mem_addr==load_addr)
							$display("[Scoreboard]ST_RD: %02d 0x%08x \n[Scoreboard] Memory location : 0x%08x \t [Design] Memory location : 0x%08x",rd_addr,scoreboard_regs[rd_addr],load_addr,trans.mem_addr);
						else
							$fatal("[Scoreboard]ST_RD: %02d 0x%08x \n[Scoreboard] Memory location : 0x%08x \t [Design] Memory location : 0x%08x",rd_addr,scoreboard_regs[rd_addr],load_addr,trans.mem_addr);
		
						trans.mem_valid =temp_mem_valid ;
						trans.mem_instr =temp_mem_instr ;
						trans.mem_ready =temp_mem_ready ;
						trans.mem_addr  =temp_mem_addr  ;
						trans.mem_wdata =temp_mem_wdata ;
						trans.mem_rdata =temp_mem_rdata ;
						trans.decode_rd =temp_decode_rd ;
						
						no_transactions++;
					end

					~|{trans.mem_rdata[13],trans.mem_rdata[12]} : begin
							if(trans.mem_rdata[14]) begin
								$display("[Scoreboard] Instruction:LBU");
								is_load_unsigned=1'b1;
							end
							else
								$display("[Scoreboard] Instruction:LB");							
						load_addr= {{20{trans.mem_rdata[31]}},trans.mem_rdata[31:20]};
						load_addr_rs = trans.mem_rdata[19:15];
//						$display("[Scoreboard]Load Adress: 0x%08x , rs1: %02d : 0x%08x",load_addr,trans.mem_rdata[19:15],scoreboard_regs[trans.mem_rdata[19:15]]);			
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
						$display("[Scoreboard]LD_RS1: %02d : 0x%08x",load_addr_rs,scoreboard_regs[load_addr_rs]);			

 						case (load_addr[1:0])
							2'b11 : begin
								if(is_load_unsigned)								
									scoreboard_regs[rd_addr]={24'b0,trans.mem_rdata[31:24]};	
								else
									scoreboard_regs[rd_addr]={{24{trans.mem_rdata[31]}},trans.mem_rdata[31:24]};	
							end
							2'b10 : begin
								if(is_load_unsigned)								
									scoreboard_regs[rd_addr]={24'b0,trans.mem_rdata[23:16]};	
								else
									scoreboard_regs[rd_addr]={{24{trans.mem_rdata[23]}},trans.mem_rdata[23:16]};	
							end
							2'b01 : begin
								if(is_load_unsigned)								
									scoreboard_regs[rd_addr]={24'b0,trans.mem_rdata[15:8]};	
								else
									scoreboard_regs[rd_addr]={{24{trans.mem_rdata[15]}},trans.mem_rdata[15:8]};	
							end
							2'b00 : begin
								if(is_load_unsigned)								
									scoreboard_regs[rd_addr]={24'b0,trans.mem_rdata[7:0]};	
								else
									scoreboard_regs[rd_addr]={{24{trans.mem_rdata[7]}},trans.mem_rdata[7:0]};	
							end
							
						
						endcase
						is_load_unsigned=1'b0;				
						scoreboard_regs[0]=32'b0;
						load_addr= {load_addr[31:2],2'b00};
						if(trans.mem_addr==load_addr)
							$display("[Scoreboard]ST_RD: %02d 0x%08x \n[Scoreboard] Memory location : 0x%08x \t [Design] Memory location : 0x%08x",rd_addr,scoreboard_regs[rd_addr],load_addr,trans.mem_addr);
						else
							$fatal("[Scoreboard]ST_RD: %02d 0x%08x \n[Scoreboard] Memory location : 0x%08x \t [Design] Memory location : 0x%08x",rd_addr,scoreboard_regs[rd_addr],load_addr,trans.mem_addr);
		
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
 
 			7'b0100011 : begin
						if(trans.mem_rdata[13])
							$display("[Scoreboard] Instruction:SW");	
						else if (trans.mem_rdata[12])
							$display("[Scoreboard] Instruction:SH");	
						else	
							$display("[Scoreboard] Instruction:SB");	
						
						 load_addr= {{20{trans.mem_rdata[31]}},trans.mem_rdata[31:25],trans.mem_rdata[11:7]};
						 load_addr_rs = trans.mem_rdata[19:15];
//						$display("[Scoreboard]Load Adress: 0x%08x , rs1: %02d : 0x%08x",load_addr,trans.mem_rdata[19:15],scoreboard_regs[trans.mem_rdata[19:15]]);			
						rd_addr=trans.mem_rdata[24:20];
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
						$display("[Scoreboard]LD_RS1: %02d : 0x%08x",load_addr_rs,scoreboard_regs[load_addr_rs]);			
						load_addr= {load_addr[31:2],2'b00};
						if(trans.mem_addr==load_addr)
							$display("[Scoreboard]LD_RS2: %02d 0x%08x \n[Scoreboard] Memory location : 0x%08x \t [Design] Memory location : 0x%08x",rd_addr,scoreboard_regs[rd_addr],load_addr,trans.mem_addr);
						else
							$fatal("[Scoreboard]LD_RS2: %02d 0x%08x \n[Scoreboard] Memory location : 0x%08x \t [Design] Memory location : 0x%08x",rd_addr,scoreboard_regs[rd_addr],load_addr,trans.mem_addr);
		
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
       $display("----------------------------------------------------------");

    end
  endtask
   
endclass