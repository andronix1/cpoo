module cpu_test();

reg ram_clk = 0;
always #10 ram_clk = ~ram_clk;
reg cpu_clk = 0;
always #1 cpu_clk = ~cpu_clk;

wire ram_txe;
wire ram_txs;
wire [31:0]ram_out;
wire ram_err;
wire ram_we;
wire [31:0]ram_wd;
wire ram_re;
wire [63:0]ram_addr;

ram #(.SIZE(32), .DUMP_PATH("imgs/ram.bin")) ram(
    .clk(ram_clk),
    .txe(ram_txe), .txs(ram_txs),
    .read(ram_re), .out(ram_out),
    .write(ram_we), .value(ram_wd),
    .addr(ram_addr)
);

cpu cpu(
    .clk(cpu_clk),
    .ram_txe(ram_txe), .ram_txs(ram_txs),
    .ram_re(ram_re), .ram_out(ram_out),
    .ram_we(ram_we), .ram_wd(ram_wd),
    .ram_addr(ram_addr)
);

initial $dumpvars;

endmodule
