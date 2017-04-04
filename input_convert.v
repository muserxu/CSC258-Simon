module input_convert(
    input [3:0] keys,
    input clk,
    output reg [1:0] out
    );
    
    localparam B = 2'b00,
               G = 2'b01,
               R = 2'b10,
               Y = 2'b11;
    
    always @(posedge clk) begin
        case (keys)
            4'b0001: out <= B;
            4'b0010: out <= G;
            4'b0100: out <= R;
            4'b1000: out <= Y;
            default: out <= B;
        endcase
    end
endmodule
