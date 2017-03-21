/*
 * Outputs one pulse per second.
 * This module assumes that the frequency of the input
 * clk is 50Mhz.
 */

module rate_divider(
    input clk,
    output reg pulse
    );
    
    reg [26:0] counter = 26'd0;
    wire pul;
    
    // the rate of the on board clock (50Mhz).
    localparam RATE = 26'd49_999_999;
    
    always @(posedge clk) begin
        counter <= counter + 1;
        
        if (counter == RATE)
            pulse <= 1'b1;
        else
            pulse <= 1'b0; 
    end
endmodule
