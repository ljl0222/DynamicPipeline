`timescale 1ns / 1ps

module cutDMEMtoRf(
    input [2:0] width_sign,
    input [1:0] pos,
    input sign,
    input [31:0] Dmem_data,
    output reg [31:0] Rf_data
    );

    always @ (*)
    begin
        if(width_sign == 3'b001)
        begin
            Rf_data <= Dmem_data;
        end
        else if(width_sign == 3'b010)
        begin
            if(pos == 2'b00)
            begin
                Rf_data <= {(sign == 1 ? {(16){Dmem_data[15]}} : 16'b0), Dmem_data[15:0]};
            end
            else if(pos == 2'b10)
            begin
                Rf_data <= {(sign == 1 ? {(16){Dmem_data[31]}} : 16'b0), Dmem_data[31:16]};
            end
        end
        else if(width_sign == 3'b100)
        begin
            if(pos == 2'b00)
            begin
                Rf_data <= {(sign == 1 ? {(24){Dmem_data[7]}} : 24'b0), Dmem_data[7:0]};
            end
            else if(pos == 2'b01)
            begin
                Rf_data <= {(sign == 1 ? {(24){Dmem_data[15]}} : 24'b0), Dmem_data[15:8]};
            end
            else if(pos == 2'b10)
            begin
                Rf_data <= {(sign == 1 ? {(24){Dmem_data[23]}} : 24'b0), Dmem_data[23:16]};
            end
            else if(pos == 2'b11)
            begin
                Rf_data <= {(sign == 1 ? {(24){Dmem_data[31]}} : 24'b0), Dmem_data[31:24]};
            end
        end
    end

endmodule
