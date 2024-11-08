`include "mips_para.v"
//指令译码器
module controller(
    input [5:0] op_i,
    input [5:0] funct_i,
    output reg [3:0] alu_op,
    output reg [1:0] ext_op,
    output reg reg_write, mem_write, alu_srcb, reg_dst, jump, alu_srca, jr, mem_to_reg, beq, lui, bne
);
    always @(*) begin
        //寄存器写入控制信号
        case(op_i)
            //立即数加法、立即数按位求与、立即数按位求或、立即数按位异或、立即数小于比较、读取字、装入立即数高位
            `ADDI, `ANDI, `ORI, `XORI, `SLTI, `LW, `LUI: reg_write <= 1'b1;
            `R_TYPE: begin
                case (funct_i)
                    //加法、减法、求与、求或、异或、小于比较、无符号小于比较、逻辑左移、逻辑右移、算数右移
                    `ADD, `SUB, `AND, `OR, `XOR, `SLT, `SLTU, `SLL, `SRL, `SRA: reg_write <= 1'b1;
                    default: reg_write <= 1'b0;
                endcase
            end
            default: reg_write <= 1'b0;
        endcase

        //ALU操作控制信号
        case (op_i)
            `ADDI, `LW, `SW: alu_op <= `alu_add;//立即数加法、读取字
            `ANDI: alu_op <= `alu_and;//立即数按位求与
            `ORI: alu_op <= `alu_or;//立即数按位求或
            `XORI: alu_op <= `alu_xor;//立即数按位异或
            `SLTI: alu_op <= `alu_slt;//立即数小于比较
            `BEQ, `BNE: alu_op <= `alu_sub;//如果相等则转移、如果不相等则转移
            `R_TYPE: begin
                case (funct_i)
                    `ADD: alu_op <= `alu_add;//加法
                    `SUB: alu_op <= `alu_sub;//减法
                    `AND: alu_op <= `alu_and;//求与
                    `OR: alu_op <= `alu_or;//求或
                    `XOR: alu_op <= `alu_xor;//异或
                    `SLT: alu_op <= `alu_slt;//小于比较
                    `SLTU: alu_op <= `alu_sltu;//无符号小于比较
                    `SLL: alu_op <= `alu_shl;//逻辑左移
                    `SRL: alu_op <= `alu_shr;//逻辑右移
                    `SRA: alu_op <= `alu_sar;//算数右移
                    default: alu_op <= 4'bx;
                endcase
            end
            default: alu_op <= 4'bx;
        endcase

        //alu输入2控制信号
        case (op_i)
            `BEQ, `BNE: alu_srcb <= 1'b0;
            `R_TYPE: begin//R型指令
                case (funct_i)
                    //加法、减法、求与、求或、异或、小于比较、无符号小于比较
                    `ADD, `SUB, `AND, `OR, `XOR, `SLT, `SLTU: alu_srcb <= 1'b0;
                    default: alu_srcb <= 1'b1;
                endcase
            end
            default: alu_srcb <= 1'b1;
        endcase

        //寄存器写入地址控制信号
        case (op_i)
            `R_TYPE: begin//R型指令
                case (funct_i)
                    //加法、减法、求与、求或、异或、小于比较、无符号小于比较、逻辑左移、逻辑右移、算数右移
                    `ADD, `SUB, `AND, `OR, `XOR, `SLT, `SLTU, `SLL, `SRL, `SRA: reg_dst <= 1'b1;
                    default: reg_dst <= 1'b0;
                endcase
            end
            default: reg_dst <= 1'b0;
        endcase

        //pc_next控制信号1
        case (op_i)
            `J: jump <= 1'b1;//跳转
            default: jump <= 1'b0;
        endcase

        //pc_next控制信号2
        case (op_i)
            `R_TYPE: begin//R型指令
                case (funct_i)
                    `JR: jr <= 1'b1;//跳转寄存器
                    default: jr <= 1'b0;
                endcase
            end
            default: jr <= 1'b0;
        endcase

        //立即数扩展控制信号
        case (op_i)
            `LUI: ext_op <= 2'b11;//装入立即数高位
            `R_TYPE: begin//R型指令
                case (funct_i)
                    //逻辑左移、逻辑右移、算数右移
                    `SLL, `SRL, `SRA: ext_op <= 2'b10;
                    default: ext_op <= 2'b00;
                endcase
            end
            default: ext_op <= 2'b00;
        endcase

        //alu输入1控制信号
        case (op_i)
            `R_TYPE: begin//R型指令
                case (funct_i)
                    //逻辑左移、逻辑右移、算数右移
                    `SLL, `SRL, `SRA: alu_srca <= 1'b1;
                    default: alu_srca <= 1'b0;
                endcase
            end
            default: alu_srca <= 1'b0;
        endcase

        //alu输出&存储器输出控制信号
        case (op_i)
            `LW: mem_to_reg <= 1'b1;
            default: mem_to_reg <= 1'b0;
        endcase

        //存储器写入控制信号
        case (op_i)
            `SW: mem_write <= 1'b1;
            default: mem_write <= 1'b0;
        endcase

        //相等转移控制信号
        case (op_i)
            `BEQ: beq <= 1'b1;
            default: beq <= 1'b0;
        endcase

        //不相等转移控制信号
        case (op_i)
            `BNE: bne <= 1'b1;
            default: bne <= 1'b0;
        endcase

        //(alu输出&存储器输出)&装入立即数高位控制信号，简称：lui控制信号
        case (op_i)
            `LUI: lui <= 1'b1;
            default: lui <= 1'b0;
        endcase
    end
endmodule