
`timescale 1ns/1ps
module tb_bin_to_gray (); /* this is automatically generated */

	// clock
	logic clk;
	initial begin
		clk = '0;
		forever #(0.5) clk = ~clk;
	end

	// synchronous reset
	logic srstb;
	initial begin
		srstb <= '0;
		repeat(10)@(posedge clk);
		srstb <= '1;
	end

	// (*NOTE*) replace reset, clock, others
	parameter SIZE = 4;

	logic [SIZE-1 : 0] bin;
	logic [SIZE-1 : 0] gray;

	bin_to_gray #(.SIZE(SIZE)) inst_bin_to_gray (.bin(bin), .gray(gray));

	task init();
		bin <= '0;
	endtask

	task drive(int iter);
		for(int it = 0; it < iter; it++) begin
			bin <= it;
			@(posedge clk);
		end
	endtask

	initial begin
		// do something

		init();
		repeat(10)@(posedge clk);

		drive(20);

		repeat(10)@(posedge clk);
		$finish;
	end
	// dump wave
	initial begin
		$display("random seed : %0d", $unsigned($get_initial_random_seed()));
		if ( $test$plusargs("fsdb") ) begin
			$fsdbDumpfile("tb_bin_to_gray.fsdb");
			$fsdbDumpvars(0, "tb_bin_to_gray");
		end
	end
endmodule
