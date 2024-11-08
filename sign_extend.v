//立即数扩展
module sign_extend(
    input [15:0] imm,
    input ext_op,
    output [31:0] sign_imm
);
    assign sign_imm = ext_op?{{16{imm[15]}}, imm}:{27'b0, imm[10:6]};
endmodule