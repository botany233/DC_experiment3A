//多路选择器
module mux2 #(parameter width = 5)
(
    input [width-1:0] a, b,
    input s,
    output [width-1:0] y
);
    assign y = s?b:a;
endmodule