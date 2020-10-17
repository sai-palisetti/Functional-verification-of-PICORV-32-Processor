`define MON_IF mon_intf.monitor.monitor_cb
class monitor;
     virtual pico_interface.monitor mon_intf;
	  typedef mailbox #(transaction) mail_gen;

     mail_gen mon2scb;
	 logic [31:0] prev_mem_rdata;
     function new(virtual pico_interface mon_intf,mailbox mon2scb);
       this.mon_intf = mon_intf;
       this.mon2scb = mon2scb;
     endfunction
	 
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
	 @(negedge `MON_IF.mem_valid);
	  /* if(prev_mem_rdata[6:0]==7'b0110011 && prev_mem_rdata[14:12] ==3'b101 && prev_mem_rdata[31:25] == 7'b0000000) begin
	     repeat(5) @(posedge `MON_IF) ;
	      trans.decode_rd = `MON_IF.decode_rd;
		  mon2scb.put(trans);
		  end
	   else if(prev_mem_rdata[6:0]==7'b0110011 && prev_mem_rdata[14:12] ==3'b101 && prev_mem_rdata[31:25] == 7'b0100000) begin
	     repeat(8) @(posedge `MON_IF) ;
		  trans.decode_rd = `MON_IF.decode_rd;
		  mon2scb.put(trans);
		  end
	  else if(prev_mem_rdata[6:0]==7'b0110011 && prev_mem_rdata[14:12] ==3'b001) begin
	     repeat(10) @(posedge `MON_IF) ;
		  trans.decode_rd = `MON_IF.decode_rd;
		  mon2scb.put(trans);
		  end
		 
	   /* if(trans.mem_rdata[6:0]==7'b0110011 && trans.mem_rdata[14:12] ==3'b101 && trans.mem_rdata[31:25] == 7'b0000000) begin
		  trans.decode_rd = `MON_IF.decode_rd;
		  mon2scb.put(trans);
	    repeat(8) @(posedge `MON_IF) ;
		$display($time);
		trans.mem_valid = `MON_IF.mem_valid;
	    trans.mem_instr = `MON_IF.mem_instr;
	    trans.mem_ready = `MON_IF.mem_ready;
	    trans.mem_addr = `MON_IF.mem_addr;
	    trans.mem_wdata = `MON_IF.mem_wdata;
	    trans.mem_rdata = `MON_IF.mem_rdata;
		trans.decode_rd = `MON_IF.decode_rd;
                   mon2scb.put(trans);
				   
	   end
	    else if(trans.mem_rdata[6:0]==7'b0110011 && trans.mem_rdata[14:12] ==3'b001) begin
		  trans.decode_rd = `MON_IF.decode_rd;
		  mon2scb.put(trans);
	    repeat(14)  @(posedge `MON_IF) ;
		$display($time);
		trans.mem_valid = `MON_IF.mem_valid;
	    trans.mem_instr = `MON_IF.mem_instr;
	    trans.mem_ready = `MON_IF.mem_ready;
	    trans.mem_addr = `MON_IF.mem_addr;
	    trans.mem_wdata = `MON_IF.mem_wdata;
	    trans.mem_rdata = `MON_IF.mem_rdata;
		trans.decode_rd = `MON_IF.decode_rd;
                   mon2scb.put(trans);
				   
	   end
	    else if(trans.mem_rdata[6:0]==7'b0110011 && trans.mem_rdata[14:12] ==3'b101 && trans.mem_rdata[31:25] == 7'b0100000) begin
		  trans.decode_rd = `MON_IF.decode_rd;
		  mon2scb.put(trans);
	    repeat(28)  @(posedge `MON_IF) ;
		$display($time);
		trans.mem_valid = `MON_IF.mem_valid;
	    trans.mem_instr = `MON_IF.mem_instr;
	    trans.mem_ready = `MON_IF.mem_ready;
	    trans.mem_addr = `MON_IF.mem_addr;
	    trans.mem_wdata = `MON_IF.mem_wdata;
	    trans.mem_rdata = `MON_IF.mem_rdata;
		trans.decode_rd = `MON_IF.decode_rd;
                   mon2scb.put(trans);
				   
	   end  */
	   //else begin
		 trans.decode_rd = `MON_IF.decode_rd;
		   mon2scb.put(trans);
       //end	 

      //prev_mem_rdata=trans.mem_rdata;	   
	  	
	 
										  
     end
    endtask
   
endclass