/*
 * A linear-feedback shift register that outputs random 2-bit numbers.
 */
module rng(
    input clk,
    input reset,
    output [1:0] out
    );
    
    reg [15:0] value = 16'd13680;
    
    assign out = value[15:14];
     
    always @(posedge clk) begin
        value <= {value[14:0], value[12] ^ value[7]};
    end
endmodule
