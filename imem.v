//指令存储器
module imem(
    input clk,
    input [31:0] addr_i,//地址
    output reg [31:0] instr//读数据
);
    reg [31:0] rom [63:0];

    always @(posedge clk) begin
        $readmemh("C:/Users/18201/Desktop/verilog/output_command.txt", rom);
    end

    always @(addr_i) begin
        instr = rom[addr_i[31:2]];
    end
endmodule