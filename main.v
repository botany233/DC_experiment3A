`timescale 1ns/1ns
module main(
    input clk, rst_n,
    input [1:0]	sw, key,
    output [1:0] com,
	output [7:0] segs,
	output [3:0] leds
);
    wire [31:0] pc, result;
    wire clk_low;

    low_f #(10) low_f1(
        .clk(clk),
        .rst_n(rst_n),
        .clk_low(clk_low)
    );

    mips mips1(
        .clk(clk_low),
        .rst_n(rst_n),
        .pc(pc),
        .s7(result)
    );

    SEG_display SEG_display1(
        .clk(clk),
        .rst_n(rst_n),
        .sw(sw),
        .key(key),
        .result(result),
        .pc(pc),
        .com(com),
        .segs(segs),
        .leds(leds)
    );
endmodule