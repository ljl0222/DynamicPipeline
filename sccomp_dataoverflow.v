`timescale 1ns / 1ps


module sccomp_dataoverflow(
    input clk,
    input rst,
    output halt,
    //output [31:0] instr,

    //output [31:0] test_dmem_addr,
    output [31:0] test_dmem_data_w,
    output [31:0] test_imem_addr,
    output [31:0] reg28
    //output [31:0] test_dmem_data_r,
    //output test_dmem_wena,
    //output [31:0] test_Rf_odata
    );

    

    wire [31:0] imem_data;
    wire [31:0] imem_addr;
    assign test_imem_addr = imem_addr;

    wire [31:0] dmem_addr;
    wire [31:0] dmem_data_w;
    wire [31:0] dmem_data_r;

    wire dmem_wena;
    wire dmem_ena;
    assign dmem_ena = 1'b1;

    wire [2:0] cDR_width_sign;
    wire [1:0] cDR_pos;
    wire cDR_sign;

    wire [2:0] cRD_width_sign;
    wire [1:0] cRD_pos;
    wire cRD_sign;
    wire [31:0] Rf_odata;

    wire [31:0] into_rf;
 
    assign instr = imem_data;

    //assign test_dmem_addr = dmem_addr;
    //assign test_dmem_data_r = dmem_data_r;
    assign test_dmem_data_w = dmem_data_w;
    //assign test_dmem_wena = dmem_wena;
    //assign test_Rf_odata = Rf_odata;

    assign halt = (dmem_data_w == 32'ha0602880) ? 1 : 0;

    assign cDR_pos = dmem_addr[1:0];
    assign cRD_pos = dmem_addr[1:0];

    

    cpuBus cB(clk,rst,halt,imem_data,into_rf,imem_addr,dmem_addr,Rf_odata,dmem_wena,cRD_width_sign,cRD_sign,cDR_width_sign,cDR_sign,reg28);

    IMEM imem((imem_addr[31:0]-32'h00400000)/4,imem_data);

    DMEM dmem(clk,1'b1,dmem_wena,1'b1,(dmem_addr[31:0]-32'h10010000)/4,dmem_data_w,dmem_data_r);

    cutDMEMtoRf cDR(cDR_width_sign,cDR_pos,cDR_sign,dmem_data_r,into_rf);

    cutRftoDMEM cRD(cRD_width_sign,cRD_pos,cRD_sign,Rf_odata,dmem_data_r,dmem_data_w);

endmodule
