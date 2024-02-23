module accum (
	input clk,    // Clock
	input rst,    // Asynchronous reset active high
	input ena,
	input [7:0] data,

	output reg [7:0] accum
);
	always @(posedge clk) begin : proc_accum
		if(rst) begin
			accum <= 8'b0000_0000;
		end else begin
			accum <= data;
		end
	end

endmodule