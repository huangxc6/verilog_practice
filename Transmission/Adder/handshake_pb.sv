module handshake_fifo #(
    parameter DATA_WIDTH = 32
)(
    input wire clk,
    input wire rst,
    input wire i_vld,
    input wire i_rdy,
    input wire [DATA_WIDTH-1:0] i_a,
    input wire [DATA_WIDTH-1:0] i_b,
    input wire [DATA_WIDTH-1:0] i_c,
    input wire [DATA_WIDTH-1:0] i_d,
    input wire [DATA_WIDTH-1:0] i_e,
    input wire [DATA_WIDTH-1:0] i_f,
    output logic [DATA_WIDTH-1:0] o_dout,
    output logic o_vld,
    output logic o_rdy
);
    reg  vld_r1;
    wire rdy_r1;
    reg  vld_r2;
    wire rdy_r2;
    reg  vld_r3;
    wire rdy_r3;
    reg [DATA_WIDTH-1:0] r1_ab;
    reg [DATA_WIDTH-1:0] r1_cd;
    reg [DATA_WIDTH-1:0] r1_ef;
    reg [DATA_WIDTH-1:0] r2_abcd;
    reg [DATA_WIDTH-1:0] r2_ef;
    reg [DATA_WIDTH-1:0] r3;

    assign o_rdy = ~vld_r1 || rdy_r1;

    always_ff @(posedge clk) begin
        if (rst) begin
            vld_r1 <= 1'b0;
        end else if (o_rdy) begin
            vld_r1 <= i_vld;
        end
    end

    always_ff @( posedge clk ) begin
        if (o_rdy && i_vld) begin
            r1_ab <= i_a + i_b;
            r1_cd <= i_c + i_d;
            r1_ef <= i_e + i_f;
        end
    end

    assign rdy_r1 = ~vld_r2 || rdy_r2;

    always_ff @(posedge clk) begin
        if (rst) begin
            vld_r2 <= 1'b0;
        end else if (rdy_r1) begin
            vld_r2 <= vld_r1;
        end
    end

    always_ff @( posedge clk ) begin
        if (rdy_r1 && vld_r1) begin
            r2_abcd <= r1_ab + r1_cd;
            r2_ef <= r1_ef;
        end
    end

    assign rdy_r2 = ~vld_r3 || rdy_r3;

    always_ff @(posedge clk) begin
        if (rst) begin
            vld_r3 <= 1'b0;
        end else if (rdy_r2) begin
            vld_r3 <= vld_r2;
        end
    end

    always_ff @( posedge clk ) begin
        if (rdy_r2 && vld_r2) begin
            r3 <= r2_abcd + r2_ef;
        end
    end

    assign o_vld = vld_r3;
    assign o_dout = r3;

endmodule