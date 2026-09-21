module steps (
    input clk,
    input rst,
    input pulse,
    output reg [13:0] steps,
    output reg SI
);

    always @(posedge clk) begin
        if (rst) begin
            steps <= 0;
            SI <= 0;
        end else if (pulse) begin
            if (steps >= 9999) begin
                steps <= 9999;
                SI <= 1;
            end else begin
                steps <= steps + 1;
            end
        end
    end
    
endmodule
