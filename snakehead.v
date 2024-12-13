module snakehead (
    input        CLOCK_50,    // Clock signal
    input  [3:0] KEY,         // Pushbutton inputs for direction control
    input        SW,          // Switch to control pause/resume
    input  [11:0] x,          // Current X pixel coordinate
    input  [11:0] y,          // Current Y pixel coordinate
    output [7:0] vga_r,       // VGA Red color component
    output [7:0] vga_g,       // VGA Green color component
    output [7:0] vga_b,       // VGA Blue color component
    output reg   game_over,   // Game-over signal
    output reg [11:0] snake_x, // Current X position of the snakehead
    output reg [11:0] snake_y  // Current Y position of the snakehead
);

    // Define screen dimensions
    parameter SCREEN_WIDTH  = 640;
    parameter SCREEN_HEIGHT = 480;

    // Define the size of the snakehead
    parameter SNAKEHEAD_SIZE = 20;
	 
	 parameter BORDER_THICKNESS = 20;


    // Movement speed (in pixels)
    parameter MOVE_STEP = 10;

    // Movement delay to control autonomous movement speed
    reg [23:0] movement_counter = 0;
    parameter MOVE_DELAY = 5_000_000;

    // Direction encoding
    reg [1:0] direction; // Direction: 00 = Up, 01 = Down, 10 = Left, 11 = Right

    always @(posedge CLOCK_50 or negedge SW) begin
        if (!SW) begin
            // Reset game state
            direction <= 2'b11; // Default direction: Right
            snake_x <= (SCREEN_WIDTH / 2) - (SNAKEHEAD_SIZE / 2); // Center horizontally
            snake_y <= (SCREEN_HEIGHT / 2) - (SNAKEHEAD_SIZE / 2); // Center vertically
            game_over <= 0;
        end else if (!game_over) begin
            // Check for direction inputs
            if (!KEY[2]) direction <= 2'b00; // Up
            else if (!KEY[1]) direction <= 2'b01; // Down
            else if (!KEY[3]) direction <= 2'b10; // Left
            else if (!KEY[0]) direction <= 2'b11; // Right

            // Movement logic
            if (movement_counter >= MOVE_DELAY) begin
                movement_counter <= 0;
                case (direction)
                    2'b00: if (snake_y > MOVE_STEP) snake_y <= snake_y - MOVE_STEP; // Move up
                    2'b01: if (snake_y < SCREEN_HEIGHT - MOVE_STEP - SNAKEHEAD_SIZE) snake_y <= snake_y + MOVE_STEP; // Move down
                    2'b10: if (snake_x > MOVE_STEP) snake_x <= snake_x - MOVE_STEP; // Move left
                    2'b11: if (snake_x < SCREEN_WIDTH - MOVE_STEP - SNAKEHEAD_SIZE) snake_x <= snake_x + MOVE_STEP; // Move right
                endcase

                // Collision detection with screen boundaries
				if ((snake_x < BORDER_THICKNESS) || 
					 (snake_x + SNAKEHEAD_SIZE > SCREEN_WIDTH - BORDER_THICKNESS) ||
					 (snake_y < BORDER_THICKNESS) || 
					 (snake_y + SNAKEHEAD_SIZE > SCREEN_HEIGHT - BORDER_THICKNESS)) begin
					 game_over <= 1;
				end

            end else begin
                movement_counter <= movement_counter + 1;
            end
        end
    end

    // checks to see if the current pixel is inside the snakehead
    wire inside_snakehead = 
        (x >= snake_x) && (x < snake_x + SNAKEHEAD_SIZE) &&
        (y >= snake_y) && (y < snake_y + SNAKEHEAD_SIZE);

    // Snakehead color is green
    assign vga_r = inside_snakehead ? 8'd0 : 8'd0;
    assign vga_g = inside_snakehead ? 8'd255 : 8'd0;
    assign vga_b = inside_snakehead ? 8'd0 : 8'd0;

endmodule
