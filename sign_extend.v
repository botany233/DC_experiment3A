//立即数扩展
module sign_extend(
    input [15:0] imm,
    output [31:0] sign_imm
);
    assign sign_imm = {{16{imm[15]}}, imm};
endmodule