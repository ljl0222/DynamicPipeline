`timescale 1ns / 1ps

module RegFiles(
        input clk,
        input rst, 
        input ena, 
        input rw_ena, 
        
        input [4:0] r0_addr,
        input [4:0] r1_addr,
        
        input [4:0] rw_addr,
        
        input [31:0] data_rw,
        output [31:0] data_r0,
        output [31:0] data_r1,
        output [31:0] reg28
    );
    
    reg [31:0] regfile[0:31];
    
    assign data_r0 = ena ? regfile[r0_addr] : 32'bz;
    assign data_r1 = ena ? regfile[r1_addr] : 32'bz;
    assign reg28 = ena ? regfile[28] : 32'bz;
 
    // always @(*)
    // begin
    //     if(ena)
    //     begin
    //         if(rw_ena && r0_addr == rw_addr)
    //         begin
    //             data_r0 <= data_rw;
    //         end
    //         else
    //         begin
    //             data_r0 <= regfile[r0_addr];
    //         end
    //     end
    //     else
    //     begin
    //         data_r0 <= 32'bz;
    //     end
    // end

    // always @(*)
    // begin
    //     if(ena)
    //     begin
    //         if(rw_ena && r1_addr == rw_addr)
    //         begin
    //             data_r1 <= data_rw;
    //         end
    //         else
    //         begin
    //             data_r1 <= regfile[r1_addr];
    //         end
    //     end
    //     else
    //     begin
    //         data_r1 <= 32'bz;
    //     end
    // end
    
    always @(negedge clk or posedge rst)
    begin
        if(rst) 
        begin
            regfile[0] <= 32'b0;
            regfile[1] <= 32'b0;
            regfile[2] <= 32'b0;
            regfile[3] <= 32'b0;
            regfile[4] <= 32'b0;
            regfile[5] <= 32'b0;
            regfile[6] <= 32'b0;
            regfile[7] <= 32'b0;
            regfile[8] <= 32'b0;
            regfile[9] <= 32'b0;
            regfile[10] <= 32'b0;
            regfile[11] <= 32'b0;
            regfile[12] <= 32'b0;
            regfile[13] <= 32'b0;
            regfile[14] <= 32'b0;
            regfile[15] <= 32'b0;
            regfile[16] <= 32'b0;
            regfile[17] <= 32'b0;
            regfile[18] <= 32'b0;
            regfile[19] <= 32'b0;
            regfile[20] <= 32'b0;
            regfile[21] <= 32'b0;
            regfile[22] <= 32'b0;
            regfile[23] <= 32'b0;
            regfile[24] <= 32'b0;
            regfile[25] <= 32'b0;
            regfile[26] <= 32'b0;
            regfile[27] <= 32'b0;
            regfile[28] <= 32'b0;
            regfile[29] <= 32'b0;
            regfile[30] <= 32'b0;
            regfile[31] <= 32'b0;
        end
        else if(ena && rw_ena && rw_addr != 5'b0)
        begin
            regfile[rw_addr] <= data_rw;
        end
        else
             regfile[rw_addr] <=  regfile[rw_addr];
    end
    
endmodule
