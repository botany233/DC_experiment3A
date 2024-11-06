`timescale 1ns/1ns
module tb_mips();
    reg clk, rst_n;
    wire [31:0] pc_next, pc, instr, sign_imm, srca, alu_result;
    wire [3:0] alu_op;
    wire reg_write, zero;

    mips mips1(
        .clk(clk),
        .rst_n(rst_n),
        .pc_next(pc_next),
        .pc(pc),
        .instr(instr),
        .sign_imm(sign_imm),
        .srca(srca),
        .alu_result(alu_result),
        .alu_op(alu_op),
        .reg_write(reg_write),
        .zero(zero)
    );

    initial begin
        rst_n = 0;
        #5 rst_n = 1;
    end

    initial begin
        clk = 1;
        forever #5 clk = ~clk;
    end
endmodule