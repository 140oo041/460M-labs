module stepsPerSec(input pulse, tick clk, rst, output reg[15:0] steps);
    always @(posedge clk) begin
        if(rst || tick) begin
            steps <= 0;
        end else begin
            if(pulse) begin
                steps <= steps + 1;
            end else begin
                steps <= steps;
            end
        end
    end
endmodule