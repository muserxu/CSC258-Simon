/*
 * A module that loads the eeprom that contains the levels.
 */
module level_loader(
    input [1:0] color_in,
    input reset,
    input clk,
    output reg [2:0] addr,
    output reg [1:0] color_out,
    output reg write
    );
    
    localparam MAX_LEVEL = 4'd8;
    wire [2:0] w;
    reg [2:0]counter;
    
    assign w = 3'd2;
    
    always @(posedge clk) begin
        if (~reset) begin
            counter <= 3'b0;
            write <= 1'b0;
        end
        else begin
            if (counter < MAX_LEVEL) begin
                color_out <= color_in;
                write <= 1'b1;
                counter <= counter + 1'b1;
            end
        end
    end
    
    always @(negedge clk) begin
        write <= 1'b0;
    end
endmodule
