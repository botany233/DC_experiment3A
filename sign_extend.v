//立即数扩展
module sign_extend(
    input [15:0] imm,
    input [1:0] ext_op,
    output [31:0] sign_imm
);
    assign sign_imm = ext_op[1]?
    (ext_op[0]?{imm, 16'b0}:{27'b0, imm[10:6]}):
    (ext_op[0]?{16'b0, imm}:{{16{imm[15]}}, imm});
endmodule