`timescale 1ns / 1ps

module ext532(
    input [4:0] datai,
    input sign,
    output [31:0] datao
    );

    assign datao = (sign == 0 || datai[4] == 0) ? {27'b0, datai} : {27'h7ffffff, datai};

endmodule
