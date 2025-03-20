module ram #(
    parameter WORD_SIZE = 32,
    parameter ADDR_SIZE = 64,
    parameter SIZE = 0,
    parameter DUMP_PATH = "",
    parameter DEBUG_TX = 0,
    parameter DEBUG_CMD = 0,
    parameter DEBUG_ERR = 0
) (
    input clk,
    input read,
    input [ADDR_SIZE-1:0]addr,
    input write,
    input [WORD_SIZE-1:0]value,
    input txs,

    output reg txe = 0,
    output reg [WORD_SIZE-1:0]out,
    output reg err
);

reg [WORD_SIZE-1:0]memory[SIZE-1:0];

localparam STATE_WAITING_INPUT = 0;
localparam STATE_WAITING_OUTPUT = 1;
reg state = STATE_WAITING_INPUT;

task run_command(); begin
    err = (read | write) & (addr >= SIZE);
    if (!err) begin
        if (read) begin
            out <= memory[addr];
            if (DEBUG_CMD) $display("RAM: [%0d] => %0d", addr, memory[addr]);
        end
        if (write) begin
            memory[addr] <= value;
            if (DEBUG_CMD) $display("RAM: [%0d] <= %0d", addr, value);
        end
        if (!read && !write) begin
            err <= 1;
            if (DEBUG_ERR) $display("RAM: error(no r/w)", addr, SIZE);
        end
    end else begin
        if (DEBUG_ERR) $display("RAM: error(%0d >= %0d)", addr, SIZE);
    end
end endtask

always @(clk) begin
    case (state)
        STATE_WAITING_INPUT: if (txs) begin
            if (DEBUG_TX) $display("RAM: tx start");
            run_command();
            txe <= 1;
            state <= STATE_WAITING_OUTPUT;
        end
        STATE_WAITING_OUTPUT: if (!txs) begin
            if (DEBUG_TX) $display("RAM: tx end");
            txe <= 0;
            state <= STATE_WAITING_INPUT;
        end
    endcase
end

initial if (DUMP_PATH) $readmemb(DUMP_PATH, memory, 0, SIZE-1);

endmodule
