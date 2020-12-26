`timescale 1ns / 1ps

module Mul(
    input sign,
    input [31:0] A,
    input [31:0] B,
    output reg [63:0] Z
    );

    reg [31:0] reg_A, reg_B;
    reg [63:0] reg_Z;
    wire flag = A[31] ^ B[31];
    //assign flag

    integer i;

    always @ (*)
    begin
        Z = 64'b0;
        if(sign)
        begin
            reg_A = A[31] ? -A : A;
            reg_B = B[31] ? -B : B;
            for(i = 0; i < 32; i = i + 1)
            begin
                reg_Z = reg_B[i] ? ({32'b0, reg_A} << i) : 64'b0;
                Z = Z + reg_Z;
            end
            if(flag)
            begin
                Z = -Z;
            end
        end
        else
        begin
            reg_A = reg_A;
            reg_B = reg_B;
            for(i = 0; i < 32; i = i + 1)
            begin
                reg_Z = reg_B[i] ? ({32'b0, reg_A} << i) : 64'b0;
                Z = Z + reg_Z;
            end
        end

        
        
    end

endmodule
