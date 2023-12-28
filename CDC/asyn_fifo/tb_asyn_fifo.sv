
`timescale 1ns/1ps
module tb_asyn_fifo (); /* this is automatically generated */

	// clock
	logic wclk;
	initial begin
		wclk = '0;
		forever #(0.5) wclk = ~wclk;
	end

	logic rclk;
	initial begin
		rclk = '0;
		forever #(1.2) rclk = ~rclk;
	end

	// asynchronous reset
	logic rst_n;
	initial begin
		rst_n <= '0;
		#10
		rst_n <= '1;
	end

	// (*NOTE*) replace reset, clock, others
	parameter         DW = 16;
	parameter      DEPTH = 32;
	parameter PROG_DEPTH = 16;
	localparam        AW = $clog2(DEPTH);

	logic          wren;
	logic [DW-1:0] wdata;
	logic          wfull;
	logic          prog_full;
	logic          rden;
	logic [DW-1:0] rdata;
	logic          rempty;

	asyn_fifo #(
			.DW(DW),
			.DEPTH(DEPTH),
			.PROG_DEPTH(PROG_DEPTH)
		) inst_asyn_fifo (
			.rst_n     (rst_n),
			.wclk      (wclk),
			.wren      (wren),
			.wdata     (wdata),
			.wfull     (wfull),
			.prog_full (prog_full),
			.rclk      (rclk),
			.rden      (rden),
			.rdata     (rdata),
			.rempty    (rempty)
		);

	task init();
		wren  <= '0;
		wdata <= '0;
		rden  <= '0;
	endtask

	task write(int iter);
		for(int it = 0; it < iter; it++) begin
			wren  <= '1;
			wdata <= $random();
			@(posedge wclk);
		end
		wren  <= '0;
	endtask

	task read(int iter);
		for(int it = 0; it < iter; it++) begin
			rden  <= '1;
			@(posedge rclk);
		end
			rden  <= '0;
	endtask

	task write_read(int iter);
		for(int it = 0; it < iter; it++) begin
			wren  <= '1;
			rden  <= '1;
			wdata <= $random();
			@(posedge wclk);
		end
			wren  <= '0;
			rden  <= '0;
	endtask

	initial begin
		// do something

		init();
		repeat(10)@(posedge wclk);

		write(36);
		read(36) ;
		write_read(36);

		repeat(10)@(posedge wclk);
		$finish;
	end
	// dump wave
	initial begin
		$display("random seed : %0d", $unsigned($get_initial_random_seed()));
		if ( $test$plusargs("fsdb") ) begin
			$fsdbDumpfile("tb_asyn_fifo.fsdb");
			$fsdbDumpvars(0, "tb_asyn_fifo");
			$fsdbDumpMDA();
		end
	end
endmodule
