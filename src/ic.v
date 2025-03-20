module ic #(
    parameter DEV_ID_SIZE = 8
) (
    input clk,
    input [DEV_IDS-1:0]ints,
    input enable,

    output reg [DEV_ID_SIZE-1:0]dev_id,
    output reg available = 0
);

localparam DEV_IDS = 1 << DEV_ID_SIZE;

localparam STATE_WAITING_FINISH = 0;
localparam STATE_SENDING_ID = 1;

reg state = STATE_WAITING_FINISH;

always @(negedge enable) begin
    state <= STATE_WAITING_FINISH;
end

integer reading = 1;

always @(posedge (clk && enable)) begin
    case (state)
        STATE_WAITING_FINISH: begin
            if (ints != 0) begin
                available <= 1;
                for (integer i = 0; i < DEV_IDS && reading; i++)
                    if (ints[i]) begin
                        dev_id <= i;
                        reading = 0;
                    end
                state <= STATE_SENDING_ID;
            end
        end
        STATE_SENDING_ID: begin
            available <= 0; 
        end
    endcase
end

endmodule
