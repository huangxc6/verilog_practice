
`timescale 1ns/1ps
module tb_handshake_sync ();

	// clock
	logic clk_fast;
	initial begin
		clk_fast = '0;
		forever #(5) clk_fast = ~clk_fast;
	end

	logic clk_slow;
	initial begin
		clk_slow = '0;
		#2
		clk_slow = '1;
		forever #(20) clk_slow = ~clk_slow;
	end

	// asynchronous reset
	logic rst_n;
	initial begin
		rst_n <= '0;
		#10
		rst_n <= '1;
	end

	// (*NOTE*) replace reset, clock, others
	parameter PULSE_INIT = 1'b0;

	logic       din_en;
	logic [7:0] din;
	logic       ack_r;
	logic       dout_en;
	logic       dout;

	handshake_sync #(
			.PULSE_INIT(PULSE_INIT)
		) inst_handshake_sync (
			.rstf_n   (rst_n),
			.rsts_n   (rst_n),
			.clk_fast (clk_fast),
			.din_en   (din_en),
			.din      (din),
			.ack_r    (ack_r),
			.clk_slow (clk_slow),
			.dout_en  (dout_en),
			.dout     (dout)
		);

	task init();
		din_en   <= '0;
		din      <= '0;
	endtask

	task drive(int iter);
		for(int it = 0; it < iter; it++) begin
			din_en   <= $random();
			din      <= $random();
			@(posedge clk_fast)
			din_en   <= '0 ;
			repeat(12)@(posedge clk_fast);
		end
	endtask

	initial begin
		// do something

		init();
		repeat(10)@(posedge clk_fast);

		drive(20);

		repeat(10)@(posedge clk_fast);
		$finish;
	end
	// dump wave
	initial begin
		$display("random seed : %0d", $unsigned($get_initial_random_seed()));
		if ( $test$plusargs("fsdb") ) begin
			$fsdbDumpfile("tb_handshake_sync.fsdb");
			$fsdbDumpvars(0, "tb_handshake_sync");
		end
	end
endmodule
