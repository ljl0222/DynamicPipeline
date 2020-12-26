`timescale 1ns / 1ps

module DMEM(
    input clk,
    input ena,
    input w_ena,
    input r_ena,
    input [31:0] addr, //这里用和IMEM统一的地�?码，且会�?�?/4（�?�过分析Mars中的指令得出
    input [31:0] data_w,
    output [31:0] data_r
    );
    //定义�?个向量数�?
    //根据Mars中测试的指令可以看出是一共最�?+120/4=30个存储单元数，每个数据是32�?
    reg [31:0] data_memory[0:1023];
    
    //读取数据
    assign data_r = (ena && r_ena) ? data_memory[addr] : 32'bz;
    
    //写入数据
    always @(posedge clk)
    begin
        if(ena && w_ena)
            data_memory[addr] <= data_w;
    end
    
endmodule
