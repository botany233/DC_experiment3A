module regfile(
    input clk, we,//始终，写使能
    input [4:0] a1, a2, a3,//读地址1，2，写地址3
    input [31:0] wd,//写数据
    output [31:0] r1, r2//读数据1，2
);
    reg [31:0] rf[31:0];

    always @(posedge clk) begin
        if (we) rf[a3] <= wd;
    end

    assign r1 = (a1 == 0) ? 32'b0 : rf[a1];
    assign r2 = (a2 == 0) ? 32'b0 : rf[a2];
endmodule