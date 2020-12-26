`timescale 1ns / 1ps

module IMEM(
    input [10:0] addr,
    output [31:0] instr
    );
    //调用coe文件，将给入的addr转换为指令
    dist_mem_gen_0 instr_mem(.a(addr), .spo(instr));
endmodule
