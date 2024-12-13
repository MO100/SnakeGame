module SnakeGame (
    input                   CLOCK_50,
    input       [3:0]       KEY,
    input       [0:0]       SW,
    output      [7:0]       VGA_R,
    output      [7:0]       VGA_G,
    output      [7:0]       VGA_B,
    output                  VGA_BLANK_N,
    output  reg             VGA_CLK,
    output                  VGA_HS,
    output                  VGA_VS,
    output                  VGA_SYNC_N,
    output      [6:0]       HEX0,  // Seven-segment display for units
    output      [6:0]       HEX1,  // Seven-segment display for tens
    output      [1:0]       LEDR,
    output      [3:0]       LEDG
);
    // screen dimensions
    parameter SCREEN_WIDTH  = 640;
    parameter SCREEN_HEIGHT = 480;
    // Debounced button outputs
    wire [3:0] debounced_key;

    // Instantiate debounce modules for each button
    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : debounce_loop
            debounce debounce_inst (
                .clk(CLOCK_50),
                .button_in(KEY[i]),
                .button_out(debounced_key[i])
            );
        end
    endgenerate
	 
    // VGA clock generation
    always @(posedge CLOCK_50)
        VGA_CLK <= ~VGA_CLK;

    // VGA timing generator
    wire [11:0] CounterX;
    wire [11:0] CounterY;

    vga_time_generator vga0(
        .pixel_clk(VGA_CLK),
        .h_disp   (SCREEN_WIDTH),
        .h_fporch (16),
        .h_sync   (96), 
        .h_bporch (48),
        .v_disp   (SCREEN_HEIGHT),
        .v_fporch (10),
        .v_sync   (2),
        .v_bporch (33),
        .vga_hs   (VGA_HS),
        .vga_vs   (VGA_VS),
        .vga_blank(VGA_BLANK_N),
        .CounterY (CounterY),
        .CounterX (CounterX)
    );

    // Game start module
    wire game_active;
    wire [7:0] start_r, start_g, start_b;

    gameStart game_start_inst(
        .CLOCK_50  (CLOCK_50),
        .SW        (SW),
        .KEY       (KEY),
        .x         (CounterX),
        .y         (CounterY),
        .game_active(game_active),
        .vga_r     (start_r),
        .vga_g     (start_g),
        .vga_b     (start_b)
    );

    // Snakehead module
    wire [7:0] snake_r, snake_g, snake_b;
    wire game_over; // Game-over signal
    wire [11:0] snake_x, snake_y;
    parameter SNAKEHEAD_SIZE = 20; // Size of the snakehead

    snakehead snakehead_inst(
        .CLOCK_50  (CLOCK_50),
        .KEY       (game_active ? debounced_key : 4'b1111), // Disable keys if game is inactive
        .SW        (SW),
        .x         (CounterX),
        .y         (CounterY),
        .vga_r     (snake_r),
        .vga_g     (snake_g),
        .vga_b     (snake_b),
        .game_over (game_over),
        .snake_x   (snake_x),
        .snake_y   (snake_y)
    );

    // Food module
    wire [7:0] food_r, food_g, food_b;
    wire [11:0] food_x, food_y;
    wire [7:0] food_score;
    parameter FOOD_SIZE = 10; // Size of the food

	// Instantiate the food module
	wire food_eaten;

    // Instantiate the food module
    food food_inst (
        .CLOCK_50  (CLOCK_50),
        .reset     (!SW),
        .x         (CounterX),
        .y         (CounterY),
        .snake_x   (snake_x),
        .snake_y   (snake_y),
        .snake_size(SNAKEHEAD_SIZE),
        .vga_r     (food_r),
        .vga_g     (food_g),
        .vga_b     (food_b),
        .food_x    (food_x),
        .food_y    (food_y),
        .score     (food_score)  // Connect score to wire
    );

	// Score module instantiation
    score score_inst (
        .score_in (food_score),  // Connect score wire
        .HEX0     (HEX0),        // Units place
        .HEX1     (HEX1)         // Tens place
    );

    // Background module
    wire [7:0] bg_r, bg_g, bg_b;
    map map_inst(
        .x        (CounterX),
        .y        (CounterY),
        .vga_r    (bg_r),
        .vga_g    (bg_g),
        .vga_b    (bg_b)
    );

    // Gameover module
    wire [7:0] gameover_r, gameover_g, gameover_b;
    gameOver gameover_inst(
        .CLOCK_50 (CLOCK_50),
        .game_over(game_over),   // Input game-over signal
        .x        (CounterX),
        .y        (CounterY),
        .vga_r    (gameover_r),
        .vga_g    (gameover_g),
        .vga_b    (gameover_b)
    );
	 
	// Combine VGA outputs: prioritize game_over > snakehead > food > background
	assign VGA_R = game_active ? 
						(game_over ? gameover_r : 
						(snake_r != 0 ? snake_r : 
						(food_r != 0 ? food_r : 
						(bg_r != 0 ? bg_r : start_r)))) : start_r;

	assign VGA_G = game_active ? 
						(game_over ? gameover_g : 
						(snake_g != 0 ? snake_g : 
						(food_g != 0 ? food_g : 
						(bg_g != 0 ? bg_g : start_g)))) : start_g;

	assign VGA_B = game_active ? 
						(game_over ? gameover_b : 
						(snake_b != 0 ? snake_b : 
						(food_b != 0 ? food_b : 
						(bg_b != 0 ? bg_b : start_b)))) : start_b;




    // VGA sync signal
    assign VGA_SYNC_N = 1;

endmodule
