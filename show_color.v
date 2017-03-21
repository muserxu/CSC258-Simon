/*
 * Set the output corresponding to color to high
 * and every other output to low.
 */
module show_color(
    input [1:0] color,
    input go,
    output [3:0] out
    );
    
    // colors
    localparam B = 2'b00,
               G = 2'b01,
               R = 2'b10,
               Y = 2'b11;
               
    always @(*) begin
        if (go) begin
            case (color)
                B: out[0] = 1'b1;
                G: out[1] = 1'b1;
                R: out[2] = 1'b1;
                Y: out[3] = 1'b1;
                default: out[3:0] = 4'b0000;
                endcase
            end
        else
            out[3:0] = 4'b0000;
endmodule
