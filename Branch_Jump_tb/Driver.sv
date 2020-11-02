`define DRIV_IF intf.tb.cb

//`DRIV_IF will point to intf.DRIVER.driver_cb

class driver;
     int no_transactions;
     virtual pico_interface.tb intf;
	typedef mailbox #(transaction) mail_gen;
	mail_gen gen2driv;   
  function new(virtual pico_interface intf,mailbox gen2driv);
    this.intf = intf;
    this.gen2driv = gen2driv;
  endfunction
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


			
				`DRIV_IF.mem_rdata <= trans.mem_rdata;

				
 			@(posedge intf.tb.cb);
`DRIV_IF.mem_ready <=0; 
				      no_transactions++;

		end
		      

        //`DRIV_IF.mem_rdata <= trans.mem_rdata;
    
 //     $display("-----------------------------------------");
    end
  endtask
          
endclass