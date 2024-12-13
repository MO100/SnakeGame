module gameStart (
    input        CLOCK_50,    // Clock
    input        SW,          // Start game switch
    input  [3:0] KEY,         // Pushbutton
    input  [11:0] x,          // Current X pixel coordinate
    input  [11:0] y,          // Current Y pixel coordinate
    output       game_active, // Signal to start the game
    output [7:0] vga_r,       // VGA Red color 
    output [7:0] vga_g,       // VGA Green color 
    output [7:0] vga_b        // VGA Blue color 
);

    // Screen dimensions
    parameter SCREEN_WIDTH  = 640;
    parameter SCREEN_HEIGHT = 480;

    // flag
    reg active = 0;

    assign game_active = active;

    // Check for start signal
    always @(posedge CLOCK_50) begin
        if (SW) begin
            active <= 1; // Activate the game when SW is toggled high
        end else begin
            active <= 0; // Deactivate the game when SW is low
        end
    end

    //start screen
    wire inside_message = 
        (x > (SCREEN_WIDTH / 4)) && (x < (SCREEN_WIDTH * 3 / 4)) &&
        (y > (SCREEN_HEIGHT / 4)) && (y < (SCREEN_HEIGHT / 2));

    assign vga_r = (active) ? 8'd0 : (inside_message ? 8'd255 : 8'd0); // White for text
    assign vga_g = (active) ? 8'd0 : (inside_message ? 8'd255 : 8'd0); // White for text
    assign vga_b = (active) ? 8'd0 : (inside_message ? 8'd255 : 8'd0); // White for text

endmodule
