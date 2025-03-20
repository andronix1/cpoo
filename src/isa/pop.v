module isa_pop #(
    parameter PART_ID = 0
) (
    input clk,
    input enabled,
    input [3:0]r0,
    input ram_txe,
    input [31:0]ram_out,
    input [63:0]reg_out,
    
    output reg ram_txs,
    output reg ram_re,
    output [63:0]ram_addr,
    output reg [3:0]reg_id,
    output reg [63:0]reg_wd,
    output reg reg_re = 0,
    output reg reg_we = 0,
    output reg finished
);

assign ram_addr = tmp;
wire [63:0]reg_data;
assign reg_data = PART_ID ? { ram_out, reg_out[31:0] } : { reg_out[63:32], ram_out };

localparam STATE_READ_SP = 0;
localparam STATE_READ_RAM_BEGIN = 1;
localparam STATE_READ_RAM_END = 2;
localparam STATE_WRITE_DATA = 3;
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
            state <= STATE_READ_RAM_BEGIN;
        end
        STATE_READ_RAM_BEGIN: begin
            reg_re <= 0;
            tmp <= reg_out - 1;
            ram_txs <= 0;
            if (!ram_txe) state <= STATE_READ_RAM_END;
        end
        STATE_READ_RAM_END: begin
            ram_txs <= 1;
            ram_re <= 1;
            reg_id <= r0;
            if (ram_txe) state <= STATE_WRITE_DATA;
        end
        STATE_WRITE_DATA: begin
            reg_re <= 0;
            reg_wd <= reg_data;
            reg_we <= 1;
            state <= STATE_WRITE_SP;
        end
        STATE_WRITE_SP: begin
            reg_id <= 15;
            reg_wd <= tmp;
            state <= STATE_CLEAN;
        end
        STATE_CLEAN: begin 
            reg_we <= 0;
            finished <= 1;
        end
    endcase
end

endmodule

