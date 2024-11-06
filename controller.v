`include "mips_para.v"
//指令译码器
module controller(
    input [5:0] op_i,
    input [5:0] funct_i,
    output reg reg_write,
    output reg mem_write,
    output reg [3:0] alu_op
);
    always @(*) begin
        case(op_i)
            `ADDI: reg_write <= 1'b1;
            default: reg_write <= 1'b0;
        endcase
    end

    always @(*) begin
        case (op_i)
            `ADDI: alu_op <= `alu_add;
            default: alu_op <= 4'bx;
        endcase
    end
endmodule