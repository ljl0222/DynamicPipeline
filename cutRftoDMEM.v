`timescale 1ns / 1ps

module cutRftoDMEM(
    input [2:0] width_sign,
    input [1:0] pos,
    input sign,
    input [31:0] Rf_data,
    input [31:0] dmem_idata,
    output reg [31:0] dmem_odata
    );

    always @ (*)
    begin
        if(width_sign == 3'b001)
        begin
            dmem_odata <= Rf_data;
        end
        else if(width_sign == 3'b010)
        begin
            if(pos == 2'b00)
            begin
                dmem_odata <= {dmem_idata[31:16], Rf_data[15:0]};
            end
            else if(pos == 2'b10)
            begin
                dmem_odata <= {Rf_data[31:16], dmem_idata[15:0]};
            end
        end
        else if(width_sign == 3'b100)
        begin
            if(pos == 2'b00)
            begin
                dmem_odata <= {dmem_idata[31:8], Rf_data[7:0]};
            end
            else if(pos == 2'b01)
            begin
                dmem_odata <= {dmem_idata[31:16], Rf_data[7:0], dmem_idata[7:0]};
            end
            else if(pos == 2'b10)
            begin
                dmem_odata <= {dmem_idata[31:24], Rf_data[7:0], dmem_idata[15:0]};
            end
            else if(pos == 2'b11)
            begin
                dmem_odata <= {Rf_data[7:0], dmem_idata[23:0]};
            end
        end
    end

endmodule
