`timescale 1ns / 1ps

module Control(
    input [31:0] id_instr,
    input [31:0] exe_instr,
    input [31:0] mem_instr,
    input [31:0] wb_instr,
    input [31:0] cp0_status,
    input halt,
    input beq,
    input euqal_0,
    input is_div,
    output reg hi_wena,
    output reg lo_wena,
    output reg cp0_mtc0,
    output reg cp0_mfc0,
    output reg cp0_exeception,
    output reg cp0_eret,
    output reg [31:0] cp0_cause,
    output reg rf_wena,
    output reg ext_16_s,
    output reg div_start,
    output reg div_s,
    output reg mul_s,
    output reg [5:0] aluc,
    output reg [2:0] cRD_width_sign,
    output reg cRD_sign,
    output reg [2:0] cDR_width_sign,
    output reg cDR_sign,
    output reg dmem_wena,
    output reg [2:0] muxPc_sel,
    output reg [5:0] muxHi_sel,
    output reg [5:0] muxLo_sel,
    output reg [5:0] muxAluA_sel,
    output reg [5:0] muxAluB_sel,
    output reg [5:0] muxData_sel,
    output reg [5:0] muxAddr_sel,
    output reg [5:0] stall,
    output reg [5:0] collision,
    output reg flag_rs,
    output reg flag_dmem,
    output reg [8:0] collision_hilo
    );

    // ID部分对指令进行译码
    wire [5:0] id_op = id_instr[31:26];
    wire [5:0] id_func = id_instr[5:0];
    wire [4:0] id_rs = id_instr[25:21];
    wire [4:0] id_rt = id_instr[20:16]; 
    //-------------------------------31
    wire id_Addi = (id_op == 6'b001000);
    wire id_Addiu = (id_op == 6'b001001);
    wire id_Andi = (id_op == 6'b001100);
    wire id_Ori = (id_op == 6'b001101);
    wire id_Sltiu = (id_op == 6'b001011);
    wire id_Lui = (id_op == 6'b001111);
    wire id_Xori = (id_op == 6'b001110);
    wire id_Slti = (id_op == 6'b001010);
    wire id_Addu = (id_op == 6'b000000 && id_func==6'b100001);
    wire id_And = (id_op == 6'b000000 && id_func == 6'b100100);
    wire id_Beq = (id_op == 6'b000100);
    wire id_Bne = (id_op == 6'b000101);
    wire id_J = (id_op == 6'b000010);
    wire id_Jal = (id_op == 6'b000011);
    wire id_Jr = (id_op == 6'b000000 && id_func == 6'b001000);
    wire id_Lw = (id_op == 6'b100011);
    wire id_Xor = (id_op == 6'b000000 && id_func == 6'b100110);
    wire id_Nor = (id_op == 6'b000000 && id_func == 6'b100111);
    wire id_Or = (id_op == 6'b000000 && id_func == 6'b100101);
    wire id_Sll = (id_op == 6'b000000 && id_func == 6'b000000);
    wire id_Sllv = (id_op == 6'b000000 && id_func == 6'b000100);
    wire id_Sltu = (id_op == 6'b000000 && id_func == 6'b101011);
    wire id_Sra = (id_op == 6'b000000 && id_func == 6'b000011);
    wire id_Srl = (id_op == 6'b000000 && id_func == 6'b000010);
    wire id_Subu = (id_op == 6'b000000 && id_func == 6'b100011);
    wire id_Sw = (id_op == 6'b101011);
    wire id_Add = (id_op == 6'b000000 && id_func == 6'b100000);
    wire id_Sub = (id_op == 6'b000000 && id_func == 6'b100010);
    wire id_Slt = (id_op == 6'b000000 && id_func == 6'b101010);
    wire id_Srlv = (id_op == 6'b000000 && id_func == 6'b000110);
    wire id_Srav = (id_op == 6'b000000 && id_func == 6'b000111);
    //-------------------------------23plus
    wire id_Clz = (id_op == 6'b011100 && id_func == 6'b100000);
    wire id_Divu = (id_op == 6'b000000 && id_func == 6'b011011);
    wire id_Eret = (id_op == 6'b010000 && id_func == 6'b011000);
    wire id_Jalr = (id_op == 6'b000000 && id_func == 6'b001001);
    wire id_Lb = (id_op == 6'b100000);
    wire id_Lbu = (id_op == 6'b100100);
    wire id_Lhu = (id_op == 6'b100101);
    wire id_Sb = (id_op == 6'b101000);
    wire id_Sh = (id_op == 6'b101001);
    wire id_Lh = (id_op == 6'b100001);
    wire id_Mfc0 = (id_instr[31:21] == 11'b01000000000 && id_instr[10:3]==8'b00000000);
    wire id_Mfhi = (id_op == 6'b000000 && id_func == 6'b010000);
    wire id_Mflo = (id_op == 6'b000000 && id_func == 6'b010010);
    wire id_Mtc0 = (id_instr[31:21] == 11'b01000000100 && id_instr[10:3]==8'b00000000);
    wire id_Mthi = (id_op == 6'b000000 && id_func == 6'b010001);
    wire id_Mtlo = (id_op == 6'b000000 && id_func == 6'b010011);
    wire id_Mul = (id_op == 6'b011100 && id_func == 6'b000010);
    wire id_Multu = (id_op == 6'b000000 && id_func == 6'b011001);
    wire id_Syscall = (id_op == 6'b000000 && id_func== 6'b001100);
    wire id_Teq = (id_op == 6'b000000 && id_func == 6'b110100);
    wire id_Bgez = (id_op == 6'b000001);
    wire id_Break = (id_op == 6'b000000 && id_func == 6'b001101);
    wire id_Div = (id_op == 6'b000000 && id_func == 6'b011010);


    // EXE部分对指令进行译码
    wire [5:0] exe_op = exe_instr[31:26];
    wire [5:0] exe_func = exe_instr[5:0];
    wire [4:0] exe_rs = exe_instr[25:21];
    wire [4:0] exe_rt = exe_instr[20:16];
    wire [4:0] exe_rd = exe_instr[15:11]; 
    //-------------------------------31
    wire exe_Addi = (exe_op == 6'b001000);
    wire exe_Addiu = (exe_op == 6'b001001);
    wire exe_Andi = (exe_op == 6'b001100);
    wire exe_Ori = (exe_op == 6'b001101);
    wire exe_Sltiu = (exe_op == 6'b001011);
    wire exe_Lui = (exe_op == 6'b001111);
    wire exe_Xori = (exe_op == 6'b001110);
    wire exe_Slti = (exe_op == 6'b001010);
    wire exe_Addu = (exe_op == 6'b000000 && exe_func==6'b100001);
    wire exe_And = (exe_op == 6'b000000 && exe_func == 6'b100100);
    wire exe_Beq = (exe_op == 6'b000100);
    wire exe_Bne = (exe_op == 6'b000101);
    wire exe_J = (exe_op == 6'b000010);
    wire exe_Jal = (exe_op == 6'b000011);
    wire exe_Jr = (exe_op == 6'b000000 && exe_func == 6'b001000);
    wire exe_Lw = (exe_op == 6'b100011);
    wire exe_Xor = (exe_op == 6'b000000 && exe_func == 6'b100110);
    wire exe_Nor = (exe_op == 6'b000000 && exe_func == 6'b100111);
    wire exe_Or = (exe_op == 6'b000000 && exe_func == 6'b100101);
    wire exe_Sll = (exe_op == 6'b000000 && exe_func == 6'b000000);
    wire exe_Sllv = (exe_op == 6'b000000 && exe_func == 6'b000100);
    wire exe_Sltu = (exe_op == 6'b000000 && exe_func == 6'b101011);
    wire exe_Sra = (exe_op == 6'b000000 && exe_func == 6'b000011);
    wire exe_Srl = (exe_op == 6'b000000 && exe_func == 6'b000010);
    wire exe_Subu = (exe_op == 6'b000000 && exe_func == 6'b100011);
    wire exe_Sw = (exe_op == 6'b101011);
    wire exe_Add = (exe_op == 6'b000000 && exe_func == 6'b100000);
    wire exe_Sub = (exe_op == 6'b000000 && exe_func == 6'b100010);
    wire exe_Slt = (exe_op == 6'b000000 && exe_func == 6'b101010);
    wire exe_Srlv = (exe_op == 6'b000000 && exe_func == 6'b000110);
    wire exe_Srav = (exe_op == 6'b000000 && exe_func == 6'b000111);
    //-------------------------------23plus
    wire exe_Clz = (exe_op == 6'b011100 && exe_func == 6'b100000);
    wire exe_Divu = (exe_op == 6'b000000 && exe_func == 6'b011011);
    wire exe_Eret = (exe_op == 6'b010000 && exe_func == 6'b011000);
    wire exe_Jalr = (exe_op == 6'b000000 && exe_func == 6'b001001);
    wire exe_Lb = (exe_op == 6'b100000);
    wire exe_Lbu = (exe_op == 6'b100100);
    wire exe_Lhu = (exe_op == 6'b100101);
    wire exe_Sb = (exe_op == 6'b101000);
    wire exe_Sh = (exe_op == 6'b101001);
    wire exe_Lh = (exe_op == 6'b100001);
    wire exe_Mfc0 = (exe_instr[31:21] == 11'b01000000000 && exe_instr[10:3]==8'b00000000);
    wire exe_Mfhi = (exe_op == 6'b000000 && exe_func == 6'b010000);
    wire exe_Mflo = (exe_op == 6'b000000 && exe_func == 6'b010010);
    wire exe_Mtc0 = (exe_instr[31:21] == 11'b01000000100 && exe_instr[10:3]==8'b00000000);
    wire exe_Mthi = (exe_op == 6'b000000 && exe_func == 6'b010001);
    wire exe_Mtlo = (exe_op == 6'b000000 && exe_func == 6'b010011);
    wire exe_Mul = (exe_op == 6'b011100 && exe_func == 6'b000010);
    wire exe_Multu = (exe_op == 6'b000000 && exe_func == 6'b011001);
    wire exe_Syscall = (exe_op == 6'b000000 && exe_func== 6'b001100);
    wire exe_Teq = (exe_op == 6'b000000 && exe_func == 6'b110100);
    wire exe_Bgez = (exe_op == 6'b000001);
    wire exe_Break = (exe_op == 6'b000000 && exe_func == 6'b001101);
    wire exe_Div = (exe_op == 6'b000000 && exe_func == 6'b011010);


    // MEM部分对指令进行译码
    wire [5:0] mem_op = mem_instr[31:26];
    wire [5:0] mem_func = mem_instr[5:0];
    wire [4:0] mem_rs = mem_instr[25:21];
    wire [4:0] mem_rt = mem_instr[20:16]; 
    wire [4:0] mem_rd = mem_instr[15:11];
    //-------------------------------31
    wire mem_Addi = (mem_op == 6'b001000);
    wire mem_Addiu = (mem_op == 6'b001001);
    wire mem_Andi = (mem_op == 6'b001100);
    wire mem_Ori = (mem_op == 6'b001101);
    wire mem_Sltiu = (mem_op == 6'b001011);
    wire mem_Lui = (mem_op == 6'b001111);
    wire mem_Xori = (mem_op == 6'b001110);
    wire mem_Slti = (mem_op == 6'b001010);
    wire mem_Addu = (mem_op == 6'b000000 && mem_func==6'b100001);
    wire mem_And = (mem_op == 6'b000000 && mem_func == 6'b100100);
    wire mem_Beq = (mem_op == 6'b000100);
    wire mem_Bne = (mem_op == 6'b000101);
    wire mem_J = (mem_op == 6'b000010);
    wire mem_Jal = (mem_op == 6'b000011);
    wire mem_Jr = (mem_op == 6'b000000 && mem_func == 6'b001000);
    wire mem_Lw = (mem_op == 6'b100011);
    wire mem_Xor = (mem_op == 6'b000000 && mem_func == 6'b100110);
    wire mem_Nor = (mem_op == 6'b000000 && mem_func == 6'b100111);
    wire mem_Or = (mem_op == 6'b000000 && mem_func == 6'b100101);
    wire mem_Sll = (mem_op == 6'b000000 && mem_func == 6'b000000);
    wire mem_Sllv = (mem_op == 6'b000000 && mem_func == 6'b000100);
    wire mem_Sltu = (mem_op == 6'b000000 && mem_func == 6'b101011);
    wire mem_Sra = (mem_op == 6'b000000 && mem_func == 6'b000011);
    wire mem_Srl = (mem_op == 6'b000000 && mem_func == 6'b000010);
    wire mem_Subu = (mem_op == 6'b000000 && mem_func == 6'b100011);
    wire mem_Sw = (mem_op == 6'b101011);
    wire mem_Add = (mem_op == 6'b000000 && mem_func == 6'b100000);
    wire mem_Sub = (mem_op == 6'b000000 && mem_func == 6'b100010);
    wire mem_Slt = (mem_op == 6'b000000 && mem_func == 6'b101010);
    wire mem_Srlv = (mem_op == 6'b000000 && mem_func == 6'b000110);
    wire mem_Srav = (mem_op == 6'b000000 && mem_func == 6'b000111);
    //-------------------------------23plus
    wire mem_Clz = (mem_op == 6'b011100 && mem_func == 6'b100000);
    wire mem_Divu = (mem_op == 6'b000000 && mem_func == 6'b011011);
    wire mem_Eret = (mem_op == 6'b010000 && mem_func == 6'b011000);
    wire mem_Jalr = (mem_op == 6'b000000 && mem_func == 6'b001001);
    wire mem_Lb = (mem_op == 6'b100000);
    wire mem_Lbu = (mem_op == 6'b100100);
    wire mem_Lhu = (mem_op == 6'b100101);
    wire mem_Sb = (mem_op == 6'b101000);
    wire mem_Sh = (mem_op == 6'b101001);
    wire mem_Lh = (mem_op == 6'b100001);
    wire mem_Mfc0 = (mem_instr[31:21] == 11'b01000000000 && mem_instr[10:3]==8'b00000000);
    wire mem_Mfhi = (mem_op == 6'b000000 && mem_func == 6'b010000);
    wire mem_Mflo = (mem_op == 6'b000000 && mem_func == 6'b010010);
    wire mem_Mtc0 = (mem_instr[31:21] == 11'b01000000100 && mem_instr[10:3]==8'b00000000);
    wire mem_Mthi = (mem_op == 6'b000000 && mem_func == 6'b010001);
    wire mem_Mtlo = (mem_op == 6'b000000 && mem_func == 6'b010011);
    wire mem_Mul = (mem_op == 6'b011100 && mem_func == 6'b000010);
    wire mem_Multu = (mem_op == 6'b000000 && mem_func == 6'b011001);
    wire mem_Syscall = (mem_op == 6'b000000 && mem_func== 6'b001100);
    wire mem_Teq = (mem_op == 6'b000000 && mem_func == 6'b110100);
    wire mem_Bgez = (mem_op == 6'b000001);
    wire mem_Break = (mem_op == 6'b000000 && mem_func == 6'b001101);
    wire mem_Div = (mem_op == 6'b000000 && mem_func == 6'b011010);


    // WB部分对指令进行译码
    wire [5:0] wb_op = wb_instr[31:26];
    wire [5:0] wb_func = wb_instr[5:0];
    wire [4:0] wb_rs = wb_instr[25:21];
    wire [4:0] wb_rt = wb_instr[20:16]; 
    wire [4:0] wb_rd = wb_instr[15:11];
    //-------------------------------31
    wire wb_Addi = (wb_op == 6'b001000);
    wire wb_Addiu = (wb_op == 6'b001001);
    wire wb_Andi = (wb_op == 6'b001100);
    wire wb_Ori = (wb_op == 6'b001101);
    wire wb_Sltiu = (wb_op == 6'b001011);
    wire wb_Lui = (wb_op == 6'b001111);
    wire wb_Xori = (wb_op == 6'b001110);
    wire wb_Slti = (wb_op == 6'b001010);
    wire wb_Addu = (wb_op == 6'b000000 && wb_func==6'b100001);
    wire wb_And = (wb_op == 6'b000000 && wb_func == 6'b100100);
    wire wb_Beq = (wb_op == 6'b000100);
    wire wb_Bne = (wb_op == 6'b000101);
    wire wb_J = (wb_op == 6'b000010);
    wire wb_Jal = (wb_op == 6'b000011);
    wire wb_Jr = (wb_op == 6'b000000 && wb_func == 6'b001000);
    wire wb_Lw = (wb_op == 6'b100011);
    wire wb_Xor = (wb_op == 6'b000000 && wb_func == 6'b100110);
    wire wb_Nor = (wb_op == 6'b000000 && wb_func == 6'b100111);
    wire wb_Or = (wb_op == 6'b000000 && wb_func == 6'b100101);
    wire wb_Sll = (wb_op == 6'b000000 && wb_func == 6'b000000);
    wire wb_Sllv = (wb_op == 6'b000000 && wb_func == 6'b000100);
    wire wb_Sltu = (wb_op == 6'b000000 && wb_func == 6'b101011);
    wire wb_Sra = (wb_op == 6'b000000 && wb_func == 6'b000011);
    wire wb_Srl = (wb_op == 6'b000000 && wb_func == 6'b000010);
    wire wb_Subu = (wb_op == 6'b000000 && wb_func == 6'b100011);
    wire wb_Sw = (wb_op == 6'b101011);
    wire wb_Add = (wb_op == 6'b000000 && wb_func == 6'b100000);
    wire wb_Sub = (wb_op == 6'b000000 && wb_func == 6'b100010);
    wire wb_Slt = (wb_op == 6'b000000 && wb_func == 6'b101010);
    wire wb_Srlv = (wb_op == 6'b000000 && wb_func == 6'b000110);
    wire wb_Srav = (wb_op == 6'b000000 && wb_func == 6'b000111);
    //-------------------------------23plus
    wire wb_Clz = (wb_op == 6'b011100 && wb_func == 6'b100000);
    wire wb_Divu = (wb_op == 6'b000000 && wb_func == 6'b011011);
    wire wb_Eret = (wb_op == 6'b010000 && wb_func == 6'b011000);
    wire wb_Jalr = (wb_op == 6'b000000 && wb_func == 6'b001001);
    wire wb_Lb = (wb_op == 6'b100000);
    wire wb_Lbu = (wb_op == 6'b100100);
    wire wb_Lhu = (wb_op == 6'b100101);
    wire wb_Sb = (wb_op == 6'b101000);
    wire wb_Sh = (wb_op == 6'b101001);
    wire wb_Lh = (wb_op == 6'b100001);
    wire wb_Mfc0 = (wb_instr[31:21] == 11'b01000000000 && wb_instr[10:3]==8'b00000000);
    wire wb_Mfhi = (wb_op == 6'b000000 && wb_func == 6'b010000);
    wire wb_Mflo = (wb_op == 6'b000000 && wb_func == 6'b010010);
    wire wb_Mtc0 = (wb_instr[31:21] == 11'b01000000100 && wb_instr[10:3]==8'b00000000);
    wire wb_Mthi = (wb_op == 6'b000000 && wb_func == 6'b010001);
    wire wb_Mtlo = (wb_op == 6'b000000 && wb_func == 6'b010011);
    wire wb_Mul = (wb_op == 6'b011100 && wb_func == 6'b000010);
    wire wb_Multu = (wb_op == 6'b000000 && wb_func == 6'b011001);
    wire wb_Syscall = (wb_op == 6'b000000 && wb_func== 6'b001100);
    wire wb_Teq = (wb_op == 6'b000000 && wb_func == 6'b110100);
    wire wb_Bgez = (wb_op == 6'b000001);
    wire wb_Break = (wb_op == 6'b000000 && wb_func == 6'b001101);
    wire wb_Div = (wb_op == 6'b000000 && wb_func == 6'b011010);

    // 处理冲突（数据相关）（可能是最难的部分了，呜呜呜）
    reg id_r_Rs;
    reg id_r_Rt;
    reg id_r_Hi;
    reg id_r_Lo;
    reg id_r_cp0;

    reg exe_w_reg;
    reg exe_w_hi;
    reg exe_w_lo;
    reg exe_w_cp0;
    reg [4:0] exe_w_rfaddr;

    reg exe_r_Rs;
    reg exe_r_Rt;
    reg exe_r_Hi;
    reg exe_r_Lo;
    reg exe_r_cp0;

    reg mem_w_reg;
    reg mem_w_hi;
    reg mem_w_lo;
    reg mem_w_cp0;
    reg [4:0] mem_w_rfaddr;

    reg mem_r_Rs;
    reg mem_r_Rt;
    reg mem_r_Hi;
    reg mem_r_Lo;
    reg mem_r_cp0;

    reg wb_w_reg;
    reg wb_w_hi;
    reg wb_w_lo;
    reg wb_w_cp0;
    reg [4:0] wb_w_rfaddr;


    // ID产生控制信号
    always @ (*)
    begin
        //hi_wena <= 0;
        //lo_wena <= 0;

        //cp0_mtc0 <= 0;
        //cp0_mfc0 <= 0;
        //cp0_exeception <= 0;
        //cp0_eret <= 0;
        cp0_cause <= 32'h0;

        //rf_wena <= 0;

        //ext_16_s <= 0;

        //div_start <= 0;
        //div_s <= 0;
        //mul_s <= 0;

        //aluc <= 6'h0;

        //dmem_wena <= 0;

        //muxPc_sel <= 3'h0;
        //muxHi_sel <= 6'h0;
        //muxLo_sel <= 6'h0;
        //muxAluA_sel <= 6'h0;
        //muxAluB_sel <= 6'h0;
        //muxData_sel <= 6'h0;
        //muxAddr_sel <= 6'h0;

        div_start <= id_Div | id_Divu;
        div_s <= id_Div;
        mul_s <= id_Mul;

        hi_wena <= id_Mthi;
        lo_wena <= id_Mtlo;

        muxHi_sel[0] <= id_Mthi;
        muxHi_sel[1] <= id_Mul | id_Multu;
        muxHi_sel[2] <= id_Div | id_Divu;
        muxHi_sel[3] <= 0;
        muxHi_sel[4] <= 0;
        muxHi_sel[5] <= 0;

        muxLo_sel[0] <= id_Mtlo;
        muxLo_sel[1] <= id_Mul | id_Multu;
        muxLo_sel[2] <= id_Div | id_Divu;
        muxLo_sel[3] <= 0;
        muxLo_sel[4] <= 0;
        muxLo_sel[5] <= 0;


        cp0_mtc0 <= id_Mtc0;
        cp0_mfc0 <= id_Mfc0;

        cp0_exeception <= id_Break | id_Syscall | (id_Teq & beq);

        cp0_eret <= id_Eret;

        rf_wena <= ~(id_Beq | id_Bne | id_J | id_Jr | id_Sw | id_Divu | id_Sb | id_Sh | id_Mtc0 | id_Mthi | id_Mtlo | id_Multu | id_Syscall | id_Teq | id_Bgez | id_Break | id_Div);

        ext_16_s <= id_Addi | id_Slti | id_Sw | id_Lw | id_Sh | id_Lh | id_Lhu | id_Sb | id_Lb | id_Lbu;

        aluc[0] <= id_Addiu | id_Ori | id_Sltiu | id_Lui | id_Addu | id_Nor | id_Or | id_Sltu | id_Sra | id_Subu | id_Srav;
        aluc[1] <= id_Sltiu | id_Lui | id_Xori | id_Slti | id_Xor | id_Nor | id_Sltu | id_Sra | id_Srl | id_Subu | id_Sub | id_Slt | id_Srlv | id_Srav;
        aluc[2] <= id_Andi | id_Ori | id_Lui | id_Xori | id_And | id_Xor | id_Nor | id_Or | id_Sllv | id_Srlv | id_Srav;
        aluc[3] <= id_Sltiu | id_Lui | id_Slti | id_Sltu | id_Slt;
        aluc[4] <= 0;
        aluc[5] <= ~(id_Lui | id_Sra | id_Srl | id_Srlv | id_Srav | id_Sll | id_Sllv);

        flag_rs <= ~(id_J | id_Srl | id_Lui);

        muxAluA_sel[0] <= ~(id_Sll | id_Srl | id_Sra);
        muxAluA_sel[1] <= id_Sll | id_Srl | id_Sra;
        muxAluA_sel[2] <= 0;
        muxAluA_sel[3] <= 0;
        muxAluA_sel[4] <= 0;
        muxAluA_sel[5] <= 0;

        muxAluB_sel[0] <= id_Addi | id_Addiu | id_Andi | id_Ori | id_Xori | id_Lw | id_Sw | id_Lb | id_Sb | id_Lh | id_Sh | id_Lbu | id_Lhu | id_Slti | id_Sltiu | id_Lui;
        muxAluB_sel[1] <= ~(id_Addi | id_Addiu | id_Andi | id_Ori | id_Xori | id_Lw | id_Sw | id_Lb | id_Sb | id_Lh | id_Sh | id_Lbu | id_Lhu | id_Slti | id_Sltiu | id_Lui);
        muxAluB_sel[2] <= 0;
        muxAluB_sel[3] <= 0;
        muxAluB_sel[4] <= 0;
        muxAluB_sel[5] <= 0;

        muxPc_sel[0] <= (id_Beq & beq) | (id_Bne & !beq) | id_Eret | id_Break | id_Syscall | (id_Teq & beq);
        muxPc_sel[1] <= id_J | id_Jal | id_Eret | id_Break | id_Syscall | (id_Teq & beq);
        muxPc_sel[2] <= id_Jr | id_Jalr | id_Break | id_Syscall | (id_Teq & beq);

        muxData_sel[0] <= ~(id_Clz | id_Jal | id_Jalr | id_Lw | id_Lh | id_Lhu | id_Lb | id_Lbu | id_Mfc0 | id_Mfhi | id_Mul);
        muxData_sel[1] <= id_Jal | id_Jalr | id_Mul;
        muxData_sel[2] <= id_Clz;
        muxData_sel[3] <= id_Lw | id_Lh | id_Lhu | id_Lb | id_Lbu;
        muxData_sel[4] <= id_Mfc0;
        muxData_sel[5] <= id_Mfhi | id_Mflo | id_Mul;

        muxAddr_sel[0] <= id_Addi | id_Addiu | id_Andi | id_Ori | id_Sltiu | id_Lui | id_Xori | id_Slti | id_Lw | id_Lh | id_Lhu | id_Lb | id_Lbu | id_Mfc0;
        muxAddr_sel[1] <= id_Addu | id_And | id_Xor | id_Nor | id_Or | id_Sll | id_Sllv | id_Sltu | id_Sra | id_Srl | id_Subu | id_Add | id_Sub | id_Slt | id_Srlv | id_Srav | id_Clz | id_Jalr | id_Mflo | id_Mfhi | id_Mul;
        muxAddr_sel[2] <= id_Jal;
        muxAddr_sel[3] <= 0;
        muxAddr_sel[4] <= 0;
        muxAddr_sel[5] <= 0;

        dmem_wena <= id_Sw | id_Sb | id_Sh;

        cDR_width_sign[0] <= id_Sw | id_Lw;
        cDR_width_sign[1] <= id_Sh | id_Lh | id_Lhu;
        cDR_width_sign[2] <= id_Sb | id_Lb | id_Lbu;

        cDR_sign <= ~(id_Lhu | id_Lbu);

        cRD_width_sign[0] <= id_Sw | id_Lw;
        cRD_width_sign[1] <= id_Sh | id_Lh | id_Lhu;
        cRD_width_sign[2] <= id_Sb | id_Lb | id_Lbu;

        cRD_sign <= ~(id_Lhu | id_Lbu);
        
        //if(id_Addi)
        //begin
        //    muxAluA_sel <= 6'b000001;
        //    muxAluB_sel <= 6'b000001;
        //    ext_16_s <= 1'b1;
        //    aluc <= 6'b100000;
        //    rf_wena <= 1'b1;
        //    muxData_sel <= 6'b000001;
        //    muxAddr_sel <= 6'b000001;
        //end
    end

    always @ (*)
    begin
        id_r_Rs <= id_Addi | id_Addu | id_Sw | id_Lw | id_Add | id_Mul | id_Slti | id_Bne;
        id_r_Rt <= id_Lui | id_Addu | id_Sw | id_Srl | id_Add | id_Mul | id_Bne;
        id_r_Hi <= 0;
        id_r_Lo <= 0;
        id_r_cp0 <= 0;

        exe_w_reg <= exe_Addi | exe_Lui | exe_Addu | exe_Srl | exe_Add | exe_Mul | exe_Slti;
        exe_w_hi <= exe_Mul;
        exe_w_lo <= exe_Mul;
        exe_w_cp0 <= 0;
        exe_w_rfaddr <= (exe_Addi | exe_Lui | exe_Slti) ? exe_rt : exe_rd;

        exe_r_Rs <= exe_Addi | exe_Addu | exe_Sw | id_Lw | exe_Add | exe_Mul | exe_Slti | exe_Bne;
        exe_r_Rt <= exe_Lui | exe_Addu | exe_Sw | exe_Srl | exe_Add | exe_Mul | exe_Bne;
        exe_r_Hi <= 0;
        exe_r_Lo <= 0;
        exe_r_cp0 <= 0;

        mem_w_reg <= mem_Addi | mem_Lui | mem_Addu | mem_Srl | mem_Add | mem_Mul | mem_Slti;
        mem_w_hi <= mem_Mul;
        mem_w_lo <= mem_Mul;
        mem_w_cp0 <= 0;
        mem_w_rfaddr <= (mem_Addi | mem_Lui | mem_Slti) ? mem_rt : mem_rd;

        mem_r_Rs <= mem_Addi | mem_Addu | mem_Sw | id_Lw | mem_Add | mem_Mul | mem_Slti | mem_Bne;
        mem_r_Rt <= mem_Lui | mem_Addu | mem_Sw | mem_Srl | mem_Add | mem_Mul | mem_Bne;
        mem_r_Hi <= 0;
        mem_r_Lo <= 0;
        mem_r_cp0 <= 0;

        wb_w_reg <= wb_Addi | wb_Lui | wb_Addu | wb_Srl | wb_Add | wb_Mul | wb_Slti;
        wb_w_hi <= wb_Mul;
        wb_w_lo <= wb_Mul;
        wb_w_cp0 <= 0;
        wb_w_rfaddr <= (wb_Addi | wb_Lui | wb_Slti) ? wb_rt : wb_rd;
    end

    //assign stall = 6'b000000;
    // 暂停
    
    always @ (*)
    begin
        stall <= 6'b000000;
        collision <= 4'b0000;
        collision_hilo <= 9'b0;
        if(exe_w_reg)
        begin
            if(id_r_Rs && id_rs == exe_w_rfaddr)
            begin
                // stall <= 6'b000011;
                collision[0] <= 1'b1;
            end
            if(id_r_Rt && id_rt == exe_w_rfaddr)
            begin
                collision[1] <= 1'b1;
            end
        end
        else if(exe_w_hi && id_r_Hi)
        begin
            // stall <= 6'b000011;
            collision_hilo[0] <= 1'b1;
        end
        else if(exe_w_lo && id_r_Lo)
        begin
            // stall <= 6'b000011;
            collision_hilo[1] <= 1'b1;
        end
        else if(exe_w_cp0 && id_r_cp0)
        begin
            // stall <= 6'b000011;
            collision_hilo[2] <= 1'b1;
        end
        if(mem_w_reg)
        begin
            if(id_r_Rs && id_rs == mem_w_rfaddr)
            begin
                // stall <= 6'b000011;
                collision[2] <= 1'b1;
            end
            if(id_r_Rt && id_rt == mem_w_rfaddr)
            begin
                collision[3] <= 1'b1;
            end
            // else if((exe_r_Rs && exe_rs == mem_w_rfaddr) || (exe_r_Rt && exe_rt == mem_w_rfaddr))
            // begin
            //     stall <= 6'b000111;
            // end
        end
        else if(mem_w_hi && id_r_Hi)
        begin
            // stall <= 6'b000011;
            collision_hilo[3] <= 1'b1;
        end
        else if(mem_w_lo && id_r_Lo)
        begin
            // stall <= 6'b000011;
            collision_hilo[4] <= 1'b1;
        end
        else if(mem_w_cp0 && id_r_cp0)
        begin
            // stall <= 6'b000011;
            collision_hilo[5] <= 1'b1;
        end
        
        if(wb_w_reg)
        begin
            if(id_r_Rs && id_rs == wb_w_rfaddr)
            begin
                // stall <= 6'b000011;
                collision[4] <= 1'b1;
            end
            if(id_r_Rt && id_rt == wb_w_rfaddr)
            begin
                collision[5] <= 1'b1;
            end
            // else if((exe_r_Rs && exe_rs == wb_w_rfaddr) || (exe_r_Rt && exe_rt == wb_w_rfaddr))
            // begin
            //     stall <= 6'b000111;
            // end
            // else if((mem_r_Rs && mem_rs == wb_w_rfaddr) || (mem_r_Rt && mem_rt == wb_w_rfaddr))
            // begin
            //     stall <= 6'b001111;
            // end
        end
        else if(wb_w_hi && id_r_Hi)
        begin
            // stall <= 6'b000011;
            collision_hilo[6] <= 1'b1;
        end
        else if(wb_w_lo && id_r_Lo)
        begin
            // stall <= 6'b000011;
            collision_hilo[7] <= 1'b1;
        end
        else if(wb_w_cp0 && id_r_cp0)
        begin
            // stall <= 6'b000011;
            collision_hilo[8] <= 1'b1;
        end
        
        if(exe_Div | exe_Divu)
        begin
            if(is_div)
            begin
                stall <= 6'b000111;
            end
        end

        if(halt)
        begin
            // stall <= 6'b111111;
        end
    end
    
endmodule