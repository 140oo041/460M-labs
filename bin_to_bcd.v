module bin_to_bcd (
    input [13:0] bin,
    output reg [3:0] b3,
    output reg [3:0] b2,
    output reg [3:0] b1,
    output reg [3:0] b0 
);

    integer i;
    reg [29:0] shift;

    // Double Dabble Algorithm with 14 bit input and 16 bit (4 BCD) output
    always @(*) begin
        shift = 0;
        shift[13:0] = bin;
        
        for (i = 0; i < 14; i = i + 1) begin
            if (shift[17:14] >= 5) shift[17:14] = shift[17:14] + 3;
            if (shift[21:18] >= 5) shift[21:18] = shift[21:18] + 3;
            if (shift[25:22] >= 5) shift[25:22] = shift[25:22] + 3;
            if (shift[29:26] >= 5) shift[29:26] = shift[29:26] + 3;
            
            shift = shift << 1;
        end
        
        b3 = shift[29:26];
        b2 = shift[25:22];
        b1 = shift[21:18];
        b0 = shift[17:14];
    end

endmodule
