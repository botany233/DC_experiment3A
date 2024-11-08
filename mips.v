module mips(
    input clk, rst_n,
    //下一条指令地址、当前指令地址、当前指令、扩展立即数、指令跳转地址、指令地址+4、下一条指令地址中间量
    output wire [31:0] pc_next, pc, instr, sign_imm, pc_jump, pc_plus_4, pc_temp,
    //寄存器输出1、寄存器输出2、alu输入1、alu输入2、alu运算结果
    output wire [31:0] r1, r2, srca, srcb, alu_result,
    //alu控制信号
    output wire [3:0] alu_op,
    //寄存器写入地址
    output wire [4:0] reg_wra,
    //寄存器写入控制信号、寄存器输出为0、寄存器写入地址控制信号、扩展立即数控制信号
    output wire reg_write, zero, reg_dst, ext_op,
    //下一条指令地址控制信号1、下一条指令地址控制信号2、alu输入1控制信号、alu输入2控制信号
    output wire jump, jr, alu_srca, alu_srcb
);
    //取指令
    pc pc1(.clk(clk), .rst_n(rst_n), .pc_next(pc_next), .pc(pc));
    assign pc_plus_4 = pc + 4;
    imem imem1(.addr_i(pc), .instr(instr));

    //指令跳转地址
    assign pc_jump = {pc_plus_4[31:28], instr[25:0], 2'b0};

    //选择0:指令地址+4还是1:指令跳转地址作为下一条指令地址中间量
    mux2 #(32) mux2_3(.a(pc_plus_4), .b(pc_jump), .s(jump), .y(pc_temp));

    //选择0:下一条指令地址中间量还是1:寄存器输出1作为下一条指令地址
    mux2 #(32) mux2_5(.a(pc_temp), .b(r1), .s(jr), .y(pc_next));

    //指令译码
    controller controller1(
        .op_i(instr[31:26]),
        .funct_i(instr[5:0]),
        .reg_write(reg_write),
        .mem_write(mem_write),
        .alu_op(alu_op),
        .alu_srcb(alu_srcb),
        .reg_dst(reg_dst),
        .jump(jump),
        .ext_op(ext_op),
        .alu_srca(alu_srca),
        .jr(jr)
    );

    //寄存器堆
    regfile regfile1(
        .clk(clk),
        .we(reg_write),
        .a1(instr[25:21]),
        .a2(instr[20:16]),
        .a3(reg_wra),
        .wd(alu_result),
        .r1(r1),
        .r2(r2)
    );

    //选择0:寄存器输出1还是1:寄存器输出2作为alu输入1
    mux2 #(32) mux2_4(.a(r1), .b(r2), .s(alu_srca), .y(srca));

    //选择0:rt还是1:rd作为寄存器写入地址
    mux2 #(5) mux2_1(.a(instr[20:16]), .b(instr[15:11]), .s(reg_dst), .y(reg_wra));

    //立即数有符号扩展
    sign_extend sign_extend1(.imm(instr[15:0]), .sign_imm(sign_imm), .ext_op(ext_op));

    //选择0:寄存器输出2还是1:扩展后立即数作为alu输入2
    mux2 #(32) mux2_2(.a(r2), .b(sign_imm), .s(alu_srcb), .y(srcb));

    //alu
    alu alu1(
        .srca_i(srca),
        .srcb_i(srcb),
        .aluop_i(alu_op),
        .zero(zero),
        .alu_result(alu_result)
    );
endmodule