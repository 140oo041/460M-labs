`timescale 1ns/1ps

module tb_top;

    localparam CYCLES_PER_SECOND = 6400;

    localparam WALK = 2'b00;
    localparam JOG = 2'b01;
    localparam RUN = 2'b10;
    localparam HYBRID = 2'b11;

    reg clk = 0;
    reg rst = 1;
    reg start = 0;
    reg [1:0] mode = WALK;
    wire SI;
    wire [3:0] an;
    wire [6:0] seg;

    top dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .mode(mode),
        .SI(SI),
        .an(an),
        .seg(seg)
    );

    // shorten 1 second to 6400 cycles for simulation
    // defparam syntax was provided by AI
    defparam dut.pulse_gen_u.SYS_CLK_HZ = CYCLES_PER_SECOND;
    defparam dut.tick_gen_u.SYS_CLK_HZ = CYCLES_PER_SECOND;

    always #5 clk = ~clk;

    integer errors = 0;

    // count a failure if the condition is false
    task check(input ok);
        if (!ok) begin
            $display("FAIL at %0t", $time);
            errors = errors + 1;
        end
    endtask

    // reset, select mode, start
    task begin_test(input [1:0] new_mode);
        rst = 1;
        start = 0;
        mode = new_mode;
        repeat (5) @(posedge clk);
        start = 1;
        repeat (5) @(posedge clk);
        rst = 0;
    endtask

    // let pulses keep running for a number of seconds
    task run_for_seconds(input integer seconds);
        repeat (seconds * CYCLES_PER_SECOND + 10) @(posedge clk);
    endtask

    // test cases were written by us, but correct values for check provided by AI
    initial begin
        // walk: 640 steps, no seconds above 32, no high activity
        begin_test(WALK);
        run_for_seconds(20);
        check(dut.steps == 640);
        check(dut.num == 0);
        check(dut.high_time_secs == 0);

        // jog just under 60 s: 3776 steps, secs above 32 = 9, high time = 0
        begin_test(JOG);
        run_for_seconds(59);
        check(dut.steps == 3776);
        check(dut.num == 9);
        check(dut.high_time_secs == 0);

        // jog 60 s: high time = 60
        begin_test(JOG);
        run_for_seconds(60);
        check(dut.high_time_secs == 60);

        // jog 65 s: high time keeps counting = 65
        begin_test(JOG);
        run_for_seconds(65);
        check(dut.high_time_secs == 65);

        // run: 1920 steps, secs above 32 = 9
        begin_test(RUN);
        run_for_seconds(20);
        check(dut.steps == 1920);
        check(dut.num == 9);

        // hybrid first 9 s: 332 steps, secs above 32 = 5
        begin_test(HYBRID);
        run_for_seconds(9);
        check(dut.steps == 332);
        check(dut.num == 5);

        // hybrid full sequence: steps saturate at 9999, SI = 1, high time = 126
        begin_test(HYBRID);
        run_for_seconds(150);
        check(dut.steps == 9999);
        check(SI == 1);
        check(dut.high_time_secs == 126);

        // walk 330 s: step overflow, steps stay 9999, SI = 1, half miles = 5
        begin_test(WALK);
        run_for_seconds(330);
        check(dut.steps == 9999);
        check(SI == 1);
        check(dut.half_miles == 5);

        // reset clears steps, SI, distance, secs above 32, high time
        rst = 1;
        repeat (3) @(posedge clk);
        #1;
        check(dut.steps == 0);
        check(SI == 0);
        check(dut.half_miles == 0);
        check(dut.num == 0);
        check(dut.high_time_secs == 0);

        if (errors == 0) $display("ALL TESTS PASSED");
        else $display("%0d TESTS FAILED", errors);
        $finish;
    end

endmodule
