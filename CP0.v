`timescale 1ns / 1ps

module CP0(
    input clk,
    input rst,
    input mfc0,
    input [4:0] addr,
    output [31:0] CP0_out,
    input mtc0,
    input [31:0] data,
    input exception,
    input eret,
    input [31:0] pc,
    input [31:0] cause,
    output [31:0] status,
    output [31:0] epc_out
    );

    //宏定义每个寄存器对应的编号
    parameter Num_sta = 5'b01100;
    parameter Num_cau = 5'b01101;
    parameter Num_epc = 5'b01110;

    //输入
    wire [31:0] Cause_in, Status_in, Epc_in;

    wire [31:0] Status_temp;

    //输出
    wire [31:0] Cause_out, Status_out, Epc_out;

    //控制信号
    wire wepc, wsta, wcau;

    //这里给出一个额外的8号寄存器
    wire wvaddr;
    wire [31:0] Vaddr_out;
    wire [31:0] Vaddr_in;

    parameter Num_vaddr = 5'b01000;


    assign wsta = ((addr == Num_sta) & mtc0) || exception || eret;
    assign wcau = ((addr == Num_cau) & mtc0) || exception;
    assign wepc = ((addr == Num_epc) & mtc0) || exception;
    assign wvaddr = (addr == Num_vaddr & mtc0);

    assign Status_temp = exception ? {status[26:0], 5'b0} : (eret ? {5'b0, status[31:5]} : status);

    assign Cause_in = mtc0 ? data : cause;
    assign Status_in = mtc0 ? data : Status_temp;
    assign Epc_in = mtc0 ? data : pc;
    assign Vaddr_in = mtc0 ? data : 32'bz;

    assign status = Status_out;
    assign epc_out = Epc_out;
    assign CP0_out = mfc0 ? ((addr == Num_vaddr) ? Vaddr_out : ((addr == Num_cau) ? Cause_out : ((addr == Num_sta) ? Status_out : ((addr == Num_epc) ? Epc_out : 32'hz)))) : 32'hz;
    //assign CP0_out = mfc0 ? (addr == Num_vaddr ? Vaddr_out : CP0_out) : 32'hz;

    SingleReg Status(
        .clk(clk),
        .rst(rst),
        .ena(wsta),
        .w_data(Status_in),
        .r_data(Status_out)
    );

    SingleReg Cause(
        .clk(clk),
        .rst(rst),
        .ena(wcau),
        .w_data(Cause_in),
        .r_data(Cause_out)
    );

    SingleReg Epc(
        .clk(clk),
        .rst(rst),
        .ena(wepc),
        .w_data(Epc_in),
        .r_data(Epc_out)
    );

    SingleReg Vaddr(
        .clk(clk),
        .rst(rst),
        .ena(wvaddr),
        .w_data(Vaddr_in),
        .r_data(Vaddr_out)
    );

endmodule
