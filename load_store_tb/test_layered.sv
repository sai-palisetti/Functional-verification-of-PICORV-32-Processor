program test_layer(pico_interface intf);
   
  //declaring environment instance
  environment env;
   
  initial begin
    //creating environment
    env = new(intf);
     
    //setting the repeat count of generator as 10, means to generate 10 packets
    env.gen.repeat_count = 200;
     
    //calling run of env, it interns calls generator and driver main tasks.
    env.run();
  end
endprogram