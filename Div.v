`timescale 1ns / 1ps

module Div(
    input [31:0] Dividend,
    input [31:0] Divisor,
    input sign,
    input start,
    input clk,
    input rst,
    output [31:0] Q,
    output [31:0] R,
    output reg busy
    );

    reg [4:0] count;
    reg [31:0] reg_q,reg_r,reg_b;
    reg r_sign;
    reg ready;

    wire [31:0] reg_q2;
    wire [31:0] reg_r2;

    assign reg_q2 = reg_q;
    assign reg_r2 = r_sign ? reg_r + reg_b : reg_r;
    wire [32:0] sub_add = r_sign ? ({reg_r,reg_q[31]} + {1'b0, reg_b[31]}) : ({reg_r, reg_q[31]} - {1'b0, reg_b});

    assign Q = ready ? ((sign & (Dividend[31] ^ Divisor[31])) ? -reg_q2 : reg_q2) : 32'bz;
    assign R = ready ? ((sign & Dividend[31]) ? -reg_r2 : reg_r2) : 32'bz;

    always @ (posedge clk or posedge rst)
    begin
        if(rst)
        begin
            count <= 5'b00000;
            busy <= 0;
            r_sign <= 0;
            ready <= 0;
            reg_q <= 32'b0;
            reg_r <= 32'b0;
            reg_b <= 32'b0;
        end
        else
        begin
            if(start)
            begin
                reg_r <= 32'b0;
                r_sign <= 0;
                count <= 5'b0;
                busy <= 1;
                if(sign & Dividend[31])
                begin
                    reg_q <= -Dividend;
                end
                else
                begin
                    reg_q <= Dividend;
                end
                if(sign & Divisor[31])
                begin
                    reg_b <= -Divisor;
                end
                else
                begin
                    reg_b <= Divisor;
                end
            end
            else if(busy)
            begin
                reg_r <= sub_add[31:0];
                r_sign <= sub_add[32];
                reg_q <= {reg_q[30:0], ~sub_add[32]};
                count <= count + 1;
                if(count == 5'b11111)
                begin
                    busy <= 0;
                    ready <= 1;
                end
            end
            else if(ready)
            begin
                ready <= 0;
            end
        end
    end

endmodule
