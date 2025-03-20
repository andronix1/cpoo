module isa_mov(
    input clk,
    input enabled,
    input [3:0]r0,
    input [3:0]r1,
    input [63:0]reg_out, 

    output reg [3:0]reg_id,
    output reg reg_re = 0,
    output reg [63:0]reg_wd, output reg reg_we = 0,
    output reg finished = 0
);

localparam STATE_READ = 0;
localparam STATE_WRITE = 1;
localparam STATE_CLEAR = 2;
reg [1:0]state = STATE_READ;

always @(negedge enabled) begin
    state <= STATE_READ;
    finished = 0;
end

always @(posedge (clk && enabled)) begin
    case (state)
        STATE_READ: begin 
            reg_id <= r0;
            reg_re <= 1;
            state <= STATE_WRITE;
        end
        STATE_WRITE: begin 
            reg_id <= r1;
            reg_we = 1;
            reg_wd = reg_out;
            state <= STATE_CLEAR;
        end
        STATE_CLEAR: begin 
            reg_re = 0;
            reg_we = 0;
            finished = 1;
        end
    endcase
end

endmodule
