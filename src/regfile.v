module regfile #(
    parameter REG_ID_LEN = 4,
    parameter REG_SIZE = 64,
    parameter DEBUG = 0
) (
    input clk,
    input [REG_ID_LEN-1:0] id,
    input write, input [REG_SIZE-1:0]value,
    input read,

    output [REG_SIZE-1:0]out
);

localparam REGS_COUNT = 1 << REG_ID_LEN;

reg [REG_SIZE-1:0]regs[REGS_COUNT-1:0];

assign out = regs[id];

always @(posedge clk) begin
    if (write) begin
        if (DEBUG) $display("RF: r%0d <= %0d", id, value);
        regs[id] <= value;
    end
end

task dump();
    integer j;
begin
    for (integer i = 0; i < REGS_COUNT; i += 1) begin
        j = i / 2;
        if (i % 2 != 0) j += REGS_COUNT / 2;
        if (j < 10) $write(" ");
        $write("r%0d: %h\t", j, regs[j]);
        if (i % 2 == 1) $write("\n");
    end
end endtask

endmodule
