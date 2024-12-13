module map (
    input [11:0] x,
    input [11:0] y,
    output [7:0] vga_r,
    output [7:0] vga_g,
    output [7:0] vga_b
);

    // Define border thickness
    parameter BORDER_THICKNESS = 20;

    // Gray color for background
    localparam GRAY_R = 8'd128;
    localparam GRAY_G = 8'd128;
    localparam GRAY_B = 8'd128;

    // Red color for borders
    localparam RED_R = 8'd255;
    localparam RED_G = 8'd0;
    localparam RED_B = 8'd0;

    // Screen dimensions
    parameter SCREEN_WIDTH  = 640;
    parameter SCREEN_HEIGHT = 480;

    // Determine if the pixel is within the border
    wire is_border = 
        (x < BORDER_THICKNESS) || 
        (x >= SCREEN_WIDTH - BORDER_THICKNESS) || 
        (y < BORDER_THICKNESS) || 
        (y >= SCREEN_HEIGHT - BORDER_THICKNESS);

    // Assign colors based on position
    assign vga_r = is_border ? RED_R : GRAY_R;
    assign vga_g = is_border ? RED_G : GRAY_G;
    assign vga_b = is_border ? RED_B : GRAY_B;

endmodule
