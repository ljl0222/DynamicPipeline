`timescale 1ns / 1ps

module SingleReg(
    input clk,
    input rst,
    input ena,
    input [31:0] w_data,
    output [31:0] r_data
    );

    reg [31:0] r_data_;

    assign r_data = r_data_;

    always @(negedge clk or posedge rst)
    begin
        if(rst)
            r_data_ = 31'h0000_0000;
        else if(ena)
        begin
            r_data_ = w_data;
        end
    end


endmodule
