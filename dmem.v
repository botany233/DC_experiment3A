module dmem(
    input clk, we,//时钟，写使能
    input [31:0] addr,//地址
    input [31:0] write_data,//写数据
    output [31:0] read_data//读数据
);
endmodule