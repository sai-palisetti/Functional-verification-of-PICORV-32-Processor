class environment;
   
  generator gen;
  driver    driv;
   monitor    mon;
  scoreboard scb;
  
  
   event gen_ended;
   
 typedef mailbox #(transaction) mail_gen;
 mail_gen gen2driv;   
 mail_gen mon2scb;
     virtual pico_interface intf;
	// virtual pico_interface.monitor mon_intf;
   
  function new( virtual pico_interface intf);
    this.intf = intf;
	//this.mon_intf = intf;
     
    gen2driv = new();
    mon2scb = new(); 
    gen  = new(gen2driv,gen_ended);
    driv = new(intf,gen2driv);
	mon  = new(intf,mon2scb);
    scb  = new(mon2scb);
  endfunction
   
  //
  task pre_test();
    driv.reset();
  endtask
   
  task test();
    fork
    gen.main();
    driv.main();
	mon.main();
    scb.main(); 
    join_any
  endtask
   
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
    $finish;
  endtask
   
endclass