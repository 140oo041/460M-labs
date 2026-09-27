module steps_per_sec (
    input pulse,
    input tick,
    input clk,
    input rst,
    output reg[15:0] steps_past_second
);

    always @(posedge clk) begin
        if(rst) begin
            steps_past_second <= 0;
        end else if(tick) begin
            // don't drop a pulse that happens on a tick (pre-add 1 if there was a pulse for the next window)
            steps_past_second <= pulse ? 1 : 0;
        end else begin
            if(pulse) begin
                steps_past_second <= steps_past_second + 1;
            end else begin
                steps_past_second <= steps_past_second;
            end
        end
    end

endmodule
