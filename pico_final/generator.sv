class generator;

  rand transaction trans; //declaring transaction class
   
  typedef mailbox #(transaction) mail_gen;
  
 mail_gen gen2driv;  //declaring generator to driver mailbox
 
  int  repeat_count; //repeat count, to specify number of items to generate
  
  event ended; //Adding an event to indicate the completion of the generation process
  
  function new(mailbox gen2driv,event ended);
    this.gen2driv = gen2driv; // getting the mailbox handle from environment
    this.ended    = ended;
  endfunction
  
   //main task, generates(create and randomizes) the repeat_count number of transaction packets and puts into mailbox
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


