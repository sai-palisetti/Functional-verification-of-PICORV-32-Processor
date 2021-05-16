`define MON_IF mon_intf.monitor.monitor_cb
class monitor;
     virtual pico_interface.monitor mon_intf; //creating virtual interface handle
	  typedef mailbox #(transaction) mail_gen;

     mail_gen mon2scb;  //creating mailbox handle
     function new(virtual pico_interface mon_intf,mailbox mon2scb);
    this.mon_intf = mon_intf; //getting the interface
    this.mon2scb = mon2scb;  //getting the mailbox handles from  environment
  endfunction
  
  //Samples the interface signal and send the sample packet to scoreboard
     task main;
    forever begin
      transaction trans;
      trans = new();
 
      @(posedge `MON_IF.mem_ready);
     trans.mem_valid = `MON_IF.mem_valid;
	 trans.mem_instr = `MON_IF.mem_instr;
	 trans.mem_ready = `MON_IF.mem_ready;
	 trans.mem_addr = `MON_IF.mem_addr;
	 trans.mem_wdata = `MON_IF.mem_wdata;
	 trans.mem_rdata = `MON_IF.mem_rdata;
     @(negedge `MON_IF.mem_ready);
	 trans.decode_rd = `MON_IF.decode_rd;

     mon2scb.put(trans);
    end
  endtask
   
endclass