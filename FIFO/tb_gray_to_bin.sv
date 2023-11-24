
`timescale 1ns/1ps
module tb_gray_to_bin (); /* this is automatically generated */

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

	logic [SIZE - 1 : 0] gray;
	logic [SIZE - 1 : 0] bin;

	gray_to_bin #(.SIZE(SIZE)) inst_gray_to_bin (.gray(gray), .bin(bin));

	task init();
		gray <= '0;
	endtask

	task drive(int iter);
		for(int it = 0; it < iter; it++) begin
			gray <= it;
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
			$fsdbDumpfile("tb_gray_to_bin.fsdb");
			$fsdbDumpvars(0, "tb_gray_to_bin");
		end
	end
endmodule
