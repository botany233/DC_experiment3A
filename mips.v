module mips(
    input clk, rst_n,
    output wire [31:0] pc_next, pc, instr, sign_imm, srca, alu_result,
    output wire [3:0] alu_op,
    output wire reg_write, zero
);
    //取指令
    pc pc1(.clk(clk), .rst_n(rst_n), .pc_next(pc_next), .pc(pc));
    assign pc_next = pc + 4;
    imem imem1(.addr_i(pc), .instr(instr));

    //指令译码
    controller controller1(
        .op_i(instr[31:26]),
        .funct_i(instr[5:0]),
        .reg_write(reg_write),
        .mem_write(mem_write),
        .alu_op(alu_op)
    );

    //寄存器堆
    regfile regfile1(
        .clk(clk),
        .we(reg_write),
        .a1(instr[25:21]),
        .a3(instr[20:16]),
        .wd(alu_result),
        .r1(srca)
    );

    //立即数有符号扩展
    sign_extend sign_extend1(.imm(instr[15:0]), .sign_imm(sign_imm));

    //alu
    alu alu1(
        .srca_i(srca),
        .srcb_i(sign_imm),
        .aluop_i(alu_op),
        .zero(zero),
        .alu_result(alu_result)
    );
endmodule