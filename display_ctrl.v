module display_ctrl (
    input clk,
    input rst,
    input tick,
    input [13:0] steps,
    input [10:0] distance_half_miles,
    input [3:0] secs_32,
    input [13:0] high_time,
    output reg [3:0] an,
    output wire [6:0] seg
);

    reg [1:0] disp_state; // 0=Steps, 1=Distance, 2=Secs_32, 3=High
    reg sec_cnt;

    // Change display state every 2 seconds
    always @(posedge clk) begin
        if (rst) begin
            disp_state <= 0;
            sec_cnt <= 0;
        end else if (tick) begin
            sec_cnt <= sec_cnt + 1;
            if (sec_cnt == 1) begin
                disp_state <= disp_state + 1;
            end
        end
    end

    // Multiplex the data based on display state
    reg [13:0] bin_val;
    always @(*) begin
        case (disp_state)
            0: bin_val = steps;
            1: bin_val = distance_half_miles * 5; // conversion (5 half miles becomes 5*5 = 25 = 2_5 miles)
            2: bin_val = secs_32;
            3: bin_val = high_time;
        endcase
    end

    // Convert selected data to BCD
    wire [3:0] b3, b2, b1, b0;
    bin_to_bcd converter (
        .bin(bin_val),
        .b3(b3),
        .b2(b2),
        .b1(b1),
        .b0(b0)
    );

    // Format BCD digits (leading zeros, underscore, off, etc.)
    reg [3:0] d3, d2, d1, d0;
    always @(*) begin
        // the X ? 4'hF : Y is a way to turn off leading zeros, and 4'hF is mapped to off in bcd_to_7seg
        case (disp_state)
            0, 3: begin // Steps and High Time, normal
                d3 = (b3 == 0) ? 4'hF : b3;
                d2 = (b3 == 0 && b2 == 0) ? 4'hF : b2;
                d1 = (b3 == 0 && b2 == 0 && b1 == 0) ? 4'hF : b1;
                d0 = b0;
            end
            1: begin // Distance, underscore in front of decimal
                d3 = (b2 == 0) ? 4'hF : b2; // tens place of miles
                d2 = b1;                    // ones place of miles
                d1 = 4'hA;                  // custom underscore
                d0 = b0;                    // decimal 5 or 0
            end
            2: begin // Secs > 32, only 1 digit on
                d3 = 4'hF;
                d2 = 4'hF;
                d1 = 4'hF;
                d0 = b0;
            end
        endcase
    end

    // Time multiplex the BCD digits
    reg [16:0] time_mux_counter;
    always @(posedge clk) begin
        if (rst) time_mux_counter <= 0;
        else time_mux_counter <= time_mux_counter + 1;
    end

    reg [3:0] current_digit;

    always @(*) begin
        case (time_mux_counter[16:15])
            2'b00: begin
                an = 4'b1110;
                current_digit = d0;
            end
            2'b01: begin
                an = 4'b1101;
                current_digit = d1;
            end
            2'b10: begin
                an = 4'b1011;
                current_digit = d2;
            end
            2'b11: begin
                an = 4'b0111;
                current_digit = d3;
            end
        endcase
    end

    // Convert current digit in the time mux to 7 segment signals
    bcd_to_7seg decoder (
        .bcd(current_digit),
        .seg(seg)
    );

endmodule
