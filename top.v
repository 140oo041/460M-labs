module top (
    input clk,
    input rst,
    input start,
    input [1:0] mode,
    output SI,
    output [3:0] an,
    output [6:0] seg
);

    wire pulse;
    pulse_gen pulse_gen_u (
        .clk(clk),
        .rst(rst),
        .start(start),
        .mode(mode),
        .pulse(pulse)
    );

    wire [13:0] steps; // part A display
    steps_A steps_A_u (
        .clk(clk),
        .rst(rst),
        .pulse(pulse),
        .steps(steps),
        .SI(SI)
    );

    wire [10:0] half_miles; // part B display
    distance_B distance_B_u (
        .clk(clk),
        .rst(rst),
        .pulse(pulse),
        .half_miles(half_miles)
    );

    wire tick;
    tick_gen tick_gen_u (
        .clk(clk),
        .rst(rst),
        .tick(tick)
    );

    wire [15:0] steps_past_second;
    steps_per_sec steps_per_sec_u (
        .clk(clk),
        .rst(rst),
        .tick(tick),
        .pulse(pulse),
        .steps_past_second(steps_past_second)
    );

    wire [3:0] num; // part C display
    secs_32_steps_C secs_32_steps_C_u (
        .clk(clk),
        .rst(rst),
        .steps_past_second(steps_past_second),
        .tick(tick),
        .num(num)
    );

    wire [13:0] high_time_secs; // part D display
    high_time_D high_time_D_u (
        .clk(clk),
        .rst(rst),
        .tick(tick),
        .steps_past_second(steps_past_second),
        .high_time_secs(high_time_secs)
    );

    display_ctrl display_ctrl_u (
        .clk(clk),
        .rst(rst),
        .tick(tick),
        .steps(steps),
        .distance_half_miles(half_miles),
        .secs_32(num),
        .high_time(high_time_secs),
        .an(an),
        .seg(seg)
    );
    
endmodule
