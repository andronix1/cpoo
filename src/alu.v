module alu(
    input [1:0]op,
    input [63:0]a,
    input [63:0]b,

    output reg [63:0]c,
    output reg neg,
    output reg pos,
    output reg zero
);
parameter ADD = 0;
parameter SUB = 1;
parameter MUL = 2;
parameter DIV = 3;

task do(input [63:0]_c, input _neg); begin
    c <= _c;
    neg <= _neg;
    zero <= _c == 0;
    pos = !zero && !_neg;
end endtask

always @(*) begin
    case (op)
        ADD: do(a + b, 0);
        SUB: do(a - b, a < b);
        MUL: do(a * b, 0);
        DIV: do(a / b, 0);
    endcase
end
endmodule
