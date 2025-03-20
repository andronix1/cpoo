module ic_tb();

reg clk = 0;
always #1 clk = ~clk;

reg [255:0]ints = 0;
reg en = 0;

ic ic(
    .clk(clk),
    .ints(ints),
    .enable(en)
);

initial begin
    if (ic.available) begin
        $display("avaiable at start");
        $stop;
    end
    en = 1;
    #2
    if (ic.available) begin
        $display("avaiable with no ints");
        $stop;
    end
    ints[0] = 1;
    ints[3] = 1;
    #2
    if (!ic.available) begin
        $display("not avaiable with ints 0 and 3");
        $stop;
    end
    if (ic.dev_id != 3) begin
        $display("expected int 3, found %0d", ic.dev_id);
        $stop;
    end
    ints[3] = 0;
    en = 0;
    #2
    if (!ic.available) begin
        $display("avaiable while disabled");
        $stop;
    end
    en = 1;
    #2
    if (!ic.available) begin
        $display("not avaiable with int 0");
        $stop;
    end
    if (ic.dev_id != 0) begin
        $display("expected int 0, found %0d", ic.dev_id);
        $stop;
    end
    $display("successfully tested!");
    $finish;
end

endmodule
