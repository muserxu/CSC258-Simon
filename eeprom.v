/*
  A simple eeprom module.
 */ 
 module eeprom(
    input [2:0] address,
    input [1:0] data_in,
    input write_en,
    output reg[1:0] out
    );
    
    // WORD_WIDTH is the number of bits we need to represent a color.
    // ADDR_WIDTH is the number of addresses (levels).
    parameter WORD_WIDTH = 2,
              ADDR_WIDTH = 8;
    
    reg [WORD_WIDTH -1 :0] data [ADDR_WIDTH - 1:0];
    
    wire [2:0] addr;
    assign addr = address;
    
    always @(*) begin
        if (!write_en)
            out = data[addr];
        else begin
            data[addr] = data_in;
        end
    end
endmodule
