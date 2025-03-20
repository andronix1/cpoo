module isa_br(
    input clk,
    input enabled,
    input [3:0]r0,
    input [63:0]reg_out,

    output [3:0]reg_id,
    output reg reg_re = 0,
    output reg ip_set = 0,
    output reg [63:0]ip_val = 0,
    output reg finished = 0
);

assign reg_id = r0;

localparam STATE_READ = 0;
localparam STATE_SET = 1;
localparam STATE_CLEAR = 2;
reg [1:0]state = STATE_READ;

always @(negedge enabled) begin
    finished <= 0;
    state <= STATE_READ;
end

always @(posedge (clk && enabled)) begin
    case (state)
        STATE_READ: begin 
            reg_re <= 1;
            state <= STATE_SET;
        end
        STATE_SET: begin 
            reg_re <= 0;
            ip_set <= 1;
            ip_val <= reg_out;
            finished <= 1;
            state <= STATE_CLEAR;
        end
        STATE_CLEAR: begin 
            finished <= 1;
        end
    endcase
end

endmodule

