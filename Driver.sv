`define DRIV_IF intf.cb

//`DRIV_IF will point to intf.DRIVER.driver_cb

class driver;
     int no_transactions;
     virtual pico_interface.tb intf;
	typedef mailbox #(transaction) mail_gen;
	mail_gen gen2driv;   
  function new(virtual pico_interface.tb intf,mailbox gen2driv);
    this.intf = intf;
    this.gen2driv = gen2driv;
  endfunction
  
  task reset;
    wait(!intf.reset);
    $display("--------- [DRIVER] Reset Started ---------");
     `DRIV_IF.mem_ready <=0; 
    wait(intf.reset);
	repeat(3) @(posedge intf.cb);

    $display("--------- [DRIVER] Reset Ended---------");
	
  endtask
   
  //drive the transaction items to interface signals
  task main;
    forever begin
	  @(posedge intf.cb);
		if (`DRIV_IF.mem_valid) begin

      transaction trans;
      gen2driv.get(trans);
	 `DRIV_IF.mem_ready <=1; 
	 
      $display("--------- [DRIVER-TRANSFER: %0d] ---------",no_transactions);


			
				`DRIV_IF.mem_rdata <= trans.mem_rdata;

				
 			@(posedge intf.cb);
            `DRIV_IF.mem_ready <=0; 
			no_transactions++;	     

		end
		      

        //`DRIV_IF.mem_rdata <= trans.mem_rdata;
    
      $display("-----------------------------------------");
	   
    end
  endtask
          
endclass