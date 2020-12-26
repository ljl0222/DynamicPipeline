`timescale 1ns / 1ps

module Sp_top(
    input clk,
    input rst,
    output [7:0] Seg,
    output [7:0] Sel
    );

    wire [31:0] reg28;
    wire [31:0] disp;
    wire [31:0] pc_out;
    reg [31:0] seg_idata;
    reg [30:0] cnt;
    reg clk_50m;
    reg flag;
    wire clk_cpu;
    wire clk_seg;

    wire halt;
   // wire [31:0] instr;
   
   //wire [31:0] seg_idata = rst ? 32'hffffffff : ((disp == 32'ha0602880) ? 32'ha0602880 : 32'h00000001);
   
//    always @ (*)
//    begin
//        if(rst)
//        begin
//            seg_idata <= 32'hffffffff;
//            flag <= 0;
//        end
//        if(disp == 32'ha0602880)
//        begin
//            seg_idata <= disp;
//            flag <= 1;
//        end
//        else
//        begin
//            seg_idata <= 32'h00000001;
//        end
//    end

    //assign halt = (disp == 32'ha0602880) ? 1 : 0;

    sccomp_dataoverflow sc(
        clk_cpu,
        rst,
        halt,
        //instr,
        disp,
        pc_out,
        reg28
    );

    Seg7x16 segdt(
        clk,
        rst,
        1'b1,
        reg28,
        Seg,
        Sel
    );
    
    divider div(
        clk,
        rst,
        clk_seg,
        clk_cpu
    );

endmodule
