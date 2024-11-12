`include "mips_para.v"
//指令译码器
module controller(
    input [5:0] op_i,
    input [5:0] funct_i,
    output reg [3:0] alu_op,
    output reg [1:0] ext_op,
    output reg reg_write, mem_write, jump, jr, mem_to_reg, lui, pc_to_reg,
    output reg reg_dst, ra_dst,
    output reg alu_srca, alu_srcb,
    output reg beq, bne, blez, bgtz
);
    always @(*) begin
        //寄存器写入控制信号
        case(op_i)
            //立即数加法、无符号立即数加法、立即数与、立即数或、立即数异或、设置小于立即数、设置小于无符号立即数、装入字、装入立即数高位、跳转并链接
            `ADDI, `ADDIU, `ANDI, `ORI, `XORI, `SLTI, `SLTIU, `LW, `LUI, `JAL: reg_write <= 1'b1;
            `R_TYPE: begin
                case (funct_i)
                    //加法、无符号加法、减法、无符号减法、求与、求或、异或、或非、小于比较、无符号小于比较、跳转并链接寄存器
                    `ADD, `ADDU, `SUB, `SUBU, `AND, `OR, `XOR, `NOR, `SLT, `SLTU, `JALR,
                    //逻辑左移、逻辑右移、算数右移、带变量的逻辑左移、带变量的逻辑右移、带变量的算数右移
                    `SLL, `SRL, `SRA, `SLLV, `SRLV, `SRAV: reg_write <= 1'b1;
                    default: reg_write <= 1'b0;
                endcase
            end
            default: reg_write <= 1'b0;
        endcase

        //ALU操作控制信号
        case (op_i)
            `ADDI, `ADDIU, `LW, `SW: alu_op <= `alu_add;//立即数加法、无符号立即数加法、装入字、存储字
            `ANDI: alu_op <= `alu_and;//立即数与
            `ORI: alu_op <= `alu_or;//立即数或
            `XORI: alu_op <= `alu_xor;//立即数异或
            `SLTI: alu_op <= `alu_slt;//设置小于立即数
            `SLTIU: alu_op <= `alu_sltu;//设置小于无符号立即数
            `BEQ, `BNE: alu_op <= `alu_sub;//如果相等则转移、如果不相等则转移
            `R_TYPE: begin
                case (funct_i)
                    `ADD, `ADDU: alu_op <= `alu_add;//加法、无符号加法
                    `SUB, `SUBU: alu_op <= `alu_sub;//减法、无符号减法
                    `AND: alu_op <= `alu_and;//求与
                    `OR: alu_op <= `alu_or;//求或
                    `XOR: alu_op <= `alu_xor;//异或
                    `NOR: alu_op <= `alu_nor;//或非
                    `SLT: alu_op <= `alu_slt;//小于比较
                    `SLTU: alu_op <= `alu_sltu;//无符号小于比较
                    `SLL, `SLLV: alu_op <= `alu_shl;//逻辑左移
                    `SRL, `SRLV: alu_op <= `alu_shr;//逻辑右移
                    `SRA, `SRAV: alu_op <= `alu_sar;//算数右移
                    default: alu_op <= 4'bx;
                endcase
            end
            default: alu_op <= 4'bx;
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

        //alu输入2控制信号
        case (op_i)
            `BEQ, `BNE: alu_srcb <= 1'b0;
            `R_TYPE: begin//R型指令
                case (funct_i)
                    //加法、无符号加法、减法、无符号减法、求与、求或、异或、小于比较、无符号小于比较
                    `ADD, `ADDU, `SUB, `SUBU, `AND, `OR, `XOR, `NOR, `SLT, `SLTU,
                    //逻辑左移、逻辑右移、算数右移、带变量的逻辑左移、带变量的逻辑右移、带变量的算数右移
                    `SLL, `SRL, `SRA, `SLLV, `SRLV, `SRAV: alu_srcb <= 1'b0;
                    default: alu_srcb <= 1'b1;
                endcase
            end
            default: alu_srcb <= 1'b1;
        endcase

        //寄存器写入地址控制信号1
        case (op_i)
            `R_TYPE: begin//R型指令
                case (funct_i)
                    //加法、无符号加法、减法、无符号减法、求与、求或、异或、小于比较、无符号小于比较
                    `ADD, `ADDU, `SUB, `SUBU, `AND, `OR, `XOR, `NOR, `SLT, `SLTU,
                    //逻辑左移、逻辑右移、算数右移、带变量的逻辑左移、带变量的逻辑右移、带变量的算数右移
                    `SLL, `SRL, `SRA, `SLLV, `SRLV, `SRAV: reg_dst <= 1'b1;
                    default: reg_dst <= 1'b0;
                endcase
            end
            default: reg_dst <= 1'b0;
        endcase

        //寄存器写入地址控制信号2
        case (op_i)
            `JAL: ra_dst <= 1'b1;//跳转并链接
            `R_TYPE: begin//R型指令
                case (funct_i)
                    `JALR: ra_dst <= 1'b1;//跳转并链接寄存器
                    default: ra_dst <= 1'b0;
                endcase
            end
            default: ra_dst <= 1'b0;
        endcase

        //pc_next控制信号1
        case (op_i)
            `J, `JAL: jump <= 1'b1;//跳转、跳转并链接
            default: jump <= 1'b0;
        endcase

        //pc_next控制信号2
        case (op_i)
            `R_TYPE: begin//R型指令
                case (funct_i)
                    `JR, `JALR: jr <= 1'b1;//跳转寄存器、跳转并链接寄存器
                    default: jr <= 1'b0;
                endcase
            end
            default: jr <= 1'b0;
        endcase

        //立即数扩展控制信号
        case (op_i)
            `LUI: ext_op <= 2'b11;//装入立即数高位
            `ANDI, `ORI, `XORI: ext_op <= 2'b01;//立即数与、立即数或、立即数异或
            `R_TYPE: begin//R型指令
                case (funct_i)
                    //逻辑左移、逻辑右移、算数右移
                    `SLL, `SRL, `SRA: ext_op <= 2'b10;
                    default: ext_op <= 2'b00;
                endcase
            end
            default: ext_op <= 2'b00;
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

        //小于等于0转移控制信号
        case (op_i)
            `BLEZ: blez <= 1'b1;
            default: blez <= 1'b0;
        endcase

        //大于0转移控制信号
        case (op_i)
            `BGTZ: bgtz <= 1'b1;
            default: bgtz <= 1'b0;
        endcase

        //存储器写入控制信号
        case (op_i)
            `SW: mem_write <= 1'b1;//存储字
            default: mem_write <= 1'b0;
        endcase

        //寄存器写入内容控制信号1
        case (op_i)
            `LW: mem_to_reg <= 1'b1;//装入字
            default: mem_to_reg <= 1'b0;
        endcase

        //寄存器写入内容控制信号2
        case (op_i)
            `LUI: lui <= 1'b1;//装入立即数高位
            default: lui <= 1'b0;
        endcase

        //寄存器写入内容控制信号3
        case (op_i)
            `JAL: pc_to_reg <= 1'b1;//跳转并链接
            `R_TYPE: begin//R型指令
                case (funct_i)
                    `JALR: pc_to_reg <= 1'b1;//跳转并链接寄存器
                    default: pc_to_reg <= 1'b0;
                endcase
            end
            default: pc_to_reg <= 1'b0;
        endcase
    end
endmodule