// -----------------------------------------------------------------------------
// Copyright (c) 2014-2024 All rights reserved
// -----------------------------------------------------------------------------
// Author : Huang Xiaochong huangxc@stu.pku.edu.cn
// File   : register.v
// Create : 2024-02-23 22:30:33
// Revise : 2024-02-23 22:30:33
// Editor : sublime text4, tab size (4)
// -----------------------------------------------------------------------------
/* Description:
	instruction register
*/
// Version: 0.1
// -----------------------------------------------------------------------------
module register (
	input clk,    // Clock
	input rst,  // Asynchronous reset active high
	
	input [7:0] data,
	input 		ena ,

	output reg [15:0] opc_iraddr
);
	reg state ;

	// If load_ir from machine actived, load instruction data from rom in 2 clock periods.
    // Load high 8 bits first, and then low 8 bits.

	always @(posedge clk) begin : proc_opc_iraddr
		if(rst) begin
			opc_iraddr <= 16'b 0000_0000_0000_0000;
			state      <= 1'b0 ;
		end else if (ena) begin
			case (state)
				1'b0 : begin
					opc_iraddr[15:8] <= data ;
					state			 <= 1'b1 	 ;
				end
				1'b1 : begin
					opc_iraddr[7:0] <= data ;
					state			<= 1'b0 	;
				end
				default : begin 
					opc_iraddr [ 15 : 0 ] <= 16'bxxxx_xxxx_xxxx_xxxx; 
					state <= 1'bx; 
				end
			endcase
		end else begin
			state <= 1'b0 ;
		end
	end

endmodule