 module eeprom(
    input [5:0] address,
    input [1:0] data_in,
    input write_en,
    input write,
    output reg[1:0] out
    );
    
    reg [1:0] data [7:0];
    
    always @(* or write) begin
        if (!write_en)
            out <= data[address];
        else begin
            data[address + 1, address] <= data_in;
        end
    end
endmodule
