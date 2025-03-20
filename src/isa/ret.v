module isa_ret(
    input clk,
    input enabled,
    input ram_txe,
    input [31:0]ram_out,
    input [63:0]ip_val,
    input [63:0]reg_out,
    
    output reg ip_set,
    output reg [63:0]ip_wd, 
    output reg ram_txs,
    output reg ram_re,
    output reg [63:0]ram_addr,
    output reg [3:0]reg_id,
    output [63:0]reg_wd,
    output reg reg_re = 0,
    output reg reg_we = 0,
    output reg finished
);

assign reg_wd = tmp;

localparam STATE_READ_SP = 0;
localparam STATE_READ_RAM1_BEGIN = 1;
localparam STATE_READ_RAM1_END = 2;
localparam STATE_READ_RAM2_BEGIN = 3;
localparam STATE_READ_RAM2_END = 4;
localparam STATE_SET_IP = 5;
localparam STATE_WRITE_SP = 6;
localparam STATE_CLEAN = 7;

reg [2:0]state = STATE_READ_SP;

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
            state <= STATE_READ_RAM1_BEGIN;
        end
        STATE_READ_RAM1_BEGIN: begin
            tmp <= reg_out + 2;
            reg_re <= 0;
            ram_txs <= 0;
            if (!ram_txe) state <= STATE_READ_RAM1_END;
        end
        STATE_READ_RAM1_END: begin
            ram_txs <= 1;
            ram_addr <= tmp;
            ram_re <= 1;
            if (ram_txe) state <= STATE_READ_RAM2_BEGIN;
        end
        STATE_READ_RAM2_BEGIN: begin
            ip_wd[31:0] <= ram_out;
            ram_txs <= 0;
            if (!ram_txe) state <= STATE_READ_RAM2_END;
        end
        STATE_READ_RAM2_END: begin
            ram_txs <= 1;
            ram_addr <= tmp - 1;
            if (ram_txe) state <= STATE_SET_IP;
        end
        STATE_SET_IP: begin
            ip_wd[63:32] <= ram_out;
            ram_re <= 0;
            ip_set <= 1;
            state <= STATE_WRITE_SP;
        end
        STATE_WRITE_SP: begin
            ip_set <= 0;
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


