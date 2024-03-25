
`timescale 1ns/1ps
module tb_ready_sync (); /* this is automatically generated */

	// clock
	logic clk2;
	initial begin
		clk2 = '0;
		forever #(0.5) clk2 = ~clk2;
	end

	// asynchronous reset
	logic rstn2;
	initial begin
		rstn2 <= '0;
		#10
		rstn2 <= '1;
	end

	// (*NOTE*) replace reset, clock, others
	parameter DATA_WIDTH = 8;

	logic                  ready;
	logic [DATA_WIDTH-1:0] data;
	logic [DATA_WIDTH-1:0] data_out;

	ready_sync #(
			.DATA_WIDTH(DATA_WIDTH)
		) inst_ready_sync (
			.clk2     (clk2),
			.rstn2    (rstn2),
			.ready    (ready),
			.data     (data),
			.data_out (data_out)
		);

	task init();
		ready <= '0;
		data  <= '0;
	endtask

	task drive(int iter);
		for(int it = 0; it < iter; it++) begin
			ready <= $random();
			data  <= $random();
			repeat(10)@(posedge clk2);
			ready <= '0 ;
			data  <= 'x ;
			repeat(5)@(posedge clk2);
		end
	endtask

	initial begin
		// do something

		init();
		repeat(10)@(posedge clk2);

		drive(20);

		repeat(10)@(posedge clk2);
		$finish;
	end
	// dump wave
	initial begin
		$display("random seed : %0d", $unsigned($get_initial_random_seed()));
		if ( $test$plusargs("fsdb") ) begin
			$fsdbDumpfile("tb_ready_sync.fsdb");
			$fsdbDumpvars(0, "tb_ready_sync");
		end
	end
endmodule
