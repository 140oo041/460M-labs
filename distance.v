module distance (
    input clk,
    input rst,
    input pulse,
    output reg [10:0] half_miles
);

    reg [10:0] step_count;

    always @(posedge clk) begin
        if (rst) begin
            step_count <= 0;
            half_miles <= 0;
        end else if (pulse) begin
            if (step_count == 2047) begin
                step_count <= 0;
                if (half_miles < 1999) begin
                    half_miles <= half_miles + 1;
                end
            end else begin
                step_count <= step_count + 1;
            end
        end
    end
    
endmodule
