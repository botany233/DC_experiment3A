`timescale 1ns/1ns
module tb_mips();
    reg clk, rst_n;
    wire [31:0] pc_next, pc, instr, sign_imm, srca, alu_result, srcb, pc_plus_4, pc_jump, pc_temp, r1, r2;
    wire [3:0] alu_op;
    wire reg_write, zero, jump, jr;
    wire [31:0] regfile [31:0];

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
        .zero(zero),
        .srcb(srcb),
        .jump(jump),
        .pc_plus_4(pc_plus_4),
        .pc_jump(pc_jump),
        .pc_temp(pc_temp),
        .r1(r1),
        .jr(jr),
        .r2(r2)
    );

    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin
            assign regfile[i] = mips1.regfile1.rf[i];
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