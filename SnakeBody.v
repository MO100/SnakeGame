module SnakeBody (
    input                   CLOCK_50,
    input                   reset,
    input       [11:0]      head_x,
    input       [11:0]      head_y,
    input                   move_signal,
    input       [7:0]       score,
    input       [11:0]      CounterX,
    input       [11:0]      CounterY,
    output reg  [7:0]       vga_r,
    output reg  [7:0]       vga_g,
    output reg  [7:0]       vga_b
);

    // Parameters
    parameter SNAKE_SEGMENT_SIZE = 20;
    parameter MAX_SEGMENTS = 64; // Maximum number of segments the snake can grow

    // Registers to store body segment positions
    reg [11:0] segment_x [0:MAX_SEGMENTS-1];
    reg [11:0] segment_y [0:MAX_SEGMENTS-1];
    reg [7:0]  segment_count; // Current number of segments

    // Temporary variable for loops
    integer i;

    // Update body segments
    always @(posedge CLOCK_50 or posedge reset) begin
        if (reset) begin
            segment_count <= 1; // Start with only the head
            // Reset all segments to prevent residual data
            for (i = 0; i < MAX_SEGMENTS; i = i + 1) begin
                segment_x[i] <= 0;
                segment_y[i] <= 0;
            end
        end else if (move_signal) begin
            // Shift body segments
            for (i = MAX_SEGMENTS-1; i > 0; i = i - 1) begin
                if (i < segment_count) begin
                    segment_x[i] <= segment_x[i-1];
                    segment_y[i] <= segment_y[i-1];
                end
            end
            // Update head position
            segment_x[0] <= head_x;
            segment_y[0] <= head_y;

            // Increase segment count based on score, capped at MAX_SEGMENTS
            if (score > segment_count && segment_count < MAX_SEGMENTS) begin
                segment_count <= segment_count + 1;
            end
        end
    end

    // Render snake body on VGA
    always @(*) begin
        vga_r = 0;
        vga_g = 0;
        vga_b = 0;

        for (i = 0; i < MAX_SEGMENTS; i = i + 1) begin
            if (i < segment_count) begin // Process only active segments
                if ((CounterX >= segment_x[i] && CounterX < segment_x[i] + SNAKE_SEGMENT_SIZE) &&
                    (CounterY >= segment_y[i] && CounterY < segment_y[i] + SNAKE_SEGMENT_SIZE)) begin
                    // Body color
                    vga_r = 8'h00;
                    vga_g = 8'hFF;
                    vga_b = 8'h00;
                end
            end
        end
    end

endmodule
