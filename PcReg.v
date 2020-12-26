`timescale 1ns / 1ps

module PcReg(
    input clk,
    input rst,
    input ena,
    input [31:0] pc_input,
    output [31:0] pc_output
    );
    reg [31:0] pc_reg;
    
    //每个指令周期结束后更新pc
    always @(negedge clk or posedge rst)
    begin
        if(rst)
            pc_reg <= 32'h00400000;
        else
        begin
            if(ena)
                pc_reg <= pc_input;
        end
    end
    
    assign pc_output = (ena ? pc_reg : 32'hz);
    
endmodule
