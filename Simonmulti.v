module Simonmulti(SW, LEDR, KEY, HEX0, HEX1, HEX2);
    input [9:0]SW;
    input [3:0]KEY;
    output [9:0]LEDR;
    output [6:0] HEX0, HEX1, HEX2;
    wire ld, next ,resetn, clk, show, cor, reload, level_up, win_single;
    wire [1:0] compare1, compare2;
    wire [3:0] out;
    reg [3:0] counter_match, counter_show, current_level;
    wire finish1, finish_match;
    reg finish3;
	 
     wire [1:0]cur_colour;


	 wire match;
	 wire [1:0]level;
     wire [3:0] current_state;
	 assign level = 2'b10;
	 
	 wire [2:0] addr;
    wire [1:0] colour_out;
    wire write_en;
    wire [1:0]out_led;
    wire finish_load;
	 
	
	 assign LEDR[3:0] = out [3:0];
	 assign LEDR[9] = cor;
    assign resetn = KEY[2];
    assign clk = ~KEY[0];


    always @(posedge clk) begin
        if (~resetn) begin
 
            counter_match <= 4'b0;
        end
        else begin
            if (match)
                counter_match <= counter_match + 1'd1;
            else if (win_single)
                counter_match <= 4'b0;
        end
    end

	 always @(posedge clk) begin
        if (~resetn) begin
            counter_show <= 4'b0;
        end
        else begin
            if (show)
                counter_show <= counter_show + 1'd1;
            else if(reload)
                counter_show <= 4'b0;
        end
    end

    always @(posedge clk) begin
        if (~resetn) begin
            current_level <= 4'b0;
        end
        else begin
            if (level_up)
                current_level <= current_level + 1'd1;
        end
    end

    always@(posedge clk) begin
        if (~resetn)begin
            current_level <= 1'b0;
            finish3 <= 1'b0;
            end
        else begin
            if (current_level == 3'd7)
                finish3 <= 1'b1;
            else
                finish3 <= 1'b0;
        end
    end


    reg [2:0]address;
    always@ (posedge clk) begin
        if (~resetn)
            address <= 3'b0;
        else begin
        if (show)
            address <= counter_show;
        else if (match)
            address <= counter_match;
        else if (ld)
            address <= addr;
            end
        end


    hex_decoder h0(.hex_digit(current_state), .segments(HEX0));
    hex_decoder h1(.hex_digit(counter1), .segments(HEX1));
    hex_decoder h2(.hex_digit(counter2), .segments(HEX2));
	 
    finish f0(.clk(clk),
              .resetn(resetn),
              .counter(counter_match),
              .level(current_level),
              .finish(finish_match));
	 
	 finish f1(.clk(clk),
              .resetn(resetn),
              .counter(counter_show),
              .level(current_level),
              .finish(finish_show));

    
	
	assign LEDR[8] = finish_match;

    rng r0(
    .clk(clk),
    .reset(resetn),
    .out(cur_colour)
    );

    

    level_loader l0(
    .color_in(cur_colour),
    .reset(resetn),
    .clk(clk),
    .addr(addr),
    .color_out(colour_out),
    .write(write_en),
    .finish_load(finish_load)
    );

    //should connect address to multiplexier 
    eeprom e0(.address(address),
            .data_in(colour_out),
            .write_en(write_en),
            .out(out_led));



    show_color s0(.color(out_led),
                  .go(show),
                  .out(out));



    comparator c0(.in(SW[9:8]),
                  .compare(out_led),
                  .clk(clk),
                  .enable(comp),
                  .resetn(resetn),
                  .out(cor));

    control C0(.clk(clk),
               .resetn(resetn),
               .cor(cor),
               .finish_show(finish_show),
		      .finish_match(finish_match),
                .finish3(finish3),
               .ld(ld),
               .show(show),
               .comp(comp),
               .match(match),
				.reload(reload),
                .current_state1(current_state),
                .win_single(win_single),
                .level_up(level_up),
                .finish_load(finish_load));


endmodule

module finish(clk, resetn, finish, counter, level);
    input clk, resetn;
    input [3:0] counter;
    input [3:0] level;
    output reg finish;
    always@(posedge clk) begin
        if (~resetn)
            finish <= 1'b0;
        else begin
            if (counter == level)
                finish <= 1'b1;
            else
                finish <= 1'b0;
        end
    end
endmodule

module comparator(in, clk, compare, resetn, enable, out);
    input [1:0] in;
    input [1:0] compare;
    input clk, enable, resetn;
    output reg out;
    always @(posedge clk) begin
        if (~resetn) begin
            out <= 1'b0;
				end
        else begin
		  if (enable) begin
            if (compare == in)
                out <= 1'b1;
            else
                out <= 1'b0;
        end
		  end
    end
endmodule



module show_color(
    input [1:0] color,
    input go,
    output reg [3:0] out
    );
    
    // colors
    localparam B = 2'b00,
               G = 2'b01,
               R = 2'b10,
               Y = 2'b11;
               
    always @(*) begin
        if (go) begin
            case (color)
                B:begin
					 out[0] = 1'b1;
					 out[1] = 1'b0;
					 out[2] = 1'b0;
					 out[3] = 1'b0;
					 end
					 G:begin
					 out[0] = 1'b0;
					 out[1] = 1'b1;
					 out[2] = 1'b0;
					 out[3] = 1'b0;
					 end
					 R:begin
					 out[0] = 1'b0;
					 out[1] = 1'b0;
					 out[2] = 1'b1;
					 out[3] = 1'b0;
					 end
					 Y:begin
					 out[0] = 1'b0;
					 out[1] = 1'b0;
					 out[2] = 1'b0;
					 out[3] = 1'b1;
					 end

                default: out[3:0] = 4'b0000;
                endcase
            end
        else
            out[3:0] = 4'b0000;
	end
endmodule




module control(
    input clk,
    input resetn,
    input cor,
    input finish_load,
    input finish_show,
	input finish_match,
    input finish3,
    
    output reg  ld, show, comp, match, reload, win_single, level_up,
    output reg [3:0]current_state1
    );

    reg [3:0] current_state, next_state; 
    
       localparam  S_LOAD        = 4'd0,
                S_SHOW        = 4'd1,
                S_SHOW_WAIT   = 4'd2,
				S_RELOAD = 4'd3,
                S_COMPARE        = 4'd4,
                S_COMPARE_WAIT   = 4'd5,
                S_MATCH        = 4'd6,
                S_WIN_SINGLE = 4'd7,
                S_LEVEL_UP = 4'd8,
                S_WIN = 4'd9,
                S_LOSE = 4'd10,
                S_START = 4'd11,
                S_LOAD_WAIT = 4'd12;
    
    // Next state logic aka our state table
    always@(*)
    begin: state_table 
            case (current_state)
                S_START: next_state = S_LOAD;
                S_LOAD: next_state = S_LOAD_WAIT; 
                S_LOAD_WAIT: next_state = finish_load ? S_SHOW : S_LOAD_WAIT;
                S_SHOW: next_state =  S_SHOW_WAIT; // Loop in current state until value is input
                S_SHOW_WAIT: next_state = finish_show ? S_RELOAD : S_SHOW; // Loop in current state until go signal goes low
		        S_RELOAD: next_state = S_COMPARE;
                S_COMPARE: next_state = S_COMPARE_WAIT  ; // Loop in current state until value is input
                S_COMPARE_WAIT: next_state = cor ? S_MATCH : S_LOSE; // Loop in current state until go signal goes low
                S_MATCH: next_state = finish_match ? S_WIN_SINGLE : S_COMPARE;
                S_WIN_SINGLE: next_state = finish3 ? S_WIN : S_LEVEL_UP;
                S_LEVEL_UP: next_state = S_SHOW;
                S_WIN: next_state = S_LOAD;
                S_LOSE: next_state = S_LOAD;
            default:     next_state = S_LOAD;
        endcase
    end // state_table
   

    // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0
        ld = 1'b0;
        show = 1'b0;
        comp = 1'b0;
        match = 1'b0;
		reload = 1'b0;
        win_single = 1'b0;
        level_up = 1'b0;

 

        case (current_state)
            S_START: begin
                current_state1 = 4'd0;
                end
            S_LOAD: begin
                ld = 1'b1;
                current_state1 = 4'd1;
                end
            S_LOAD_WAIT: begin
                ld = 1'b0;
                end
            S_SHOW: begin
                show = 1'b1;
                level_up = 1'b0;
                current_state1 = 4'd2;
                end
			S_SHOW_WAIT: begin
                show = 1'b0;
                current_state1 = 4'd3;
                end
			S_RELOAD: begin
				reload = 1'b1;
                current_state1 = 4'd4;
				end
					
            S_COMPARE: begin
				reload = 1'b0;
                comp = 1'b1;
                match = 1'b0;

                current_state1 = 4'd5;
                end
			S_COMPARE_WAIT: begin
                comp = 1'b0;
                current_state1 = 4'd6;
                end
            S_MATCH: begin
                match = 1'b1;
                current_state1 = 4'd7;
                end
            S_WIN_SINGLE: begin
                win_single = 1'b1;
                current_state1 = 4'd8;
                end
            S_LEVEL_UP: begin
                win_single = 1'b0;
                level_up = 1'b1;
                current_state1 = 4'd9;
                end
            S_WIN: begin
                current_state1 = 4'd10;
                end
            S_LOSE: begin
                current_state1 = 4'd11;
                end

            
        endcase
    end // enable_signals
   
    // current_state registers
    always@(posedge clk)
    begin: state_FFs
        if(!resetn)
            current_state <= S_LOAD;
        else
            current_state <= next_state;
    end // state_FFS
endmodule

module hex_decoder(hex_digit, segments);
    input [3:0] hex_digit;
    output reg [6:0] segments;
   
    always @(*)
        case (hex_digit)
            4'h0: segments = 7'b100_0000;
            4'h1: segments = 7'b111_1001;
            4'h2: segments = 7'b010_0100;
            4'h3: segments = 7'b011_0000;
            4'h4: segments = 7'b001_1001;
            4'h5: segments = 7'b001_0010;
            4'h6: segments = 7'b000_0010;
            4'h7: segments = 7'b111_1000;
            4'h8: segments = 7'b000_0000;
            4'h9: segments = 7'b001_1000;
            4'hA: segments = 7'b000_1000;
            4'hB: segments = 7'b000_0011;
            4'hC: segments = 7'b100_0110;
            4'hD: segments = 7'b010_0001;
            4'hE: segments = 7'b000_0110;
            4'hF: segments = 7'b000_1110;   
            default: segments = 7'h7f;
        endcase
endmodule

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

module level_loader(
    input [1:0] color_in,
    input reset,
    input clk,
    output reg [2:0] addr,
    output reg [1:0] color_out,
    output reg write,
    output reg finish_load
    );
    
    localparam MAX_LEVEL = 4'd8;
    
    assign w = 3'd2;
    
    always @(posedge clk) begin
        if (~reset) begin
            addr <= 3'b0;
            write <= 1'b0;
            finish_load <= 1'b0;
        end
        else begin
            if (addr < MAX_LEVEL) begin
                color_out <= color_in;
                write <= 1'b1;
                addr <= addr + 1'b1;
            end
            else begin
                finish_load <= 1'b1;
                end
        end
    end
    
    always @(negedge clk) begin
        write <= 1'b0;
    end
endmodule

