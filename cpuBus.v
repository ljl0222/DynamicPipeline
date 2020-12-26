`timescale 1ns / 1ps

module cpuBus(
    input clk,
    input rst,
    input halt,
    input [31:0] imem_data,
    input [31:0] dmem_odata,
    output [31:0] imem_addr,
    output [31:0] dmem_addr,
    output [31:0] dmem_idata,
    output dmem_wena,
    output [2:0] cRD_width_sign,
    //output [1:0] cRD_pos,
    output cRD_sign, //似乎没用
    output [2:0] cDR_width_sign,
    output cDR_sign,
    output [31:0] reg28

    //test

    );

    // IF声明
    wire [31:0] if_npc;
    wire [31:0] if_npc_mux;
    wire [31:0] if_imem_instr;

    // IF/ID声明
    reg [31:0] ifid_npc;
    reg [31:0] ifid_instr;

    // ID声明
    wire id_beq;
    wire id_equal_0;
    wire [31:0] id_cp0_status;
    wire id_is_div;
    wire id_hi_wena;
    wire id_lo_wena;
    wire id_cp0_mtc0;
    wire id_cp0_mfc0;
    wire id_cp0_exeception;
    wire id_cp0_eret;
    wire [31:0] id_cp0_cause;
    wire id_rf_wena;
    wire id_ext_16_s;
    wire id_div_start;
    wire id_div_s;
    wire id_mul_s;
    wire [5:0] id_aluc;
    wire [2:0] id_cRD_width_sign;
    wire [2:0] id_cDR_width_sign;
    wire id_cRD_sign;
    wire id_cDR_sign;
    wire id_dmem_wena;
    wire [2:0] id_muxPc_sel;
    wire [5:0] id_muxHi_sel;
    wire [5:0] id_muxLo_sel;
    wire [5:0] id_muxAluA_sel;
    wire [5:0] id_muxAluB_sel;
    wire [5:0] id_muxData_sel;
    wire [5:0] id_muxAddr_sel;
    wire [5:0] id_stall;
    wire [31:0] id_rf_rdata0;
    wire [31:0] id_rf_rdata1;
    wire [31:0] id_ext16_32_out;
    wire [31:0] id_AluAout;
    wire [31:0] id_AluBout;
    wire [31:0] id_epc_out;

    wire [5:0] collision;

    wire flag_rs;
    wire flag_dmem; //控制前推到dmem的
    wire [8:0] collision_hilo;

    // ID/EXE声明
    reg [31:0] idexe_npc;
    reg [31:0] idexe_AluA;
    reg [31:0] idexe_AluB;
    reg [31:0] idexe_Rdata;
    reg [31:0] idexe_instr;
    reg idexe_hi_wena;
    reg idexe_lo_wena;
    reg idexe_Rf_wena;
    reg idexe_cp0_mtc0;
    reg idexe_cp0_mfc0;
    reg idexe_div_start;
    reg idexe_div_s;
    reg idexe_mul_s;
    reg [5:0] idexe_aluc;
    reg [2:0] idexe_cRD_width_sign;
    reg [2:0] idexe_cDR_width_sign;
    reg idexe_cRD_sign;
    reg idexe_cDR_sign;
    reg idexe_dmem_wena;
    reg [5:0] idexe_muxHi_sel;
    reg [5:0] idexe_muxLo_sel;
    reg [5:0] idexe_muxData_sel;
    reg [5:0] idexe_muxAddr_sel;

    // EXE声明
    wire [31:0] exe_Aluout;

    wire exe_div_busy;
    wire [31:0] exe_div_q; // 商
    wire [31:0] exe_div_r; // 余数
    wire [63:0] exe_mul_z; // 乘积
    

    // EXE/MEM声明
    reg [31:0] exemem_npc;
    reg [31:0] exemem_Aluout;
    reg [31:0] exemem_Rdata;
    reg [31:0] exemem_instr;
    reg exemem_hi_wena;
    reg exemem_lo_wena;
    reg exemem_rf_wena;
    reg exemem_cp0_mtc0;
    reg [2:0] exemem_cRD_width_sign;
    reg [2:0] exemem_cDR_width_sign;
    reg exemem_cRD_sign;
    reg exemem_cDR_sign;
    reg exemem_dmem_wena;
    reg [5:0] exemem_muxHi_sel;
    reg [5:0] exemem_muxLo_sel;
    reg [5:0] exemem_muxData_sel;
    reg [5:0] exemem_muxAddr_sel;

    reg [31:0] exemem_div_q;
    reg [31:0] exemem_div_r;
    reg [63:0] exemem_mul_z;

    // MEM声明
    wire [31:0] mem_dmemout;

    // MEM/WB声明
    reg [31:0] memwb_npc;
    reg [31:0] memwb_Aluout;
    reg [31:0] memwb_Mdata;
    reg [31:0] memwb_instr;
    reg memwb_hi_wena;
    reg memwb_lo_wena;
    reg memwb_rf_wena;
    reg memwb_cp0_mtc0;   
    reg [5:0] memwb_muxHi_sel;
    reg [5:0] memwb_muxLo_sel;
    reg [5:0] memwb_muxData_sel;
    reg [5:0] memwb_muxAddr_sel;

    reg [31:0] memwb_div_q;
    reg [31:0] memwb_div_r;
    reg [63:0] memwb_mul_z;

    // WB声明
    wire [31:0] wb_muxHiout;
    wire [31:0] wb_muxLoout;
    wire [31:0] wb_muxDataout;
    wire [31:0] wb_muxAddrout;

    wire [5:0] stall;

    Control ctrl(
        ifid_instr,
        idexe_instr,
        exemem_instr,
        memwb_instr,
        id_cp0_status,
        halt,
        id_beq,
        id_equal_0,
        id_is_div,
        id_hi_wena,
        id_lo_wena,
        id_cp0_mtc0,
        id_cp0_mfc0,
        id_cp0_exeception,
        id_cp0_eret,
        id_cp0_cause,
        id_rf_wena,
        id_ext_16_s,
        id_div_start,
        id_div_s,
        id_mul_s,
        id_aluc,
        id_cRD_width_sign,
        id_cRD_sign,
        id_cDR_width_sign,
        id_cDR_sign,
        id_dmem_wena,
        id_muxPc_sel,
        id_muxHi_sel,
        id_muxLo_sel,
        id_muxAluA_sel,
        id_muxAluB_sel,
        id_muxData_sel,
        id_muxAddr_sel,
        stall,
        collision,
        flag_rs,
        flag_dmem,
        collision_hilo
    );

    // IF layer
    // assign if_npc_mux = if_npc + 4; // to do:选择pc
    reg [31:0] if_temp_npc;
    assign if_npc_mux = if_temp_npc;
    always @ (*)
    begin
        if(id_muxPc_sel == 3'b000)
        begin
            if_temp_npc <= if_npc + 4;
        end
        else if(id_muxPc_sel == 3'b001)
        begin
            if_temp_npc <= if_npc + 4 + {{(14){ifid_instr[15]}}, ifid_instr[15:0], 2'b00};
        end
        else if(id_muxPc_sel == 3'b010)
        begin
            if_temp_npc <= {if_npc[31:28], ifid_instr[25:0], 2'b00};
        end
        else if(id_muxPc_sel == 3'b100)
        begin
            if_temp_npc <= id_rf_rdata0;
        end
        else if(id_muxPc_sel == 3'b011)
        begin
            if_temp_npc <= id_epc_out;
        end
        else if(id_muxPc_sel == 3'b111)
        begin
            if_temp_npc <= 32'h00400004;
        end
        else
        begin
            if_temp_npc <= if_npc + 4;
        end
    end

    PcReg pcreg(clk,rst,!stall[0],if_npc_mux,if_npc);
    assign imem_addr = if_npc;
    assign if_imem_instr = imem_data; 

    // IF/ID reg
    always @ (posedge clk or posedge rst)
    begin
        if(rst || (stall[0] & !stall[1]))
        begin
            ifid_npc <= 32'h0;
            ifid_instr <= 32'h0; 
        end
        else if(!stall[0])
        begin
            ifid_npc <= if_npc;
            ifid_instr <= if_imem_instr;
        end
    end

    // ID layer
    // todo:cp0 hi lo 
    wire [4:0] id_rf_raddr0;
    wire [4:0] id_rf_raddr1;
    wire [15:0] id_rf_imme;
    wire [4:0] id_rf_shamt;

    wire [4:0] id_cp0_addr;

    wire [31:0] id_cp0_out;
    wire [31:0] id_cp0_in;


    //wire [31:0] id_hi_wdata;
    wire [31:0] id_hi_rdata;
    //wire [31:0] id_lo_wdata;
    wire [31:0] id_lo_rdata;

    assign id_rf_raddr0 = ifid_instr[25:21];
    assign id_rf_raddr1 = ifid_instr[20:16];
    assign id_rf_imme = ifid_instr[15:0];
    assign id_rf_shamt = ifid_instr[10:6];

    assign id_cp0_in = id_rf_rdata1;
    assign id_cp0_addr = ifid_instr[15:11];

    //assign id_hi_wdata = id_rf_raddr0; // 错了
    //assign id_lo_wdata = id_rf_raddr0;

    RegFiles rf(
        clk,
        rst,
        1'b1,
        memwb_rf_wena,
        id_rf_raddr0,
        id_rf_raddr1,
        wb_muxAddrout, //注意这里，需要wb传回来值，因此只有当进入到wb阶段才能写回
        wb_muxDataout,
        id_rf_rdata0,
        id_rf_rdata1,
        reg28
    );

    SingleReg Hi(clk,rst,memwb_hi_wena,wb_muxHiout,id_hi_rdata);

    SingleReg Lo(clk,rst,memwb_lo_wena,wb_muxLoout,id_lo_rdata);

    reg [31:0] id_rdatahi;
    reg [31:0] id_rdatalo;

    always @ (*)
    begin
        if(collision_hilo[0] == 1'b1)
        begin
            id_rdatahi <= exe_mul_z[63:32];
        end
        else if(collision_hilo[3] == 1'b1)
        begin
            id_rdatahi <= exemem_mul_z[63:32];
        end
        
        else if(collision_hilo[6] == 1'b1)
        begin
            id_rdatahi <= memwb_mul_z[63:32];
        end
        else
        begin
            id_rdatahi <= id_hi_rdata;
        end
        

        if(collision_hilo[1] == 1'b1)
        begin
            id_rdatalo <= exe_mul_z[31:0];
        end
        else if(collision_hilo[4] == 1'b1)
        begin
            id_rdatalo <= exemem_mul_z[31:0];
        end
        else if(collision_hilo[7] == 1'b1)
        begin
            id_rdatalo <= memwb_mul_z[31:0];
        end
        else
        begin
            id_rdatalo <= id_lo_rdata;
        end
    end



    // ???
    // ifid_npc可能错了
    CP0 cp0(clk,rst,id_cp0_mfc0,id_cp0_addr,id_cp0_out,id_cp0_mtc0,id_cp0_in,id_cp0_exeception,id_cp0_eret,ifid_npc,id_cp0_cause,id_cp0_status,id_epc_out);

    ext16_32 ext1632(id_rf_imme,id_ext_16_s,id_ext16_32_out);

    //assign id_AluAout = id_rf_raddr0; //todo: 选择alua
    //assign id_AluBout = id_ext16_32_out; //todo: 选择alub

    reg [31:0] id_temp_A;
    reg [31:0] id_temp_B;

    reg [31:0] id_rdata0;
    reg [31:0] id_rdata1;

    wire [31:0] exe_out;

    always @ (*)
    begin
        if(id_rf_raddr0 == 5'b0)
        begin
            id_rdata0 <= 32'b0;
        end
        else if(collision[0] == 1'b1)
        begin
            id_rdata0 <= exe_out;
        end
        else if(collision[2] == 1'b1)
        begin
            id_rdata0 <= exemem_Aluout;
        end
        else if(collision[4] == 1'b1)
        begin
            id_rdata0 <= memwb_Aluout;
        end
        else
        begin
            id_rdata0 <= id_rf_rdata0;
        end
    end

    always @ (*)
    begin
        if(id_rf_raddr1 == 5'b0)
        begin
            id_rdata1 <= 32'b0;
        end
        else if(collision[1] == 1'b1)
        begin
            id_rdata1 <= exe_out;
        end
        else if(collision[3] == 1'b1)
        begin
            id_rdata1 <= exemem_Aluout;
        end
        else if(collision[5] == 1'b1)
        begin
            id_rdata1 <= memwb_Aluout;
        end
        else
        begin
            id_rdata1 <= id_rf_rdata1;
        end
    end

    assign id_AluAout = id_temp_A;
    assign id_AluBout = id_temp_B;

    always @ (*)
    begin
        if(id_muxAluA_sel == 6'b000001)
        begin
            id_temp_A <= id_rdata0;
        end
        else if(id_muxAluA_sel == 6'b000010)
        begin
            id_temp_A <= id_rf_shamt;
        end
    end

    always @ (*)
    begin
        if(id_muxAluB_sel == 6'b000001)
        begin
            id_temp_B <= id_ext16_32_out;
        end
        else if(id_muxAluB_sel == 6'b000010)
        begin
            id_temp_B <= id_rdata1;
        end
    end

    assign id_beq = (id_AluAout == id_AluBout);
    // todo: shift beq equal_0

    // ID/EXE reg
    reg [31:0] idexe_cp0_out;
    reg [31:0] idexe_hi_rdata;
    reg [31:0] idexe_lo_rdata;
    reg [31:0] idexe_hilo_wdata;

    always @ (posedge clk or posedge rst)
    begin
        if(rst || (stall[1] & !stall[2]))
        begin
            idexe_npc <= 32'b0;
            idexe_AluA <= 32'h0;
            idexe_AluB <= 32'h0;
            idexe_Rdata <= 32'h0; //注意，这里是读入dmem的
            idexe_instr <= 32'h0;
            idexe_hi_wena <= 1'b0;
            idexe_lo_wena <= 1'b0;
            idexe_hi_rdata <= 32'h0;
            idexe_lo_rdata <= 32'h0;
            idexe_hilo_wdata <= 32'h0;
            idexe_Rf_wena <= 1'b0;
            idexe_cp0_mtc0 <= 1'b0;
            idexe_cp0_mfc0 <= 1'b0;
            idexe_cp0_out <= 32'h0;
            idexe_div_start <= 1'b0;
            idexe_div_s <= 1'b0;
            idexe_mul_s <= 1'b0;
            idexe_aluc <= 6'b000000;
            idexe_cRD_width_sign <= 3'b000;
            idexe_cDR_width_sign <= 3'b000;
            idexe_cRD_sign <= 0;
            idexe_cDR_sign <= 0;
            idexe_dmem_wena <= 1'b0;
            idexe_muxHi_sel <= 6'b000000;
            idexe_muxLo_sel <= 6'b000000;
            idexe_muxData_sel <= 6'b000000;
            idexe_muxAddr_sel <= 6'b000000;
        end
        else if(!stall[1])
        begin
            idexe_npc <= ifid_npc;
            idexe_AluA <= id_AluAout;
            idexe_AluB <= id_AluBout;
            idexe_Rdata <= id_rdata1; //注意，这里是读入dmem的
            idexe_instr <= ifid_instr;
            idexe_hi_wena <= id_hi_wena;
            idexe_lo_wena <= id_lo_wena;
            idexe_Rf_wena <= id_rf_wena;
            idexe_hi_rdata <= id_rdatahi;
            idexe_lo_rdata <= id_rdatalo;
            idexe_hilo_wdata <= id_rdata0; //读入hilo
            idexe_cp0_mtc0 <= id_cp0_mtc0;
            idexe_cp0_mfc0 <= id_cp0_mfc0;
            idexe_cp0_out <= id_cp0_out;
            idexe_div_start <= id_div_start;
            idexe_div_s <= id_div_s;
            idexe_mul_s <= id_mul_s;
            idexe_aluc <= id_aluc;
            idexe_cRD_width_sign <= id_cRD_width_sign;
            idexe_cDR_width_sign <= id_cDR_width_sign;
            idexe_cRD_sign <= id_cRD_sign;
            idexe_cDR_sign <= id_cDR_sign;
            idexe_dmem_wena <= id_dmem_wena;
            idexe_muxHi_sel <= id_muxHi_sel;
            idexe_muxLo_sel <= id_muxLo_sel;
            idexe_muxData_sel <= id_muxData_sel;
            idexe_muxAddr_sel <= id_muxAddr_sel;
        end
    end

    // EXE layer
    // todo: div mul
    wire zero,carry,negative,overflow,flag;
    wire [31:0] exe_dividend;
    wire [31:0] exe_divisor;

    wire [31:0] exe_mul_a;
    wire [31:0] exe_mul_b;

    

    assign exe_dividend = idexe_hilo_wdata; // data0（借用一下
    assign exe_divisor = idexe_Rdata; // data1（借用一下
    assign exe_mul_a = idexe_hilo_wdata;
    assign exe_mul_b = idexe_Rdata;

    Alu alu(
        idexe_AluA,
        idexe_AluB,
        idexe_aluc,
        exe_Aluout,
        zero,
        carry,
        negative,
        overflow,
        flag
    );

    Div div(
        exe_dividend,
        exe_divisor,
        idexe_div_s,
        idexe_div_start,
        clk,
        rst,
        exe_div_q,
        exe_div_r,
        exe_div_busy
    );

    Mul mul(
        idexe_mul_s,
        exe_mul_a,
        exe_mul_b,
        exe_mul_z
    );

    assign exe_out = (idexe_muxHi_sel[1]) ? exe_mul_z[31:0] : exe_Aluout;

    // EXE/MEM reg
    reg [31:0] exemem_cp0_out;

    reg [31:0] exemem_hi_rdata;
    reg [31:0] exemem_lo_rdata;

    reg [31:0] exemem_hilo_wdata;
    always @ (posedge clk or posedge rst)
    begin
        if(rst || (stall[2] & !stall[3]))
        begin
            exemem_div_q <= 32'b0;
            exemem_div_r <= 32'b0;
            exemem_mul_z <= 64'b0;
            exemem_npc <= 32'h0;
            exemem_Aluout <= 32'h0;
            exemem_Rdata <= 32'h0;
            exemem_instr <= 32'h0;
            exemem_hi_wena <= 0;
            exemem_lo_wena <= 0;
            exemem_hi_rdata <= 32'h0;
            exemem_lo_rdata <= 32'h0;
            exemem_hilo_wdata <= 32'h0;
            exemem_rf_wena <= 0;
            exemem_cp0_mtc0 <= 0;
            exemem_cp0_out <= 32'h0;
            exemem_cRD_width_sign <= 3'b000;
            exemem_cRD_sign <= 0;
            exemem_cDR_width_sign <= 3'b000;
            exemem_cDR_sign <= 0;
            exemem_dmem_wena <= 0;
            exemem_muxHi_sel <= 6'b0;
            exemem_muxLo_sel <= 6'b0;
            exemem_muxData_sel <= 6'b0;
            exemem_muxAddr_sel <= 6'b0;
        end
        else if(!stall[2])
        begin
            exemem_div_q <= exe_div_q;
            exemem_div_r <= exe_div_r;
            exemem_mul_z <= exe_mul_z;
            exemem_npc <= idexe_npc;
            exemem_Aluout <= exe_out;
            exemem_Rdata <= idexe_Rdata;
            exemem_instr <= idexe_instr;
            exemem_hi_wena <= idexe_hi_wena;
            exemem_lo_wena <= idexe_lo_wena;
            exemem_hi_rdata <= idexe_hi_rdata;
            exemem_lo_rdata <= idexe_lo_rdata;
            exemem_hilo_wdata <= idexe_hilo_wdata;
            exemem_rf_wena <= idexe_Rf_wena;
            exemem_cp0_mtc0 <= idexe_cp0_mtc0;
            exemem_cp0_out <= idexe_cp0_out;
            exemem_cRD_width_sign <= idexe_cRD_width_sign;
            exemem_cRD_sign <= idexe_cRD_sign;
            exemem_cDR_width_sign <= idexe_cDR_width_sign;
            exemem_cDR_sign <= idexe_cDR_sign;
            exemem_dmem_wena <= idexe_dmem_wena;
            exemem_muxHi_sel <= idexe_muxHi_sel;
            exemem_muxLo_sel <= idexe_muxLo_sel;
            exemem_muxData_sel <= idexe_muxData_sel;
            exemem_muxAddr_sel <= idexe_muxAddr_sel;
        end
    end
    
    // MEM layer
    // todo: 什么都没干呢，哈哈
    assign mem_dmemout = dmem_odata;
    assign dmem_addr = exemem_Aluout;
    assign dmem_idata = exemem_Rdata;
    assign dmem_wena = exemem_dmem_wena;
    assign cRD_width_sign = exemem_cRD_width_sign;
    assign cDR_width_sign = exemem_cDR_width_sign;
    assign cRD_sign = exemem_cRD_sign;
    assign cDR_sign = exemem_cDR_sign;

    // MEM/WB reg
    reg [31:0] memwb_cp0_out;

    reg [31:0] memwb_hi_rdata;
    reg [31:0] memwb_lo_rdata;

    reg [31:0] memwb_hilo_wdata;

    always @ (posedge clk or posedge rst)
    begin
        if(rst || (stall[3] & !stall[4]))
        begin
            memwb_div_q <= 32'b0;
            memwb_div_r <= 32'b0;
            memwb_mul_z <= 64'b0;
            memwb_npc <= 32'b0;
            memwb_Aluout <= 32'b0;
            memwb_Mdata <= 32'b0;
            memwb_instr <= 32'b0;
            memwb_hi_wena <= 0;
            memwb_lo_wena <= 0;
            memwb_hi_rdata <= 32'h0;
            memwb_lo_rdata <= 32'h0;
            memwb_hilo_wdata <= 32'h0;
            memwb_rf_wena <= 0;
            memwb_cp0_mtc0 <= 0;
            memwb_cp0_out <= 32'h0;
            memwb_muxHi_sel <= 6'b0;
            memwb_muxLo_sel <= 6'b0;
            memwb_muxData_sel <= 6'b0;
            memwb_muxAddr_sel <= 6'b0;
        end
        else if(!stall[3])
        begin
            memwb_div_q <= exemem_div_q;
            memwb_div_r <= exemem_div_r;
            memwb_mul_z <= exemem_mul_z;
            memwb_npc <= exemem_npc;
            memwb_Aluout <= exemem_Aluout;
            memwb_Mdata <= mem_dmemout;
            memwb_instr <= exemem_instr;
            memwb_hi_wena <= exemem_hi_wena;
            memwb_lo_wena <= exemem_lo_wena;
            memwb_hi_rdata <= exemem_hi_rdata;
            memwb_lo_rdata <= exemem_lo_rdata;
            memwb_hilo_wdata <= exemem_hilo_wdata;
            memwb_rf_wena <= exemem_rf_wena;
            memwb_cp0_mtc0 <= exemem_cp0_mtc0;
            memwb_cp0_out <= exemem_cp0_out;
            memwb_muxHi_sel <= exemem_muxHi_sel;
            memwb_muxLo_sel <= exemem_muxLo_sel;
            memwb_muxData_sel <= exemem_muxData_sel;
            memwb_muxAddr_sel <= exemem_muxAddr_sel;
        end
    end

    // WB layer
    // todo: 选择dataw，addr
    //assign wb_muxDataout = memwb_Aluout;
    //assign wb_muxAddrout = memwb_instr[20:16];

    reg [31:0] wb_data_temp;
    reg [31:0] wb_addr_temp;
    reg [31:0] wb_hi_temp;
    reg [31:0] wb_lo_temp;

    assign wb_muxAddrout = wb_addr_temp;
    assign wb_muxDataout = wb_data_temp;
    assign wb_muxHiout = wb_hi_temp;
    assign wb_muxLoout = wb_lo_temp;

    always @ (*)
    begin
        if(memwb_muxData_sel == 6'b000001)
        begin
            wb_data_temp <= memwb_Aluout;
        end
        else if(memwb_muxData_sel == 6'b000010)
        begin
            wb_data_temp <= memwb_npc;
        end
        else if(memwb_muxData_sel == 6'b000100)
        begin
            // todo: 这里需要clz的计数结果，clz一会儿写
        end
        else if(memwb_muxData_sel == 6'b001000)
        begin
            wb_data_temp <= memwb_Mdata;
        end
        else if(memwb_muxData_sel == 6'b010000)
        begin
            wb_data_temp <= memwb_cp0_out;
        end
        else if(memwb_muxData_sel == 6'b100000)
        begin
            wb_data_temp <= memwb_hi_rdata;
        end
        else if(memwb_muxData_sel == 6'b100001)
        begin
            wb_data_temp <= memwb_lo_rdata;
        end
        else if(memwb_muxData_sel == 6'b100010)
        begin
            wb_data_temp <= memwb_mul_z[31:0];
        end
    end

    always @ (*)
    begin
        if(memwb_muxAddr_sel == 6'b000001)
        begin
            wb_addr_temp <= memwb_instr[20:16];
        end
        else if(memwb_muxAddr_sel == 6'b000010)
        begin
            wb_addr_temp <= memwb_instr[15:11];
        end
        else if(memwb_muxAddr_sel == 6'b000100)
        begin
            wb_addr_temp <= 5'b11111;
        end
    end

    always @ (*)
    begin
        if(memwb_muxHi_sel == 6'b000001)
        begin
            wb_hi_temp <= memwb_hilo_wdata;
        end
        else if(memwb_muxHi_sel == 6'b000010)
        begin
            wb_hi_temp <= memwb_mul_z[63:32];
        end
        else if(memwb_muxHi_sel == 6'b000100)
        begin
            wb_hi_temp <= memwb_div_r;
        end
    end

    always @ (*)
    begin
        if(memwb_muxLo_sel == 6'b000001)
        begin
            wb_lo_temp <= memwb_hilo_wdata;
        end
        else if(memwb_muxLo_sel == 6'b000010)
        begin
            wb_lo_temp <= memwb_mul_z[31:0];
        end
        else if(memwb_muxLo_sel == 6'b000100)
        begin
            wb_lo_temp <= memwb_div_q;
        end
    end

endmodule
