

> https://blog.csdn.net/HFUT90S/article/details/127853205



# CPU简介

## CPU工作的5个阶段

1. 取指 (IF, Instruction Fetch)
2. 译指(ID, Instruction Decode)
3. 执行(EX, exexute)
4. 访存(MEM, Memory)
5. 回写(WB, Write Back)



## CPU内部关键结构：
（1）算术逻辑运算器（ALU）；
（2）累加器；
（3）程序计数器；
（4）指令寄存器和译码器；
（5）时序和控制部件。

## RISC_CPU内部结构和Verilog实现
本项目中的RISC_CPU一共有9个模块组成，具体如下：
（1）时钟发生器；
（2）指令寄存器；
（3）累加器；
（4）算术逻辑运算单元；
（5）数据控制器；
（6）状态控制器；
（7）主状态机；
（8）程序计数器；
（9）地址多路器。