`timescale 1ns/1ns
module tb_regfile();
    reg [4:0] a1, a2, a3;
    reg [31:0] wd;
    wire [31:0] r1, r2;
    reg clk, we;

    regfile regfile1(
        .a1(a1),
        .a2(a2),
        .a3(a3),
        .wd(wd),
        .r1(r1),
        .r2(r2),
        .clk(clk),
        .we(we)
    );

    initial begin
        a1 = 5'b00000;
        a2 = 5'b00001;
        a3 = 5'b00001;
        wd = 32'h12345678;
        #10 we = 1;
        #10 we = 0;
        a3 = 5'b00000;
        wd = 32'h87654321;
        #10 we = 1;
        a3 = 5'b00001;
    end

    initial begin
        clk = 1;
        forever #5 clk = ~clk;
    end
endmodule