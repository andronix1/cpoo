module isa_brc #(
    parameter IF_FLAG_NEG = 0,
    parameter ALU_OP = 0
) (
    input clk,
    input enabled,
    input [3:0]r0,
    input [3:0]r1,
    input [3:0]r2,
    input [63:0]reg_out,
    input alu_flag,

    output [63:0]alu_a,
    output [63:0]alu_b,
    output [1:0]alu_op,
    output reg [3:0]reg_id,
    output reg reg_re = 0,
    output reg ip_set = 0,
    output reg [63:0]ip_val = 0,
    output reg finished = 0
);

assign alu_a = tmp;
assign alu_b = reg_out;
assign alu_op = ALU_OP;

localparam STATE_READ0 = 0;
localparam STATE_READ1 = 1;
localparam STATE_COMPARE = 2;
localparam STATE_READ2 = 3;
localparam STATE_SET = 4;
localparam STATE_CLEAR = 5;
reg [2:0]state = STATE_READ0;

always @(negedge enabled) begin
    finished <= 0;
    state <= STATE_READ0;
end

reg [63:0]tmp;

always @(posedge (clk && enabled)) begin
    case (state)
        STATE_READ0: begin 
            reg_id <= r0;
            reg_re <= 1;
            state <= STATE_READ1;
        end
        STATE_READ1: begin
            tmp <= reg_out;
            reg_id <= r1;
            state <= STATE_COMPARE;
        end
        STATE_COMPARE: begin
            reg_re <= 0;
            state <= STATE_READ2;
        end
        STATE_READ2: begin
            if (alu_flag ^ IF_FLAG_NEG) begin
                reg_id = r2;
                reg_re <= 1;
                state <= STATE_SET;
            end else state <= STATE_CLEAR;
        end
        STATE_SET: begin 
            reg_re <= 0;
            ip_set <= 1;
            ip_val <= reg_out;
            state <= STATE_CLEAR;
        end
        STATE_CLEAR: begin 
            ip_set <= 0;
            finished <= 1;
        end
    endcase
end

endmodule


