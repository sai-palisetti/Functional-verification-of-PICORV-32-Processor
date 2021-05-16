`define DRIV_IF intf.tb.cb

//`DRIV_IF will point to intf.DRIVER.driver_cb

class driver;
     int no_transactions; //used to count the number of transactions
static	 logic [31:0]driver_regs[0:31];
static   logic Branch_taken;
		logic [1:0] sel_byte;
		   integer i=0;

	 rand bit [31:0]driver_load_instr;
	 logic [31:0] driver_rd_data[$]; //queue for data
	 logic [31:0] driver_load_data[$]; //queue for data
	 logic [4:0] driver_rd_addr[$];
     virtual pico_interface.tb intf;  //creating virtual interface handle
	typedef mailbox #(transaction) mail_gen;
	mail_gen gen2driv;   //creating mailbox handle
	
  function new(virtual pico_interface intf,mailbox gen2driv);
    this.intf = intf; //getting the interface
    this.gen2driv = gen2driv;  //getting the mailbox handle from  environment
	for ( i=0;i<32;i++) begin
		driver_regs[i] = 0;
	end
  endfunction
  
  /* 	constraint valid_load_insr{
		driver_load_instr[1:0] inside {2'b00};
		driver_load_addr[17:16] inside {2'b00};
	} */
	
	
	//Reset task, Reset the Interface signals to default/initial values
    task reset;
    wait(!intf.tb.reset);
    $display("--------- [DRIVER] Reset Started ---------");
     `DRIV_IF.mem_ready <=0; 
    wait(intf.tb.reset);
	repeat(2) @(posedge intf.tb.cb);

    $display("--------- [DRIVER] Reset Ended---------");
	
  endtask
   
  //drive the transaction items to interface signals
  task main;
    forever begin	 
	@(posedge intf.tb.cb);
		if (`DRIV_IF.mem_valid) begin

      transaction trans;
     
      gen2driv.get(trans);
	`DRIV_IF.mem_ready <=1; 
      $display("--------- [DRIVER-TRANSFER: %0d] ---------",no_transactions);

			if(`DRIV_IF.mem_instr)	begin
			
			
				case (trans.mem_rdata[6:0])
				
				7'b1100111 : begin  //jalr
					//environment::update_scb_regs();
					//scoreboard_regs=environment::env_regs;
												Branch_taken=0;

					if(driver_rd_addr.size()!=0 && driver_rd_data.size()!=0 && trans.mem_rdata[19:15]==driver_rd_addr[0]) begin
						driver_regs[trans.mem_rdata[19:15]]=driver_rd_data[0];
						driver_regs[0]=32'b0;
					end
					case (driver_regs[trans.mem_rdata[19:15]][1:0])
						2'b00 : `DRIV_IF.mem_rdata <= trans.mem_rdata;
						2'b01 : `DRIV_IF.mem_rdata <= {trans.mem_rdata[31:22],2'b11,trans.mem_rdata[19:0]};					
						2'b10 : `DRIV_IF.mem_rdata <= {trans.mem_rdata[31:22],2'b10,trans.mem_rdata[19:0]};					
						2'b11 : `DRIV_IF.mem_rdata <= {trans.mem_rdata[31:22],2'b01,trans.mem_rdata[19:0]};					
					endcase
				end
				7'b0000011 : begin
					//environment::update_scb_regs();
					//scoreboard_regs=environment::env_regs;
							driver_load_instr=$random; 
					if(! Branch_taken) 	begin	
							
						
						
						if(driver_rd_addr.size()!=0 && driver_rd_data.size()!=0 && trans.mem_rdata[19:15]==driver_rd_addr[0]) begin
							driver_regs[trans.mem_rdata[19:15]]=driver_rd_data[0];
							driver_regs[0]=32'b0;
						end
						if(trans.mem_rdata[13])  begin //lw
							case (driver_regs[trans.mem_rdata[19:15]][1:0])
								2'b00 : `DRIV_IF.mem_rdata <= trans.mem_rdata;
								2'b01 : `DRIV_IF.mem_rdata <= {trans.mem_rdata[31:22],2'b11,trans.mem_rdata[19:0]};					
								2'b10 : `DRIV_IF.mem_rdata <= {trans.mem_rdata[31:22],2'b10,trans.mem_rdata[19:0]};					
								2'b11 : `DRIV_IF.mem_rdata <= {trans.mem_rdata[31:22],2'b01,trans.mem_rdata[19:0]};					
							endcase
							driver_rd_data.push_back(driver_load_instr);
							
						end
						else if(trans.mem_rdata[12]) begin //lh and lhu
								//							driver_load_instr=$random; 
								//	driver_rd_addr.push_back(trans.mem_rdata[11:7]);
								//	driver_rd_data.push_back(driver_load_instr);
							//if(driver_rd_addr.size()!=0 && driver_rd_data.size()!=0 && trans.mem_rdata[19:15]==driver_rd_addr[0])
							//driver_regs[trans.mem_rdata[19:15]]=driver_rd_data[0];
		
							if(driver_regs[trans.mem_rdata[19:15]][0]) begin
								`DRIV_IF.mem_rdata <= {trans.mem_rdata[31:21],1'b1,trans.mem_rdata[19:0]};	
								if(driver_regs[trans.mem_rdata[19:15]][1]+1'b1+trans.mem_rdata[21]) begin
									if(trans.mem_rdata[14])
										driver_rd_data.push_back($unsigned(driver_load_instr[31:16]));
									else
										driver_rd_data.push_back($signed(driver_load_instr[31:16]));
								end
								else begin
									if(trans.mem_rdata[14])
										driver_rd_data.push_back($unsigned(driver_load_instr[15:0]));
									else
										driver_rd_data.push_back($signed(driver_load_instr[15:0]));
								end
							end
							else begin
								`DRIV_IF.mem_rdata <= {trans.mem_rdata[31:21],1'b0,trans.mem_rdata[19:0]};
								if(driver_regs[trans.mem_rdata[19:15]][1]+trans.mem_rdata[21]) begin
									if(trans.mem_rdata[14]) 
										driver_rd_data.push_back($unsigned(driver_load_instr[31:16]));
									else
										driver_rd_data.push_back($signed(driver_load_instr[31:16]));
								end
								else begin
									if(trans.mem_rdata[14])
										driver_rd_data.push_back($unsigned(driver_load_instr[15:0]));
									else
										driver_rd_data.push_back($signed(driver_load_instr[15:0]));
								end
							end
						end
						else begin //lb and lbu
						
							`DRIV_IF.mem_rdata <= trans.mem_rdata;
							sel_byte=trans.mem_rdata[21:20]+driver_regs[trans.mem_rdata[19:15]][1:0];
							case (sel_byte[1:0])
							2'b00 : begin
								if(trans.mem_rdata[14])
									driver_rd_data.push_back($unsigned(driver_load_instr[7:0]));
								else
									driver_rd_data.push_back($signed(driver_load_instr[7:0]));					
							end
					
							2'b01 : begin
								if(trans.mem_rdata[14])
									driver_rd_data.push_back($unsigned(driver_load_instr[15:8]));
								else
									driver_rd_data.push_back($signed(driver_load_instr[15:8]));					
							end
							2'b10 : begin
								if(trans.mem_rdata[14])
									driver_rd_data.push_back($unsigned(driver_load_instr[23:16]));
								else
									driver_rd_data.push_back($signed(driver_load_instr[23:16]));					
							end
							2'b11 : begin
								if(trans.mem_rdata[14])
									driver_rd_data.push_back($unsigned(driver_load_instr[31:24]));
								else
									driver_rd_data.push_back($signed(driver_load_instr[31:24]));					
							end							
							endcase
						end
						driver_rd_addr.push_back(trans.mem_rdata[11:7]);
						driver_load_data.push_back(driver_load_instr);

					end
					else begin
						
							Branch_taken=0;
						`DRIV_IF.mem_rdata <= trans.mem_rdata;
					end	
								//	driver_regs[trans.mem_rdata[11:7]]=driver_load_instr;

				
				end
				
				7'b0100011 : begin
					//environment::update_scb_regs();
					// =environment::env_regs;
								// 	driver_load_instr=$random; 
					if(! Branch_taken) 	begin	
			
								
						if(driver_rd_addr.size()!=0 && driver_rd_data.size()!=0 && trans.mem_rdata[19:15]==driver_rd_addr[0]) begin
							driver_regs[trans.mem_rdata[19:15]]=driver_rd_data[0];
							driver_regs[0]=32'b0;
						end
						if(trans.mem_rdata[13])  begin //sw
							case (driver_regs[trans.mem_rdata[19:15]][1:0])
								2'b00 : `DRIV_IF.mem_rdata <= trans.mem_rdata;
								2'b01 : `DRIV_IF.mem_rdata <= {trans.mem_rdata[31:9],2'b11,trans.mem_rdata[6:0]};					
								2'b10 : `DRIV_IF.mem_rdata <= {trans.mem_rdata[31:9],2'b10,trans.mem_rdata[6:0]};					
								2'b11 : `DRIV_IF.mem_rdata <= {trans.mem_rdata[31:9],2'b01,trans.mem_rdata[6:0]};					
							endcase
						end
						else if(trans.mem_rdata[12]) begin //sh
							if(driver_regs[trans.mem_rdata[19:15]][0])
								`DRIV_IF.mem_rdata <= {trans.mem_rdata[31:8],1'b1,trans.mem_rdata[6:0]};	
							else
								`DRIV_IF.mem_rdata <= trans.mem_rdata;
							
						end
						else
						`DRIV_IF.mem_rdata <= trans.mem_rdata;
					end
					else
						Branch_taken=0;
				
				end
				
				default:   begin 
					`DRIV_IF.mem_rdata <= trans.mem_rdata;
							Branch_taken=0;

				end
				endcase
				
				
			end
			else	begin
				if(! (|`DRIV_IF.mem_wstrb)) begin
				driver_rd_addr.pop_front();
				driver_rd_data.pop_front();
				`DRIV_IF.mem_rdata <= driver_load_data.pop_front();
				end
			end

				
 			@(posedge intf.tb.cb);
`DRIV_IF.mem_ready <=0; 
				      no_transactions++;

		end
		      

        //`DRIV_IF.mem_rdata <= trans.mem_rdata;
    
 //     $display("-----------------------------------------");
    end
  endtask
          
endclass