module ip_counter(
    input clk,
    input inc,
    input set,
    input [63:0]data,

    output reg [63:0]val = 0
);

always @(posedge clk) begin
    if (set) val = data;
    else if (inc) val = val + 1;
end

endmodule
