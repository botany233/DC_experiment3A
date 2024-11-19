`timescale 1ns/1ns
module tb_main();
    reg clk, rst_n;
    reg [1:0] sw, key;
    wire [31:0] pc, result;
    wire [1:0] com;
    wire [3:0] leds;
    wire [7:0] segs;
    wire [31:0] regfile [31:0];
    wire [31:0] dmem [31:0];

    main main1(
        .clk(clk),
        .rst_n(rst_n),
        .sw(sw),
        .key(key),
        .com(com),
        .segs(segs),
        .leds(leds)
    );
    assign pc = main1.pc;
    assign result = main1.result;

    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin
            assign regfile[i] = main1.mips1.regfile1.rf[i];
        end
    endgenerate

    genvar j;
    generate
        for (j = 0; j < 32; j = j + 1) begin
            assign dmem[j] = main1.mips1.dmem1.ram[j];
        end
    endgenerate

    initial begin
        rst_n = 0;
        #5 rst_n = 1;
    end

    initial begin
        clk = 1;
        forever #5 clk = ~clk;
    end
endmodule