module isa_push #(
    parameter PART_ID = 0
) (
    input clk,
    input enabled,
    input [3:0]r0,
    input ram_txe,
    input [63:0]reg_out,
    
    output reg ram_txs,
    output reg ram_we, output [31:0]ram_wd,
    output [63:0]ram_addr,
    output reg [3:0]reg_id,
    output [63:0]reg_wd,
    output reg reg_re = 0,
    output reg reg_we = 0,
    output reg finished
);

assign ram_addr = tmp;
assign ram_wd = PART_ID ? reg_out[63:32] : reg_out[31:0];
assign reg_wd = tmp + 1;

localparam STATE_READ_SP = 0;
localparam STATE_READ_DATA = 1;
localparam STATE_WRITE_RAM_BEGIN = 2;
localparam STATE_WRITE_RAM_END = 3;
localparam STATE_WRITE_SP = 4;
localparam STATE_CLEAN = 5;

reg [2:0]state = STATE_READ_SP;

always @(negedge enabled) begin
    state <= STATE_READ_SP;
    finished = 0;
end

reg [63:0]tmp;

always @(posedge (clk && enabled)) begin
    case (state)
        STATE_READ_SP: begin
            reg_id <= 15;
            reg_re <= 1;
            state <= STATE_READ_DATA;
        end
        STATE_READ_DATA: begin
            tmp <= reg_out;
            reg_id <= r0;
            state <= STATE_WRITE_RAM_BEGIN;
        end
        STATE_WRITE_RAM_BEGIN: begin
            reg_re <= 0;
            ram_txs <= 0;
            if (!ram_txe) state <= STATE_WRITE_RAM_END;
        end
        STATE_WRITE_RAM_END: begin
            ram_txs <= 1;
            ram_we <= 1;
            if (ram_txe) state <= STATE_WRITE_SP;
        end
        STATE_WRITE_SP: begin
            ram_we <= 0;
            reg_id <= 15;
            reg_we <= 1;
            state <= STATE_CLEAN;
        end
        STATE_CLEAN: begin
            reg_we <= 0;
            finished <= 1;
        end
    endcase
end

endmodule
