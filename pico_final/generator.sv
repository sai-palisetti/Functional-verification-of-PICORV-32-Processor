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
  
  task main();
  repeat(repeat_count/2) begin
      trans = new("transact");
	  	  trans.valid_instr_reg_imm.constraint_mode(0);

	  	  trans.valid_instr_load_store_branch_jump_ui.constraint_mode(1);
      if( !trans.randomize() ) $display("Gen:: trans randomization failed");   
      gen2driv.put(trans);
	trans.print();
    end
    repeat(repeat_count/2) begin
      trans = new("transact");
	  	  trans.valid_instr_load_store_branch_jump_ui.constraint_mode(0);

	  	  trans.valid_instr_reg_imm.constraint_mode(1);
 
      if( !trans.randomize() ) $display("Gen:: trans randomization failed");   
      gen2driv.put(trans);
	trans.print();
    end
   -> ended;
  endtask 
endclass


