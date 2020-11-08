`define DRIV_IF intf.tb.cb

//`DRIV_IF will point to intf.DRIVER.driver_cb

class driver;
     int no_transactions;
	 rand bit [31:0]driver_load_instr;
     virtual pico_interface.tb intf;
	typedef mailbox #(transaction) mail_gen;
	mail_gen gen2driv;   
  function new(virtual pico_interface intf,mailbox gen2driv);
    this.intf = intf;
    this.gen2driv = gen2driv;
  endfunction
  
  /* 	constraint valid_load_insr{
		driver_load_instr[1:0] inside {2'b00};
		driver_load_addr[17:16] inside {2'b00};
	} */
	
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
 //     $display("--------- [DRIVER-TRANSFER: %0d] ---------",no_transactions);

			if(`DRIV_IF.mem_instr)			
				`DRIV_IF.mem_rdata <= trans.mem_rdata;
			//else
			//	`DRIV_IF.mem_rdata <= {trans.mem_rdata[31:17],1'b0,trans.mem_rdata[15:1],1'b0};
			else	begin
				driver_load_instr=$random; 
				`DRIV_IF.mem_rdata <= {driver_load_instr[31:26],2'b00,driver_load_instr[23:18],2'b00,driver_load_instr[15:10],2'b00,driver_load_instr[7:2],2'b00};
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