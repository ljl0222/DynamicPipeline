`timescale 1ns / 1ps

module ext16_32(
    input [15:0] datai,
    input sign,
    output [31:0] datao
    );

    assign datao = (sign == 0 || datai[15] == 0) ? {16'h0000, datai} : {16'hffff, datai};

endmodule
