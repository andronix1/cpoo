module isa_call(
    input clk,
    input enabled,
    input [3:0]r0,
    input ram_txe,
    input [63:0]reg_out,
    input [63:0]ip_val,
    
    output reg ip_set,
    output reg [63:0]ip_wd, 
    output reg ram_txs,
    output reg ram_we, output reg [31:0]ram_wd,
    output reg [63:0]ram_addr,
    output reg [3:0]reg_id,
    output [63:0]reg_wd,
    output reg reg_re = 0,
    output reg reg_we = 0,
    output reg finished
);

assign reg_wd = tmp - 2;

localparam STATE_READ_SP = 0;
localparam STATE_WRITE_RAM1_BEGIN = 1;
localparam STATE_WRITE_RAM1_END = 2;
localparam STATE_WRITE_RAM2_BEGIN = 3;
localparam STATE_WRITE_RAM2_END = 4;
localparam STATE_READ_DATA = 5;
localparam STATE_SET_IP = 6;
localparam STATE_WRITE_SP = 7;
localparam STATE_CLEAN = 8;

reg [3:0]state = STATE_READ_SP;

always @(negedge enabled) begin
    state <= STATE_READ_SP;
    finished = 0;
end

reg [63:0]tmp;

always @(posedge (clk && enabled)) begin
    case (state)
        STATE_READ_SP: begin
            reg_id <= 14;
            reg_re <= 1;
            state <= STATE_WRITE_RAM1_BEGIN;
        end
        STATE_WRITE_RAM1_BEGIN: begin
            tmp <= reg_out;
            reg_re <= 0;
            ram_txs <= 0;
            if (!ram_txe) state <= STATE_WRITE_RAM1_END;
        end
        STATE_WRITE_RAM1_END: begin
            ram_txs <= 1;
            ram_addr <= tmp;
            ram_we <= 1;
            ram_wd <= ip_val[31:0];
            if (ram_txe) state <= STATE_WRITE_RAM2_BEGIN;
        end
        STATE_WRITE_RAM2_BEGIN: begin
            ram_txs <= 0;
            if (!ram_txe) state <= STATE_WRITE_RAM2_END;
        end
        STATE_WRITE_RAM2_END: begin
            ram_txs <= 1;
            ram_we <= 1;
            ram_addr <= tmp - 1;
            ram_wd <= ip_val[63:32];
            if (ram_txe) state <= STATE_READ_DATA;
        end
        STATE_READ_DATA: begin
            ram_we <= 0;
            reg_re <= 1;
            reg_id <= r0;
            state <= STATE_SET_IP;
        end
        STATE_SET_IP: begin
            reg_re <= 0;
            ip_set <= 1;
            ip_wd <= reg_out;
            state <= STATE_WRITE_SP;
        end
        STATE_WRITE_SP: begin
            reg_id <= 14;
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

