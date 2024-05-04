module handshake_fifo #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 8
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
    localparam WATERLINE = ADDR_WIDTH - 3;
    logic handshake;
    logic handshake_ff1;
    logic handshake_ff2;
    logic wr_en;

    assign handshake = i_vld & o_rdy;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            handshake_ff1 <= 1'b0;
            handshake_ff2 <= 1'b0;
        end else begin
            handshake_ff1 <= handshake;
            handshake_ff2 <= handshake_ff1;
        end
    end

    reg [DATA_WIDTH-1:0] r1_ab;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            r1_ab <= '0;
        end else if (handshake) begin
            r1_ab <= i_a + i_b;
        end 
    end

    reg [DATA_WIDTH-1:0] r1_cd;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            r1_cd <= '0;
        end else if (handshake) begin
            r1_cd <= i_c + i_d;
        end 
    end

    reg [DATA_WIDTH-1:0] r1_ef;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            r1_ef <= '0;
        end else if (handshake) begin
            r1_ef <= i_e + i_f;
        end 
    end

    reg [DATA_WIDTH-1:0] r2_abcd;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            r2_abcd <= '0;
        end else if (handshake_ff1) begin
            r2_abcd <= r1_ab + r1_cd;
        end 
    end

    reg [DATA_WIDTH-1:0] r2_ef;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            r2_ef <= '0;
        end else if (handshake_ff1) begin
            r2_ef <= r1_ef;
        end 
    end

    reg [DATA_WIDTH-1:0] r3;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            r3 <= '0;
        end else if (handshake_ff2) begin
            r3 <= r2_abcd + r2_ef;
        end 
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            wr_en <= 1'b0;
        end else if (handshake_ff2) begin
            wr_en <= 1'b1;
        end else begin
            wr_en <= 1'b0;
        end
    end

    // usedw;
    reg [ADDR_WIDTH-1:0] usedw;
    wire empty;

    always_ff @(posedge clk) begin
        if (rst) begin
            o_rdy <= 1'b0;
        end else if (usedw > WATERLINE) begin
            o_rdy <= 1'b0;
        end else begin
            o_rdy <= 1'b1;
        end
    end

    assign o_vld = ~empty;

    sync_fifo #(
        .MEM_TYPE("auto"),
        .READ_MODE("fwft"),
        .WIDTH(DATA_WIDTH),
        .DEPTH(ADDR_WIDTH)
    ) u_sync_fifo (
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en),
        .din(r3),
        .rd_en(i_rdy),
        .dout(o_dout),
        .empty(empty),
        .usedw(usedw)
    );
    
endmodule