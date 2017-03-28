/*
 * A module that loads the eeprom that contains the levels.
 */
module level_loader(
    input go,
    input [1:0] color_in,
    input reset,
    input clk,
    output reg [2:0] addr,
    output reg [1:0] color_out,
    output reg write
    );
    
    localparam MAX_LEVEL = 4'd8;

    always @(posedge clk) begin
        if (~reset) begin
            addr <= 3'b0;
            color_out <= 3'b0;
            write <= 1'b0;
        end

        else begin
            if (addr < MAX_LEVEL) begin
                color_out <= color_in;
                write <= 1'b1;
                addr <= addr + 1'b1;
            end
        end
    end
    
    always @(negedge clk) begin
        write <= 1'b0;
    end
endmodule
