`timescale 1 ns / 1 ps

module test_top;
   
  bit clk=0;
  bit reset=0;
  always #5 clk = ~clk;

  initial begin
 
   if ($test$plusargs("vcd")) begin
			$dumpfile("testbench.vcd");
			$dumpvars(0, test_top);
		end
		repeat (10) @(posedge clk);
		reset <= 1;
		//repeat (1000) @(posedge clk);
  end
   
  pico_interface intf(clk,reset);
   
  test_layer t1(intf);
   
 picorv32 #(
	) uut (
		.clk         (intf.clk        ),
		.resetn      (intf.reset     ),
		.trap        (intf.trap       ),
		.mem_valid   (intf.mem_valid  ),
		.mem_instr   (intf.mem_instr  ),
		.mem_ready   (intf.mem_ready  ),
		.mem_addr    (intf.mem_addr   ),
		.mem_wdata   (intf.mem_wdata  ),
		.mem_wstrb   (intf.mem_wstrb  ),
		.mem_rdata   (intf.mem_rdata  )

	);
   
  //enabling the wave dump
  initial begin
    $dumpfile("dump.vcd"); $dumpvars;
  end
endmodule