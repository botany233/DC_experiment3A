//取指
module pc (
    input clk,//时钟
    input rst_n,//复位
    input [31:0] pc_next,//下一条指令地址
    output reg [31:0] pc//本条指令地址
);
    always @(negedge rst_n, posedge clk) begin
        if (!rst_n) pc <= 32'b0;
        else pc <= pc_next;
    end
endmodule