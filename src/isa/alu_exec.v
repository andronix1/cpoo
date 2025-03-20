module isa_alu_exec #(
    parameter ALU_OP = 0
) (
    input clk,
    input enabled,
    input [3:0]r0,
    input [3:0]r1,
    input [3:0]r2,
    input [63:0]reg_out, 
    input [63:0]alu_out,

    output [63:0]alu_a,
    output [63:0]alu_b,
    output [1:0]alu_op,
    output reg [3:0]reg_id,
    output reg reg_re = 0,
    output [63:0]reg_wd, output reg reg_we = 0,
    output reg finished = 0
);

localparam STATE_READ0 = 0;
localparam STATE_READ1 = 1;
localparam STATE_EXEC = 2;
localparam STATE_WRITE = 3;
localparam STATE_CLEAR = 4;
reg [2:0]state = STATE_READ0;

always @(negedge enabled) begin
    state <= STATE_READ0;
    finished = 0;
end

reg [63:0]tmp;

assign alu_a = tmp;
assign alu_b = reg_out;
assign alu_op = ALU_OP;
assign reg_wd = alu_out;

always @(posedge (clk && enabled)) begin
    case (state)
        STATE_READ0: begin
            reg_id <= r1;
            reg_re <= 1;
            state <= STATE_READ1;
        end
        STATE_READ1: begin
            tmp <= reg_out;
            reg_id <= r2;
            state <= STATE_EXEC;
        end
        STATE_EXEC: begin
            reg_re <= 0;
            state <= STATE_WRITE;
        end
        STATE_WRITE: begin
            reg_id <= r0;
            reg_we <= 1;
            state <= STATE_CLEAR;
        end
        STATE_CLEAR: begin
            reg_we <= 0;
            finished <= 1;
        end
    endcase
end

endmodule
