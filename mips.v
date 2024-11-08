module mips(
    input clk, rst_n,
    //当前指令、扩展立即数、lui输出信号后
    output wire [31:0] instr, sign_imm, result_extimm,
    //寄存器输出1、寄存器输出2、alu输入1、alu输入2、alu运算结果、存储器输出、alu&存储器输出、指令地址转移分支
    output wire [31:0] r1, r2, srca, srcb, alu_result, read_data, result, pc_branch,
    //当前指令地址、指令地址+4、指令跳转地址、下一条指令地址、下一条指令地址中间量1、下一条指令地址中间量2
    output wire [31:0] pc, pc_plus_4, pc_jump, pc_next, pc_sel_1, pc_sel_2,
    //扩展立即数控制信号
    output wire [1:0] ext_op,
    //alu控制信号
    output wire [3:0] alu_op,
    //寄存器写入地址
    output wire [4:0] reg_wra,
    //寄存器写入控制信号、存储器写入控制信号、寄存器输出为0、寄存器写入地址控制信号、lui控制信号
    output wire reg_write, mem_write, zero, reg_dst, lui,
    //下一条指令地址控制信号1、下一条指令地址控制信号2、alu输入1控制信号、alu输入2控制信号、alu&存储器输出控制信号
    output wire jump, jr, alu_srca, alu_srcb, mem_to_reg,
    //相等转移信号、相等转移控制信号、相等转移控制信号
    output wire pc_src, beq, bne
);
    //取指令
    pc pc1(.clk(clk), .rst_n(rst_n), .pc_next(pc_next), .pc(pc));
    assign pc_plus_4 = pc + 4;

    //指令寄存器、存储器
    imem imem1(.addr_i(pc), .instr(instr));
    dmem dmem1(.clk(clk), .we(mem_write), .write_data(r2), .read_data(read_data), .addr(alu_result));

    //相等转移信号
    assign pc_src = (beq & zero) | (bne & ~zero);
    assign pc_branch = pc_plus_4 + {sign_imm[29:0], 2'b0};

    //指令跳转地址
    assign pc_jump = {pc_plus_4[31:28], instr[25:0], 2'b0};

    //选择0:指令地址+4还是1:指令地址转移分支作为alu&存储器输出
    mux2 #(32) mux2_8(.a(result), .b(sign_imm), .s(lui), .y(result_extimm));

    //选择0:指令地址+4还是1:指令地址转移分支作为alu&存储器输出
    mux2 #(32) mux2_7(.a(pc_plus_4), .b(pc_branch), .s(pc_src), .y(pc_sel_1));

    //选择0:alu运算结果还是1:存储器输出作为alu&存储器输出
    mux2 #(32) mux2_6(.a(alu_result), .b(read_data), .s(mem_to_reg), .y(result));

    //选择0:下一条指令地址中间量1还是1:指令跳转地址作为下一条指令地址中间量2
    mux2 #(32) mux2_3(.a(pc_sel_1), .b(pc_jump), .s(jump), .y(pc_sel_2));

    //选择0:下一条指令地址中间量2还是1:寄存器输出1作为下一条指令地址
    mux2 #(32) mux2_5(.a(pc_sel_2), .b(r1), .s(jr), .y(pc_next));

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
        .bne(bne)
    );

    //寄存器堆
    regfile regfile1(
        .clk(clk),
        .we(reg_write),
        .a1(instr[25:21]),
        .a2(instr[20:16]),
        .a3(reg_wra),
        .wd(result_extimm),
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