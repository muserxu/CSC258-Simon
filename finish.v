module finish(clk, resetn, finish, counter, level);
	input clk, resetn;
	input [2:0] counter, level;
	output finish;
	always@(posedge clk) begin
		if (~resetn)
			finish <= 1'b0;
		else begin
			if (counter == level)
				finish <= 1'b1;
			else
				finish <= 1'b0
		end
	end
endmodule