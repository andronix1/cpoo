module cpu(
    input clk,
    input ram_txe,
    input ram_err,
    input [31:0]ram_out,
    input [7:0]int_dev_id,
    input int,

    output reg ram_txs,
    output reg ram_we, output reg [31:0]ram_wd,
    output reg ram_re,
    output reg [63:0]ram_addr,
    output hlt
);

reg [1:0]alu_op;
reg [63:0]alu_a;
reg [63:0]alu_b;
wire [63:0]alu_out;
alu alu(.op(alu_op), .a(alu_a), .b(alu_b), .c(alu_out));

reg inc_ip = 0;
reg ip_set = 0;
reg [63:0]ip_val;
ip_counter ip(.clk(clk), .inc(inc_ip), .set(ip_set), .data(ip_val));

reg [3:0]reg_id;
reg [63:0]reg_wd;
reg reg_we = 0;
reg reg_re = 0;
regfile #(.DEBUG(0)) rf(.clk(clk), .id(reg_id), .write(reg_we), .read(reg_re), .value(reg_wd));

localparam STATE_BEGIN = 0;
localparam STATE_READ = 1;
localparam STATE_EXECUTE = 2;
localparam STATE_END = 3;
localparam STATE_HLT = 4;
localparam STATE_INTERRUPTED = 5;

reg [2:0]state = STATE_BEGIN;
assign hlt = state == STATE_HLT;

reg [31:0]instr;
wire [11:0]opcode; assign opcode = instr[11:0];
wire [3:0]r0; assign r0 = instr[15:12];
wire [3:0]r1; assign r1 = instr[19:16];
wire [3:0]r2; assign r2 = instr[23:20];
wire [3:0]r3; assign r3 = instr[27:24];
wire [3:0]r4; assign r4 = instr[31:28];
wire [15:0]imm; assign imm = instr[31:16];

task dump(); begin
    $display("--- INTERNAL ---");
    $display(" ip: %h", ip.val);
    $display("--- REGISTERS ---");
    rf.dump();
end endtask

task finish_on(input ended);
    if (ended) state <= STATE_END;
endtask

wire ex = state == STATE_EXECUTE;
localparam OP_CLR = 0;
localparam OP_SETLL = 1;
localparam OP_SETLH = 2;
localparam OP_SETHL = 3;
localparam OP_SETHH = 4;
localparam OP_HLT = 5;
localparam OP_MOV = 6;
localparam OP_BR = 7;
localparam OP_BRL = 8;
localparam OP_BRG = 9;
localparam OP_BRE = 10;
localparam OP_BRNE = 11;
localparam OP_BRLE = 12;
localparam OP_BRGE = 13;
localparam OP_ADD = 14;
localparam OP_SUB = 15;
localparam OP_MUL = 16;
localparam OP_DIV = 17;
isa_clr clr(.clk(clk), .enabled(ex && opcode == OP_CLR), .r0(r0));
isa_set #(.POS(0)) setll(.clk(clk), .enabled(ex && opcode == OP_SETLL), .r0(r0), .imm(imm), .reg_out(rf.out));
isa_set #(.POS(1)) setlh(.clk(clk), .enabled(ex && opcode == OP_SETLH), .r0(r0), .imm(imm), .reg_out(rf.out));
isa_set #(.POS(2)) sethl(.clk(clk), .enabled(ex && opcode == OP_SETHL), .r0(r0), .imm(imm), .reg_out(rf.out));
isa_set #(.POS(3)) sethh(.clk(clk), .enabled(ex && opcode == OP_SETHH), .r0(r0), .imm(imm), .reg_out(rf.out));
isa_mov mov(.clk(clk), .enabled(ex && opcode == OP_MOV), .r0(r0), .r1(r1), .reg_out(rf.out));
isa_br br(.clk(clk), .enabled(ex && opcode == OP_BR), .r0(r0), .reg_out(rf.out));
isa_brc #(.IF_FLAG_NEG(0), .ALU_OP(1 /* alu.SUB */)) brl(.clk(clk), .enabled(ex && opcode == OP_BRL), .r0(r0), .r1(r1), .r2(r2), .alu_flag(alu.neg), .reg_out(rf.out));
isa_brc #(.IF_FLAG_NEG(0), .ALU_OP(1 /* alu.SUB */)) brg(.clk(clk), .enabled(ex && opcode == OP_BRG), .r0(r0), .r1(r1), .r2(r2), .alu_flag(alu.pos), .reg_out(rf.out));
isa_brc #(.IF_FLAG_NEG(0), .ALU_OP(1 /* alu.SUB */)) bre(.clk(clk), .enabled(ex && opcode == OP_BRZ), .r0(r0), .r1(r1), .r2(r2), .alu_flag(alu.zero), .reg_out(rf.out));
isa_brc #(.IF_FLAG_NEG(1), .ALU_OP(1 /* alu.SUB */)) brne(.clk(clk), .enabled(ex && opcode == OP_BRNZ), .r0(r0), .r1(r1), .r2(r2), .alu_flag(alu.zero), .reg_out(rf.out));
isa_brc #(.IF_FLAG_NEG(1), .ALU_OP(1 /* alu.SUB */)) brge(.clk(clk), .enabled(ex && opcode == OP_BRGE), .r0(r0), .r1(r1), .r2(r2), .alu_flag(alu.neg), .reg_out(rf.out));
isa_brc #(.IF_FLAG_NEG(1), .ALU_OP(1 /* alu.SUB */)) brle(.clk(clk), .enabled(ex && opcode == OP_BRLE), .r0(r0), .r1(r1), .r2(r2), .alu_flag(alu.pos), .reg_out(rf.out));
isa_alu_exec #(.ALU_OP(0 /* alu.ADD */)) add(.clk(clk), .enabled(ex && opcode == OP_ADD), .r0(r0), .r1(r1), .r2(r2), .alu_out(alu.c), .reg_out(rf.out));
isa_alu_exec #(.ALU_OP(1 /* alu.SUB */)) sub(.clk(clk), .enabled(ex && opcode == OP_SUB), .r0(r0), .r1(r1), .r2(r2), .alu_out(alu.c), .reg_out(rf.out));
isa_alu_exec #(.ALU_OP(2 /* alu.MUL */)) mul(.clk(clk), .enabled(ex && opcode == OP_MUL), .r0(r0), .r1(r1), .r2(r2), .alu_out(alu.c), .reg_out(rf.out));
isa_alu_exec #(.ALU_OP(3 /* alu.DIV */)) div(.clk(clk), .enabled(ex && opcode == OP_DIV), .r0(r0), .r1(r1), .r2(r2), .alu_out(alu.c), .reg_out(rf.out));

always @(posedge clk) begin
    case (state)
        STATE_BEGIN: begin
            inc_ip <= 0;
            if (int) begin
                state <= STATE_INTERRUPTED;
            end else if (!ram_txe) begin
                ram_txs <= 1;
                ram_re <= 1;
                ram_addr <= ip.val;
                state <= STATE_READ;
            end
        end
        STATE_READ: if (ram_txe) begin
            ram_re <= 0;
            instr <= ram_out;
            state <= STATE_EXECUTE;
        end
        STATE_EXECUTE: begin
            case (opcode)
                OP_CLR: begin
                    finish_on(clr.finished);
                    reg_id <= clr.reg_id;
                    reg_wd <= clr.reg_wd;
                    reg_we <= clr.reg_we;
                end
                OP_SETLL: begin
                    finish_on(setll.finished);
                    reg_id = setll.reg_id;
                    reg_re = setll.reg_re;
                    reg_wd = setll.reg_wd;
                    reg_we = setll.reg_we;
                end
                OP_SETLH: begin
                    finish_on(setlh.finished);
                    reg_id = setlh.reg_id;
                    reg_re = setlh.reg_re;
                    reg_wd = setlh.reg_wd;
                    reg_we = setlh.reg_we;
                end
                OP_SETHL: begin
                    finish_on(sethl.finished);
                    reg_id = sethl.reg_id;
                    reg_re = sethl.reg_re;
                    reg_wd = sethl.reg_wd;
                    reg_we = sethl.reg_we;
                end
                OP_SETHH: begin
                    finish_on(sethh.finished);
                    reg_id = sethh.reg_id;
                    reg_re = sethh.reg_re;
                    reg_wd = sethh.reg_wd;
                    reg_we = sethh.reg_we;
                end
                OP_HLT: begin
                    state <= STATE_HLT;
                end
                OP_MOV: begin
                    finish_on(mov.finished);
                    reg_id = mov.reg_id;
                    reg_re = mov.reg_re;
                    reg_wd = mov.reg_wd;
                    reg_we = mov.reg_we;
                end
                OP_BR: begin
                    finish_on(br.finished);
                    reg_id = br.reg_id;
                    reg_re = br.reg_re;
                    ip_set = br.ip_set;
                    ip_val = br.ip_val;
                end
                OP_BRL: begin
                    finish_on(brl.finished);
                    reg_id = brl.reg_id;
                    reg_re = brl.reg_re;
                    ip_set = brl.ip_set;
                    ip_val = brl.ip_val;
                    alu_a = brl.alu_a;
                    alu_b = brl.alu_b;
                    alu_op = brl.alu_op;
                end
                OP_BRG: begin
                    finish_on(brg.finished);
                    reg_id = brg.reg_id;
                    reg_re = brg.reg_re;
                    ip_set = brg.ip_set;
                    ip_val = brg.ip_val;
                    alu_a = brg.alu_a;
                    alu_b = brg.alu_b;
                    alu_op = brg.alu_op;
                end
                OP_BRZ: begin
                    finish_on(bre.finished);
                    reg_id = bre.reg_id;
                    reg_re = bre.reg_re;
                    ip_set = bre.ip_set;
                    ip_val = bre.ip_val;
                    alu_a = bre.alu_a;
                    alu_b = bre.alu_b;
                    alu_op = bre.alu_op;
                end
                OP_BRNZ: begin
                    finish_on(brne.finished);
                    reg_id = brne.reg_id;
                    reg_re = brne.reg_re;
                    ip_set = brne.ip_set;
                    ip_val = brne.ip_val;
                    alu_a = brne.alu_a;
                    alu_b = brne.alu_b;
                    alu_op = brne.alu_op;
                end
                OP_BRLE: begin
                    finish_on(brle.finished);
                    reg_id = brle.reg_id;
                    reg_re = brle.reg_re;
                    ip_set = brle.ip_set;
                    ip_val = brle.ip_val;
                    alu_a = brle.alu_a;
                    alu_b = brle.alu_b;
                    alu_op = brle.alu_op;
                end
                OP_BRGE: begin
                    finish_on(brge.finished);
                    reg_id = brge.reg_id;
                    reg_re = brge.reg_re;
                    ip_set = brge.ip_set;
                    ip_val = brge.ip_val;
                    alu_a = brge.alu_a;
                    alu_b = brge.alu_b;
                    alu_op = brge.alu_op;
                end
                OP_ADD: begin
                    finish_on(add.finished);
                    reg_id = add.reg_id;
                    reg_re = add.reg_re;
                    reg_we = add.reg_we;
                    reg_wd = add.reg_wd;
                    alu_a = add.alu_a;
                    alu_b = add.alu_b;
                    alu_op = add.alu_op;
                end
                OP_SUB: begin
                    finish_on(sub.finished);
                    reg_id = sub.reg_id;
                    reg_re = sub.reg_re;
                    reg_we = sub.reg_we;
                    reg_wd = sub.reg_wd;
                    alu_a = sub.alu_a;
                    alu_b = sub.alu_b;
                    alu_op = sub.alu_op;
                end
                OP_MUL: begin
                    finish_on(mul.finished);
                    reg_id = mul.reg_id;
                    reg_re = mul.reg_re;
                    reg_we = mul.reg_we;
                    reg_wd = mul.reg_wd;
                    alu_a = mul.alu_a;
                    alu_b = mul.alu_b;
                    alu_op = mul.alu_op;
                end
                OP_DIV: begin
                    finish_on(div.finished);
                    reg_id = div.reg_id;
                    reg_re = div.reg_re;
                    reg_we = div.reg_we;
                    reg_wd = div.reg_wd;
                    alu_a = div.alu_a;
                    alu_b = div.alu_b;
                    alu_op = div.alu_op;
                end
                default: begin
                    $display("invalid opcode %0d", opcode);
                    dump();
                    $stop;
                end
            endcase
        end
        STATE_END: if (ram_txe) begin
            ram_txs <= 0;
            if (!ip_set) inc_ip <= 1;
            ip_set <= 0;
            state <= STATE_BEGIN;
        end
        STATE_HLT: begin end
        STATE_INTERRUPTED: begin
            $display("TODO: interrupt logic");
            state <= STATE_HLT;
        end
        default: begin
            $display("invalid cpu state %0d", state);
            dump();
            $stop;
        end
    endcase
end

endmodule
