class scoreboard;
    
typedef mailbox #(transaction) mail_gen;
     mail_gen mon2scb;    //creating mailbox handle
  int no_transactions;    //used to count the number of transactions
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
	
	//coverage
	logic [31:0] instr_cov;
	logic [31:0] prev_instr_cov;
	
   integer i=0;
//static   logic driver::Branch_taken=0;
   logic [31:0] prev_pc,curr_pc;
   
   
   
  covergroup cg;
	opcode_6_0	:	coverpoint instr_cov[6:0] {
		bins lui_begin   		= {7'b0110111};	//bin for lui 
		bins auipc_begin		= {7'b0010111};	//bin for auipc
		bins jal_begin   		= {7'b1101111};	//bin for jal
		bins jalr_begin  		= {7'b1100111};	//bin for jalr
		bins branch_begin		= {7'b1100011};	//bin for branch opcode
		bins load_begin  		= {7'b0000011};	//bin for load
		bins store_begin   		= {7'b0100011};	//bin for store 
		bins reg_imm_begin   	= {7'b0010011}; //bin for register_immediate 
		bins reg_reg_begin   	= {7'b0110011};	//bin for register_register 
		bins illegal	= default;
		
		type_option.weight	= 0;	// only to count cross coverage
	
	}
	
	rd_11_7	:	coverpoint instr_cov[11:7]{
		 bins rd[] 	= {[0:$]};
		type_option.weight	= 0;
	}
	
	fun3_14_12 : coverpoint instr_cov[14:12]{
			 bins fun3[] 	= {[0:$]};

		type_option.weight	= 0;
	}
	
	rs1_19_15 : coverpoint instr_cov[19:15]{
		bins rs1[] 	= {[0:$]};
		type_option.weight	= 0;
	}

	rs2_24_20 : coverpoint instr_cov[24:20]{
		bins rs2[] 	= {[0:$]};
		type_option.weight	= 0;
	}

	fun7_31_25 : coverpoint instr_cov[31:25]{
		bins fun7_bin1		= {7'b0000000};
		bins fun7_bin2		= {7'b0100000};
		type_option.weight	= 0;
	}

	sign_31 :	coverpoint instr_cov[31]{
		bins sign_bit[] = {0,1};
		type_option.weight	= 0;
	}
	
	lui : cross sign_31,rd_11_7,opcode_6_0{
		ignore_bins rem = !binsof(opcode_6_0.lui_begin) ;
	//	bins lui		= binsof(opcode_6_0.lui_begin) && binsof(rd_11_7) && binsof(sign_31);
		//bins misc		= default;
		type_option.weight	= 1;
	
	}
	
	auipc : cross sign_31,rd_11_7,opcode_6_0{
		ignore_bins rem = !binsof(opcode_6_0.auipc_begin) ;
		//bins auipc		= binsof(opcode_6_0.auipc_begin) && binsof(rd_11_7) && binsof(sign_31);
		//bins misc		= default;
		type_option.weight	= 1;
	
	}	


	jal : cross sign_31,rd_11_7,opcode_6_0{
		ignore_bins rem = !binsof(opcode_6_0.jal_begin) ;
		//bins auipc		= binsof(opcode_6_0.auipc_begin) && binsof(rd_11_7) && binsof(sign_31);
		//bins misc		= default;
		type_option.weight	= 1;
	
	}	

	jalr : cross sign_31,rs1_19_15,fun3_14_12,rd_11_7,opcode_6_0{
		ignore_bins rem = !binsof(opcode_6_0.jalr_begin) ;
		ignore_bins rem2 = !binsof(fun3_14_12) intersect {3'b000};
		//bins auipc		= binsof(opcode_6_0.auipc_begin) && binsof(rd_11_7) && binsof(sign_31);
		//bins misc		= default;
		type_option.weight	= 1;
	
	}		

	branch : cross sign_31,rs2_24_20,rs1_19_15,fun3_14_12,opcode_6_0{
		ignore_bins rem = !binsof(opcode_6_0.branch_begin) ;
		ignore_bins rem2 = binsof(fun3_14_12) intersect {3'b010,3'b011};

		//bins auipc		= binsof(opcode_6_0.auipc_begin) && binsof(rd_11_7) && binsof(sign_31);
		//bins misc		= default;
		type_option.weight	= 6;
	
	}

	load : cross sign_31,rs1_19_15,fun3_14_12,rd_11_7,opcode_6_0{
		ignore_bins rem = !binsof(opcode_6_0.load_begin) ;
		ignore_bins rem2 = binsof(fun3_14_12) intersect {3'b011,3'b110,3'b111};
		//bins auipc		= binsof(opcode_6_0.auipc_begin) && binsof(rd_11_7) && binsof(sign_31);
		//bins misc		= default;
		type_option.weight	= 5;
	
	}	
	
	store : cross sign_31,rs2_24_20,rs1_19_15,fun3_14_12,opcode_6_0{
		ignore_bins rem = !binsof(opcode_6_0.store_begin) ;
		ignore_bins rem2 = !binsof(fun3_14_12) intersect {3'b000,3'b001,3'b010};

		//bins auipc		= binsof(opcode_6_0.auipc_begin) && binsof(rd_11_7) && binsof(sign_31);
		//bins misc		= default;
		type_option.weight	= 3;
	
	}

	reg_imm : cross sign_31,rs1_19_15,fun3_14_12,rd_11_7,opcode_6_0{
		ignore_bins rem = !binsof(opcode_6_0.reg_imm_begin) ;
		ignore_bins rem2 = binsof(fun3_14_12) intersect {3'b001,3'b101};
		//bins auipc		= binsof(opcode_6_0.auipc_begin) && binsof(rd_11_7) && binsof(sign_31);
		//bins misc		= default;
		type_option.weight	= 6;
	
	}

	set_imm : cross fun7_31_25,rs2_24_20,rs1_19_15,fun3_14_12,opcode_6_0{
		ignore_bins rem = !binsof(opcode_6_0.reg_imm_begin) ;
		ignore_bins rem2 = !binsof(fun3_14_12) intersect {3'b001,3'b101};
		ignore_bins rem3 = binsof(fun7_31_25.fun7_bin2)&& binsof(fun3_14_12) intersect {3'b001};
		//bins auipc		= binsof(opcode_6_0.auipc_begin) && binsof(rd_11_7) && binsof(sign_31);
		//bins misc		= default;
		type_option.weight	= 3;
	
	}

	reg_reg : cross fun7_31_25,rs2_24_20,rs1_19_15,fun3_14_12,opcode_6_0{
		ignore_bins rem = !binsof(opcode_6_0.reg_reg_begin) ;
		ignore_bins rem2 = binsof(fun7_31_25.fun7_bin2)&& binsof(fun3_14_12) intersect {3'b001,3'b010,3'b011,3'b100,3'b110,3'b111};
		//ignore_bins rem3 = !binsof(fun7_31_25.fun7_bin2)&& binsof(fun3_14_12) intersect {3'b101};
		//bins auipc		= binsof(opcode_6_0.auipc_begin) && binsof(rd_11_7) && binsof(sign_31);
		//bins misc		= default;
		type_option.weight	= 10;
	
	}
  endgroup
  
  covergroup cg_among_instr;
	instr1: coverpoint instr_cov {
		wildcard bins lui 			= {32'b?????????????????????????0110111};
		wildcard bins auipc 		= {32'b?????????????????????????0010111};
		wildcard bins jal 			= {32'b?????????????????????????1101111};
		wildcard bins jalr 			= {32'b?????????????????????????1100111};
		wildcard bins beq 			= {32'b?????????????????000?????1100011};
		wildcard bins bne 			= {32'b?????????????????001?????1100011};
		wildcard bins blt 			= {32'b?????????????????100?????1100011};
		wildcard bins bge 			= {32'b?????????????????101?????1100011};
		wildcard bins bltu 			= {32'b?????????????????110?????1100011};
		wildcard bins bgeu 			= {32'b?????????????????111?????1100011};
		wildcard bins lb 			= {32'b?????????????????000?????0000011};
		wildcard bins lh 			= {32'b?????????????????001?????0000011};
		wildcard bins lw 			= {32'b?????????????????010?????0000011};
		wildcard bins lbu 			= {32'b?????????????????100?????0000011};
		wildcard bins lhu 			= {32'b?????????????????101?????0000011};
		wildcard bins sb 			= {32'b?????????????????000?????0100011};
		wildcard bins sh 			= {32'b?????????????????001?????0100011};
		wildcard bins sw 			= {32'b?????????????????010?????0100011};
		wildcard bins addi 			= {32'b?????????????????000?????0010011};
		wildcard bins slti 			= {32'b?????????????????010?????0010011};
		wildcard bins sltiu 		= {32'b?????????????????011?????0010011};
		wildcard bins xori 			= {32'b?????????????????100?????0010011};
		wildcard bins ori 			= {32'b?????????????????110?????0010011};
		wildcard bins andi 			= {32'b?????????????????111?????0010011};
		wildcard bins slli		 	= {32'b0000000??????????001?????0010011}; 
		wildcard bins srli		 	= {32'b0000000??????????101?????0010011};
		wildcard bins srai		 	= {32'b0100000??????????101?????0010011};
		wildcard bins add		 	= {32'b0000000??????????000?????0110011};
		wildcard bins sub		 	= {32'b0100000??????????000?????0110011};
		wildcard bins sll			= {32'b0000000??????????001?????0110011};
		wildcard bins slt		 	= {32'b0000000??????????010?????0110011};
		wildcard bins sltu		 	= {32'b0000000??????????011?????0110011};
		wildcard bins xor1		 	= {32'b0000000??????????100?????0110011};
		wildcard bins srl		 	= {32'b0000000??????????101?????0110011};
		wildcard bins sra		 	= {32'b0100000??????????101?????0110011};
		wildcard bins or1		 	= {32'b0000000??????????110?????0110011};
		wildcard bins and1		 	= {32'b0000000??????????111?????0110011};
		type_option.weight	= 0;

	}
	instr2: coverpoint prev_instr_cov {
		wildcard bins lui 			= {32'b?????????????????????????0110111};
		wildcard bins auipc 		= {32'b?????????????????????????0010111};
		wildcard bins jal 			= {32'b?????????????????????????1101111};
		wildcard bins jalr 			= {32'b?????????????????????????1100111};
		wildcard bins beq 			= {32'b?????????????????000?????1100011};
		wildcard bins bne 			= {32'b?????????????????001?????1100011};
		wildcard bins blt 			= {32'b?????????????????100?????1100011};
		wildcard bins bge 			= {32'b?????????????????101?????1100011};
		wildcard bins bltu 			= {32'b?????????????????110?????1100011};
		wildcard bins bgeu 			= {32'b?????????????????111?????1100011};
		wildcard bins lb 			= {32'b?????????????????000?????0000011};
		wildcard bins lh 			= {32'b?????????????????001?????0000011};
		wildcard bins lw 			= {32'b?????????????????010?????0000011};
		wildcard bins lbu 			= {32'b?????????????????100?????0000011};
		wildcard bins lhu 			= {32'b?????????????????101?????0000011};
		wildcard bins sb 			= {32'b?????????????????000?????0100011};
		wildcard bins sh 			= {32'b?????????????????001?????0100011};
		wildcard bins sw 			= {32'b?????????????????010?????0100011};
		wildcard bins addi 			= {32'b?????????????????000?????0010011};
		wildcard bins slti 			= {32'b?????????????????010?????0010011};
		wildcard bins sltiu 		= {32'b?????????????????011?????0010011};
		wildcard bins xori 			= {32'b?????????????????100?????0010011};
		wildcard bins ori 			= {32'b?????????????????110?????0010011};
		wildcard bins andi 			= {32'b?????????????????111?????0010011};
		wildcard bins slli		 	= {32'b0000000??????????001?????0010011}; 
		wildcard bins srli		 	= {32'b0000000??????????101?????0010011};
		wildcard bins srai		 	= {32'b0100000??????????101?????0010011};
		wildcard bins add		 	= {32'b0000000??????????000?????0110011};
		wildcard bins sub		 	= {32'b0100000??????????000?????0110011};
		wildcard bins sll			= {32'b0000000??????????001?????0110011};
		wildcard bins slt		 	= {32'b0000000??????????010?????0110011};
		wildcard bins sltu		 	= {32'b0000000??????????011?????0110011};
		wildcard bins xor1		 	= {32'b0000000??????????100?????0110011};
		wildcard bins srl		 	= {32'b0000000??????????101?????0110011};
		wildcard bins sra		 	= {32'b0100000??????????101?????0110011};
		wildcard bins or1		 	= {32'b0000000??????????110?????0110011};
		wildcard bins and1		 	= {32'b0000000??????????111?????0110011};

		type_option.weight	= 0;

	}
	among: cross instr1,instr2;
  endgroup
      
  function new(mailbox mon2scb);
    this.mon2scb = mon2scb;  //getting the mailbox handles from  environment
	for ( i=0;i<32;i++) begin
		scoreboard_regs[i] = 0;
	end
	cg = new;
	cg_among_instr = new;
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
		driver::Branch_taken=0;
		// coverage 
		
		prev_instr_cov=instr_cov;
		instr_cov=trans.mem_rdata;
		cg.sample();
		cg_among_instr.sample();
		case (trans.mem_rdata[6:0])
		
		
		
        7'b0010011 : begin
			case (trans.mem_rdata[14:12])
			
			    3'b000: begin
		           $display("Instruction:ADDI");
			       $display("[Scoreboard]LD_RS1: %02d 0x%08x",trans.mem_rdata[19:15],scoreboard_regs[trans.mem_rdata[19:15]]);
                   scoreboard_regs[trans.mem_rdata[11:7]] = scoreboard_regs[trans.mem_rdata[19:15]] + {{20{trans.mem_rdata[31]}} , trans.mem_rdata[31:20]} ;
			       scoreboard_regs[0] = 0;
				   	   driver::driver_regs=scoreboard_regs;

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
						   driver::driver_regs=scoreboard_regs;

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
					   	   driver::driver_regs=scoreboard_regs;

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
						   driver::driver_regs=scoreboard_regs;

					   
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
						   driver::driver_regs=scoreboard_regs;

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
							   driver::driver_regs=scoreboard_regs;

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
							   driver::driver_regs=scoreboard_regs;

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
						   driver::driver_regs=scoreboard_regs;

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
					 	   driver::driver_regs=scoreboard_regs;

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
							   driver::driver_regs=scoreboard_regs;

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
							   driver::driver_regs=scoreboard_regs;

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
						   driver::driver_regs=scoreboard_regs;

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
					   	   driver::driver_regs=scoreboard_regs;

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
					   	   driver::driver_regs=scoreboard_regs;

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
						   driver::driver_regs=scoreboard_regs;

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
							   driver::driver_regs=scoreboard_regs;

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
							   driver::driver_regs=scoreboard_regs;

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
						   driver::driver_regs=scoreboard_regs;

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
					 	   driver::driver_regs=scoreboard_regs;

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
					   driver::driver_regs=scoreboard_regs;

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
	   driver::driver_regs=scoreboard_regs;
				
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
						driver::Branch_taken=1;
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
						driver::Branch_taken=1;
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
						driver::Branch_taken=1;
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
						driver::Branch_taken=1;
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
						driver::Branch_taken=1;
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
						driver::Branch_taken=1;
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

		//	if(curr_pc[31])begin
		//		curr_pc=~curr_pc+1'b1;
		//		curr_pc=scoreboard_regs[trans.mem_rdata[19:15]]-curr_pc;
		//	end
		//	else
				curr_pc=scoreboard_regs[trans.mem_rdata[19:15]]+curr_pc;
				
			scoreboard_regs[trans.mem_rdata[11:7]] = trans.mem_addr + 32'd4;
			scoreboard_regs[0]=32'd0;
				   driver::driver_regs=scoreboard_regs;

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
	   driver::driver_regs=scoreboard_regs;
			
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
						$display("[Scoreboard]LD_RS1: %02d : 0x%08x",load_addr_rs,scoreboard_regs[load_addr_rs]);			

					
						scoreboard_regs[rd_addr]=trans.mem_rdata[31:0];	
							
						scoreboard_regs[0]=32'b0;
							   driver::driver_regs=scoreboard_regs;

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
							   driver::driver_regs=scoreboard_regs;

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
							   driver::driver_regs=scoreboard_regs;

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