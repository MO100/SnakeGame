module food (
    input        CLOCK_50,     // Clock signal
    input        reset,        // Reset signal
    input  [11:0] x,           // Current X pixel coordinate
    input  [11:0] y,           // Current Y pixel coordinate
    input  [11:0] snake_x,     // X position of the snakehead
    input  [11:0] snake_y,     // Y position of the snakehead
    input  [11:0] snake_size,  // Size of the snakehead (assumes square dimensions)
    output [7:0] vga_r,        // VGA Red color component
    output [7:0] vga_g,        // VGA Green color component
    output [7:0] vga_b,        // VGA Blue color component
    output [11:0] food_x,      // X position of the food
    output [11:0] food_y,      // Y position of the food
    output reg [7:0] score     // Add: Current score as an output
);

    // Screen dimensions, food size, and border
    parameter SCREEN_WIDTH   = 640;
    parameter SCREEN_HEIGHT  = 480;
    parameter FOOD_SIZE      = 10;
    parameter BORDER_THICKNESS = 20;
    parameter SAFE_BUFFER    = 10;

    // Safe 
    localparam SAFE_MIN_X = BORDER_THICKNESS + SAFE_BUFFER;
    localparam SAFE_MAX_X = SCREEN_WIDTH - BORDER_THICKNESS - SAFE_BUFFER - FOOD_SIZE;
    localparam SAFE_MIN_Y = BORDER_THICKNESS + SAFE_BUFFER;
    localparam SAFE_MAX_Y = SCREEN_HEIGHT - BORDER_THICKNESS - SAFE_BUFFER - FOOD_SIZE;

    // Registers for food position
    reg [11:0] food_x_reg;
    reg [11:0] food_y_reg;

    assign food_x = food_x_reg;
    assign food_y = food_y_reg;

    // Pseudo-random number generation using LFSR
    reg [15:0] lfsr_x = 16'hACE1; // Initial seed for X
    reg [15:0] lfsr_y = 16'hBEEF; // Initial seed for Y

    // Collision detection
    wire snake_collides_with_food = 
        (snake_x < food_x_reg + FOOD_SIZE) && (snake_x + snake_size > food_x_reg) &&
        (snake_y < food_y_reg + FOOD_SIZE) && (snake_y + snake_size > food_y_reg);

    always @(posedge CLOCK_50 or posedge reset) begin
        if (reset) begin
            // Reset food position and score
            food_x_reg <= (SAFE_MIN_X + SAFE_MAX_X) / 2 & ~(FOOD_SIZE - 1);  
            food_y_reg <= (SAFE_MIN_Y + SAFE_MAX_Y) / 2 & ~(FOOD_SIZE - 1); 
            score <= 8'd0; // Reset score
        end else begin
            if (snake_collides_with_food) begin
                // Increment score
                score <= score + 1'b1;

                // Generate new food position within the safe zone collision
                lfsr_x <= {lfsr_x[14:0], lfsr_x[15] ^ lfsr_x[13] ^ lfsr_x[12] ^ lfsr_x[10]};
                lfsr_y <= {lfsr_y[14:0], lfsr_y[15] ^ lfsr_y[13] ^ lfsr_y[12] ^ lfsr_y[10]};
                food_x_reg <= (lfsr_x % (SAFE_MAX_X - SAFE_MIN_X + 1) + SAFE_MIN_X) & ~(FOOD_SIZE - 1);
                food_y_reg <= (lfsr_y % (SAFE_MAX_Y - SAFE_MIN_Y + 1) + SAFE_MIN_Y) & ~(FOOD_SIZE - 1);
            end
        end
    end

    // Check if the current pixel is inside the food
    wire inside_food = 
        (x >= food_x_reg) && (x < food_x_reg + FOOD_SIZE) &&
        (y >= food_y_reg) && (y < food_y_reg + FOOD_SIZE);

    // Red output
    assign vga_r = inside_food ? 8'd255 : 8'd0; // Red
    assign vga_g = inside_food ? 8'd0   : 8'd0; // No green
    assign vga_b = inside_food ? 8'd0   : 8'd0; // No blue

endmodule
