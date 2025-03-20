module isa_clr(
    input clk,
    input enabled,
    input [3:0]r0,

    output [3:0]reg_id,
    output [63:0]reg_wd,
    output reg reg_we = 0,
    output reg finished = 0
);

assign reg_id = r0;
assign reg_wd = 0;

localparam STATE_WORK = 0;
localparam STATE_CLEAR = 1;
reg state = STATE_WORK;

always @(negedge enabled) begin
    finished <= 0;
    state <= STATE_WORK;
end

always @(posedge (clk && enabled)) begin
    case (state)
        STATE_WORK: begin 
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
