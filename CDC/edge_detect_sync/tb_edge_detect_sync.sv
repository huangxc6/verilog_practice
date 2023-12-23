
`timescale 1ns/1ps
module tb_edge_detect_sync ();

	// clock
	logic clk_fast;
	initial begin
		clk_fast = '0;
		forever #(0.5) clk_fast = ~clk_fast;
	end

	logic clk_slow;
	initial begin
		clk_slow = '0;
		forever #(1.2) clk_slow = ~clk_slow;
	end

	// asynchronous reset
	logic rst_n;
	initial begin
		rst_n <= '0;
		#10
		rst_n <= '1;
	end

	// (*NOTE*) replace reset, clock, others
	logic  din_en;
	logic  dout_en;

	edge_detect_sync inst_edge_detect_sync
		(
			.clk_slow (clk_slow),
			.clk_fast (clk_fast),
			.rst_n    (rst_n),
			.din_en   (din_en),
			.dout_en  (dout_en)
		);

	task init();
		din_en   <= '0;
	endtask

	task drive(int iter);
		for(int it = 0; it < iter; it++) begin
			din_en   <= $random();
			@(posedge clk_slow);
			din_en   <= '0;
			repeat(4)@(posedge clk_slow);
		end
	endtask

	initial begin
		// do something

		init();
		repeat(10)@(posedge clk_slow);

		drive(20);

		repeat(10)@(posedge clk_slow);
		$finish;
	end
	// dump wave
	initial begin
		$display("random seed : %0d", $unsigned($get_initial_random_seed()));
		if ( $test$plusargs("fsdb") ) begin
			$fsdbDumpfile("tb_edge_detect_sync.fsdb");
			$fsdbDumpvars(0, "tb_edge_detect_sync");
		end
	end
endmodule
