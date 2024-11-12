module mips(
    input clk, rst_n,
    //alu运算结果、寄存器写入内容中间量1、寄存器写入内容中间量2、寄存器写入内容
    output wire [31:0] alu_result, result, result_extimm, reg_wrd,
    //当前指令、扩展立即数
    output wire [31:0] instr, sign_imm,
    //寄存器输出1、寄存器输出2、alu输入1、alu输入2、存储器输出、指令地址转移分支
    output wire [31:0] r1, r2, srca, srcb, read_data, pc_branch,
    //当前指令地址、指令地址+4、指令跳转地址、下一条指令地址、下一条指令地址中间量1、下一条指令地址中间量2
    output wire [31:0] pc, pc_plus_4, pc_jump, pc_next, pc_sel_1, pc_sel_2,
    //扩展立即数控制信号
    output wire [1:0] ext_op,
    //alu控制信号
    output wire [3:0] alu_op,
    //寄存器写入地址、寄存器写入地址中间量
    output wire [4:0] reg_wra, rt_rd,
    //寄存器写入控制信号、存储器写入控制信号、寄存器输出为0、寄存器写入地址控制信号1、寄存器写入地址控制信号2
    output wire reg_write, mem_write, zero, reg_dst, ra_dst,
    //下一条指令地址控制信号1、下一条指令地址控制信号2、alu输入1控制信号、alu输入2控制信号
    output wire jump, jr, alu_srca, alu_srcb, 
    //相等转移信号、相等转移控制信号、不相等转移控制信号、小于等于0转移控制信号、大于0转移控制信号
    output wire branch, beq, bne, blez, bgtz,
    //寄存器写入内容控制信号1、寄存器写入内容控制信号2、寄存器写入内容控制信号3
    output wire mem_to_reg, lui, pc_to_reg
);
    //取指令
    pc pc1(.clk(clk), .rst_n(rst_n), .pc_next(pc_next), .pc(pc));
    assign pc_plus_4 = pc + 4;

    //指令寄存器、存储器
    imem imem1(.addr_i(pc), .instr(instr));
    dmem dmem1(.clk(clk), .we(mem_write), .write_data(r2), .read_data(read_data), .addr(alu_result));

    //相等转移信号
    assign branch = ((beq & zero) | (bne & ~zero) | (blez & $signed(r1) <= 0) | (bgtz & $signed(r1) > 0)) == 1'b1;
    assign pc_branch = pc_plus_4 + {sign_imm[29:0], 2'b0};

    //指令跳转地址
    assign pc_jump = {pc_plus_4[31:28], instr[25:0], 2'b0};

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
        .jr(jr),
        .mem_to_reg(mem_to_reg),
        .beq(beq),
        .lui(lui),
        .bne(bne),
        .ra_dst(ra_dst),
        .pc_to_reg(pc_to_reg),
        .bgtz(bgtz),
        .blez(blez)
    );

    //寄存器堆
    regfile regfile1(
        .clk(clk),
        .we(reg_write),
        .a1(instr[25:21]),
        .a2(instr[20:16]),
        .a3(reg_wra),
        .wd(reg_wrd),
        .r1(r1),
        .r2(r2)
    );

    //立即数有符号扩展
    sign_extend sign_extend1(.imm(instr[15:0]), .sign_imm(sign_imm), .ext_op(ext_op));

    //ALU
    alu alu1(
        .srca_i(srca),
        .srcb_i(srcb),
        .aluop_i(alu_op),
        .zero(zero),
        .alu_result(alu_result)
    );

    //选择0:rt还是1:rd作为寄存器写入地址中间量
    mux2 #(5) mux2_1(.a(instr[20:16]), .b(instr[15:11]), .s(reg_dst), .y(rt_rd));

    //选择0:寄存器输出2还是1:扩展后立即数作为alu输入2
    mux2 #(32) mux2_2(.a(r2), .b(sign_imm), .s(alu_srcb), .y(srcb));

    //选择0:下一条指令地址中间量1还是1:指令跳转地址作为下一条指令地址中间量2
    mux2 #(32) mux2_3(.a(pc_sel_1), .b(pc_jump), .s(jump), .y(pc_sel_2));

    //选择0:寄存器输出1还是1:寄存器输出2作为alu输入1
    mux2 #(32) mux2_4(.a(r1), .b(sign_imm), .s(alu_srca), .y(srca));

    //选择0:下一条指令地址中间量2还是1:寄存器输出1作为下一条指令地址
    mux2 #(32) mux2_5(.a(pc_sel_2), .b(r1), .s(jr), .y(pc_next));

    //选择0:alu运算结果还是1:存储器输出作为alu&存储器输出
    mux2 #(32) mux2_6(.a(alu_result), .b(read_data), .s(mem_to_reg), .y(result));

    //选择0:指令地址+4还是1:指令地址转移分支作为下一条指令地址中间量1
    mux2 #(32) mux2_7(.a(pc_plus_4), .b(pc_branch), .s(branch), .y(pc_sel_1));

    //选择0:寄存器写入内容中间量1还是1:扩展立即数作为寄存器写入内容中间量2
    mux2 #(32) mux2_8(.a(result), .b(sign_imm), .s(lui), .y(result_extimm));

    //选择0:寄存器写入地址中间量还是1:31($ra)作为寄存器写入地址
    mux2 #(5) mux2_9(.a(rt_rd), .b(5'b11111), .s(ra_dst), .y(reg_wra));

    //选择0:寄存器写入内容中间量2还是1:指令地址+4作为寄存器写入内容
    mux2 #(32) mux2_10(.a(result_extimm), .b(pc_plus_4), .s(pc_to_reg), .y(reg_wrd));
endmodule