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
 
    repeat(repeat_count) begin
      trans = new("transact");
      if( !trans.randomize() ) $display("Gen:: trans randomization failed");   
      gen2driv.put(trans);
	trans.print();
    end
   -> ended;
  endtask 
endclass

module test;

generator g1;
typedef mailbox #(transaction) mail_gen;
  mail_gen gen2driv;
  event ended;
initial begin
gen2driv=new;
g1 = new(gen2driv,ended); 
g1.repeat_count=10;
run;
get;
end

task run;
g1.main;
@(ended);
$display("Generation Ended");
endtask

task get;

@(ended);
$display("Generation Ended");
endtask
endmodule