module high_time (
    input clk,
    input rst,
    input tick,
    input [15:0] steps_past_second,
    output reg [13:0] high_time_secs
);

    reg [5:0] consecutive_secs;

    always @(posedge clk) begin
        if (rst) begin
            high_time_secs <= 0;
            consecutive_secs <= 0;
        end else if (tick) begin
            if (steps_past_second >= 64) begin
                if (consecutive_secs == 59) begin // reached 60s
                    high_time_secs <= high_time_secs + 60;
                    consecutive_secs <= 60;
                end else if (consecutive_secs == 60) begin // past 60s threshold
                    high_time_secs <= high_time_secs + 1;
                end else begin
                    consecutive_secs <= consecutive_secs + 1;
                end
            end else begin
                consecutive_secs <= 0;
            end
        end
    end
    
endmodule
