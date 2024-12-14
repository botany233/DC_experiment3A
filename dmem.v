//数据存储器
module dmem(
    input clk, we,//时钟，写使能
    input [31:0] addr,//地址
    input [31:0] write_data,//写数据
    output [31:0] read_data//读数据
);
    reg [31:0] ram [63:0];

    assign read_data = ram[addr[7:2]];

    always @(posedge clk) begin
        if (we) ram[addr[7:2]] <= write_data;
    end
endmodule