/*
 * Loads the pattern and shift the next color to compare.
 * The output is the shifted color.
 */
module pattern_shifter(
    input [3:0] pattern,
    input load_p,
    input next,
    input resetn,
    input clk,
    output reg [0:1] compare);
    
    reg [3:0] current_pattern;

    always @(posedge clk) begin
        if (~resetn)
            current_pattern <= 4'b0;
            result <= 1'b1;
        else if (load_p)
            current_pattern <= pattern;
        else if (next) begin
            compare <= current_pattern [0:1];
            current_pattern << 2;
        end
    end
endmodule
