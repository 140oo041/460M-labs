module tick_gen (
    input clk,
    input rst,
    output tick
);

    localparam SYS_CLK_HZ = 100_000_000;
    localparam TARGET_HZ = 1;
    localparam MAX_CNT = SYS_CLK_HZ / TARGET_HZ;
    localparam CNT_W = $clog2(MAX_CNT);

    reg [CNT_W-1:0] cnt;
    
    always @(posedge clk) begin
        if (rst) cnt <= 0;
        else begin
            if (cnt == MAX_CNT - 1) cnt <= 0;
            else cnt <= cnt + 1;
        end
    end

    assign tick = (cnt == MAX_CNT - 1);
    
endmodule
