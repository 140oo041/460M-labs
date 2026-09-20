module secs_32_steps (
    input clk,
    input rst,
    input [15:0] steps_past_second,
    input tick,
    output reg [3:0] num
);
    
    reg [3:0] second_timer;

    always @(posedge clk) begin
        if (rst) second_timer <= 0;
        else if (tick && second_timer < 9) second_timer <= second_timer + 1;
    end

    always @(posedge clk) begin
        if (rst) num <= 0;
        else if (tick && second_timer < 9 && steps_past_second > 32) num <= num + 1;
    end

endmodule
