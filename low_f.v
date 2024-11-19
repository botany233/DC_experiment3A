module low_f
#(
    parameter low_exp = 10
)
(
    input clk, rst_n,
    output clk_low
);
    reg [low_exp-1:0] count;
    assign clk_low = count[low_exp-1];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            count <= 0;
        else
            count <= count + 1;
    end
endmodule