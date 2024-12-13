module gameOver (
    input        CLOCK_50,
    input        game_over,
    input  [11:0] x,
    input  [11:0] y,
    output [7:0] vga_r,
    output [7:0] vga_g,
    output [7:0] vga_b
);

    // Red screen for game-over state
    assign vga_r = game_over ? 8'd255 : 8'd0;
    assign vga_g = game_over ? 8'd0 : 8'd0;
    assign vga_b = game_over ? 8'd0 : 8'd0;

endmodule
