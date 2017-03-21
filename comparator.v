/*
* Comparator to compare whether the colour matches, output 1 if match, 2 if not.
*/

module comparator(in, clk, compare, resetn, enable, out);
	input [1:0] in;
	input [1:0] compare;
	input clk, enable, resetn;
	output reg [1:0] out;
	always (posedge clk)
		if (~resetn)
			compare <= 2'b0;
			out <= 2'b0;
		else if (enable) begin
			if (compare == in)
				out <= 2'b01;
			else
				out <= 2'b10;
		end
	end
endmodule
