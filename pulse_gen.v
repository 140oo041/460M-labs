module pulse_gen (
    input clk,
    input rst,
    input start,
    input [1:0] mode,
    output reg pulse
);
    
    parameter SYS_CLK_HZ = 100_000_000;
    localparam TARGET_HZ = 1;
    localparam MAX_CNT = SYS_CLK_HZ / TARGET_HZ;
    localparam CNT_W = $clog2(MAX_CNT);

    reg prev_start;
    always @(posedge clk) prev_start <= start; // delayed-cycle start to detect LOW->HIGH change

    reg [CNT_W-1:0] sec_cnt;
    reg [7:0] secs_elapsed; // 145 max

    wire tick;
    assign tick = (sec_cnt == MAX_CNT - 1);

    always @(posedge clk) begin
        if (rst || (!prev_start && start)) begin
            sec_cnt <= 0;
            secs_elapsed <= 0;
        end
        else if (tick) begin
            sec_cnt <= 0;
            if (secs_elapsed < 145) secs_elapsed <= secs_elapsed + 1; // saturate at 145 elapsed secs
        end
        else sec_cnt <= sec_cnt + 1;
    end

    reg [6:0] n; // 7 bits to hold max 111 pulses/sec

    always @(*) begin
        n = 0;
        case (mode)
            2'b00: n = 32;
            2'b01: n = 64;
            2'b10: n = 96;
            2'b11: begin
                case (secs_elapsed)
                    0: n = 18;
                    1: n = 35;
                    2: n = 57;
                    3: n = 24;
                    4: n = 71;
                    5: n = 39;
                    6: n = 22;
                    7: n = 30;
                    8: n = 36;
                    default: begin
                        if (secs_elapsed >= 9 && secs_elapsed <= 70) n = 73;
                        else if (secs_elapsed >= 71 && secs_elapsed <= 79) n = 41;
                        else if (secs_elapsed >= 80 && secs_elapsed <= 143) n = 111;
                        else if (secs_elapsed >= 144) n = 0;
                    end
                endcase
            end
        endcase
    end

    reg [27:0] acc; // 100_000_000 max

    always @(posedge clk) begin
        if (rst || !start || n == 0) begin
            acc <= SYS_CLK_HZ / 2; // mid-second phase so no pulse lands on a 1s tracker boundary
            pulse <= 0;
        end else begin
            if (acc + n >= SYS_CLK_HZ) begin
                acc <= acc + n - SYS_CLK_HZ;
                pulse <= 1;
            end else begin
                acc <= acc + n;
                pulse <= 0;
            end
        end
    end
    
endmodule
