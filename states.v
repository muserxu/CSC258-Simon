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
