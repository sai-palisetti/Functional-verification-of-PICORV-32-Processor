class environment;
   //generator, driver, monitor and scoreboard instances
  generator gen;
  driver    driv;
   monitor    mon;
  scoreboard scb;
  static logic [31:0] env_regs[0:31];

  
   event gen_ended; //event for synchronization between generator and test_layered
   
 typedef mailbox #(transaction) mail_gen;
 mail_gen gen2driv;    //gen2driv mailbox handle's
 mail_gen mon2scb;   //mon2scb mailbox handle's
     virtual pico_interface intf; // virtual pico_interface.monitor mon_intf;
	
   
  function new( virtual pico_interface intf);
    this.intf = intf;  //get the interface from test_layered
	//this.mon_intf = intf;
     
    gen2driv = new(); //creating the mailbox (Same handle will be shared across generator and driver)
    mon2scb = new();  //creating the mailbox (Same handle will be shared across monitor and scoreboard)
    gen  = new(gen2driv,gen_ended); //creating generator
    driv = new(intf,gen2driv);  //creating driver
	mon  = new(intf,mon2scb);  //creating monitor
    scb  = new(mon2scb);       //creating scoreboard
  endfunction
   
  /*  static task update_scb_regs();
   
		env_regs=scb.scoreboard_regs;
   
   endtask */
   
  //pre_test() – Method to call Initialization. i.e, reset method.
  task pre_test();
    driv.reset();
  endtask
  
//test() – Method to call Stimulus Generation and Stimulus Driving  
  task test();
    fork
    gen.main();
    driv.main();
	mon.main();
    scb.main(); 
    join_any
  endtask
 
//post_test() – Method to wait the completion of generation and driving. 
  task post_test();
    wait(gen.ended.triggered);
    wait(gen.repeat_count == driv.no_transactions);
	wait(gen.repeat_count <= scb.no_transactions+3);

  endtask 
   
  //run task
  task run;
    pre_test();
    test();
    post_test();
	$display("coverage= %0.2f",scb.cg.get_inst_coverage());
    $finish;
  endtask
   
endclass