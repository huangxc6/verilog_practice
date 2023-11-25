
`timescale 1ns/1ps
module tb_gray_counter (); /* this is automatically generated */

	// clock
	logic clk;
	initial begin
		clk = '0;
		forever #(0.5) clk = ~clk;
	end

	// asynchronous reset
	logic rst_n;
	initial begin
		rst_n <= '0;
		#10
		rst_n <= '1;
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

	logic                inr;
	logic [SIZE - 1 : 0] gray;

	gray_counter #(.SIZE(SIZE)) inst_gray_counter (.clk(clk), .rst_n(rst_n), .inr(inr), .gray(gray));

	task init();
		inr   <= '0;
	endtask

	task drive(int iter);
		for(int it = 0; it < iter; it++) begin
			inr   <= $urandom_range(0,1);
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
			$fsdbDumpfile("tb_gray_counter.fsdb");
			$fsdbDumpvars(0, "tb_gray_counter");
		end
	end
endmodule
