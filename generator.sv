class generator;
   
  rand transaction trans;
   
  typedef mailbox #(transaction) mail_gen;
 mail_gen gen2driv;
  int  repeat_count; 
  event ended;
  
  function new(mailbox gen2driv,event ended);
    this.gen2driv = gen2driv;
    this.ended    = ended;
  endfunction
  
  task load_reg();
   repeat(31) begin
      trans = new("transact");
	  trans.valid_instr.constraint_mode(0);
      if( !trans.randomize() ) $display("Gen:: trans randomization failed");   
      gen2driv.put(trans);
	trans.print();
    end
  endtask
   
  task main();
 
    repeat(repeat_count) begin
      trans = new("transact");
	  trans.valid_instr.constraint_mode(1);
	  trans.load_reg.constraint_mode(0);
      if( !trans.randomize() ) $display("Gen:: trans randomization failed");   
      gen2driv.put(trans);
	trans.print();
    end
   -> ended;
  endtask 
endclass

