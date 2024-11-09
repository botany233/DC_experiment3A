`timescale 1ns/1ns
module tb_mips();
    reg clk, rst_n;
    wire [31:0] pc_next, pc, instr, sign_imm, srca, alu_result, srcb, r1, r2, reg_wrd, pc_branch, pc_sel_1, pc_sel_2;
    wire zero, branch, test1, test2, test3, test4, test5, test6;
    wire [31:0] regfile [31:0];
    wire [31:0] dmem [31:0];

    mips mips1(
        .clk(clk),
        .rst_n(rst_n),
        .pc_next(pc_next),
        .pc(pc),
        .instr(instr),
        .sign_imm(sign_imm),
        .srca(srca),
        .srcb(srcb),
        .alu_result(alu_result),
        .zero(zero),
        .r1(r1),
        .r2(r2),
        .reg_wrd(reg_wrd),
        .branch(branch),
        .pc_branch(pc_branch),
        .pc_sel_1(pc_sel_1),
        .pc_sel_2(pc_sel_2),
        .test1(test1),
        .test2(test2),
        .test3(test3),
        .test4(test4),
        .test5(test5),
        .test6(test6)
    );

    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin
            assign regfile[i] = mips1.regfile1.rf[i];
        end
    endgenerate

    genvar j;
    generate
        for (j = 0; j < 32; j = j + 1) begin
            assign dmem[j] = mips1.dmem1.ram[j];
        end
    endgenerate

    initial begin
        rst_n = 0;
        #5 rst_n = 1;
    end

    initial begin
        clk = 1;
        forever #5 clk = ~clk;
    end
endmodule