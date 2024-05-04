> ref:
>
> https://zhuanlan.zhihu.com/p/359330607



*前言：在芯片设计或者FPGA设计过程中，流水设计是经常用到的，但是考虑数据安全性，需要与前后级模块进行握手通信，这时候就需要对流水数据进行反压处理，本文将具体介绍握手与反压。*

**目录**

- **握手协议**

- **握手与反压**

- **反压**

- **带存储体的反压**

- - **字节的问题**
  - **代码分析**
  - **逐级反压与跨级反压**

- **不带存储体的反压**

- - **代码分析**

### **握手协议**

本文讲述valid-ready握手，下面列出三种握手情况，目的是解释清楚握手的时序。

- valid先发起请求

![img](https://pic1.zhimg.com/80/v2-b6e5825d295cd1327c4406681de334e4_720w.webp)

- ready先发起请求

![img](https://pic2.zhimg.com/80/v2-df7b58f89b52d56d6b5eabce820acbd9_720w.webp)

- 同时发起请求

![img](https://pic4.zhimg.com/80/v2-2ad04643ab5f2f7387675d5891a4a4b3_720w.webp)

- 分析

仔细观察上述3幅时序图，我们了解valid-ready握手机制需要注意三件事：

1. valid与ready不可过度依赖，比如valid不可以等待ready到达再拉高，但是在axi协议中的握手信号，ready是可以等待valid拉高再拉高的，valid不可依赖ready的原因是防止死锁（deadlock），本文的代码他俩彼此可以互相独立发出请求拉高；
2. valid拉高时与有效数据同步，时钟要对齐；
3. 当数据计算好后，valid可以拉高等待ready拉高，但是每当握手成功之后，数据需要更新，如果此时没有新的有效数据，valid要拉低。

## 握手与反压

当入口流量大于出口流量，这时候就需要反压，或者，当后级未准备好时，如果本级进行数据传递，那么它就需要反压前级，所以此时前级需要将数据保持不动，直到握手成功才能更新数据。而反压在多级流水线中就变得稍显复杂，原因在于，比如我们采用三级流水设计，如果我们收到后级反压信号，我们理所当然想反压本级输出信号的寄存器，但是如果只反压最后一级寄存器，那么会面临一个问题，就是最后一级寄存器数据会被前两级流水冲毁，导致数据丢失，引出数据安全问题，所以我们此时需要考虑反压设计。

### 反压

常用的反压方法有三种：

- 不带存储体的反压

也就是后级反压信号对本级模块中所有流水寄存器都进行控制，由于不包含存储体，为了保证数据安全性，后级反压信号可以同时反压本模块中所有流水寄存器。

优点：节省面积资源

缺点：寄存器端口控制复杂

适用情况：流水线深度较大时

- 带存储体的逐级反压

如果流水级数不深，可以在每一需要握手交互模块增加存储体，原理上相当于，如果后级发出反压信号，可以直接对本级流水线数据源头进行反压，其余中间级不需控制，但后级需要包含RAM或FIFO等存储体，可以接收流水，并需设置水线（water line)，确定反压时间，防止数据溢出，保证数据安全性。

优点：各级流水寄存器端口控制简单

缺点：需要额外存储体

适用情况：流水线深度较小，每一模块都包含存储体时

- 带存储体的跨级反压

很多时候在具体设计过程中，颗粒度划分不精细，反压这时候是对模块而言，而不是说模块内部有多少级流水。此外，并不是每一模块都带有存储体。比如，其中可能a模块没有存储体，b模块没有存储体，但ab模块内部还有多级流水，如果c模块有存储体，并且需要反压前级模块，这时候可以选择反压a模块的源头输入数据，然后将ab的流水都存储到带有存储体的c模块，但是如果ab不是都没有存储体的话，就不应该跨级反压，而应该逐级反压，具体原因后续会讲。

优点：控制简单方便

缺点：需要额外存储体，模块间耦合度高

适用情况：某些模块带存储体，某些模块不带存储体时

## 带存储体的反压

如上文所述，很多时候我们不喜欢对每一级细分流水都进行反压，所以可以选择带存储体的反压，也就是增加RAM或者FIFO，在反压上级模块的同时，本级有足够的深度来存储上一级的流水数据。具体内容如下图所示：

![img](https://pic1.zhimg.com/80/v2-5ede7588003ef07b2c5a21d245efd624_720w.webp)

此时我们假设车库就是最后一级模块，需要对前一级进行反压，车库是带有存储体的模块，那么此时就需要设计水线waterline，也就是当waterline为多少时开始反压前一级模块（车库入口闸机）。由上图可知，当waterline最大为90时，必须向上一模块发出反压请求，因为在途的还有10辆车，这个就相当于我们设计的10级流水，其中有10级寄存器有流水数据输出，所以车库的剩余容量还可以存储住途中流水，保证了数据安全。

### 举个例子——字节的问题

问题：设计一个并行6输入32比特加法器，输出1个带截断的32比特加法结果，要求用三级流水设计，带前后反压。

主要输入：

1. 6个32bit数据
2. 上一级的valid_i
3. 下一级的ready_i

输出：

1. 1个32bit结果
2. 给上一级的ready_o
3. 给下一级的valid_o

- 分析

其实在多级流水设计中，如果每一级只有一个寄存器，并且都在一个模块中，也就是说当颗粒度划分的很细的时候，一般使用带存储体的反压，比如六级流水，那么就设计好水线，在FIFO未满时提前发出反压信号，一般水线设为FIFO_DEPTH - 流水级数，下面是我设计的代码。

核心思想就是如果FIFO未达到水线（WATERLINE）时，给上一级的反压信号ready_o就持续拉高，否则拉低；FIFO非空时就可以给下一级valid_o拉高，然后下一级的反压信号ready_i可以作为FIFO的读使能信号，具体请参考下文代码。

```systemverilog
//还未仿真，欢迎指出问题
module handshake_fifo #(
    parameter           FIFO_DATA_WIDTH = 32,
    parameter           FIFO_DEPTH = 8
)(
    input  wire         clk,
    input  wire         rst,
    input  wire         valid_i,
    input  wire         ready_i,
    input  wire  [31:0] a,
    input  wire  [31:0] b,
    input  wire  [31:0] c,
    input  wire  [31:0] d,
    input  wire  [31:0] e,
    input  wire  [31:0] f,
    output logic [31:0] dout,
    output logic        ready_o,
    output logic        valid_o
    );
    
    localparam          WATERLINE = FIFO_DEPTH - 3; //three levels' pipeline
    logic               handshake;
    logic               handshake_ff1;
    logic               handshake_ff2;
    logic               wr_en;
        
    assign handshake = ready_o & valid_i;

    always @ (posedge clk or posedge rst) begin
        if(rst) begin
            handshake_ff1 <= '0;
            handshake_ff2 <= '0;
        end
        else begin
            handshake_ff1 <= handshake;
            handshake_ff2 <= handshake_ff1;
        end
    end
    
    reg [31 : 0] r1_ab;
    always @ (posedge clk or posedge rst) begin
        if(rst) begin
            r1_ab <= '0;
        end
        else if(handshake)begin
            r1_ab <= a + b;
        end
    end
    
    reg [31 : 0] r1_cd;
    always @ (posedge clk or posedge rst) begin
        if(rst) begin
            r1_cd <= '0;
        end
        else if(handshake)begin
            r1_cd <= c + d;
        end
    end
    
    reg [31 : 0] r1_ef;
    always @ (posedge clk or posedge rst) begin
        if(rst) begin
            r1_ef <= '0;
        end
        else if(handshake)begin
            r1_ef <= e + f;
        end
    end
    
    reg [31 : 0] r2_abcd;
    always @ (posedge clk or posedge rst) begin
        if(rst) begin
            r2_abcd <= '0;
        end
        else if(handshake_ff1) begin
            r2_abcd <= r1_ab + r1_cd;
        end
    end
    
    reg [31 : 0] r2_ef;
    always @ (posedge clk or posedge rst) begin
        if(rst) begin
            r2_ef <= '0;
        end
        else if(handshake_ff1) begin
            r2_ef <= r1_ef;
        end
    end
    
    reg [31 : 0] r3;
    always @ (posedge clk or posedge rst) begin
        if(rst) begin
            r3 <= '0;
        end
        else if(handshake_ff2) begin
            r3 <= r2_ef + r2_abcd;
        end
    end
    
    always @ (posedge clk or posedge rst) begin
        if(rst) begin
            wr_en <= 1'b0;
        end
        else if(handshake_ff2) begin
            wr_en <= 1'b1;
        end
        else begin
            wr_en <= 1'b0;
        end
    end

    always_ff @(posedge clk)begin
        if(rst)begin
            ready_o <= 1'b0;
        end
        else if(usedw > WATERLINE)begin
            ready_o <= 1'b0;
        end
        else begin
            ready_o <= 1'b1;
        end
    end

    assign valid_o = ~empty;
     sync_fifo # (
        .MEM_TYPE   ("auto"         ),
        .READ_MODE  ("fwft"         ),
        .WIDTH      (FIFO_DATA_WIDTH),
        .DEPTH      (FIFO_DEPTH     )
    )fifo_inst(
        .clk    (clk                ), // input  wire
        .rst_n  (rst_n              ), // input  wire
        .wren   (wr_en              ), // input  wire
        .din    (r3                 ), // input  wire [WIDTH-1:0]
        .rden   (ready_i            ), // input  wire
        .dout   (dout               ), // output reg  [WIDTH-1:0]
        .empty  (empty              ), // output wire
        .usedw  (usedw              )
    );

endmodule
```

### 逐级反压与跨级反压

这时候的反压包括逐级反压和跨级反压，具体区别可以参考下图：

![img](https://pic2.zhimg.com/80/v2-b0b7c25408364e8805d98054f238b1e1_720w.webp)

由上图可见，3个模块都包含存储体，我们假设此时module3到达了它的水线，那么它有两种方式反压前面的模块，一种是从最源头进行反压，另一种是逐级反压。

建议：当每一模块都有存储体时，建议逐级反压。

原因：如果逐级反压的话，方法就是module3到达水线则反压module2，module2到达水线反压module1，每一级的水线和存储体大小设计就如上文车库模型所述，简单清晰。但是，如果选择跨级反压，那么module3的存储体深度 = waterlie3 + 在途1 + waterline1 + 在途2 + waterline2 + 在途3，可见每一级的存储体会变大并且水线计算复杂，另外路径变长，模块间耦合度增高，不利于复用与维护。但是，如果不是每一模块都包含存储体，那么可以选择跨级反压。

## 不带存储体的反压

### 分析与代码

同样是上文字节的问题，如果此时要求不允许使用FIFO，那应该怎么设计呢？

核心思想就是保证每一级流水中的每一级寄存器的数据安全，可以把每一级寄存器当成一个深度为1的FIFO，下一级有无数据可以看对应的valid信号。下一级无数据或者下一级已经准备好了，那么就可以向上一级取数据，本质上是pre-fetch结构。具体内容可以参考如下代码，注意：我没有把重复部分的代码写全，但是写出了所有核心代码，可供参考。

```verilog
module handshake_pb #(
)(
    input  wire         clk,
    input  wire         rst,
    input  wire         valid_i,
    output wire         ready_o,
    input  wire  [31:0] a,
    input  wire  [31:0] b,
    input  wire  [31:0] c,
    input  wire  [31:0] d,
    input  wire  [31:0] e,
    input  wire  [31:0] f,
    output wire  [31:0] dout,
    input  wire         ready_i,
    output reg          valid_o
    );

    assign ready_o = ~valid_r1 || ready_r1;
    //pre_fetch结构
    //valid_r1为0代表下一级无数据
    //ready_r1代表下一级准备好了读

    always_ff @ (posedge clk) begin 
        if(rst)begin
            valid_r1    <= 1'b0;
        end
        else if(ready_o)begin
            valid_r1    <= valid_i;
        end
    end
    
    always_ff @ (posedge clk) begin
        if(ready_o & valid_i)begin
            r1_ab       <= a + b;   //数据信号不复位
        end
    end

    assign ready_r1 = ~valid_r2 || ready_r2;

    reg [31 : 0] r2_abcd;

    always_ff @ (posedge clk) begin 
        if(rst)begin
            valid_r2    <= 1'b0;
        end
        else if(ready_r1)begin
            valid_r2    <= valid_r1;
        end
    end
    
    always_ff @ (posedge clk) begin
        if(ready_r1 & valid_r1)begin
            r2_abcd     <= r1_ab + r1_cd;
        end
    end

    assign ready_r2 = ~valid_r3 || ready_i;
    
    reg [31 : 0] r3;

    always_ff @ (posedge clk) begin 
        if(rst)begin
            valid_r3    <= 1'b0;
        end
        else if(ready_r2)begin
            valid_r3    <= valid_r2;
        end
    end
    
    always_ff @ (posedge clk) begin
        if(ready_r2 & valid_r2)begin
            r3          <= r2_ef + r2_abcd;
        end
    end

    assign dout     = r3;
    assign valid_o  = valid_r3;
endmodule
```

值得大家注意的是ready和valid的输入输出，此外就是每一级流水的握手信号处理，本人才疏学浅，如果有问题欢迎指出。