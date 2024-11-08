`include "mips_para.v"
//指令译码器
module controller(
    input [5:0] op_i,
    input [5:0] funct_i,
    output reg reg_write,
    output reg mem_write,
    output reg [3:0] alu_op,
    output reg alu_srcb,
    output reg reg_dst
);
    always @(*) begin
        //寄存器写入控制信号
        case(op_i)
            //立即数加法, 立即数按位求与, 立即数按位求或, 立即数按位异或, 立即数小于比较
            `ADDI, `ANDI, `ORI, `XORI, `SLTI: reg_write <= 1'b1;
            `R_TYPE: begin
                case (funct_i)
                    //加法
                    `ADD: reg_write <= 1'b1;
                    default: reg_write <= 1'b0;
                endcase
            end
            default: reg_write <= 1'b0;
        endcase

        //ALU操作控制信号
        case (op_i)
            `ADDI: alu_op <= `alu_add;//立即数加法
            `ANDI: alu_op <= `alu_and;//立即数按位求与
            `ORI: alu_op <= `alu_or;//立即数按位求或
            `XORI: alu_op <= `alu_xor;//立即数按位异或
            `SLTI: alu_op <= `alu_slt;//立即数小于比较
            `R_TYPE: begin
                case (funct_i)
                    `ADD: alu_op <= `alu_add;//加法
                    default: alu_op <= 4'bx;
                endcase
            end
            default: alu_op <= 4'bx;
        endcase

        //alu输入控制信号
        case (op_i)
            `R_TYPE: begin//R型指令
                case (funct_i)
                    //加法
                    `ADD: alu_srcb <= 1'b0;
                    default: alu_srcb <= 1'b1;
                endcase
            end
            default: alu_srcb <= 1'b1;
        endcase

        //寄存器写入地址控制信号
        case (op_i)
            `R_TYPE: begin//R型指令
                case (funct_i)
                    `ADD: reg_dst <= 1'b1;
                    default: reg_dst <= 1'b0;
                endcase
            end
            default: reg_dst <= 1'b0;
        endcase
    end
endmodule