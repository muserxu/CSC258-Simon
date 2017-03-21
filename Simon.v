module simon(SW, LEDR, KEY);
    input SW[9:0];
    input KEY[3:0];
    output LEDR[9:0];
    wire ld, next ,resetn, clk, show, match, cor;
    wire [1:0] compare1, compare2;
    wire [3:0] out;
    reg [1:0] counter;


    assign resetn = ~KEY[2];
    assign clk = ~KEY[0];
    always @(posedge clk) begin
        if (~resetn) begin
            match <= 1'b0;
            counter <= 2'b0;
        end
        else begin
            if (match)
                counter <= counter + 1'd1;
        end
    end

    finish f0(.clk(clk),
              .resetn(resetn),
              .counter(counter),
              .level(level),
              .finish(finish));


    pattern_shifter p0(.pattern(SW[3:0]),
                       .load_p(ld),
                       .next(next),
                       .resetn(resetn),
                       .clk(clk),
                       .out(compare1));

    show_color s0(.color(compare1),
                  .go(show),
                  .out(out));

    pattern_shifter p1(.pattern(SW[3:0]),
                       .load_p(ld),
                       .next(next),
                       .resetn(resetn),
                       .clk(clk),
                       .out(compare2));

    comparator c0(.in(SW[9:8]),
                  .compare(compare2),
                  .clk(clk),
                  .enable(comp),
                  .resetn(resetn),
                  .out(cor));

    control C0(.clk(clk),
               .resetn(resetn),
               .go(KEY[1]),
               .cor(cor),
               .finish(finish),
               .ld(ld),
               .show(show),
               .comp(comp),
               .match(match));


endmodule;

module finish(clk, resetn, finish, counter, level);
    input clk, resetn;
    input [1:0] counter, level;
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

module comparator(in, clk, compare, resetn, enable, out);
    input [1:0] in;
    input [1:0] compare;
    input clk, enable, resetn;
    output reg out;
    always (posedge clk)
        if (~resetn)
            compare <= 2'b0;
            out <= 1'b1;
        else if (enable) begin
            if (compare == in)
                out <= 1'b1;
            else
                out <= 1'b0;
        end
    end
endmodule

module pattern_shifter(
    input [3:0] pattern,
    input load_p,
    input next,
    input resetn,
    input clk,
    output reg [1:0] compare
    );
    
    reg [3:0] current_pattern;

    always @(posedge clk) begin
        if (~resetn)
            current_pattern <= 4'b0;
            result <= 1'b1;
        else if (load_p)
            current_pattern <= pattern;
        else if (next) begin
            compare[1:0] <= current_pattern[1:0];
            current_pattern >> 2;
        end
    end
endmodule



module show_color(
    input [1:0] color,
    input go,
    output [3:0] out
    );
    
    // colors
    localparam B = 2'b00,
               G = 2'b01,
               R = 2'b10,
               Y = 2'b11;
               
    always @(*) begin
        if (go) begin
            case (color)
                B: out[0] = 1'b1;
                G: out[1] = 1'b1;
                R: out[2] = 1'b1;
                Y: out[3] = 1'b1;
                default: out[3:0] = 4'b0000;
                endcase
            end
        else
            out[3:0] = 4'b0000;
endmodule




module control(
    input clk,
    input resetn,
    input go,
    input cor,
    input finish,
    
    output reg  ld, show, comp, match
    );

    reg [3:0] current_state, next_state; 
    
       localparam  S_LOAD        = 4'd0,
                S_LOAD_WAIT   = 4'd1,
                S_SHOW        = 4'd2,
                S_SHOW_WAIT   = 4'd3,
                S_COMPARE        = 4'd4,
                S_COMPARE_WAIT   = 4'd5,
                S_MATCH        = 4'd6,
                S_WIN = 4'd7,
                S_LOSE = 4'b8;
    
    // Next state logic aka our state table
    always@(*)
    begin: state_table 
            case (current_state)
                S_LOAD: next_state = go ? S_LOAD_WAIT : S_LOAD; // Loop in current state until value is input
                S_LOAD_A_WAIT: next_state = go ? S_LOAD_WAIT : S_SHOW; // Loop in current state until go signal goes low
                S_SHOW: next_state = go ? S_SHOW_WAIT : S_SHOW; // Loop in current state until value is input
                S_SHOW_WAIT: next_state = go ? S_SHOW_WAIT : S_COMPARE; // Loop in current state until go signal goes low
                S_COMPARE: next_state = go ? S_COMPARE_WAIT : S_COMPARE; // Loop in current state until value is input
                S_COMPARE_WAIT: next_state = cor ? S_MATCH : S_LOSE; // Loop in current state until go signal goes low
                S_MATCH: next_state = finish ? S_WIN : S_COMPARE; // Loop in current state until value is input
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
 

        case (current_state)
            S_LOAD: begin
                ld = 1'b1;
                end
            S_SHOW: begin
                show = 1'b1;
                end
            S_COMPARE: begin
                compare = 1'b1;
                end
            S_MATCH: begin
                match = 1'b1;
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
