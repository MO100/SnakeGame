module score (
    input [7:0] score_in,  // 8-bit input score from the food module
    output [6:0] HEX0,     // Output for the first seven-segment display (units)
    output [6:0] HEX1      // Output for the second seven-segment display (tens)
);
    wire [3:0] ones;  // Units place
    wire [3:0] tens;  // Tens place

    assign ones = score_in % 10;  // Calculate units digit
    assign tens = score_in / 10;  // Calculate tens digit

    // Instantiate seven-segment decoders for HEX0 and HEX1
    HEX_counter units_display (.data_in(ones), .data_out(HEX0));
    HEX_counter tens_display  (.data_in(tens), .data_out(HEX1));
endmodule




module HEX_counter(data_in, data_out);
    input [3:0] data_in; 
    output [6:0] data_out; 
    reg [6:0] data_out; 
    
    parameter blnk = 7'b000_0000;
    parameter zero = 7'b100_0000;
    parameter one = 7'b111_1001;
    parameter two = 7'b010_0100;
    parameter three = 7'b011_0000;
    parameter four = 7'b001_1001;
    parameter five = 7'b001_0010;
    parameter six = 7'b000_0010;
    parameter seven = 7'b111_1000;
    parameter eight = 7'b000_0000; 
    parameter nine = 7'b001_0000;
    
    always@(data_in) begin 
        case(data_in) 
            4'd0: data_out = zero; 
            4'd1: data_out = one; 
            4'd2: data_out = two; 
            4'd3: data_out = three; 
            4'd4: data_out = four; 
            4'd5: data_out = five; 
            4'd6: data_out = six; 
            4'd7: data_out = seven; 
            4'd8: data_out = eight; 
            4'd9: data_out = nine; 
            default: data_out = blnk;
        endcase 
    end 
endmodule
