`include "mips_para.v"
//算数逻辑单元
module alu(
    input [31:0] srca_i, srcb_i,//操作数1，2
    input [3:0] aluop_i,//控制alu运算模式
    output reg zero,//判断结果是否为0
    output reg [31:0] alu_result//运算结果
);
    always @(srca_i, srcb_i, aluop_i) begin
        case (aluop_i)
            `alu_shl:begin alu_result=srcb_i<<srca_i[4:0];zero=alu_result==0?1:0;end
            `alu_shr:begin alu_result=srcb_i>>srca_i[4:0];zero=alu_result==0?1:0;end
            `alu_sar:begin alu_result=($signed(srcb_i))>>>srca_i[4:0];zero=alu_result==0?1:0;end
            `alu_add:begin alu_result=srca_i+srcb_i; zero=alu_result==0?1:0;end
            `alu_sub:begin alu_result=srca_i-srcb_i; zero=alu_result==0?1:0;end
            `alu_and:begin alu_result=srca_i&srcb_i; zero=alu_result==0?1:0;end
            `alu_or:begin alu_result=srca_i|srcb_i; zero=alu_result==0?1:0;end
            `alu_xor:begin alu_result=srca_i^srcb_i; zero=alu_result==0?1:0;end
            `alu_nor:begin alu_result=~(srca_i|srcb_i); zero=alu_result==0?1:0;end
            `alu_slt:begin alu_result=($signed(srca_i))<($signed(srcb_i))?32'b1:32'b0; zero=alu_result==0?1:0;end
            `alu_sltu:begin alu_result=srca_i<srcb_i?32'b1:32'b0; zero=alu_result==0?1:0;end
            default: begin alu_result=32'b0; zero=0;end
        endcase
    end
endmodule